public with sharing class DiseaseHandler {
    @AuraEnabled(cacheable=true)
    public static List<Disease__c> getActiveDiseases(){
        try {
            List<Disease__c> activeDiseaseList = new List<Disease__c>();
            for(Disease__c d : Disease__c.getall().values()){
                if(d.Active__c){
                    activeDiseaseList.add(d);
                }
            }
            return activeDiseaseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}