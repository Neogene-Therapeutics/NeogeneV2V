public class PatientJourneyTriggerHandler extends TriggerHandler {

    public PatientJourneyTriggerHandler() {
      this.setMaxLoopCount(2);
    }
    
    public override void afterInsert() {
        List<Patient_Journey__c> patientJourneyList = new List<Patient_Journey__c>();
        for(Sobject s : Trigger.new){
            Patient_Journey__c pj = (Patient_Journey__c) s;
            if(pj.Study_Definition__c != null) {
                patientJourneyList.add(pj);
            }
        }
        if(!patientJourneyList.isEmpty()){
            PatientJourneyTriggerService.createPaitentJourneyData(patientJourneyList);
        }     
    }

    public override void afterUpdate() {
        List<Patient_Journey__c> definitionChangePJList = new List<Patient_Journey__c>();
        List<Patient_Journey__c> coiUpdateList = new List<Patient_Journey__c>();
        for(Sobject s : Trigger.new){
            Patient_Journey__c pj = (Patient_Journey__c) s;
            if(Trigger.oldMap.containsKey(pj.Id) && pj.Study_Definition__c != null && pj.Study_Definition__c != ( (Patient_Journey__c) Trigger.oldMap.get(pj.Id)).Study_Definition__c) {
                definitionChangePJList.add(pj);
            }
            if(Trigger.oldMap.containsKey(pj.Id) && pj.COI__c != null && pj.COI__c != ( (Patient_Journey__c) Trigger.oldMap.get(pj.Id)).COI__c) {
                coiUpdateList.add(pj);
            }    
        }
        if(!definitionChangePJList.isEmpty()){
            PatientJourneyTriggerService.createPaitentJourneyData(definitionChangePJList);
        }    
        if(!coiUpdateList.isEmpty()){
            PatientJourneyTriggerService.sendCOIDetailsToProtrac(coiUpdateList);
        }    
    }
}