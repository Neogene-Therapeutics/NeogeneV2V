public with sharing class MfgSlotController {
    
    @AuraEnabled(cacheable=true)
    public static List<Manufacturing_Slot__c> getMFGSlots() {
        try {
            return [
                SELECT Id, Name, Slot_Quantity__c, Study_ID__r.Display_Name__c, Clinical_Site__c, 
                       Capacity_Pool__c, Booking_Status__c, Manufacturing_Site__c, 
                       Start_Date__c
                FROM Manufacturing_Slot__c
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Manufacturing Slots: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateManufacturingSlots(List<Manufacturing_Slot__c> updatedSlots) {
        try {
            update updatedSlots;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating Manufacturing Slots: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SiteOption> getManufacturingSiteOptions() {
        try {
            List<SiteOption> options = new List<SiteOption>();
            List<Account> sites = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Manufacturing_Site'];
            for (Account site : sites) {
                options.add(new SiteOption(site.Id, site.Name));
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Manufacturing Site options: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SiteOption> getClinicalSiteOptions() {
        try {
            List<SiteOption> options = new List<SiteOption>();
            List<Account> sites = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Clinical_Site'];
            for (Account site : sites) {
                options.add(new SiteOption(site.Id, site.Name));
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Clinical Site options: ' + e.getMessage());
        }
    }

    // Custom class for dropdown options
    public class SiteOption {
        @AuraEnabled public String value;
        @AuraEnabled public String label;

        public SiteOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}