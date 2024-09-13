public with sharing class SiteTriggerHandler extends TriggerHandler{
    public SiteTriggerHandler() {
        this.setMaxLoopCount(2);
    }
    public override void afterInsert() {
        for(Account acc : (List<Account>) Trigger.new){
            if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Clinical Site').getRecordTypeId() || acc.RecordTypeId  == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Manufacturing Site').getRecordTypeId()){
                System.enqueueJob(new IntegrationHandler('Protrac_Site', 'PROTRAC', acc.Id));
            }
        }
    }
}