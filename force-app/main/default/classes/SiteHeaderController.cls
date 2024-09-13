public class SiteHeaderController {
    @AuraEnabled(cacheable = true)
    public static Study_Template__c getProtocolOptions() { 
        try {
            return [SELECT Id, Name FROM Study_Template__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}