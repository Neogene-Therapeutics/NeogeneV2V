trigger StudyProtocolTrigger on Study_Protocol__c (before insert, before update, after insert, after update) {
    new StudyProtocolTriggerHandler().run();
}