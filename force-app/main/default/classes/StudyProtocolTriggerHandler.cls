public class StudyProtocolTriggerHandler extends TriggerHandler {

    public StudyProtocolTriggerHandler() {
      this.setMaxLoopCount(2);
    }
    
    public override void afterInsert() {
        List<Study_Protocol__c> studyProtocolList = new List<Study_Protocol__c>();
        for(Sobject s : Trigger.new){
            Study_Protocol__c pj = (Study_Protocol__c) s;
            if(pj.Study_Template__c != null) {
                studyProtocolList.add(pj);
            }
            System.enqueueJob(new IntegrationHandler('Protrac_Study', 'PROTRAC', pj.Id));
        }
        if(!studyProtocolList.isEmpty()){
            createStudyProtocolData(studyProtocolList);
        } 
        createStudySiteRecords((List<Study_Protocol__c>)Trigger.New, (Map<Id,Study_Protocol__c>)Trigger.oldMap);
    }

    public override void afterUpdate() {
        List<Study_Protocol__c> definitionChangePJList = new List<Study_Protocol__c>();
        for(Sobject s : Trigger.new){
            Study_Protocol__c pj = (Study_Protocol__c) s;
            if(Trigger.oldMap.containsKey(pj.Id) && pj.Study_Template__c != null && pj.Study_Template__c != ( (Study_Protocol__c) Trigger.oldMap.get(pj.Id)).Study_Template__c) {
                definitionChangePJList.add(pj);
            }
        }
        if(!definitionChangePJList.isEmpty()){
            createStudyProtocolData(definitionChangePJList);
        }
        
        createStudySiteRecords((List<Study_Protocol__c>)Trigger.New, (Map<Id,Study_Protocol__c>)Trigger.oldMap);
    }

    public static void createStudyProtocolData(List<Study_Protocol__c> studyProtocolList){
        List<Study_Milestone__c> studyMilestones =  createStudyMilestone(studyProtocolList);
        List<Study_Milestone_Task__c> studyMilestoneTasks =  createStudyMilestoneTask(studyMilestones);
        List<Form__c> studyMilestoneTaskFormList =  createStudyMilestoneTaskForm(studyMilestoneTasks);  
        List<Form_Section__c> formSections = createFormSection(studyMilestoneTaskFormList);
        List<Form_Question__c> formQuestions = createFormQuestion(formSections);
        
       }

    public static List<Study_Milestone__c> createStudyMilestone(List<Study_Protocol__c> studyProtocolList){
        List<Study_Milestone__c> studyMilestoneList = new List<Study_Milestone__c>();
        Set<Id> studyTemplateSet = new Set<Id>();
        Map<String , List<Study_Template_Milestone__c>> studyTemplateMilestoneMap = new Map<String, List<Study_Template_Milestone__c>>();
        for(Study_Protocol__c p : studyProtocolList){
            studyTemplateSet.add(p.Study_Template__c);
        }
        List<Study_Template_Milestone__c> studyTemplateMilestones = [SELECT Id,Write_Access_Queue__c, Read_Access_Queues__c, COI_Generation__c,Display_Name__c, Site_Facing__c, Sponsor_Facing__c,  Order__c, Study_Template__c FROM Study_Template_Milestone__c WHERE Study_Template__c IN : studyTemplateSet];
        for(Study_Template_Milestone__c sm : studyTemplateMilestones){
            if(!studyTemplateMilestoneMap.containsKey(sm.Study_Template__c)) {
                studyTemplateMilestoneMap.put(sm.Study_Template__c , new List<Study_Template_Milestone__c>());
            }
            studyTemplateMilestoneMap.get(sm.Study_Template__c).add(sm);
        }
        for(Study_Protocol__c p : studyProtocolList){
           if(studyTemplateMilestoneMap.containsKey(p.Study_Template__c)) {
                List<Study_Template_Milestone__c> templateMilestones = studyTemplateMilestoneMap.get(p.Study_Template__c);
                for(Study_Template_Milestone__c sm : templateMilestones) {
                    Study_Milestone__c pm = new Study_Milestone__c();
                    pm.Order__c = sm.Order__c;
                    pm.Study_Definition__c = p.Id;
                    pm.COI_Generation__c = sm.COI_Generation__c;
                    pm.Study_Template_Milestone__c = sm.Id;
                    pm.Display_Name__c = sm.Display_Name__c;
                    pm.Sponsor_Facing__c = sm.Sponsor_Facing__c;
                    pm.Site_Facing__c = sm.Site_Facing__c;
                    pm.Read_Access_Queues__c = sm.Read_Access_Queues__c;
                    pm.Write_Access_Queues__c = sm.Write_Access_Queue__c;
                    studyMilestoneList.add(pm);
                }
           }
        }

        if(!studyMilestoneList.isEmpty()){
            insert studyMilestoneList;
        }
        return studyMilestoneList;
    }
    
    
    
    public static List<Study_Milestone_Task__c> createStudyMilestoneTask(List<Study_Milestone__c> studyMilestones){
        List<Study_Milestone_Task__c> studyMilestoneTaskList = new List<Study_Milestone_Task__c>();
        Set<Id> studyTemplateMilestoneSet = new Set<Id>();
        Map<String , List<Study_Template_Milestone_Task__c>> studyTemplateMilestoneTaskMap = new Map<String, List<Study_Template_Milestone_Task__c>>();
        for(Study_Milestone__c pm : studyMilestones){
            studyTemplateMilestoneSet.add(pm.Study_Template_Milestone__c);
        }
        List<Study_Template_Milestone_Task__c> studyTemplateMilestonTasks = [SELECT Id,Write_Access_Queues__c, Read_Access_Queues__c,Name,Display_Name__c,Site_Facing__c,Sponsor_facing__c, Order__c , Task_Owner__c, Apheresis_Shipment__c, Drug_Product_Shipment__c,  Study_Template_Milestone__c, Verify__c FROM Study_Template_Milestone_Task__c WHERE Study_Template_Milestone__c IN :studyTemplateMilestoneSet];
        for(Study_Template_Milestone_Task__c smt : studyTemplateMilestonTasks){
            if(!studyTemplateMilestoneTaskMap.containsKey(smt.Study_Template_Milestone__c)) {
                studyTemplateMilestoneTaskMap.put(smt.Study_Template_Milestone__c , new List<Study_Template_Milestone_Task__c>());
            }
            studyTemplateMilestoneTaskMap.get(smt.Study_Template_Milestone__c).add(smt);
        }
        for(Study_Milestone__c pm : studyMilestones){
           if(studyTemplateMilestoneTaskMap.containsKey(pm.Study_Template_Milestone__c)) {
                List<Study_Template_Milestone_Task__c> templateMilestoneTasks = studyTemplateMilestoneTaskMap.get(pm.Study_Template_Milestone__c);
                for(Study_Template_Milestone_Task__c smt : templateMilestoneTasks) {
                    Study_Milestone_Task__c pmt = new Study_Milestone_Task__c();
                    pmt.Order__c = smt.Order__c;
                    pmt.Display_Name__c = smt.Display_Name__c;
                    pmt.Sponsor_facing__c = smt.Sponsor_facing__c;
                    pmt.Site_Facing__c = smt.Site_Facing__c;
                    pmt.Study_Milestone__c = pm.Id;
                    pmt.Task_Owner__c = smt.Task_Owner__c;
                    pmt.Apheresis_Shipment__c = smt.Apheresis_Shipment__c;
                    pmt.Drug_Product_Shipment__c = smt.Drug_Product_Shipment__c;
                    pmt.Study_Template_Milestone_Task__c = smt.Id;
                    pmt.Verify__c = smt.Verify__c;
                    pmt.Read_Access_Queues__c = smt.Read_Access_Queues__c;
                    pmt.Write_Access_Queues__c = smt.Write_Access_Queues__c;
                    studyMilestoneTaskList.add(pmt);
                }
           }
        }
        if(!studyMilestoneTaskList.isEmpty()){
            insert studyMilestoneTaskList;
        }
        return studyMilestoneTaskList;
    }

    
    
    public static List<Form__c> createStudyMilestoneTaskForm(List<Study_Milestone_Task__c> studyMilestoneTasks){
        List<Form__c> studyMilestoneTaskFormList = new List<Form__c>();
        Set<Id> milestoneTaskIds = new Set<Id>();
        Map<String , List<Study_Template_Form__c>> studyTemplateMilestoneTaskFormMap = new Map<String, List<Study_Template_Form__c>>();
        
        for(Study_Milestone_Task__c pmt : studyMilestoneTasks){
            milestoneTaskIds.add(pmt.Study_Template_Milestone_Task__c);
        }

        List<Study_Template_Form__c> forms = [SELECT Id, Form_Name__c, Form_Subtitle__c, Form_Title__c, Order__c, Study_Template_Milestone_Task__c FROM Study_Template_Form__c WHERE Study_Template_Milestone_Task__c =:milestoneTaskIds];
        for(Study_Template_Form__c fq : forms){
            if(!studyTemplateMilestoneTaskFormMap.containsKey(fq.Study_Template_Milestone_Task__c)) {
                studyTemplateMilestoneTaskFormMap.put(fq.Study_Template_Milestone_Task__c , new List<Study_Template_Form__c>());
            }
            studyTemplateMilestoneTaskFormMap.get(fq.Study_Template_Milestone_Task__c).add(fq);
        }
        
        for(Study_Milestone_Task__c pmt : studyMilestoneTasks){
           if(studyTemplateMilestoneTaskFormMap.containsKey(pmt.Study_Template_Milestone_Task__c)) {
                List<Study_Template_Form__c> formList = studyTemplateMilestoneTaskFormMap.get(pmt.Study_Template_Milestone_Task__c);
                for(Study_Template_Form__c fq : formList) {
                    Form__c pmtfq = new Form__c();
                    pmtfq.Order__c = fq.Order__c;
                    pmtfq.Form_Name__c = fq.Form_Name__c;
                    pmtfq.Form_Title__c = fq.Form_Title__c;
                    pmtfq.Form_Subtitle__c = fq.Form_Subtitle__c;
                    pmtfq.Study_Template_Form__c = fq.Id;
                    pmtfq.Study_Milestone_Task1__c = pmt.id;
                    studyMilestoneTaskFormList.add(pmtfq);
                }
           }
        }
        if(!studyMilestoneTaskFormList.isEmpty()){
            insert studyMilestoneTaskFormList;
            Map<Id,Study_Milestone_Task__c> studyTemplateMilestoneMap = new Map<Id, Study_Milestone_Task__c>(studyMilestoneTasks);
            for(Form__c f : studyMilestoneTaskFormList){
                if(studyTemplateMilestoneMap.containsKey(f.Study_Milestone_Task1__c)){
                    studyTemplateMilestoneMap.get(f.Study_Milestone_Task1__c).Form__c = f.Id;
                }
            }
            update studyTemplateMilestoneMap.values();
        }

        return studyMilestoneTaskFormList;
    }

    public static List<Form_Section__c> createFormSection(List<Form__c> studyMilestoneTaskFormList){
        List<Form_Section__c> studyMilestoneTaskFormSectionList = new List<Form_Section__c>();
        Set<Id> formSet = new Set<Id>();
        
        Map<String , List<Study_Template_Form_Section__c>> studyMilestoneTaskFormSectionMap = new Map<String, List<Study_Template_Form_Section__c>>();
        for(Form__c f : studyMilestoneTaskFormList){
            formSet.add(f.Study_Template_Form__c);
        }
        List<Study_Template_Form_Section__c> formSections = [SELECT Id, Form_Section_Name__c, Study_Template_Form__c FROM Study_Template_Form_Section__c WHERE Study_Template_Form__c =:formSet];
        for(Study_Template_Form_Section__c fq : formSections){
            if(!studyMilestoneTaskFormSectionMap.containsKey(fq.Study_Template_Form__c)) {
                studyMilestoneTaskFormSectionMap.put(fq.Study_Template_Form__c , new List<Study_Template_Form_Section__c>());
            }
            studyMilestoneTaskFormSectionMap.get(fq.Study_Template_Form__c).add(fq);
        }
        for(Form__c f : studyMilestoneTaskFormList){
           if(studyMilestoneTaskFormSectionMap.containsKey(f.Study_Template_Form__c)) {
                List<Study_Template_Form_Section__c> fqList = studyMilestoneTaskFormSectionMap.get(f.Study_Template_Form__c);
                for(Study_Template_Form_Section__c fq : fqList) {
                    Form_Section__c fs = new Form_Section__c();
                    fs.Name = fq.Form_Section_Name__c;
                    fs.Study_Template_Form_Section__c = fq.Id;
                    fs.Form__c = f.Id;
                    studyMilestoneTaskFormSectionList.add(fs);
                }
           }
        }
        if(!studyMilestoneTaskFormSectionList.isEmpty()){
            insert studyMilestoneTaskFormSectionList;
        }
        return studyMilestoneTaskFormSectionList;
    }
    
    
    public static List<Form_Question__c> createFormQuestion(List<Form_Section__c> studyMilestoneTaskFormSectionList){
        List<Form_Question__c> FormQuestionList = new List<Form_Question__c>();
        Set<Id> formSet = new Set<Id>();
        
        Map<String , List<Study_Template_Form_Question__c>> studyMilestoneTaskFormQuestionMap = new Map<String, List<Study_Template_Form_Question__c>>();
        for(Form_Section__c fs : studyMilestoneTaskFormSectionList){
            formSet.add(fs.Study_Template_Form_Section__c);
        }
        List<Study_Template_Form_Question__c> formQuestions = [SELECT Id,Is_Subject__c, Is_DIN__c,Slot_Booking_Task__c, Active__c,Field_Path__c,Label__c,Order__c,Picklist_Values__c,Read_Only__c,Required__c,Type__c,Visible__c,isManufacturingStatus__c, Study_Template_Form_Section__c FROM Study_Template_Form_Question__c WHERE Study_Template_Form_Section__c =:formSet];
        for(Study_Template_Form_Question__c fq : formQuestions){
            if(!studyMilestoneTaskFormQuestionMap.containsKey(fq.Study_Template_Form_Section__c)) {
                studyMilestoneTaskFormQuestionMap.put(fq.Study_Template_Form_Section__c , new List<Study_Template_Form_Question__c>());
            }
            studyMilestoneTaskFormQuestionMap.get(fq.Study_Template_Form_Section__c).add(fq);
        }
        for(Form_Section__c pmt : studyMilestoneTaskFormSectionList){
           if(studyMilestoneTaskFormQuestionMap.containsKey(pmt.Study_Template_Form_Section__c)) {
                List<Study_Template_Form_Question__c> fqList = studyMilestoneTaskFormQuestionMap.get(pmt.Study_Template_Form_Section__c);
                for(Study_Template_Form_Question__c fq : fqList) {
                    Form_Question__c pmtfq = new Form_Question__c();
                    pmtfq.Active__c = fq.Active__c;
                    pmtfq.Field_Path__c = fq.Field_Path__c;
                    pmtfq.Label__c = fq.Label__c;
                    pmtfq.Order__c = fq.Order__c;
                    pmtfq.Picklist_Values__c = fq.Picklist_Values__c;
                    pmtfq.Read_Only__c = fq.Read_Only__c;
                    pmtfq.Required__c = fq.Required__c;
                    pmtfq.Is_Subject__c = fq.Is_Subject__c;
                    pmtfq.Is_DIN__c = fq.Is_DIN__c;
                    pmtfq.Type__c = fq.Type__c;
                    pmtfq.isManufacturingStatus__c = fq.isManufacturingStatus__c;
                    pmtfq.Visible__c = fq.Visible__c;
                    pmtfq.Slot_Booking_Task__c = fq.Slot_Booking_Task__c;
                    pmtfq.Study_Template_Form_Question__c = fq.Id;
                    pmtfq.Form_Section__c = pmt.id;
                    FormQuestionList.add(pmtfq);
                }
           }
        }
        if(!FormQuestionList.isEmpty()){
            insert FormQuestionList;
        }
        return FormQuestionList;
    }
    
    public static void createStudySiteRecords(List<Study_Protocol__c> newStudies, Map<Id, Study_Protocol__c> oldStudyMap) {
        Set<String> siteNames = new Set<String>();
        Map<Id, Set<String>> studySiteMap = new Map<Id, Set<String>>();
        for (Study_Protocol__c study : newStudies) {
            // Check for insert or if the Site multi-picklist field has changed on update
            if (Trigger.isInsert || 
                (oldStudyMap != null && 
                study.Clinical_Site__c != oldStudyMap.get(study.Id).Clinical_Site__c) && study.Clinical_Site__c!= null) {
                Set<String> selectedSites = new Set<String>(study.Clinical_Site__c.split(';'));
                    System.debug('selectedSites: '+selectedSites);
                siteNames.addAll(selectedSites);
                studySiteMap.put(study.Id, selectedSites);
            }
        }
 
        if (!siteNames.isEmpty()) {
            // Query the Site records that match the selected names
            List<Account> sites = [SELECT Id, Name FROM Account WHERE Name IN :siteNames];
            System.debug('sites: '+sites);
            Map<String, Id> siteNameToIdMap = new Map<String, Id>();
            for (Account site : sites) {
               // String normalizedSiteName = site.Name.replaceAll('\\s+', '_').trim();
                siteNameToIdMap.put(site.Name, site.Id);
            }
 
            // List to hold the new StudySite records to be inserted
            List<Site_Study_Relation__c> studySiteRecords = new List<Site_Study_Relation__c>();
 				System.debug('siteNameToIdMap: '+siteNameToIdMap);
            System.debug('studySiteMap: '+studySiteMap);
            // Loop through the map and create StudySite records
            for (Id studyId : studySiteMap.keySet()) {
                for (String siteName : studySiteMap.get(studyId)) {
                    // Check if the site exists in the Site object
                    
                //    String normalizedSiteName = siteName.replaceAll('\\s+', '_').trim();
                 //   system.debug('normalizedSiteName: '+normalizedSiteName);
                    if (siteNameToIdMap.containsKey(siteName)) {
                        // Create the StudySite record
                        Site_Study_Relation__c newStudySite = new Site_Study_Relation__c(
                            Study_Protocol__c = studyId,
                            Account__c = siteNameToIdMap.get(siteName)
                        );
                        studySiteRecords.add(newStudySite);
                    }
                }
            }
 				system.debug('studySiteRecords: '+studySiteRecords);
            List<Site_Study_Relation__c> siteStudiesToDelete = [select Id,Name,Study_Protocol__c from Site_Study_Relation__c where Study_Protocol__c IN :studySiteMap.keySet() ];
            system.debug('siteStudiesToDelete: '+siteStudiesToDelete);
            if (!siteStudiesToDelete.isEmpty()) {
                delete siteStudiesToDelete;
            }
            // Insert the StudySite records
            if (!studySiteRecords.isEmpty()) {
                insert studySiteRecords;
            }
        }
    }
  }