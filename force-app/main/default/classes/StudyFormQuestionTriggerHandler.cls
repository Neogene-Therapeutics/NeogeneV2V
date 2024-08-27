public with sharing class StudyFormQuestionTriggerHandler extends TriggerHandler {
    public StudyFormQuestionTriggerHandler() {
        this.setMaxLoopCount(1);
    }
    public override void afterInsert(){
        createTaskFormQuestions();
    }
    public void createTaskFormQuestions(){
        List<Form_Question__c> questions = (List<Form_Question__c>)Trigger.new;
        Set<Id> formIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        List<Form_Question__c> formQuestionsList = [SELECT Form_Section__r.Form__r.Study_Milestone_Task__c FROM Form_Question__c WHERE Id IN : questions];
        for(Form_Question__c ques : formQuestionsList){
            if(ques.Form_Section__r.Form__r.Study_Milestone_Task__c != null){
                taskIds.add(ques.Form_Section__r.Form__r.Study_Milestone_Task__c);
            }
        }
        List<Study_Milestone_Task__c> studyMilestoneTaskList = [SELECT Apheresis_Shipment__c, Drug_Product_Shipment__c, Form__c FROM Study_Milestone_Task__c WHERE Id IN:taskIds];
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
            SecurityCheckController.doInsert(formQuestions);
        }
    }
}