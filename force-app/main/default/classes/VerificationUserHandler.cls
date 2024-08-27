public with sharing class VerificationUserHandler {
    @AuraEnabled(cacheable=true)
    public static User getCurrentUserInfo(){
        try {
            user us = [SELECT Id, username, E_sign_Pin__c, Profile.Name FROM User where Id=:UserInfo.getUserId()];
            return us;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}