import { LightningElement, api, wire, track } from 'lwc';
import getMilestonesAndTasks from '@salesforce/apex/PatientJourneyController.getMilestonesAndTasks';

export default class PatientJourneyComponent extends LightningElement {
    @api recordId;
    @track milestones;
    @track error;
    @track progressValue = 0;
    @track completedMilestones = [];
    @track pendingMilestones = [];
    @track currentMilestone = '';

    @wire(getMilestonesAndTasks, { recordId: '$recordId' })
    wiredMilestonesAndTasks({ error, data }) {
        if (data) {
            this.milestones = data.map(milestoneWrapper => {
                return {
                    ...milestoneWrapper,
                    milestone: {
                        ...milestoneWrapper.milestone,
                        statusClass: this.getStatusClass(milestoneWrapper.milestone.Status__c)
                    },
                    tasks: milestoneWrapper.tasks.map(taskWrapper => {
                        return {
                            ...taskWrapper,
                            task: {
                                ...taskWrapper.task,
                                statusClass: this.getStatusClass(taskWrapper.task.Status__c)
                            }
                        };
                    })
                };
            });
            this.error = undefined;
            this.calculateProgress();
        } else if (error) {
            this.error = error;
            this.milestones = undefined;
            this.progressValue = 0;
            this.completedMilestones = [];
            this.pendingMilestones = [];
            this.currentMilestone = '';
        }
    }

    getStatusClass(status) {
        switch (status.toLowerCase()) {
            case 'in-progress':
            case 'active':
                return 'status-in-progress';
            case 'completed':
                return 'status-completed';
            default:
                return 'status-not-started';
        }
    }

    calculateProgress() {
        if (this.milestones && this.milestones.length > 0) {
            this.completedMilestones = [];
            this.pendingMilestones = [];
            let completedCount = 0;
            let currentFound = false;

            this.milestones.forEach(m => {
                const status = m.milestone.Status__c.toLowerCase();
                if (status === 'completed') {
                    completedCount++;
                    this.completedMilestones.push(m.milestone.Name);
                } else {
                    this.pendingMilestones.push(m.milestone.Name);
                    if (!currentFound && (status === 'in-progress' || status === 'active')) {
                        this.currentMilestone = m.milestone.Name;
                        currentFound = true;
                    }
                }
            });

            this.progressValue = (completedCount / this.milestones.length) * 100;

            // If no in-progress milestone found, set current to the first pending milestone
            if (!currentFound && this.pendingMilestones.length > 0) {
                this.currentMilestone = this.pendingMilestones[0];
            }
        } else {
            this.progressValue = 0;
            this.completedMilestones = [];
            this.pendingMilestones = [];
            this.currentMilestone = '';
        }
    }
}