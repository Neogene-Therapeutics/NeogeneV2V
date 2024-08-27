public with sharing class PatientJourneyController {
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
    public static List<Patient_Milestone__c> getPatientJourneyMilestones(String recordId) {
        try {
            return [SELECT Id, Name, Study_Milestone__c, Status__c, Order__c, Patient_Journey__c, (SELECT Id, Form__c, Name, Patient_Milestone__c, Order__c, Status__c, Study_Milestone_Task__c, Apheresis_Shipment__c, Verify__c,LastModifiedById, Owner.Profile.Name, Verify_By__r.Name, Courier__c, Drug_Product_Shipment__c, (SELECT Id, Name, Patient_Milestone_Task__c, Form_Question__c, Label__c, Value__c, Order__c, Read_Only__c, Required__c, Type__c, Help_Text__c, Picklist_Values__c FROM Patient_Milestone_Task_Form_Questions__r ORDER BY Order__c) FROM Patient_Milestone_Tasks__r ORDER BY Order__c) 
                    FROM Patient_Milestone__c 
                    WHERE Patient_Journey__c =: recordId ORDER BY Order__c];
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
        Patient_Milestone__c patientMilestone = [SELECT Id, Patient_Journey__r.Study_Definition__c, Patient_Journey__r.Clinical_Site__r.Apheresis_center__c FROM Patient_Milestone__c WHERE Id=:milestoneId];
        Account aphresisAccount = [SELECT Person_to_contact__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account WHERE Id =:patientMilestone.Patient_Journey__r.Clinical_Site__r.Apheresis_center__c];
        Manufacturing_Slot__c manufacturingSite = [SELECT Manufacturing_Site__r.Person_to_contact__c, Manufacturing_Site__r.BillingCity, Manufacturing_Site__r.BillingCountry, Manufacturing_Site__r.BillingState, Manufacturing_Site__r.BillingStreet, Manufacturing_Site__r.BillingPostalCode FROM Manufacturing_Slot__c Where Study_ID__c =: patientMilestone.Patient_Journey__r.Study_Definition__c AND Booking_Status__c = 'Booked' AND Clinical_Site__c =: patientMilestone.Patient_Journey__r.Clinical_Site__r.Id];
        // Account cellTherapyAccount = [SELECT Person_to_contact__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account WHERE Id =:[SELECT Manufacturing_Site__c FROM Manufacturing_Slot__c Where Study_ID__c =: patientMilestone.Patient_Journey__r.Study_Definition__c AND Booking_Status__c = 'Booked' AND Clinical_Site__c =: patientMilestone.Patient_Journey__r.Clinical_Site__r.Id].Manufacturing_Site__c LIMIT 1];
        aw.aphresisAccount = aphresisAccount;
        aw.manufacturingSite = manufacturingSite;
        aw.patientMilestone = patientMilestone;
        return aw;
    }

    @AuraEnabled
    public static void createCopyOfFile(String recordId, String documentId){
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.ContentDocumentId = documentId;
        newLink.LinkedEntityId = recordId;
        newLink.ShareType = 'V'; 
        newLink.Visibility = 'AllUsers';
        insert newLink;
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