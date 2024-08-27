public with sharing class StudyTemplateMilestoneTaskHandler extends TriggerHandler {
    public StudyTemplateMilestoneTaskHandler() {
        this.setMaxLoopCount(4);
    }
    public override void afterInsert(){
        createTaskFormQuestions();
    }
    public override void afterUpdate(){
        createTaskFormQuestions();
    }
    //SELECT Id, Apheresis_Shipment__c, Drug_Product_Shipment__c, Study_Template_Form__c FROM Study_Template_Milestone_Task__c
    public void createTaskFormQuestions(){
        List<Study_Template_Milestone_Task__c> studyMilestoneTask = (List<Study_Template_Milestone_Task__c>)Trigger.new;
        Set<Id> formIds = new Set<Id>();
        for(Study_Template_Milestone_Task__c smt : studyMilestoneTask){
            if(smt.Apheresis_Shipment__c || smt.Drug_Product_Shipment__c && smt.Study_Template_Form__c != null){
                formIds.add(smt.Study_Template_Form__c);
            }
        }
        if(!formIds.isEmpty()){
            List<Study_Template_Form_Section__c> formSections = [SELECT Id, Study_Template_Form__c, Form_Section_Name__c, (SELECT Id, Order__c FROM Study_Template_Form_Question__r ORDER BY Order__c LIMIT 1) FROM Study_Template_Form_Section__c WHERE Study_Template_Form__c IN : formIds];
            List<Study_Template_Form_Question__c> formQuestions = new List<Study_Template_Form_Question__c>();
            for(Study_Template_Form_Section__c fs : formSections){
                Study_Template_Form_Question__c formQues = new Study_Template_Form_Question__c();
                formQues.Label__c = 'Select Courier';
                formQues.Picklist_Values__c = 'BioCair, Manual';
                formQues.Read_Only__c = false;
                formQues.Required__c = false;
                formQues.Type__c = 'Picklist';
                formQues.Visible__c = false;
                formQues.Study_Template_Form_Section__c = fs.Id;
                if(fs.Study_Template_Form_Question__r.size() > 0){
                    formQues.Order__c = fs.Study_Template_Form_Question__r[0].Order__c + 1;
                }else{
                    formQues.Order__c = 1;
                }
                formQuestions.add(formQues);
            }
            new SecurityCheckController().doInsert(formQuestions);
        }
    }
}