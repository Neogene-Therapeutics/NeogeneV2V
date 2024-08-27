trigger COITrigger on Chain_of_Identity__c (before insert, before update, after insert, after update) {
    new COITriggerHandler().run();
}