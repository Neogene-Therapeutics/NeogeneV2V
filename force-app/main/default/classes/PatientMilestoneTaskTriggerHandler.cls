public with sharing class PatientMilestoneTaskTriggerHandler extends TriggerHandler {
    public PatientMilestoneTaskTriggerHandler() {
        this.setMaxLoopCount(5);
    }

    public override void afterUpdate() {
        checkMilestoneTaskStatus();
        createShipmentMilestoneTask();
        createSharingRecords();
    }
    
    public override void afterInsert(){
        createSharingRecords();   
    }
    
    public override void beforeUpdate(){
        System.debug('in before update');
        if(Trigger.IsBefore && Trigger.IsUpdate){
             validateQueueMember();
        }
       
    }
    
    public static void validateQueueMember(){
      // Create a map to store the queue names and corresponding task records
    Map<String, List<Patient_Milestone_Task__c>> queueNameToTaskMap = new Map<String, List<Patient_Milestone_Task__c>>();
    List<Patient_Milestone_Task__c> listOfTasks= (List<Patient_Milestone_Task__c>)Trigger.new;
    for (Patient_Milestone_Task__c task : listOfTasks) {
        Patient_Milestone_Task__c oldTask = (Patient_Milestone_Task__c)Trigger.oldMap.get(task.Id);
        
        // Check if Status__c is changed to 'Completed'
        if (task.Status__c == 'Completed' && oldTask.Status__c != 'Completed') {
            // Get the selected queue name from Task_Owner__c
            String selectedQueueName = task.Task_Owner__c;
            
            if (!queueNameToTaskMap.containsKey(selectedQueueName)) {
                queueNameToTaskMap.put(selectedQueueName, new List<Patient_Milestone_Task__c>());
            }
            queueNameToTaskMap.get(selectedQueueName).add(task);
        }
    }
    
    // Query all the groups (queues) that match the selected queue names
    List<Group> queues = [SELECT Id, Name FROM Group WHERE Name IN :queueNameToTaskMap.keySet() AND Type = 'Queue'];
    
    // Create a set of group (queue) IDs
    Set<Id> queueIds = new Set<Id>();
    for (Group queue : queues) {
        queueIds.add(queue.Id);
    }
    
    // Query GroupMembers to check if the current user is part of any of these queues
    Set<Id> userQueueMemberships = new Set<Id>();
    for (GroupMember gm : [SELECT GroupId FROM GroupMember WHERE GroupId IN :queueIds AND UserOrGroupId = :UserInfo.getUserId()]) {
        userQueueMemberships.add(gm.GroupId);
    }
    
    // Iterate over tasks and check if the user has permission to complete the task
    for (String queueName : queueNameToTaskMap.keySet()) {
        Group matchingQueue;
        
        // Find the queue by name
        for (Group queue : queues) {
            if (queue.Name == queueName) {
                matchingQueue = queue;
                break;
            }
        }
        
        if (matchingQueue != null && !userQueueMemberships.contains(matchingQueue.Id)) {
            for (Patient_Milestone_Task__c task : queueNameToTaskMap.get(queueName)) {
                task.addError('You do not have permission to complete this task because you are not a member of the selected queue.');
            }
        }
    }
    }
    
    public static void createSharingRecords(){
        List<Patient_Milestone_Task__Share> sharesToCreate = new List<Patient_Milestone_Task__Share>();
	List<Patient_Milestone_Task__c> patientMilestoneTasks = (List<Patient_Milestone_Task__c>) Trigger.new;
    for (Patient_Milestone_Task__c task : patientMilestoneTasks) {
        // Read access queues
        if (task.Read_Access_Queues__c != null) {
            List<String> readQueueNames = task.Read_Access_Queues__c.split(';');
            System.debug('readQueueNames: '+readQueueNames);
            List<Group> readGroups = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name IN :readQueueNames];
            System.debug('readGroups: '+readGroups);
            for (Group rGroup : readGroups) {
                Patient_Milestone_Task__Share share = new Patient_Milestone_Task__Share();
                share.ParentId = task.Id;
                share.UserOrGroupId = rGroup.Id;
                share.AccessLevel = 'Read';
                sharesToCreate.add(share);
            }
        }

        // Write access queues
        if (task.Write_Access_Queues__c != null) {
            List<String> writeQueueNames = task.Write_Access_Queues__c.split(';');
            System.debug('writeQueueNames: '+writeQueueNames);
            List<Group> writeGroups = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name IN :writeQueueNames];
            System.debug('writeGroups: '+writeGroups);
            for (Group wGroup : writeGroups) {
                Patient_Milestone_Task__Share share = new Patient_Milestone_Task__Share();
                share.ParentId = task.Id;
                share.UserOrGroupId = wGroup.Id;
                share.AccessLevel = 'Edit';
                sharesToCreate.add(share);
            }
        }
    }
	System.debug('sharesToCreate: '+sharesToCreate);
    if (!sharesToCreate.isEmpty()) {
        insert sharesToCreate;
    }
    }

    public static void checkMilestoneTaskStatus() {
        Set<Id> milestoneIds = new Set<Id>();
        
        List<Patient_Milestone_Task__c> patientMilestoneTasks = (List<Patient_Milestone_Task__c>) Trigger.new;
        for(Patient_Milestone_Task__c pmt : patientMilestoneTasks){
            if(pmt.Status__c == 'Completed' && pmt.Patient_Milestone__c != null) {
                milestoneIds.add(pmt.Patient_Milestone__c);
            }
        }
        if(!milestoneIds.isEmpty()){
            Map<Id,Patient_Milestone__c> patientMilestones = new Map<Id,Patient_Milestone__c>([SELECT Id, Status__c, (SELECT Status__c, Verify__c, Verify_By__c, Apheresis_Shipment__c, Drug_Product_Shipment__c FROM Patient_Milestone_Tasks__r ORDER BY Order__c), (SELECT Id FROM Shipment__r) FROM Patient_Milestone__c WHERE Id IN :milestoneIds]);
            for(Patient_Milestone__c pm : patientMilestones.values()){
                String status = pm.Status__c;
                for(Patient_Milestone_Task__c pmt : pm.Patient_Milestone_Tasks__r){
                    if(pmt.Status__c == 'Completed' && !pmt.Verify__c){
                        status = 'Completed';
                    }else if(pmt.Status__c == 'Completed' && pmt.Verify__c && pmt.Verify_By__c != null){
                        status = 'Completed';
                    }else{
                        status = pm.Status__c;
                    }
                    if(pmt.Apheresis_Shipment__c || pmt.Drug_Product_Shipment__c){
                        if(pm.Shipment__r.size() == 0){
                            status = pm.Status__c;
                        }
                    }

                }
                pm.Status__c = status;
            }
            if(!patientMilestones.isEmpty()){
                update patientMilestones.values();
            }
        }
        
    }

    public static void createShipmentMilestoneTask() {
        List<Patient_Milestone_Task__c> patientMilestoneTasks = (List<Patient_Milestone_Task__c>) Trigger.new;
        Map<Id, Patient_Milestone_Task__c> oldPatientMilestoneTasks = (Map<Id, Patient_Milestone_Task__c>) Trigger.oldMap;

        List<Patient_Milestone_Task__c> patientMilestoneTaskShipment = new List<Patient_Milestone_Task__c>();
        for (Patient_Milestone_Task__c pmt : patientMilestoneTasks) {
            if (pmt.Courier__c == 'BioCair' && (pmt.Apheresis_Shipment__c || pmt.Drug_Product_Shipment__c)&& (pmt.Status__c == 'Completed' && pmt.Status__c != oldPatientMilestoneTasks.get(pmt.Id).Status__c)) {
                patientMilestoneTaskShipment.add(pmt);
            }
        }

        if (!patientMilestoneTaskShipment.isEmpty()) {
            List<Patient_Milestone_Task__c> shipmentTasks = [SELECT Id, Drug_Product_Shipment__c, Apheresis_Shipment__c, Courier__c, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__c, Patient_Milestone__r.Patient_Journey__r.Study_Definition__c FROM Patient_Milestone_Task__c WHERE Id IN :patientMilestoneTaskShipment];
            if (!shipmentTasks.isEmpty()) {
                
                Map<Id, Patient_Milestone_Task__c> clinicalIdToMilestoneMap = new Map<Id, Patient_Milestone_Task__c>();
                Map<Id, Patient_Milestone_Task__c> studyToMilestoneMap = new Map<Id, Patient_Milestone_Task__c>();
                for (Patient_Milestone_Task__c pmtShip : shipmentTasks) {
                    if (pmtShip.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__c != null) {
                        clinicalIdToMilestoneMap.put(pmtShip.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__c, pmtShip);
                    }
                    if (pmtShip.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c != null) {
                        studyToMilestoneMap.put(pmtShip.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c, pmtShip);
                    }
                }

                if (!clinicalIdToMilestoneMap.isEmpty() && !studyToMilestoneMap.isEmpty()) {
                    createShipmentRecords(clinicalIdToMilestoneMap, studyToMilestoneMap);
                }
            }
        }
    }

    public static void createShipmentRecords(Map<Id, Patient_Milestone_Task__c> clinicalIdToMilestoneMap, Map<Id, Patient_Milestone_Task__c> studyToMilestoneMap) {
        Map<Id, Account> clinicalAccounts = new Map<Id, Account>([
            SELECT Id, Name, Study__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                   Apheresis_center__r.BillingCity, Apheresis_center__r.BillingCountry, Apheresis_center__r.BillingPostalCode, 
                   Apheresis_center__r.BillingState, Apheresis_center__r.BillingStreet
            FROM Account
            WHERE Id IN :clinicalIdToMilestoneMap.keySet()]
        );
        Map<Id, Manufacturing_Slot__c> manufacturingMap = new Map<Id,Manufacturing_Slot__c>();
        for(Manufacturing_Slot__c man : [SELECT Clinical_Site__c, Manufacturing_Site__r.BillingCity, Manufacturing_Site__r.BillingState, Manufacturing_Site__r.BillingStreet, Manufacturing_Site__r.BillingCountry, Manufacturing_Site__r.BillingPostalCode FROM Manufacturing_Slot__c Where Study_ID__c IN: studyToMilestoneMap.keySet() AND Booking_Status__c = 'Booked' AND Clinical_Site__c =: clinicalIdToMilestoneMap.keySet()]){
            if(man.Manufacturing_Site__c != null){
                manufacturingMap.put(man.Clinical_Site__c,man);
            }
        }

        List<Shipment__c> shipmentList = new List<Shipment__c>();
        for (Id clinicalId : clinicalIdToMilestoneMap.keySet()) {
            Account acc = clinicalAccounts.get(clinicalId);
            Manufacturing_Slot__c manSlot = manufacturingMap.get(clinicalId);
            if (acc != null) {
                Shipment__c ship = new Shipment__c();
                if(clinicalIdToMilestoneMap.get(clinicalId).Apheresis_Shipment__c){
                    ship.Type__c = 'Apheresis';
                }else if(clinicalIdToMilestoneMap.get(clinicalId).Drug_Product_Shipment__c){
                    ship.Type__c = 'Drug Product';
                }
                ship.RecordTypeId = Schema.getGlobalDescribe().get('Shipment__c').getDescribe().getRecordTypeInfosByName().get(clinicalIdToMilestoneMap.get(clinicalId).Courier__c).getRecordTypeId();
                ship.Patient_Milestone__c = clinicalIdToMilestoneMap.get(clinicalId).Patient_Milestone__r.Id;
                ship.Patient_Journey__c = clinicalIdToMilestoneMap.get(clinicalId).Patient_Milestone__r.Patient_Journey__r.Id;
                setAddressFields(ship, acc, manSlot);
                shipmentList.add(ship);
            }
        }

        if (!shipmentList.isEmpty()) {
            insert shipmentList;
        }
    }

    public static void setAddressFields(Shipment__c ship, Account acc, Manufacturing_Slot__c manSlot) {
        ship.Pickup_Address__Street__s = acc.Apheresis_center__r.BillingStreet;
        ship.Pickup_Address__City__s = acc.Apheresis_center__r.BillingCity;
        ship.Pickup_Address__PostalCode__s = acc.Apheresis_center__r.BillingPostalCode;
        ship.Pickup_Address__CountryCode__s = acc.Apheresis_center__r.BillingCountry;
        ship.Pickup_Address__StateCode__s = acc.Apheresis_center__r.BillingState;

        ship.Dropoff_Address__Street__s = manSlot.Manufacturing_Site__r.BillingStreet;
        ship.Dropoff_Address__City__s = manSlot.Manufacturing_Site__r.BillingCity;
        ship.Dropoff_Address__PostalCode__s = manSlot.Manufacturing_Site__r.BillingPostalCode;
        ship.Dropoff_Address__CountryCode__s = manSlot.Manufacturing_Site__r.BillingCountry;
        ship.Dropoff_Address__StateCode__s = manSlot.Manufacturing_Site__r.BillingState;
    }
}