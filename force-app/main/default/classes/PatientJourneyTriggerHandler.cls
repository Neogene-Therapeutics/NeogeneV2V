public class PatientJourneyTriggerHandler extends TriggerHandler {

    public PatientJourneyTriggerHandler() {
      this.setMaxLoopCount(4);
    }
    
    public override void afterInsert() {
        List<Patient_Registration__c> patients = new List<Patient_Registration__c>();
        List<Patient_Journey__c> patientJourneyList = new List<Patient_Journey__c>();
        for(Sobject s : Trigger.new){
            Patient_Journey__c pj = (Patient_Journey__c) s;
            if(pj.Study_Definition__c != null) {
                patientJourneyList.add(pj);
            }
            if(pj.Patient__c != null){
                Patient_Registration__c pr = new Patient_Registration__c(Id=pj.Patient__c, Is_Patient_Journey_Started__c = true);
                patients.add(pr);
            }
        }
        if(!patientJourneyList.isEmpty()){
            PatientJourneyTriggerService.createPaitentJourneyData(patientJourneyList);
            if(!patients.isEmpty()){
                update patients;
            }
        }     
    }

    public override void afterUpdate() {
        List<Patient_Journey__c> definitionChangePJList = new List<Patient_Journey__c>();
        // List<Patient_Journey__c> coiUpdateList = new List<Patient_Journey__c>();
        for(Sobject s : Trigger.new){
            Patient_Journey__c pj = (Patient_Journey__c) s;
            if(Trigger.oldMap.containsKey(pj.Id) && pj.Study_Definition__c != null && pj.Study_Definition__c != ( (Patient_Journey__c) Trigger.oldMap.get(pj.Id)).Study_Definition__c) {
                definitionChangePJList.add(pj);
            }
            // if(Trigger.oldMap.containsKey(pj.Id) && pj.COI__c != null && pj.COI__c != ( (Patient_Journey__c) Trigger.oldMap.get(pj.Id)).COI__c) {
            //     coiUpdateList.add(pj);
            // }    
        }
        if(!definitionChangePJList.isEmpty()){
            PatientJourneyTriggerService.createPaitentJourneyData(definitionChangePJList);
        }    
        // if(!coiUpdateList.isEmpty()){
        //     PatientJourneyTriggerService.sendCOIDetailsToProtrac(coiUpdateList);
        // }    
    }
}