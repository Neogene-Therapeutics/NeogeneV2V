public class StudySiteRelationTriggerHandler extends TriggerHandler {
    public StudySiteRelationTriggerHandler() {
        this.setMaxLoopCount(4);
    }
    public override void beforeInsert(){
        checkDuplicateSiteStudy();
    }
    public override void beforeUpdate(){
        checkDuplicateSiteStudy();
    }
    public void checkDuplicateSiteStudy(){
        List<Site_Study_Relation__c> siteStudyList = (List<Site_Study_Relation__c>)Trigger.new;
        Map<Id, Site_Study_Relation__c> clinicalMap = new Map<Id,Site_Study_Relation__c>();
        Map<Id, Site_Study_Relation__c> studyMap = new Map<Id,Site_Study_Relation__c>();
        for(Site_Study_Relation__c ssr : siteStudyList){
            clinicalMap.put(ssr.Account__c, ssr);
            studyMap.put(ssr.Study_Protocol__c, ssr);
        }
        List<Site_Study_Relation__c> duplicateSiteStudy = [SELECT Account__c, Study_Protocol__c FROM Site_Study_Relation__c WHERE Account__c IN:clinicalMap.keySet() AND Study_Protocol__c IN:studyMap.keySet()];
        for(Site_Study_Relation__c ssr : duplicateSiteStudy){
            if(clinicalMap.containsKey(ssr.Account__c) && studyMap.containsKey(ssr.Study_Protocol__c)){
                clinicalMap.get(ssr.Account__c).addError('Relationship already exists.');
            }
        }
    }
}