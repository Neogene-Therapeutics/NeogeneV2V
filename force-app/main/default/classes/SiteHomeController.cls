public without sharing class SiteHomeController {
    @AuraEnabled(cacheable = true)
    public static List<StudyProtocolWrapper> getStudyProtocolOptions() { 
        try {
            List<StudyProtocolWrapper> wrapperList = new List<StudyProtocolWrapper>();
            List<User> users = [select id, contactId, Contact.AccountId from User where id = : UserInfo.getUserId() LIMIT 1];
            if(!users.isEmpty()) {
                for(Site_Study_Relation__c ssr : [SELECT Id, Study_Protocol__r.Id, Study_Protocol__r.Display_Name__c FROM Site_Study_Relation__c WHERE Account__c = :users[0].Contact.AccountId]){
                    StudyProtocolWrapper wrapper = new StudyProtocolWrapper();
                    wrapper.name = ssr.Study_Protocol__r.Display_Name__c;
                    wrapper.studyId = ssr.Study_Protocol__r.id;
                    wrapperList.add(wrapper);
                }
            }
            return wrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class StudyProtocolWrapper {
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public String studyId{get; set;}
    }

    @AuraEnabled(cacheable=true)
    public static JourneyOverviewDetails getJourneyOverview(String studyId) {
        JourneyOverviewDetails details = new JourneyOverviewDetails();
        try {
            List<User> users = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (!users.isEmpty()) {
                String clinicalSiteId = users[0].Contact.AccountId;
                List<AggregateResult> results = [SELECT COUNT(Id) mileCount, Current_Stage__c FROM Patient_Journey__c WHERE Clinical_Site__c =  :clinicalSiteId AND Study_Definition__c = :studyId GROUP BY Current_Stage__c ];

                List<AggregateResult> pjAggList = [
                    SELECT COUNT(Id) pjCount 
                    FROM Patient_Journey__c 
                    WHERE Clinical_Site__c = :clinicalSiteId 
                    AND Study_Definition__c = :studyId
                ];

                List<AggregateResult> activePjAggList = [
                    SELECT COUNT(Id) activePj 
                    FROM Patient_Journey__c 
                    WHERE Status__c = 'In Progress' AND Clinical_Site__c = :clinicalSiteId 
                    AND Study_Definition__c = :studyId
                ];

                details.ApheresisCompletedCount = 0;
                details.ManufacturingStartedCount = 0;
                details.IPPackOutCompletedCount = 0;
                details.IPInfusionCompletedCount = 0;

                details.totalJourney = !pjAggList.isEmpty() ? ((Long) pjAggList.get(0).get('pjCount')).intValue() : 0;
                details.activeJourney = !activePjAggList.isEmpty() ? ((Long) activePjAggList.get(0).get('activePj')).intValue() : 0;

                Integer totalJourneyCount = 0;
                for (AggregateResult ar : results) {
                    String stage = (String) ar.get('Current_Stage__c');
                    Integer count = ((Long) ar.get('mileCount')).intValue();
                    totalJourneyCount += count;
                    if (stage.equals('Apheresis Completed')) {
                        details.ApheresisCompletedCount = count;
                    } else if (stage.equals('Manufacturing Started')) {
                        details.ManufacturingStartedCount = count;
                    } else if (stage.equals('IP Pack-Out Completed')) {
                        details.IPPackOutCompletedCount = count;
                    } else if (stage.equals('IP Infusion Completed')) {
                        details.IPInfusionCompletedCount = count;
                    }
                }
                System.debug('totalJourneyCount=>'+totalJourneyCount);
            }
            return details;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class JourneyOverviewDetails {
        @AuraEnabled
        public Integer ApheresisCompletedCount { get; set; }
        @AuraEnabled
        public Integer ManufacturingStartedCount { get; set; }
        @AuraEnabled
        public Integer IPPackOutCompletedCount { get; set; }
        @AuraEnabled
        public Integer IPInfusionCompletedCount { get; set; }
        @AuraEnabled
        public Integer totalJourney { get; set; }
        @AuraEnabled
        public Integer activeJourney { get; set; }
    }
}
