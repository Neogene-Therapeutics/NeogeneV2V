trigger PatientMilestoneTaskFormQuestionTrigger on Patient_Milestone_Task_Form_Question__c (before insert, before update, after insert, after update) {
    new MilestoneTaskFormQuestionTriggerHandler().run();
}