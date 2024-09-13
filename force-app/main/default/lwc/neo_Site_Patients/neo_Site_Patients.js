import { api,LightningElement, wire, track } from 'lwc';
import getPatientsForProtocol from '@salesforce/apex/PatientController.getPatientsByProtocol';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import messageDemoMC from "@salesforce/messageChannel/MessageChannel__c";
import getPatientJourneyMilestonesSponsor from '@salesforce/apex/PatientJourneyController.getPatientJourneyMilestonesSponsor';
import isReadAccess from '@salesforce/apex/PatientJourneyController.isReadAccess';
import isWriteAccess from '@salesforce/apex/PatientJourneyController.isWriteAccess';
import getCurrentUserInfo from '@salesforce/apex/VerificationUserHandler.getCurrentUserInfo';


export default class Neo_Site_Patients extends LightningElement {
    @track patients = [];
    @api recordId;
    milestoneId='';
    patientMilestoneResults;
    milestoneTaskId='';
    msg = false;
    subscription;
    protocol;
    milestones = [];
    milestoneIds = [];
    milestoneTaskIds = [];
    userInfo=[];

    @wire(MessageContext)
    messageContext;

    @wire(getCurrentUserInfo)
    currentUserInfo({ error, data }) {
        if (data) {
            this.userInfo.username = data?.Username;
            this.userInfo.password = data?.E_sign_Pin__c;
            this.userInfo.profileName = data?.Profile?.Name;
        } else if (error) {
            this.error = error;
        }
    }
    @wire(getPatientJourneyMilestonesSponsor, { recordId: '$recordId', userInfo: '$userInfo' })
    async wirePatientMilestones(result) {
        this.patientMilestoneResults = result;
        if (result.data) {
            let count = 0;
            this.milestoneTaskIds = [];
            this.milestones = result.data.map(d => {
                let { Id, Name, Patient_Journey__c, Status__c, Order__c, Patient_Milestone_Tasks__r } = d;
                count++;
                this.milestoneIds = [...this.milestoneIds, Id];
                let milestoneId = `/${Id}`;
                let classNames = '';
                if (Status__c == 'In Progress') {
                    classNames = 'slds-progress__item slds-is-active tooltip_con';
                } else if (Status__c == 'Completed') {
                    classNames = 'slds-progress__item completed tooltip_con';
                } else {
                    classNames = 'slds-progress__item tooltip_con';
                }
                let showEndLine = !(count === result.data.length);
                let hasMilestoneTasks = !!Patient_Milestone_Tasks__r?.length;
                let patientMilestoneTasks = [];
                if (hasMilestoneTasks) {
                    patientMilestoneTasks = Patient_Milestone_Tasks__r.map(task => {
                        this.milestoneTaskIds = [...this.milestoneTaskIds, task.Id];
                        let milestoneTaskId = `/${task.Id}`;
                        let hasVerifiedUser = false;
                        let verifyUserName = '';
                        let hasVerifiedUserId = '';
                        if (task.Verify_By__r) {
                            hasVerifiedUser = true;
                            hasVerifiedUserId = `/${task.Verify_By__r.Id}`;
                            verifyUserName = task.Verify_By__r.Name;
                        }
                        let showVerify = task.Status__c == 'Completed' && (task.Verify__c && ((task.Owner.Profile.Name == 'System Administrator') || (task.Owner.Profile.Name == this.userInfo.profileName && task.LastModifiedById != userId)));
                        return { ...task, milestoneTaskId, showVerify, hasVerifiedUser, verifyUserName, hasVerifiedUserId }
                    });
                }
                return { Id, count, classNames, Name, Status__c, milestoneId, showEndLine, Patient_Journey__c, hasMilestoneTasks, Order__c, patientMilestoneTasks };
            });

            let milestonesReadMap = await isReadAccessForMilestone({ recordIds: this.milestoneIds });
            let milestoneWriteMap = await isWriteAccessForMilestone({ recordIds: this.milestoneIds });

            let taskReadAccessMap = await isReadAccess({ recordIds: this.milestoneTaskIds });
            let taskWriteAccessMap = await isWriteAccess({ recordIds: this.milestoneTaskIds });

            this.milestones = this.milestones.map(mile => {
                const milestoneHasReadAccess = milestonesReadMap[mile.Id];
                const milestoneHasWriteAccess = milestoneWriteMap[mile.Id];

                if (mile.patientMilestoneTasks) {
                    mile.patientMilestoneTasks = mile.patientMilestoneTasks.map(task => {
                        const taskHasReadAccess = taskReadAccessMap[task.Id];
                        const taskHasWriteAccess = taskWriteAccessMap[task.Id];

                        const hasWriteAccess = milestoneHasWriteAccess && (taskHasReadAccess || taskHasWriteAccess);
                        const isTaskReadOnly = !milestoneHasWriteAccess;
                        task.isComplete = (task.Status__c == 'Completed');
                        task.submittedById = '/' + task.LastModifiedBy.Id;
                        task.taskStatusButton = isTaskReadOnly || task.Status__c !== 'In Progress';

                        task.isManualShipment = (task.Drug_Product_Shipment__c || task.Apheresis_Shipment__c) && task?.Courier__c == 'Manual' && task.Status__c == 'Completed';

                        if (task.Patient_Milestone_Task_Form_Questions__r) {
                            task.Patient_Milestone_Task_Form_Questions__r = task.Patient_Milestone_Task_Form_Questions__r.map(ques => {
                                // Apply read-only logic to task form questions
                                const formQuestionReadOnly = isTaskReadOnly || task.Status__c !== 'In Progress' || !taskHasWriteAccess || ques.Read_Only__c;

                                if (ques.Type__c === 'Picklist') {
                                    let picklistArray = [];
                                    if (ques.Picklist_Values__c) {
                                        picklistArray = ques.Picklist_Values__c.split(', ').map(value => ({
                                            value: value,
                                            label: value
                                        }));
                                    }
                                    return {
                                        ...ques,
                                        Read_Only__c: formQuestionReadOnly,
                                        picklistArray,
                                        isInput: false,
                                        isPicklist: true,
                                        readableTask: taskHasReadAccess || taskHasWriteAccess,
                                        isTextarea: false
                                    };
                                } else if (ques.Type__c === 'Textarea') {
                                    return {
                                        ...ques,
                                        isInput: false,
                                        Read_Only__c: formQuestionReadOnly || !hasWriteAccess,
                                        isPicklist: false,
                                        readableTask: taskHasReadAccess || taskHasWriteAccess,
                                        isTextarea: true,
                                        isFile: false
                                    };
                                } else if (ques.Type__c === 'Checkbox') {
                                    return {
                                        ...ques,
                                        Value__c: ques.Value__c === 'true',
                                        readableTask: taskHasReadAccess || taskHasWriteAccess,
                                        Read_Only__c: formQuestionReadOnly || !hasWriteAccess,
                                        isInput: true,
                                        isPicklist: false,
                                        isTextarea: false,
                                        isFile: false
                                    };
                                } else if (ques.Type__c === 'File') {
                                    return {
                                        ...ques,
                                        isInput: false,
                                        Read_Only__c: formQuestionReadOnly || !hasWriteAccess,
                                        isPicklist: false,
                                        isTextarea: false,
                                        readableTask: taskHasReadAccess || taskHasWriteAccess,
                                        isFile: true
                                    };
                                } else {
                                    return {
                                        ...ques,
                                        isInput: true,
                                        Read_Only__c: formQuestionReadOnly || !hasWriteAccess,
                                        isPicklist: false,
                                        isTextarea: false,
                                        readableTask: taskHasReadAccess || taskHasWriteAccess,
                                        isFile: false
                                    };
                                }
                            });
                        }

                        return task;
                    });
                }
                return mile;
            });
            let formSections = await getFormSectionByPatientMilestoneTaskIds({ milestoneTaskIds: this.milestoneTaskIds });
            this.milestones = this.milestones.map(mile => {
                if (mile.patientMilestoneTasks.length > 0) {
                    mile.patientMilestoneTasks.forEach(task => {
                        let sections = formSections.filter(form => task.Id === form.mileTaskId);
                        task.sections = sections[0];
                    });
                }
                return { ...mile };
            });
            this.isLoading = false;
            count = 0;
            this.milestones = this.milestones.filter(mile => {
                if (milestonesReadMap[mile.Id] || milestoneWriteMap[mile.Id]) {
                    count++;
                    mile.count = count;
                    return { ...mile };
                }
            })
            console.log(JSON.stringify(this.milestones));

        } else if (result.error) {
            console.error('Error:', result.error);
            this.isLoading = false;
        }
    }

    get showMiletones() {
        return this.milestones.length > 0;
    }

    connectedCallback() {
        console.log('neo_site_patient connectedCallback fired');
        this.subscribeToMessageChannel(); // Subscribe to the message channel
        this.protocol = sessionStorage.getItem('selectedProtocol'); // Retrieve from sessionStorage
        if (this.protocol) {
            console.log('Loaded protocol from sessionStorage:', this.protocol);
            this.loadPatients();
        } else {
            console.log('No protocol found in sessionStorage.');
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel(); // Unsubscribe when the component is destroyed
    }

    subscribeToMessageChannel() {
        console.log('Subscribing to message channel in neo_site_patient');
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                messageDemoMC,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
            console.log('Subscription successful:', this.subscription);
        } else {
            console.log('Already subscribed:', this.subscription);
        }
    }

   /* handleMessage(message) {
        this.msg = message.msg;
        this.protocol = message.protocol || sessionStorage.getItem('selectedProtocol');
        console.log('Message received in neo_site_patient:', this.protocol);
    
        if (this.protocol) {
            this.loadPatients();
        } else {
            console.warn('No protocol available.');
        }
    }*/

    loadPatients() {
        if (this.protocol) {
            getPatientsForProtocol({ protocolId: this.protocol })
                .then((result) => {
                    this.patients = result;
                    console.log('Patients loaded:', JSON.stringify(this.patients));
                })
                .catch((error) => {
                    console.error('Error fetching patients:', error);
                });
        } else {
            console.warn('No protocol selected');
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}