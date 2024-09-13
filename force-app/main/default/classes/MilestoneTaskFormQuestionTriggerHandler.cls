public with sharing class MilestoneTaskFormQuestionTriggerHandler extends TriggerHandler {
    public MilestoneTaskFormQuestionTriggerHandler() {
        this.setMaxLoopCount(4);
    }
    
    public override void afterUpdate(){
        checkSubjectIdTask();
        updateMilestoneCourier();
        formStatusProtracCall();
    }    

    public void checkSubjectIdTask() {
        Set<Id> subjectIdQues = new Set<Id>();
        List<Patient_Milestone_Task_Form_Question__c> formQuestions = (List<Patient_Milestone_Task_Form_Question__c>) Trigger.new;
        for (Patient_Milestone_Task_Form_Question__c pmtfq : formQuestions) {
            if (pmtfq.Is_Subject__c) {
                subjectIdQues.add(pmtfq.Id);
            }
        }
        if (!subjectIdQues.isEmpty()) {
            try {
                List<Patient_Milestone_Task_Form_Question__c> subjectFormQuesList = [
                    SELECT Value__c, Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__c 
                    FROM Patient_Milestone_Task_Form_Question__c 
                    WHERE Id IN :subjectIdQues
                ];
                if (!subjectFormQuesList.isEmpty()) {
                    List<Patient_Registration__c> patientList = new List<Patient_Registration__c>();
                    for (Patient_Milestone_Task_Form_Question__c subques : subjectFormQuesList) {
                        if (subques.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__c != null) {
                            Patient_Registration__c p = new Patient_Registration__c(
                                Id = subques.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__c,
                                Subject_ID__c = subques.Value__c
                            );
                            patientList.add(p);
                        }
                    }
                    if (!patientList.isEmpty()) {
                        update patientList;
                    }
                }
            } catch (DmlException dmlEx) {
                System.debug('DML Exception: ' + dmlEx.getMessage());
            } catch (Exception ex) {
                System.debug('Exception: ' + ex.getMessage());
            }
        }
    }
    

    public void formStatusProtracCall(){
        List<Patient_Milestone_Task_Form_Question__c> formQuestions = (List<Patient_Milestone_Task_Form_Question__c>)Trigger.new;
        for(Patient_Milestone_Task_Form_Question__c pmtfq : formQuestions){
            if(pmtfq.Value__c == 'QC Completed'){
                // createDrugTypeShipment(pmtfq.Id);
            }else if(pmtfq.Value__c == 'Shipped to Clinical Site'){
                // System.enqueueJob(new IntegrationHandler('Protrac_DP_Receipt', 'PROTRAC', pmtfq.Id));
            }
        }
    }

    public void createDrugTypeShipment(String recordId) {
        try {
            List<Patient_Milestone_Task_Form_Question__c> formQuestions = [
                SELECT  Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__c, Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c, 
                       Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__r.Clinical_Site__c,
                       Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Id,
                       Patient_Milestone_Task__r.Patient_Milestone__r.Id
                FROM Patient_Milestone_Task_Form_Question__c 
                WHERE Id = :recordId
            ];
            if (!formQuestions.isEmpty()) {
                Patient_Milestone_Task_Form_Question__c pmtfq = formQuestions.get(0);
                List<Account> accountList = [
                    SELECT Id, Name, Study__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                           Apheresis_center__r.BillingCity, Apheresis_center__r.BillingCountry, Apheresis_center__r.BillingPostalCode, 
                           Apheresis_center__r.BillingState, Apheresis_center__r.BillingStreet
                    FROM Account 
                    WHERE Id = :pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__r.Clinical_Site__c
                ];
                if (!accountList.isEmpty()) {
                    Account acc = accountList.get(0);
                    Manufacturing_Slot__c manuSite = [
                        SELECT Manufacturing_Site__c, Manufacturing_Site__r.BillingCity, Manufacturing_Site__r.BillingStreet, 
                               Manufacturing_Site__r.BillingState, Manufacturing_Site__r.BillingCountry, Manufacturing_Site__r.BillingPostalCode 
                        FROM Manufacturing_Slot__c 
                        WHERE Study_ID__c = :pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c 
                              AND Booking_Status__c = 'Booked' 
                              AND Clinical_Site__c = :acc.Id
                              AND Patient__c =: pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Patient__c
                        LIMIT 1
                    ];
                    
                    Shipment__c ship = new Shipment__c();
                    ship.Type__c = 'Drug Product';
                    ship.Patient_Journey__c = pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.Id;
                    ship.Patient_Milestone__c = pmtfq.Patient_Milestone_Task__r.Patient_Milestone__r.Id;
                    
                    ship.RecordTypeId = Schema.getGlobalDescribe().get('Shipment__c')
                        .getDescribe()
                        .getRecordTypeInfosByName()
                        .get('BioCair')
                        .getRecordTypeId();
                    PatientMilestoneTaskTriggerHandler.setAddressFields(ship, acc, manuSite);
                    insert ship;
                }
            }
        } catch (DmlException dmlEx) {
            System.debug('DML Exception: ' + dmlEx.getMessage());
        } catch (QueryException qEx) {
            System.debug('Query Exception: ' + qEx.getMessage());
        } catch (Exception ex) {
            System.debug('General Exception: ' + ex.getMessage());
        }
    }
    
    public void updateMilestoneCourier() {
        try {
            List<Patient_Milestone_Task_Form_Question__c> formQuestions = (List<Patient_Milestone_Task_Form_Question__c>) Trigger.new;
            List<Patient_Milestone_Task_Form_Question__c> queriedQuestions = [
                SELECT Id, Value__c, Patient_Milestone_Task__r.Apheresis_Shipment__c, Patient_Milestone_Task__r.Drug_Product_Shipment__c, 
                       Patient_Milestone_Task__r.Id 
                FROM Patient_Milestone_Task_Form_Question__c 
                WHERE Id IN :formQuestions
            ];
            List<Patient_Milestone_Task__c> patientMilestoneTasks = new List<Patient_Milestone_Task__c>();
            for (Patient_Milestone_Task_Form_Question__c fq : queriedQuestions) {
                if ((fq.Patient_Milestone_Task__r.Apheresis_Shipment__c || fq.Patient_Milestone_Task__r.Drug_Product_Shipment__c) && 
                    (fq.Value__c == 'BioCair' || fq.Value__c == 'Manual')) {
                    Patient_Milestone_Task__c pmt = new Patient_Milestone_Task__c();
                    pmt.Id = fq.Patient_Milestone_Task__r.Id;
                    pmt.Courier__c = fq.Value__c;
                    patientMilestoneTasks.add(pmt);
                }
            }
            if (!patientMilestoneTasks.isEmpty()) {
                update patientMilestoneTasks;
            }
        } catch (DmlException dmlEx) {
            System.debug('DML Exception: ' + dmlEx.getMessage());
        } catch (Exception ex) {
            System.debug('General Exception: ' + ex.getMessage());
        }
    }
}