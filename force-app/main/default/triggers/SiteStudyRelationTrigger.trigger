trigger SiteStudyRelationTrigger on Site_Study_Relation__c (before insert, before update) {
    new StudySiteRelationTriggerHandler().run();
}