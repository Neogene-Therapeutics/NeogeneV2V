public with sharing class StudyMilestoneTaskHandler extends TriggerHandler{
    public StudyMilestoneTaskHandler() {
        this.setMaxLoopCount(4);
    }
    public override void afterUpdate(){
        createTaskFormQuestions();
    }
    public void createTaskFormQuestions(){
        List<Study_Milestone_Task__c> studyMilestoneTask = (List<Study_Milestone_Task__c>)Trigger.new;
        Set<Id> formIds = new Set<Id>();

        List<Study_Milestone_Task__c> studyMilestoneTaskList = [SELECT Apheresis_Shipment__c, Drug_Product_Shipment__c, Form__c FROM Study_Milestone_Task__c WHERE Id IN:studyMilestoneTask];
        System.debug(JSON.serialize(studyMilestoneTaskList));
        for(Study_Milestone_Task__c smt : studyMilestoneTaskList){
            if((smt.Apheresis_Shipment__c || smt.Drug_Product_Shipment__c) && smt.Form__c != null){
                formIds.add(smt.Form__c);
            }
        }
        if(!formIds.isEmpty()){
            List<Form_Section__c> formSections = [SELECT Id, Form__c, (SELECT Id, Order__c FROM Form_Questions__r ORDER BY Order__c LIMIT 1) FROM Form_Section__c WHERE Form__c IN : formIds];
            List<Form_Question__c> formQuestions = new List<Form_Question__c>();
            System.debug('formSections=>'+JSON.serialize(formSections));
            for(Form_Section__c fs : formSections){
                Form_Question__c formQues = new Form_Question__c();
                formQues.Label__c = 'Select Courier';
                formQues.Picklist_Values__c = 'BioCair, Manual';
                formQues.Read_Only__c = false;
                formQues.Required__c = false;
                formQues.Type__c = 'Picklist';
                formQues.Visible__c = false;
                formQues.Form_Section__c = fs.Id;
                if(fs.Form_Questions__r.size() > 0){
                    formQues.Order__c = fs.Form_Questions__r[0].Order__c + 1;
                }else{
                    formQues.Order__c = 1;
                }
                formQuestions.add(formQues);
            }
            System.debug(JSON.serialize(formQuestions));
            SecurityCheckController.doInsert(formQuestions);
        }
    }
}