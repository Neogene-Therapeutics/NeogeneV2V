public with sharing class MilestoneTaskFormQuestionTriggerHandler extends TriggerHandler {
    public MilestoneTaskFormQuestionTriggerHandler() {
        this.setMaxLoopCount(4);
    }
    
    public override void afterUpdate(){
        updateMilestoneCourier();
        formStatusProtracCall();
    }

    public void formStatusProtracCall(){
        List<Patient_Milestone_Task_Form_Question__c> formQuestions = (List<Patient_Milestone_Task_Form_Question__c>)Trigger.new;
        for(Patient_Milestone_Task_Form_Question__c pmtfq : formQuestions){
            if(pmtfq.Value__c == 'QC Completed'){
                createDrugTypeShipment(pmtfq.Id);
            }else if(pmtfq.Value__c == 'Shipped to Clinical Site'){
                System.enqueueJob(new IntegrationHandler('Protrac_DP_Receipt', 'PROTRAC', pmtfq.Id));
            }
        }
    }

    public void createDrugTypeShipment(String recordId){
        List<Patient_Milestone_Task_Form_Question__c> formQuestions = [SELECT Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c, Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__r.Clinical_Site__c FROM Patient_Milestone_Task_Form_Question__c WHERE Id =: recordId];
        if(!formQuestions.isEmpty()){
            Patient_Milestone_Task_Form_Question__c pmtfq = formQuestions.get(0);
            List<Account> accountList = [SELECT Id, Name, Study__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                   Apheresis_center__r.BillingCity, Apheresis_center__r.BillingCountry, Apheresis_center__r.BillingPostalCode, 
                   Apheresis_center__r.BillingState, Apheresis_center__r.BillingStreet
            FROM Account WHERE Id=:pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__r.Clinical_Site__c];
            if(!accountList.isEmpty()){
                Account acc = accountList.get(0);
                Manufacturing_Slot__c manuSite = [SELECT Manufacturing_Site__c, Manufacturing_Site__r.BillingCity, Manufacturing_Site__r.BillingStreet, Manufacturing_Site__r.BillingState, Manufacturing_Site__r.BillingCountry, Manufacturing_Site__r.BillingPostalCode FROM Manufacturing_Slot__c Where Study_ID__c =: pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c AND Booking_Status__c = 'Booked' AND Clinical_Site__c =: acc.Id];
                Shipment__c ship = new Shipment__c();
                ship.Type__c = 'Drug Product';
                ship.Patient_Journey__c = pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Id;
                ship.Patient_Milestone__c = pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Id;
                ship.RecordTypeId = Schema.getGlobalDescribe().get('Shipment__c').getDescribe().getRecordTypeInfosByName().get('BioCair').getRecordTypeId();
                PatientMilestoneTaskTriggerHandler.setAddressFields(ship, acc, manuSite);
                insert ship;
            }
        }
    }


    public void updateMilestoneCourier(){
        List<Patient_Milestone_Task__c> patientMilestoneTasks = new List<Patient_Milestone_Task__c>();
        List<Patient_Milestone_Task_Form_Question__c> formQuestions = (List<Patient_Milestone_Task_Form_Question__c>)Trigger.new;
        for(Patient_Milestone_Task_Form_Question__c fq : [SELECT Id, Value__c, Patient_Milestone_Task__r.Apheresis_Shipment__c, Patient_Milestone_Task__r.Drug_Product_Shipment__c FROM Patient_Milestone_Task_Form_Question__c WHERE Id IN :formQuestions]){
            if((fq.Patient_Milestone_Task__r.Apheresis_Shipment__c || fq.Patient_Milestone_Task__r.Drug_Product_Shipment__c ) && fq.Value__c == 'BioCair'){
                Patient_Milestone_Task__c pmt = new Patient_Milestone_Task__c();
                pmt.Id = fq.Patient_Milestone_Task__r.Id;
                pmt.Courier__c = fq.Value__c;
                patientMilestoneTasks.add(pmt);
            }else if((fq.Patient_Milestone_Task__r.Apheresis_Shipment__c || fq.Patient_Milestone_Task__r.Drug_Product_Shipment__c ) && fq.Value__c == 'Manual'){
                Patient_Milestone_Task__c pmt = new Patient_Milestone_Task__c();
                pmt.Id = fq.Patient_Milestone_Task__r.Id;
                pmt.Courier__c = fq.Value__c;
                patientMilestoneTasks.add(pmt);
            }
        }
        if(!patientMilestoneTasks.isEmpty()){
            update patientMilestoneTasks;
        }
    }
}