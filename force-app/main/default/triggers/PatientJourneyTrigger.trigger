trigger PatientJourneyTrigger on Patient_Journey__c (before insert, before update, after insert, after update) {
    new PatientJourneyTriggerHandler().run();
}