public with sharing class PatientJourneyTriggerService {

    public static void createPaitentJourneyData(List<Patient_Journey__c> patientJourneyList){
        List<Patient_Milestone__c> patientMilestones =  createPatientMilestone(patientJourneyList);
        List<Patient_Milestone_Task__c> patientMilestoneTasks =  createPatientMilestoneTask(patientMilestones);
        List<Patient_Milestone_Task_Form_Question__c> patientMilestoneTaskQuestion =  createPatientMilestoneTaskQuestion(patientMilestoneTasks);
    }

    public static List<Patient_Milestone__c> createPatientMilestone(List<Patient_Journey__c> patientJourneyList){
        List<Patient_Milestone__c> patientMilestoneList = new List<Patient_Milestone__c>();
        Set<Id> studyDefinitionSet = new Set<Id>();
        Map<String , List<Study_Milestone__c>> studyMilestoneMap = new Map<String, List<Study_Milestone__c>>();
        for(Patient_Journey__c p : patientJourneyList){
            studyDefinitionSet.add(p.Study_Definition__c);
        }
        List<Study_Milestone__c> studyMilestons = [SELECT Id,Display_Name__c, Order__c, Study_Definition__c FROM Study_Milestone__c WHERE Study_Definition__c IN : studyDefinitionSet];
        for(Study_Milestone__c sm : studyMilestons){
            if(studyMilestoneMap.containsKey(sm.Study_Definition__c)) {
                studyMilestoneMap.get(sm.Study_Definition__c).add(sm);
            }
            else {
                studyMilestoneMap.put(sm.Study_Definition__c , new List<Study_Milestone__c>{sm});
            }
        }
        
        for(Patient_Journey__c p : patientJourneyList){
           if(studyMilestoneMap.containsKey(p.Study_Definition__c)) {
                List<Study_Milestone__c> studyMilestones = studyMilestoneMap.get(p.Study_Definition__c);
                for(Study_Milestone__c sm : studyMilestones) {
                    Patient_Milestone__c pm = new Patient_Milestone__c();
                    pm.Name = sm.Display_Name__c;
                    pm.Order__c = sm.Order__c;
                    if(sm.Order__c == 1){
                        pm.Status__c = 'In Progress';
                    } else {
                        pm.Status__c = 'Pending';
                    }
                    pm.Patient_Journey__c = p.Id;
                    pm.Study_Milestone__c = sm.Id;
                    patientMilestoneList.add(pm);
                }
           }
        }

        if(!patientMilestoneList.isEmpty()){
            insert patientMilestoneList;
        }
        return patientMilestoneList;
    }

    public static List<Patient_Milestone_Task__c> createPatientMilestoneTask(List<Patient_Milestone__c> patientMilestones){
        List<Patient_Milestone_Task__c> patientMilestoneTaskList = new List<Patient_Milestone_Task__c>();
        Set<Id> studyMilestoneSet = new Set<Id>();
        Map<String , List<Study_Milestone_Task__c>> studyMilestoneTaskMap = new Map<String, List<Study_Milestone_Task__c>>();
        for(Patient_Milestone__c pm : patientMilestones){
            studyMilestoneSet.add(pm.Study_Milestone__c);
        }
        List<Study_Milestone_Task__c> studyMilestonTasks = [SELECT Id,Task_Owner__c,Display_Name__c, Verify__c, Order__c, Form__c , Study_Milestone__c FROM Study_Milestone_Task__c WHERE Study_Milestone__c IN :studyMilestoneSet];
        for(Study_Milestone_Task__c smt : studyMilestonTasks){
            if(studyMilestoneTaskMap.containsKey(smt.Study_Milestone__c)) {
                studyMilestoneTaskMap.get(smt.Study_Milestone__c).add(smt);
            }
            else {
                studyMilestoneTaskMap.put(smt.Study_Milestone__c , new List<Study_Milestone_Task__c>{smt});
            }
        }
        
        for(Patient_Milestone__c pm : patientMilestones){
           if(studyMilestoneTaskMap.containsKey(pm.Study_Milestone__c)) {
                List<Study_Milestone_Task__c> studyMilestoneTasks = studyMilestoneTaskMap.get(pm.Study_Milestone__c);
                for(Study_Milestone_Task__c smt : studyMilestoneTasks) {
                    Patient_Milestone_Task__c pmt = new Patient_Milestone_Task__c();
                    pmt.Name = smt.Display_Name__c;
                    pmt.Order__c = smt.Order__c;
                    if(smt.Order__c == 1 && pm.Status__c == 'In Progress'){
                        pmt.Status__c = 'In Progress';
                    } else {
                        pmt.Status__c = 'Pending';
                    }
                    pmt.Patient_Milestone__c = pm.Id;
                    pmt.Study_Milestone_Task__c = smt.Id;
                    pmt.Task_Owner__c= smt.Task_Owner__c;
                    pmt.Verify__c = smt.Verify__c;
                    // pmt.OwnerId = smt.OwnerId;
                    pmt.Form__c = smt.Form__c;
                    patientMilestoneTaskList.add(pmt);
                }
           }
        }

        if(!patientMilestoneTaskList.isEmpty()){
            insert patientMilestoneTaskList;
        }
        return patientMilestoneTaskList;
    }


    public static List<Patient_Milestone_Task_Form_Question__c> createPatientMilestoneTaskQuestion(List<Patient_Milestone_Task__c> patientMilestoneTasks){
        List<Patient_Milestone_Task_Form_Question__c> patientMilestoneTaskQuestionList = new List<Patient_Milestone_Task_Form_Question__c>();
        Set<Id> formSet = new Set<Id>();
        Map<String , List<Form_Question__c>> studyMilestoneTaskFormQuestionMap = new Map<String, List<Form_Question__c>>();
        
        for(Patient_Milestone_Task__c pmt : patientMilestoneTasks){
            formSet.add(pmt.Form__c);
        }

        List<Form_Question__c> formQuestions = [SELECT Id,Slot_Booking_Task__c, Picklist_Values__c, Label__c, Read_Only__c , Required__c, Visible__c , Order__c, Form_Section__r.Form__c, Type__c FROM Form_Question__c WHERE Form_Section__r.Form__c IN :formSet];
        for(Form_Question__c fq : formQuestions){
            if(studyMilestoneTaskFormQuestionMap.containsKey(fq.Form_Section__r.Form__c)) {
                studyMilestoneTaskFormQuestionMap.get(fq.Form_Section__r.Form__c).add(fq);
            }
            else {
                studyMilestoneTaskFormQuestionMap.put(fq.Form_Section__r.Form__c , new List<Form_Question__c>{fq});
            }
        }
        
        for(Patient_Milestone_Task__c pmt : patientMilestoneTasks){
           if(studyMilestoneTaskFormQuestionMap.containsKey(pmt.Form__c)) {
                List<Form_Question__c> fqList = studyMilestoneTaskFormQuestionMap.get(pmt.Form__c);
                for(Form_Question__c fq : fqList) {
                    Patient_Milestone_Task_Form_Question__c pmtfq = new Patient_Milestone_Task_Form_Question__c();
                 //   pm.Name = sm.Display_Name__c;
                 //   pmtfq.Study_Milestone_Task__c = smt.Id;
                    pmtfq.Label__c = fq.Label__c;
                    pmtfq.Slot_Booking_Task__c = fq.Slot_Booking_Task__c;
                    pmtfq.Read_Only__c = fq.Read_Only__c;
                    pmtfq.Required__c = fq.Required__c;
                    pmtfq.Visible__c = fq.Visible__c;
                    pmtfq.Order__c = fq.Order__c;
                    pmtfq.Type__c = fq.Type__c;
                    pmtfq.Picklist_Values__c = fq.Picklist_Values__c;
                    pmtfq.Form_Question__c = fq.Id;
                    pmtfq.Patient_Milestone_Task__c = pmt.id;
                    patientMilestoneTaskQuestionList.add(pmtfq);
                }
           }
        }

        if(!patientMilestoneTaskQuestionList.isEmpty()){
            insert patientMilestoneTaskQuestionList;
        }
        return patientMilestoneTaskQuestionList;
    }

    public static void sendCOIDetailsToProtrac(List<Patient_Journey__c> records){
        for(Patient_Journey__c record : records){
            // IntegrationHandler.initiateAPI('Protrac_Patient_Registration', 'PROTRAC', record.Id);
            System.enqueueJob(new IntegrationHandler('Protrac_Patient_Registration', 'PROTRAC', record.Id));
        }
    }
}