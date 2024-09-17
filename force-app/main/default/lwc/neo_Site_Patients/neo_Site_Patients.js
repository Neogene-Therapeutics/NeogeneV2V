import { api,LightningElement, wire, track } from 'lwc';
import getPatientsForProtocol from '@salesforce/apex/PatientController.getPatientsByProtocol';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import messageDemoMC from "@salesforce/messageChannel/MessageChannel__c";
import getPatientJourneyMilestonesLst from '@salesforce/apex/PatientJourneyController.getPatientJourneyMilestonesLst';
import isReadAccess from '@salesforce/apex/PatientJourneyController.isReadAccess';
import isWriteAccess from '@salesforce/apex/PatientJourneyController.isWriteAccess';
import getCurrentUserInfo from '@salesforce/apex/VerificationUserHandler.getCurrentUserInfo';
import isReadAccessForMilestone from '@salesforce/apex/PatientJourneyController.isReadAccessForMilestone';
import isWriteAccessForMilestone from '@salesforce/apex/PatientJourneyController.isWriteAccessForMilestone';
import getFormSectionByPatientMilestoneTaskIds from '@salesforce/apex/PatientJourneyController.getFormSectionByPatientMilestoneTaskIds';




export default class Neo_Site_Patients extends LightningElement {
    @track patients = [];
   // @api recordIds = []; // Changed to an array of patient recordIds
    milestonesData = {}; //
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
    @track patientsWithMilestones = []; // Array to hold patients with their milestones
    @track recordIds = []; // Array to hold the patient IDs (should be populated based on your context)

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
    // @wire(getPatientJourneyMilestonesSponsor, { recordId: '$recordId', userInfo: '$userInfo' })
    // async wirePatientMilestones(result) {
    //     console.log('milecheck', result.data);
    //     this.patientMilestoneResults = result;
    //     if (result.data) {
    //         let count = 0;
    //         this.milestoneTaskIds = [];
    //         this.milestones = result.data.map(d => {
    //             let { Id, Name, Patient_Journey__c, Status__c, Order__c, Patient_Milestone_Tasks__r } = d;
    //             count++;
    //             this.milestoneIds = [...this.milestoneIds, Id];
    //             let milestoneId = `/${Id}`;
    //             let classNames = '';
    //             if (Status__c == 'In Progress') {
    //                 classNames = 'slds-progress__item slds-is-active tooltip_con';
    //             } else if (Status__c == 'Completed') {
    //                 classNames = 'slds-progress__item completed tooltip_con';
    //             } else {
    //                 classNames = 'slds-progress__item tooltip_con';
    //             }
    //             let showEndLine = !(count === result.data.length);
    //             let hasMilestoneTasks = !!Patient_Milestone_Tasks__r?.length;
    //             let patientMilestoneTasks = [];
    //             if (hasMilestoneTasks) {
    //                 patientMilestoneTasks = Patient_Milestone_Tasks__r.map(task => {
    //                     this.milestoneTaskIds = [...this.milestoneTaskIds, task.Id];
    //                     let milestoneTaskId = `/${task.Id}`;
    //                     let hasVerifiedUser = false;
    //                     let verifyUserName = '';
    //                     let hasVerifiedUserId = '';
    //                     if (task.Verify_By__r) {
    //                         hasVerifiedUser = true;
    //                         hasVerifiedUserId = `/${task.Verify_By__r.Id}`;
    //                         verifyUserName = task.Verify_By__r.Name;
    //                     }
    //                     let showVerify = task.Status__c == 'Completed' && (task.Verify__c && ((task.Owner.Profile.Name == 'System Administrator') || (task.Owner.Profile.Name == this.userInfo.profileName && task.LastModifiedById != userId)));
    //                     return { ...task, milestoneTaskId, showVerify, hasVerifiedUser, verifyUserName, hasVerifiedUserId }
    //                 });
    //             }
    //             return { Id, count, classNames, Name, Status__c, milestoneId, showEndLine, Patient_Journey__c, hasMilestoneTasks, Order__c, patientMilestoneTasks };
    //         });

    //         let milestonesReadMap = await isReadAccessForMilestone({ recordIds: this.milestoneIds });
    //         let milestoneWriteMap = await isWriteAccessForMilestone({ recordIds: this.milestoneIds });

    //         let taskReadAccessMap = await isReadAccess({ recordIds: this.milestoneTaskIds });
    //         let taskWriteAccessMap = await isWriteAccess({ recordIds: this.milestoneTaskIds });

    //         this.milestones = this.milestones.map(mile => {
    //             const milestoneHasReadAccess = milestonesReadMap[mile.Id];
    //             const milestoneHasWriteAccess = milestoneWriteMap[mile.Id];

    //             return mile;
    //         });
    //         this.milestones = this.milestones.filter(mile => {
    //             if (milestonesReadMap[mile.Id] || milestoneWriteMap[mile.Id]) {
    //                 count++;
    //                 mile.count = count;
    //                 return { ...mile };
    //             }
    //         })
    //         console.log('mile',JSON.stringify(this.milestones));

    //     } else if (result.error) {
    //         console.error('Error:', result.error);
    //         this.isLoading = false;
    //     }
    // }

    /*@wire(getPatientJourneyMilestonesLst, { patientIds: '$recordIds', userInfo: '$userInfo' })
    async wirePatientMilestones(result) {
        console.log('Record IDs passed to Apex:', JSON.stringify(this.recordIds)); // Log the recordIds before calling Apex
        if (result.data) {
            console.log('result',JSON.stringify(result.data));
            this.milestoneTaskIds = [];
            const milestonesByPatient = {};

            // Iterate through each patient's milestones
            for (const patient of result.data) {
                let patientId = patient.Id;
                let count = 0;
                let milestones = patient.Milestones__r.map(d => {
                    let { Id, Name, Patient_Journey__c, Status__c, Order__c, Patient_Milestone_Tasks__r } = d;
                    count++;
                    let milestoneId = `/${Id}`;
                    let classNames = this.getMilestoneClassNames(Status__c);
                    let showEndLine = !(count === patient.Milestones__r.length);
                    let hasMilestoneTasks = !!Patient_Milestone_Tasks__r?.length;
                    let patientMilestoneTasks = this.processMilestoneTasks(Patient_Milestone_Tasks__r, patientId);

                    return { Id, count, classNames, Name, Status__c, milestoneId, showEndLine, Patient_Journey__c, hasMilestoneTasks, Order__c, patientMilestoneTasks };
                });

                let milestonesReadMap = await isReadAccessForMilestone({ recordIds: milestones.map(m => m.Id) });
                let milestoneWriteMap = await isWriteAccessForMilestone({ recordIds: milestones.map(m => m.Id) });

                milestones = milestones.filter(mile => milestonesReadMap[mile.Id] || milestoneWriteMap[mile.Id]);

                milestonesByPatient[patientId] = milestones;
            }

            this.milestonesData = milestonesByPatient;
            console.log('Milestones for multiple patients:', JSON.stringify(this.milestonesData));

        } else if (result.error) {
            console.error('Error:', result.error);
            this.isLoading = false;
        }
    }*/
        // @wire(getPatientJourneyMilestonesLst, { patientIds: '$recordIds' })
        // async wirePatientMilestones(result) {
        //     if (result.data) {
        //         console.log('Milestones data:', JSON.stringify(result.data));
        
        //         this.patientsWithMilestones = result.data.map(patientWrapper => {
        //             return {
        //                 patientId: patientWrapper.patientId,
        //                 milestones: patientWrapper.milestones,
        //                 currentMilestone: patientWrapper.currentMilestone
        //             };
        //         });
        //     } else if (result.error) {
        //         console.error('Error fetching milestones:', result.error);
        //     }
        // }
        
//         
@wire(getPatientJourneyMilestonesLst, { patientIds: '$recordIds' })
async wirePatientMilestones(result) {
    if (result.data) {
        console.log('Milestones data received:', JSON.stringify(result.data));

        // Process the result to achieve the same functionality as before
        this.patientsWithMilestones = result.data.map(patientWrapper => {
            console.log(`Processing patient: ${patientWrapper.patientId}`);
            
            // Create a unique set of milestones for the patient
            let uniqueMilestones = [];
            let milestoneNamesSet = new Set(); // To ensure unique milestone names

            patientWrapper.milestones.forEach(milestone => {
                // Log milestone being processed
                console.log(`Processing milestone: ${milestone.Name} for patient: ${patientWrapper.patientId}`);
                // Check if milestone name already exists in the Set
                if (!milestoneNamesSet.has(milestone.Name)) {
                    uniqueMilestones.push({
                        id: milestone.Id,
                        name: milestone.Name,
                        status: milestone.Status__c,
                        order: milestone.Order__c,
                        isCurrent: false // Will set this later
                    });
                    // Add the milestone name to the Set
                    milestoneNamesSet.add(milestone.Name);
                } else {
                    console.log(`Duplicate milestone found: ${milestone.Name} for patient: ${patientWrapper.patientId}`);
                }
            });

            // Identify the current milestone, if any, and mark it
            if (patientWrapper.currentMilestone) {
                let currentMilestoneId = patientWrapper.currentMilestone.Id;
                console.log(`Current milestone ID: ${currentMilestoneId} for patient: ${patientWrapper.patientId}`);

                uniqueMilestones = uniqueMilestones.map(milestone => {
                    return {
                        ...milestone,
                        isCurrent: milestone.id === currentMilestoneId // Set isCurrent to true if this is the current milestone
                    };
                });
            } else {
                console.log(`No current milestone for patient: ${patientWrapper.patientId}`);
            }

            // Log the unique milestones found for the patient
            console.log(`Unique milestones for patient ${patientWrapper.patientId}:`, JSON.stringify(uniqueMilestones));

            // Return the processed patient data with unique milestones and the current milestone
            return {
                patientId: patientWrapper.patientId,
                name:patientWrapper.name,
                subjectID: patientWrapper.subjectID,
                yearOfBirth: patientWrapper.yearOfBirth,
                status: patientWrapper.status,
                milestones: uniqueMilestones,
                currentMilestone: uniqueMilestones.find(milestone => milestone.isCurrent) || null // Find the current milestone if marked
            };
        });

        console.log('Processed patients with milestones:', JSON.stringify(this.patientsWithMilestones));
    } else if (result.error) {
        console.error('Error fetching milestones:', result.error);
    }
}



    getMilestoneClassNames(status) {
        if (status === 'In Progress') {
            return 'slds-progress__item slds-is-active tooltip_con';
        } else if (status === 'Completed') {
            return 'slds-progress__item completed tooltip_con';
        }
        return 'slds-progress__item tooltip_con';
    }
    shouldShowVerify(task, patientId) {
        return task.Status__c === 'Completed' && task.Verify__c && (task.Owner.Profile.Name === 'System Administrator' || (task.Owner.Profile.Name === this.userInfo.profileName && task.LastModifiedById !== patientId));
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

    /*loadPatients() {
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
    }*/
        loadPatients() {
            if (this.protocol) {
                getPatientsForProtocol({ protocolId: this.protocol })
                    .then((result) => {
                        this.patients = result;
                        this.recordIds = this.patients.map(p => p.Id); // Set multiple recordIds
                        console.log('Patients loaded:', JSON.stringify(this.patients));
                        console.log('Patients loaded:', JSON.stringify(this.recordIds));
                    })
                    .catch((error) => {
                        console.error('Error fetching patients:', error);
                    });
            }
        }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}