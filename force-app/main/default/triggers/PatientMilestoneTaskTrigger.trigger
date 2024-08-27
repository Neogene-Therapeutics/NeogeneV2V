trigger PatientMilestoneTaskTrigger on Patient_Milestone_Task__c (before insert, before update, after insert, after update) {
    new PatientMilestoneTaskTriggerHandler().run();
}