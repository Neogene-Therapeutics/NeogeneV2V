import { LightningElement, wire } from 'lwc';
import getPatientJourneyMilestonesSite from '@salesforce/apex/PatientJourneyController.getPatientJourneyMilestonesSite';
import getTaskSections from '@salesforce/apex/PatientJourneyController.getTaskSections';

export default class Neo_Site_V2VFlow extends LightningElement {
    recordId = 'a0Ndz000000Bdm1EAC';
    milestones = [];
    currentMilestoneTask = [];
    @wire(getPatientJourneyMilestonesSite, { recordId: '$recordId' })
    patientJourneyDetails({ data, error }) {
        if (data) {
            this.milestones = data.map(mile => {
                let classNames = mile.Status__c == 'In Progress' ? 'side-pannel-tab active' : 'side-pannel-tab';
                let divId = `side-${mile.Order__c}`
                return { ...mile, classNames, divId };
            });
            this.getCurrentMilestoneTasks();
        } else if (error) {
            console.log(error);
        }
    }

    async getCurrentMilestoneTasks() {
        let inProgressMilestone = this.milestones.find(milestone => {
            return milestone.Status__c === 'In Progress';
        });
        if (inProgressMilestone) {
            let taskIds = [];
            let patientTasks = inProgressMilestone.Patient_Milestone_Tasks__r.map(task => {
                taskIds.push(task.Id); // Use push instead of spreading
                return task;
            });
            let sectionQuestions = await getTaskSections({ taskIds: taskIds });
            console.log(sectionQuestions);
            this.currentMilestoneTask = patientTasks.map(task => {
                let sections = sectionQuestions.filter(s => {
                    return s.taskId == task.Id;
                })
                return { ...task, sections };
            })
        }
        console.log('Current Milestone Task:', JSON.stringify(this.currentMilestoneTask));
    }

}