public without sharing class PatientJourneyController {
    @AuraEnabled(cacheable=true)
    public static List<MilestoneWrapper> getMilestonesAndTasks(Id recordId) {
        List<MilestoneWrapper> milestones = new List<MilestoneWrapper>();

        // Fetch Patient Milestones
        List<Patient_Milestone__c> milestoneRecords = [
            SELECT Id, Name, Status__c 
            FROM Patient_Milestone__c 
            WHERE Patient_Journey__c = :recordId
        ];

        // Fetch Patient Milestone Tasks associated with milestones
        List<Patient_Milestone_Task__c> taskRecords = [
            SELECT Id, Name, Status__c, Patient_Milestone__c 
            FROM Patient_Milestone_Task__c 
            WHERE Patient_Milestone__c IN :milestoneRecords
        ];

        // Fetch Patient Milestone Task Form Questions associated with tasks
        List<Patient_Milestone_Task_Form_Question__c> taskFormQuestionRecords = [
            SELECT Id, Form_Question__c, Patient_Milestone_Task__c 
            FROM Patient_Milestone_Task_Form_Question__c 
            WHERE Patient_Milestone_Task__c IN :taskRecords
        ];

        // Map task form questions to their respective tasks
        Map<Id, List<Patient_Milestone_Task_Form_Question__c>> taskFormQuestionsMap = new Map<Id, List<Patient_Milestone_Task_Form_Question__c>>();
        for (Patient_Milestone_Task_Form_Question__c taskFormQuestion : taskFormQuestionRecords) {
            if (!taskFormQuestionsMap.containsKey(taskFormQuestion.Patient_Milestone_Task__c)) {
                taskFormQuestionsMap.put(taskFormQuestion.Patient_Milestone_Task__c, new List<Patient_Milestone_Task_Form_Question__c>());
            }
            taskFormQuestionsMap.get(taskFormQuestion.Patient_Milestone_Task__c).add(taskFormQuestion);
        }

        // Map tasks to their respective milestones
        Map<Id, List<TaskWrapper>> milestoneTasksMap = new Map<Id, List<TaskWrapper>>();
        for (Patient_Milestone_Task__c task : taskRecords) {
            TaskWrapper taskWrapper = new TaskWrapper();
            taskWrapper.task = task;
            taskWrapper.formQuestions = taskFormQuestionsMap.containsKey(task.Id) ? taskFormQuestionsMap.get(task.Id) : new List<Patient_Milestone_Task_Form_Question__c>();

            if (!milestoneTasksMap.containsKey(task.Patient_Milestone__c)) {
                milestoneTasksMap.put(task.Patient_Milestone__c, new List<TaskWrapper>());
            }
            milestoneTasksMap.get(task.Patient_Milestone__c).add(taskWrapper);
        }

        // Prepare the milestone wrapper list
        for (Patient_Milestone__c milestone : milestoneRecords) {
            MilestoneWrapper milestoneWrapper = new MilestoneWrapper();
            milestoneWrapper.milestone = milestone;
            milestoneWrapper.tasks = milestoneTasksMap.containsKey(milestone.Id) ? milestoneTasksMap.get(milestone.Id) : new List<TaskWrapper>();
            milestones.add(milestoneWrapper);
        }

        return milestones;
    }

    public class MilestoneWrapper {
        @AuraEnabled public Patient_Milestone__c milestone { get; set; }
        @AuraEnabled public List<TaskWrapper> tasks { get; set; }
    }

    public class TaskWrapper {
        @AuraEnabled public Patient_Milestone_Task__c task { get; set; }
        @AuraEnabled public List<Patient_Milestone_Task_Form_Question__c> formQuestions { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Patient_Milestone__c> getPatientJourneyMilestonesSponsor(String recordId) {
        try {
            return [SELECT Id, Name, Study_Milestone__c, Status__c, Order__c, Patient_Journey__c, (SELECT Id, Form__c, Name, Patient_Milestone__c, Order__c, Status__c, Study_Milestone_Task__c, Apheresis_Shipment__c, Verify__c,LastModifiedBy.Name,LastModifiedDate, Owner.Profile.Name, Verify_By__r.Name, Courier__c, Drug_Product_Shipment__c, (SELECT Id, Name, Patient_Milestone_Task__c, Form_Question__c, Label__c, Value__c, Order__c, Read_Only__c, Required__c, Type__c, Help_Text__c, Picklist_Values__c, (SELECT Id, ContentDocument.Title FROM ContentDocumentLinks) FROM Patient_Milestone_Task_Form_Questions__r ORDER BY Order__c) FROM Patient_Milestone_Tasks__r ORDER BY Order__c) 
                    FROM Patient_Milestone__c 
                    WHERE Patient_Journey__c =: recordId AND Sponsor_Facing__c = true ORDER BY Order__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Patient_Milestone__c> getPatientJourneyMilestonesSite(String recordId) {
        try {
            return [SELECT Id, Name, Study_Milestone__c, Status__c, Order__c, Patient_Journey__c, (SELECT Id, Form__c, Name, Patient_Milestone__c, Order__c, Status__c, Study_Milestone_Task__c, Apheresis_Shipment__c, Verify__c,LastModifiedBy.Name,LastModifiedDate, Owner.Profile.Name, Verify_By__r.Name, Courier__c, Drug_Product_Shipment__c, (SELECT Id, Name, Patient_Milestone_Task__c, Form_Question__c, Label__c, Value__c, Order__c, Read_Only__c, Required__c, Type__c, Help_Text__c, Picklist_Values__c, (SELECT Id, ContentDocument.Title FROM ContentDocumentLinks) FROM Patient_Milestone_Task_Form_Questions__r ORDER BY Order__c) FROM Patient_Milestone_Tasks__r ORDER BY Order__c) 
                    FROM Patient_Milestone__c 
                    WHERE Patient_Journey__c =: recordId /*AND Sponsor_Facing__c = true*/ ORDER BY Order__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<FormSectionMilestoneTaskWrapper> getFormSectionByPatientMilestoneTaskIds(List<String> milestoneTaskIds){
        try {
            List<FormSectionMilestoneTaskWrapper> formSectionList = new List<FormSectionMilestoneTaskWrapper>();
            if(!milestoneTaskIds.isEmpty()){
                List<Patient_Milestone_Task__c> milestoneTaskList = [SELECT Id, Form__c FROM Patient_Milestone_Task__c WHERE Id IN: milestoneTaskIds];
                Map<Id, List<String>> formMap = new Map<Id, List<String>>();
                for(Patient_Milestone_Task__c pmt : milestoneTaskList){
                    if(pmt.Form__c != null){
                        if(!formMap.containsKey(pmt.Form__c)){
                            formMap.put(pmt.Form__c, new List<String>());
                        }
                        formMap.get(pmt.Form__c).add(pmt.Id);
                    }
                }
                if(!formMap.isEmpty()){
                    List<Form__c> formList = [SELECT Id, Name,  
                    (SELECT Id, Name, Form__c
                    FROM Form_Sections__r)
                    FROM Form__c WHERE Id IN: formMap.keySet()];
                    if(!formList.isEmpty()){
                        for(Form__c form : formList){
                            for(String pmt : formMap.get(form.Id)){
                                FormSectionMilestoneTaskWrapper fsw = new FormSectionMilestoneTaskWrapper();
                                fsw.mileTaskId = pmt;
                                fsw.formSections = new List<Form_Section__c>();
                                if(form.Form_Sections__r.size() > 0){
                                    fsw.formSections.addAll(form.Form_Sections__r);
                                }
                                formSectionList.add(fsw);
                            }
                        }
                    }
                }
            }
            return formSectionList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FormSectionMilestoneTaskWrapper {
        @AuraEnabled public String mileTaskId {get;set;}
        @AuraEnabled public List<Form_Section__c> formSections { get; set; }
    }

    @AuraEnabled
    public static AddressWrapper getShipmentDetails(String milestoneId){
        AddressWrapper aw = new AddressWrapper();
        Patient_Milestone__c patientMilestone = [SELECT Id,Patient_Journey__r.Patient__c, Patient_Journey__r.Study_Definition__c, Patient_Journey__r.Clinical_Site__r.Apheresis_center__c FROM Patient_Milestone__c WHERE Id=:milestoneId];

        Account aphresisAccount = [SELECT Person_to_contact__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account WHERE Id =:patientMilestone.Patient_Journey__r.Clinical_Site__r.Apheresis_center__c];
        
        Manufacturing_Slot__c manufacturingSite = [SELECT Manufacturing_Site__r.Person_to_contact__c, Manufacturing_Site__r.BillingCity, Manufacturing_Site__r.BillingCountry, Manufacturing_Site__r.BillingState, Manufacturing_Site__r.BillingStreet, Manufacturing_Site__r.BillingPostalCode FROM Manufacturing_Slot__c Where Study_ID__c =: patientMilestone.Patient_Journey__r.Study_Definition__c AND Booking_Status__c = 'Booked' AND Clinical_Site__c =: patientMilestone.Patient_Journey__r.Clinical_Site__r.Id AND Patient__c =:patientMilestone.Patient_Journey__r.Patient__c];
        aw.aphresisAccount = aphresisAccount;
        aw.manufacturingSite = manufacturingSite;
        aw.patientMilestone = patientMilestone;
        return aw;
    }

    @AuraEnabled
    public static Boolean fileValidate(String taskQuesId, String fileName){
        try {
            List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:taskQuesId];
            return contentDocumentLinks.size() > 0;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId, String patientJourneyId) {
        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl : documentLinks) {
            documentIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> existingDocuments = [SELECT Id FROM ContentDocument WHERE Id IN :documentIds];
        if (!existingDocuments.isEmpty()) {
            Database.delete([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: patientJourneyId AND ContentDocumentId IN : documentIds]);
            List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId IN :existingDocuments AND LinkedEntityId = :recordId];
            delete existingLinks;
        }
        ContentVersion cv = createContentVersion(base64, filename, null);
        if (cv == null) {
            return null;
        }
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId, patientJourneyId);
        if (cdl == null) {
            return null;
        }
        return cdl.Id;
    }


    private static ContentVersion createContentVersion(String base64, String filename, String contentDocumentId) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;

        if (contentDocumentId != null) {
            cv.ContentDocumentId = contentDocumentId;
        }

        try {
            insert cv;
            return cv;
        } catch (DMLException e) {
            System.debug('Error inserting ContentVersion: ' + e);
            return null;
        }
    }

    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId, String patientJourneyId) {
        if (contentVersionId == null || recordId == null) {
            return null;
        }

        try {
            ContentVersion cv = [SELECT Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];

            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;

            // Database.delete([SELECT Id FROM ContentDocumentLink WHERE ContentDocument.Title =: cv.Title AND LinkedEntityId =: patientJourneyId],false);

            ContentDocumentLink newLink = new ContentDocumentLink();
            newLink.ContentDocumentId = cv.ContentDocumentId;
            newLink.LinkedEntityId = patientJourneyId;
            newLink.ShareType = 'V';
            insert newLink;

            return cdl;
        } catch (DMLException e) {
            System.debug('Error inserting ContentDocumentLink: ' + e);
            return null;
        }
    }

    public class TaskSectionWrapper {
        @AuraEnabled public String sectionName { get; set; }
        @AuraEnabled public Id taskId { get; set; }
        @AuraEnabled public List<Patient_Milestone_Task_Form_Question__c> formQuestions { get; set; }
    
        public TaskSectionWrapper(String sectionName, Id taskId, List<Patient_Milestone_Task_Form_Question__c> formQuestions) {
            this.sectionName = sectionName;
            this.taskId = taskId;
            this.formQuestions = formQuestions;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Patient_Journey__c getPatientDetailsByJourneyId(String recordId){
        try{
            return [SELECT Patient__r.Study_Protocol__r.Display_Name__c, Patient__r.Year_Of_Birth__c, Current_Stage__c, Patient__r.Subject_Id__c FROM Patient_Journey__c WHERE Id =: recordId LIMIT 1];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static List<TaskSectionWrapper> getTaskSections(List<String> taskIds) {
        List<Patient_Milestone_Task__c> milestoneTasks = [
            SELECT Form__c, 
                (SELECT Id, Form_Question__c, Patient_Milestone_Task__c, Label__c, Order__c, Picklist_Values__c, Read_Only__c, Required__c, Type__c, Value__c FROM Patient_Milestone_Task_Form_Questions__r) 
            FROM Patient_Milestone_Task__c 
            WHERE Id IN :taskIds
        ];

        Set<Id> formIds = new Set<Id>();

        for (Patient_Milestone_Task__c pmt : milestoneTasks) {
            if (pmt.Form__c != null) {
                formIds.add(pmt.Form__c);
            }
        }

        List<TaskSectionWrapper> taskSectionWrappers = new List<TaskSectionWrapper>();

        if (!formIds.isEmpty()) {
            Map<Id, Form_Question__c> formQuestions = new Map<Id, Form_Question__c>(
                [SELECT Id, Form_Section__r.Name 
                FROM Form_Question__c 
                WHERE Form_Section__r.Form__c IN :formIds]
            );

            for (Patient_Milestone_Task__c pmt : milestoneTasks) {
                Map<String, List<Patient_Milestone_Task_Form_Question__c>> sectionQuestionMap = new Map<String, List<Patient_Milestone_Task_Form_Question__c>>();

                for (Patient_Milestone_Task_Form_Question__c pmtfq : pmt.Patient_Milestone_Task_Form_Questions__r) {
                    if (formQuestions.containsKey(pmtfq.Form_Question__c)) {
                        String formSectionName = formQuestions.get(pmtfq.Form_Question__c).Form_Section__r.Name;

                        if (!sectionQuestionMap.containsKey(formSectionName)) {
                            sectionQuestionMap.put(formSectionName, new List<Patient_Milestone_Task_Form_Question__c>());
                        }

                        sectionQuestionMap.get(formSectionName).add(pmtfq);
                    }
                }

                for (String sectionName : sectionQuestionMap.keySet()) {
                    List<Patient_Milestone_Task_Form_Question__c> questions = sectionQuestionMap.get(sectionName);
                    taskSectionWrappers.add(new TaskSectionWrapper(sectionName, pmt.Id, questions));
                }
            }
        }

        return taskSectionWrappers;
    }




    @AuraEnabled(cacheable=true)
    public static Map<Id, Boolean> isReadAccess(List<Id> recordIds) {
        // Initialize the map to store the result
        Map<Id, Boolean> accessMap = new Map<Id, Boolean>();
        // Query the tasks based on the provided record IDs
        List<Patient_Milestone_Task__c> tasks = [
            SELECT Id, Read_Access_Queues__c 
            FROM Patient_Milestone_Task__c 
            WHERE Id IN :recordIds
        ];
        // Loop through each task and check access
        for (Patient_Milestone_Task__c task : tasks) {
            List<String> selectedQueueNames = task.Read_Access_Queues__c != null ? task.Read_Access_Queues__c.split(';') : new List<String>();
            if (selectedQueueNames.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Query the groups (queues) with the selected queue names
            List<Group> queues = [
                SELECT Id 
                FROM Group 
                WHERE Name IN :selectedQueueNames 
                AND Type = 'Queue'
            ];
            if (queues.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Create a set of group (queue) IDs
            Set<Id> queueIds = new Set<Id>();
            for (Group queue : queues) {
                queueIds.add(queue.Id);
            }
    
            // Query GroupMembers to check if the current user is part of any of these queues
            List<GroupMember> groupMembers = [
                SELECT GroupId 
                FROM GroupMember 
                WHERE GroupId IN :queueIds 
                AND UserOrGroupId = :UserInfo.getUserId()
            ];
    
            // Add the result to the map
            accessMap.put(task.Id, !groupMembers.isEmpty());
        }
    
        // Handle the case where a recordId wasn't found (no task)
        for (Id recordId : recordIds) {
            if (!accessMap.containsKey(recordId)) {
                accessMap.put(recordId, false);
            }
        }
    
        return accessMap;
    }
 
 
	@AuraEnabled(cacheable=true)
    public static Map<Id, Boolean> isWriteAccess(List<Id> recordIds) {
        // Initialize the map to store the result
        Map<Id, Boolean> accessMap = new Map<Id, Boolean>();
        // Query the tasks based on the provided record IDs
        List<Patient_Milestone_Task__c> tasks = [
            SELECT Id, Write_Access_Queues__c 
            FROM Patient_Milestone_Task__c 
            WHERE Id IN :recordIds
        ];
        // Loop through each task and check access
        for (Patient_Milestone_Task__c task : tasks) {
            List<String> selectedQueueNames = task.Write_Access_Queues__c != null ? task.Write_Access_Queues__c.split(';') : new List<String>();
            if (selectedQueueNames.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Query the groups (queues) with the selected queue names
            List<Group> queues = [
                SELECT Id 
                FROM Group 
                WHERE Name IN :selectedQueueNames 
                AND Type = 'Queue'
            ];
            if (queues.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Create a set of group (queue) IDs
            Set<Id> queueIds = new Set<Id>();
            for (Group queue : queues) {
                queueIds.add(queue.Id);
            }
    
            // Query GroupMembers to check if the current user is part of any of these queues
            List<GroupMember> groupMembers = [
                SELECT GroupId 
                FROM GroupMember 
                WHERE GroupId IN :queueIds 
                AND UserOrGroupId = :UserInfo.getUserId()
            ];
    
            // Add the result to the map
            accessMap.put(task.Id, !groupMembers.isEmpty());
        }
    
        // Handle the case where a recordId wasn't found (no task)
        for (Id recordId : recordIds) {
            if (!accessMap.containsKey(recordId)) {
                accessMap.put(recordId, false);
            }
        }
    
        return accessMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Boolean> isReadAccessForMilestone(List<Id> recordIds) {
        // Initialize the map to store the result
        Map<Id, Boolean> accessMap = new Map<Id, Boolean>();
        // Query the tasks based on the provided record IDs
        List<Patient_Milestone__c> tasks = [
            SELECT Id, Read_Access_Queues__c 
            FROM Patient_Milestone__c 
            WHERE Id IN :recordIds
        ];
        // Loop through each task and check access
        for (Patient_Milestone__c task : tasks) {
            List<String> selectedQueueNames = task.Read_Access_Queues__c != null ? task.Read_Access_Queues__c.split(';') : new List<String>();
            if (selectedQueueNames.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Query the groups (queues) with the selected queue names
            List<Group> queues = [
                SELECT Id 
                FROM Group 
                WHERE Name IN :selectedQueueNames 
                AND Type = 'Queue'
            ];
            if (queues.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Create a set of group (queue) IDs
            Set<Id> queueIds = new Set<Id>();
            for (Group queue : queues) {
                queueIds.add(queue.Id);
            }
    
            // Query GroupMembers to check if the current user is part of any of these queues
            List<GroupMember> groupMembers = [
                SELECT GroupId 
                FROM GroupMember 
                WHERE GroupId IN :queueIds 
                AND UserOrGroupId = :UserInfo.getUserId()
            ];
    
            // Add the result to the map
            accessMap.put(task.Id, !groupMembers.isEmpty());
        }
    
        // Handle the case where a recordId wasn't found (no task)
        for (Id recordId : recordIds) {
            if (!accessMap.containsKey(recordId)) {
                accessMap.put(recordId, false);
            }
        }
    
        return accessMap;
    }
 
 
	@AuraEnabled(cacheable=true)
    public static Map<Id, Boolean> isWriteAccessForMilestone(List<Id> recordIds) {
        // Initialize the map to store the result
        Map<Id, Boolean> accessMap = new Map<Id, Boolean>();
        // Query the tasks based on the provided record IDs
        List<Patient_Milestone__c> tasks = [
            SELECT Id, Write_Access_Queues__c 
            FROM Patient_Milestone__c 
            WHERE Id IN :recordIds
        ];
        // Loop through each task and check access
        for (Patient_Milestone__c task : tasks) {
            List<String> selectedQueueNames = task.Write_Access_Queues__c != null ? task.Write_Access_Queues__c.split(';') : new List<String>();
            if (selectedQueueNames.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Query the groups (queues) with the selected queue names
            List<Group> queues = [
                SELECT Id 
                FROM Group 
                WHERE Name IN :selectedQueueNames 
                AND Type = 'Queue'
            ];
            if (queues.isEmpty()) {
                accessMap.put(task.Id, false);
                continue;
            }
    
            // Create a set of group (queue) IDs
            Set<Id> queueIds = new Set<Id>();
            for (Group queue : queues) {
                queueIds.add(queue.Id);
            }
    
            // Query GroupMembers to check if the current user is part of any of these queues
            List<GroupMember> groupMembers = [
                SELECT GroupId 
                FROM GroupMember 
                WHERE GroupId IN :queueIds 
                AND UserOrGroupId = :UserInfo.getUserId()
            ];
    
            // Add the result to the map
            accessMap.put(task.Id, !groupMembers.isEmpty());
        }
    
        // Handle the case where a recordId wasn't found (no task)
        for (Id recordId : recordIds) {
            if (!accessMap.containsKey(recordId)) {
                accessMap.put(recordId, false);
            }
        }
    
        return accessMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Integration_Log__c> getPatientIntegrationLog(String recordId){
        try {
            List<Integration_Log__c> patientIntegrationLogs = [SELECT Id, API_Name__c, Record_Id__c, Request_Body__c, Response_Body__c, Status_Code__c FROM Integration_Log__c WHERE API_Name__c = 'Protrac_Patient_Registration'];
            Map<String, List<Integration_Log__c>> patientMap = new Map<String, List<Integration_Log__c>>();
            if(!patientIntegrationLogs.isEmpty()){
                for(Integration_Log__c il : patientIntegrationLogs){
                    if(il.API_Name__c != null){
                        if(!patientMap.containsKey(il.Record_Id__c)){
                            patientMap.put(il.Record_Id__c, new List<Integration_Log__c>());
                        }
                        patientMap.get(il.Record_Id__c).add(il);
                    }
                }
                List<Integration_Log__c> patientLog = new List<Integration_Log__c>();
                if(!patientMap.isEmpty()){
                    List<Shipment__c> shipmentList = [SELECT Id FROM Shipment__c WHERE Id IN: patientMap.keySet() AND Patient_Journey__c =: recordId];
                    if(!shipmentList.isEmpty()){
                        for(Shipment__c s : shipmentList){
                            if(patientMap.containsKey(s.Id)){
                                patientLog.addAll(patientMap.get(s.Id));
                            }
                        }
                        return patientLog;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkPatientJourneyRegistration(String recordId, String logId){
        List<Integration_Log__c> integrationLogs = [SELECT Record_Id__c FROM Integration_Log__c WHERE Id =: logId];
        if(!integrationLogs.isEmpty()){
            String shipId = integrationLogs[0].Record_Id__c;
            if(shipId != null){
                List<Shipment__c> patientShipments = [SELECT Id FROM Shipment__c WHERE Id =: shipId AND Patient_Journey__c =:recordId];
                return patientShipments.size() > 0;
            }
        }
        return false;
    }
    /*@AuraEnabled(cacheable=true)
public static List<Patient_Milestone__c> getPatientJourneyMilestonesLst(List<Id> patientIds) {
    System.debug('Patient IDs: ' + patientIds);  
    try {
        if (patientIds == null || patientIds.isEmpty()) {
            throw new AuraHandledException('No Patient IDs provided');
        }
 System.debug('Patient IDs: ' + patientIds);        
        return [
            SELECT 
                Id, 
                Name, 
                Study_Milestone__c, 
                Status__c, 
                Order__c, 
                Patient_Journey__c, 
                Patient_Journey__r.Patient__c
            FROM Patient_Milestone__c 
            WHERE Patient_Journey__r.Patient__c IN :patientIds 
            AND Sponsor_Facing__c = true 
            ORDER BY Order__c
        ];
    } catch (Exception e) {
        throw new AuraHandledException('Error fetching milestones: ' + e.getMessage());
    }
}*/
  @AuraEnabled(cacheable=true)
public static List<PatientWrapper> getPatientJourneyMilestonesLst(List<Id> patientIds) {
    System.debug('Patient IDs: ' + patientIds);  
    try {
        if (patientIds == null || patientIds.isEmpty()) {
            throw new AuraHandledException('No Patient IDs provided');
        }

        // Fetch all milestones for given patients
        List<Patient_Milestone__c> milestones = [
            SELECT 
                Id, 
                Name, 
                Study_Milestone__c, 
                Status__c, 
                Order__c, 
                Patient_Journey__c, 
                Patient_Journey__r.Patient__c,
                Sponsor_Facing__c
            FROM Patient_Milestone__c 
            WHERE Patient_Journey__r.Patient__c IN :patientIds 
            AND Sponsor_Facing__c = true 
            ORDER BY Patient_Journey__r.Patient__c, Order__c
        ];

        // Map to hold unique milestones per patient
        Map<Id, Map<String, Patient_Milestone__c>> milestonesByPatient = new Map<Id, Map<String, Patient_Milestone__c>>();

        for (Patient_Milestone__c milestone : milestones) {
            Id patientId = milestone.Patient_Journey__r.Patient__c;

            // Initialize patient map if not already present
            if (!milestonesByPatient.containsKey(patientId)) {
                milestonesByPatient.put(patientId, new Map<String, Patient_Milestone__c>());
            }

            // Ensure no duplicate milestone names for the patient
            Map<String, Patient_Milestone__c> patientMilestonesMap = milestonesByPatient.get(patientId);
            if (!patientMilestonesMap.containsKey(milestone.Name)) {
                patientMilestonesMap.put(milestone.Name, milestone);
            }
        }

        List<PatientWrapper> patientWrappers = new List<PatientWrapper>();
        Map<Id, Patient_Registration__c> IdvsPatientMap =new Map<Id, Patient_Registration__c>();
        for(Patient_Registration__c pr: [SELECT Id, Name, Subject_ID__c,Year_of_Birth__c,Status__c FROM Patient_Registration__c WHERE Id in :patientIds]){
            IdvsPatientMap.put(pr.Id, pr);
        }

        // Create wrapper to store patient info and current milestone
        for (Id patientId : patientIds) {
            // Get milestones for this patient
            Map<String, Patient_Milestone__c> patientMilestonesMap = milestonesByPatient.get(patientId);
            
            List<Patient_Milestone__c> uniqueMilestones = new List<Patient_Milestone__c>();
            Patient_Milestone__c currentMilestone = null;

            // Check if the patient has milestones
            if (patientMilestonesMap != null && !patientMilestonesMap.isEmpty()) {
                uniqueMilestones.addAll(patientMilestonesMap.values());

                // Identify the current milestone (in-progress one)
                for (Patient_Milestone__c milestone : uniqueMilestones) {
                    if (milestone.Status__c == 'In Progress') {
                        currentMilestone = milestone;
                        break;
                    }
                }

                // Add the wrapper to the result
                patientWrappers.add(new PatientWrapper(patientId,IdvsPatientMap.get(patientId).Name,IdvsPatientMap.get(patientId).Subject_ID__c,IdvsPatientMap.get(patientId).Year_of_Birth__c,IdvsPatientMap.get(patientId).Status__c, uniqueMilestones, currentMilestone));
            } else {
                // Handle case where there are no milestones for the patient
                patientWrappers.add(new PatientWrapper(patientId,IdvsPatientMap.get(patientId).Name,IdvsPatientMap.get(patientId).Subject_ID__c,IdvsPatientMap.get(patientId).Year_of_Birth__c,IdvsPatientMap.get(patientId).Status__c,new List<Patient_Milestone__c>(), null));
            }
        }

        return patientWrappers;

    } catch (Exception e) {
        throw new AuraHandledException('Error fetching milestones: ' + e.getMessage());
    }
}

public class PatientWrapper {
    @AuraEnabled public Id patientId;
    @AuraEnabled public String name;
    @AuraEnabled public List<Patient_Milestone__c> milestones;
    @AuraEnabled public Patient_Milestone__c currentMilestone;
    @AuraEnabled public String subjectID;
    @AuraEnabled public String yearOfBirth;
    @AuraEnabled public String status;

    public PatientWrapper(Id patientId,String name,String subjectID, String yearOfBirth, String status, List<Patient_Milestone__c> milestones, Patient_Milestone__c currentMilestone) {
        this.patientId = patientId;
        this.name=name;
        this.subjectID=subjectID;
        this.yearOfBirth=yearOfBirth;
        this.status=status;
        this.milestones = milestones;
        this.currentMilestone = currentMilestone;
    }
}







    public class AddressWrapper{
        @AuraEnabled
        public Patient_Milestone__c patientMilestone {get;set;}
        @AuraEnabled
        public Account aphresisAccount {get;set;}
        @AuraEnabled
        public Manufacturing_Slot__c manufacturingSite {get;set;}
    }
}