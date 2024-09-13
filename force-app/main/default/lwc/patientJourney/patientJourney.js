import { LightningElement, wire, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import SHIPMENT from "@salesforce/schema/Shipment__c";
import VALUE_FIELD from "@salesforce/schema/Patient_Milestone_Task_Form_Question__c.Value__c";
import ID_FIELD from "@salesforce/schema/Patient_Milestone_Task_Form_Question__c.Id";
import READ_ONLY_FIELD from "@salesforce/schema/Patient_Milestone_Task_Form_Question__c.Read_Only__c";
import MILESTONE_TASK_FIELD from "@salesforce/schema/Patient_Milestone_Task_Form_Question__c.Patient_Milestone_Task__c";
import getCurrentUserInfo from '@salesforce/apex/VerificationUserHandler.getCurrentUserInfo';
import getPatientJourneyMilestonesSponsor from '@salesforce/apex/PatientJourneyController.getPatientJourneyMilestonesSponsor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import userId from '@salesforce/user/Id';
import getFormSectionByPatientMilestoneTaskIds from '@salesforce/apex/PatientJourneyController.getFormSectionByPatientMilestoneTaskIds';
import getShipmentDetails from '@salesforce/apex/PatientJourneyController.getShipmentDetails';
import fileValidate from '@salesforce/apex/PatientJourneyController.fileValidate';
import LightningConfirm from 'lightning/confirm';
import isReadAccess from '@salesforce/apex/PatientJourneyController.isReadAccess';
import isWriteAccess from '@salesforce/apex/PatientJourneyController.isWriteAccess';
import uploadFile from '@salesforce/apex/PatientJourneyController.uploadFile';
import isReadAccessForMilestone from '@salesforce/apex/PatientJourneyController.isReadAccessForMilestone';
import isWriteAccessForMilestone from '@salesforce/apex/PatientJourneyController.isWriteAccessForMilestone';

export default class PatientJourney extends LightningElement {
    @api recordId;
    milestoneId = '';
    milestoneTaskId = '';
    valueField = VALUE_FIELD.fieldApiName;
    shipmentObject = SHIPMENT.objectApiName;
    milestones = [];
    milestoneIds = [];
    milestoneTaskIds = [];
    patientMilestoneResults;
    updateTaskQuestions = [];
    userInfo = {};
    showShipmentCreateModal = false;
    verifyTaskId = '';
    showModalVerify = false;
    pickupAddress = {};
    dropoffAddress = {};
    isLoading = true;
    manualShipmentRecordTypeId;
    files = [];
    selectedFileName = '';


    @wire(getObjectInfo, { objectApiName: SHIPMENT })
    wireShipmentData({ data, error }) {
        if (data) {
            let recordTypeInfo = data?.recordTypeInfos;
            this.manualShipmentRecordTypeId = Object.keys(recordTypeInfo).find(rtype => (recordTypeInfo[rtype].name === 'Manual'));
        } else if (error) {
            console.error(error);
        }
    }

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

    inputChangeHandler(event) {
        let taskQuestionId = event.target.dataset.taskQuestionId;
        let mileTaskId = event.target.dataset.mileTaskId;
        let fieldName = event.target.name;
        let selectedQues = this.updateTaskQuestions.find(ques => {
            return ques[ID_FIELD.fieldApiName] == taskQuestionId;
        })
        if (!selectedQues) {
            selectedQues = {};
            selectedQues[ID_FIELD.fieldApiName] = taskQuestionId;
            selectedQues[MILESTONE_TASK_FIELD.fieldApiName] = mileTaskId;
            this.updateTaskQuestions = [...this.updateTaskQuestions, selectedQues];
        }
        if (event.target.type == 'checkbox') {
            selectedQues[fieldName] = event.target.checked.toString();
        } else {
            selectedQues[fieldName] = event.target.value;
        }
    }

    async saveTaskHandler(event) {
        this.isLoading = true;
        let mileTaskId = event.target.dataset.milestoneTaskId;
        let inputFields = [...this.template.querySelectorAll(`[data-mile-task-id="${mileTaskId}"]`)];
        if (inputFields.length > 0) {
            let isValid = inputFields.reduce((validSoFar, inputCmp) => {
                if (inputCmp.type == 'file') {
                    let milestoneTask = this.milestones.find(mile => {
                        return mile.patientMilestoneTasks.find(task => {
                            return task.Id == mileTaskId;
                        })
                    })
                    if (milestoneTask) {
                        let selectedMileTask = milestoneTask.patientMilestoneTasks.find(taskQues => {
                            return taskQues?.Patient_Milestone_Task_Form_Questions__r?.find(pmtfq => {
                                return pmtfq.Id == inputCmp.dataset.taskQuestionId;
                            })
                        })
                        if (selectedMileTask) {
                            let selectedFileQues = selectedMileTask?.Patient_Milestone_Task_Form_Questions__r.find(taskQues => {
                                return taskQues.Id == inputCmp.dataset.taskQuestionId;
                            })
                            if (selectedFileQues) {
                                if (!(selectedFileQues?.ContentDocumentLinks?.length > 0)) {
                                    inputCmp.reportValidity();
                                    return validSoFar && inputCmp.checkValidity();
                                }
                                return true;
                            }
                        }
                    }
                    return true;
                }
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (!isValid) {
                this.showToastMessage('Required Fields Missing', 'Fill all the required fields.', 'error');
                this.isLoading = false;
                return;
            }
            let milestoneTaskUpdates = this.updateTaskQuestions.filter((ques) => {
                return ques[MILESTONE_TASK_FIELD.fieldApiName] === mileTaskId;
            })
            let recordUpdates = milestoneTaskUpdates.map((recordInput) => {
                delete recordInput[MILESTONE_TASK_FIELD.fieldApiName];
                return { fields: recordInput };
            })
            let promiseToResolve = recordUpdates.map(rec => {
                return updateRecord(rec);
            })

            let quesFileList = this.files.filter(f => {
                return f.mileTaskId == mileTaskId;
            })
            if (quesFileList.length > 0) {
                let uploadedFiles = quesFileList.map(async (f) => {
                    return uploadFile({ base64: f.fileData.base64, filename: f.fileData.filename, recordId: f.fileData.recordId, patientJourneyId: this.recordId });
                })
                await Promise.all(uploadedFiles);
            }

            await Promise.all(promiseToResolve);

            await refreshApex(this.patientMilestoneResults);
            this.updateTaskQuestions = [];
            this.showToastMessage('Success', 'Patient Milestone task form questions updated successfully', 'success');
        }
        this.isLoading = false;
    }

    async markAsCompleteHandler(event) {
        try {
            this.isLoading = true;
            let milestoneTaskId = event.target.dataset.milestoneTaskId;
            let inputFields = [...this.template.querySelectorAll(`[data-mile-task-id="${milestoneTaskId}"]`)];
            if (inputFields.length > 0) {
                let isValid = inputFields?.reduce((validSoFar, inputCmp) => {
                    if (inputCmp.type == 'file') {
                        let milestoneTask = this.milestones.find(mile => {
                            return mile.patientMilestoneTasks.find(task => {
                                return task.Id == milestoneTaskId;
                            })
                        })
                        if (milestoneTask) {
                            let selectedMileTask = milestoneTask.patientMilestoneTasks.find(taskQues => {
                                return taskQues?.Patient_Milestone_Task_Form_Questions__r?.find(pmtfq => {
                                    return pmtfq.Id == inputCmp.dataset.taskQuestionId;
                                })
                            })
                            if (selectedMileTask) {
                                let selectedFileQues = selectedMileTask?.Patient_Milestone_Task_Form_Questions__r.find(taskQues => {
                                    return taskQues.Id == inputCmp.dataset.taskQuestionId;
                                })
                                if (selectedFileQues) {
                                    if (!(selectedFileQues?.ContentDocumentLinks?.length > 0)) {
                                        inputCmp.reportValidity();
                                        return validSoFar && inputCmp.checkValidity();
                                    }
                                    return true;
                                }
                            }
                        }
                        return false;
                    }
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
                if (!isValid) {
                    this.showToastMessage('Required Fields Missing', 'Fill all the required fields.', 'error');
                    this.isLoading = false;
                    return;
                }
            }

            let mileTaskFormQues = this.milestones?.find(mile => {
                return mile?.patientMilestoneTasks?.find(task => {
                    return task.Id === milestoneTaskId;
                })
            })
            if (mileTaskFormQues) {
                let patientTask = mileTaskFormQues.patientMilestoneTasks.find(task => {
                    return task.Id === milestoneTaskId;
                })
                if (patientTask.Patient_Milestone_Task_Form_Questions__r) {
                    let formQuestionsMap = patientTask?.Patient_Milestone_Task_Form_Questions__r?.map(ques => {
                        let fields = {};
                        fields[ID_FIELD.fieldApiName] = ques.Id;
                        fields[READ_ONLY_FIELD.fieldApiName] = true;
                        if (inputFields.length > 0) {
                            let quesInput = inputFields.find(input => input.dataset.taskQuestionId == ques.Id);
                            if (quesInput) {
                                fields[VALUE_FIELD.fieldApiName] = quesInput.type == 'checkbox' ? quesInput?.checked.toString() : quesInput?.value;
                            }
                        } else {
                            fields[VALUE_FIELD.fieldApiName] = ques?.Value__c;
                        }
                        return { fields };
                    })

                    let promiseToResolve = formQuestionsMap?.map(rec => {
                        return updateRecord(rec);
                    })
                    await Promise.all(promiseToResolve);
                    let quesFileList = this.files.filter(f => {
                        return f.mileTaskId == milestoneTaskId;
                    })
                    if (quesFileList.length > 0) {
                        let uploadedFiles = quesFileList.map((f) => {
                            return uploadFile({ base64: f.fileData.base64, filename: f.fileData.filename, recordId: f.fileData.recordId, patientJourneyId: this.recordId });
                        })
                        await Promise.all(uploadedFiles);
                    }
                }
                let updatePatientTaskStatus = {};
                updatePatientTaskStatus.Id = patientTask.Id;
                updatePatientTaskStatus.Status__c = 'Completed';
                await updateRecord({ fields: updatePatientTaskStatus });
                await refreshApex(this.patientMilestoneResults);
                this.showToastMessage('Completed', `${patientTask.Name} Task is completed.`, 'success');
            }
            this.isLoading = false;
        } catch (error) {
            console.log(error);
            console.error(error);
            this.showToastMessage('Error', error?.body?.message, 'error');
        }
        finally {
            this.isLoading = false;
        }
    }

    showToastMessage(title, message, variant) {
        let evt = new ShowToastEvent({
            title,
            message,
            variant,
        })
        this.dispatchEvent(evt);
    }

    async verifyHandler(event) {
        this.showModalVerify = false;
        let updatePatientTaskVerify = {};
        updatePatientTaskVerify.Id = event.detail.taskId;
        updatePatientTaskVerify.Verify_By__c = userId;
        updatePatientTaskVerify.Comment__c = event.detail.comment;
        await updateRecord({ fields: updatePatientTaskVerify });
        await refreshApex(this.patientMilestoneResults);
    }

    verifyShowHandler(event) {
        this.verifyTaskId = event.target.dataset.milestoneTaskId;
        this.showModalVerify = true;
    }

    closeHandler() {
        this.showModalVerify = false;
    }

    closeShipmentCreate() {
        this.showShipmentCreateModal = false;
    }

    async submitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        const inputFields = [...this.template.querySelectorAll('lightning-input-field')];
        let isValid = true;
        inputFields.forEach(inputField => {
            if (!inputField.reportValidity()) {
                isValid = false;
            }
        });
        if (isValid) {
            let mileTaskFormQues = this.milestones?.find(mile => {
                return mile?.patientMilestoneTasks?.find(task => {
                    return task.Id === this.milestoneTaskId;
                })
            })
            let patientTask = mileTaskFormQues.patientMilestoneTasks.find(task => {
                return task.Id === this.milestoneTaskId;
            })
            if (patientTask?.Apheresis_Shipment__c == true) {
                fields.Type__c = 'Apheresis';
            } else if (patientTask?.Drug_Product_Shipment__c == true) {
                fields.Type__c = 'Drug Product';
            }
            fields.Pickup_Address__Street__s = this.pickupAddress.street;
            fields.Pickup_Address__City__s = this.pickupAddress.city;
            fields.Pickup_Address__StateCode__s = this.pickupAddress.state;
            fields.Pickup_Address__CountryCode__s = this.pickupAddress.country;
            fields.Pickup_Address__PostalCode__s = this.pickupAddress.postalCode;
            fields.Dropoff_Address__Street__s = this.dropoffAddress.street;
            fields.Dropoff_Address__City__s = this.dropoffAddress.city;
            fields.Dropoff_Address__StateCode__s = this.dropoffAddress.state;
            fields.Dropoff_Address__CountryCode__s = this.dropoffAddress.country;
            fields.Dropoff_Address__PostalCode__s = this.dropoffAddress.postalCode;
            fields.Patient_Milestone__c = this.milestoneId;
            fields.RecordTypeId = this.manualShipmentRecordTypeId;
            fields.Patient_Journey__c = this.recordId;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleError(event) {
        let errorMessage = event.detail;
        console.log("errorMessage : " + JSON.stringify(errorMessage));
    }

    async successHandler() {
        this.isLoading = true;
        this.showShipmentCreateModal = false;
        await refreshApex(this.patientMilestoneResults);
        this.isLoading = false;
        this.showToastMessage('Shipment is created', '', 'success')
    }

    async createShipment(event) {
        this.milestoneId = event.target.dataset.milestoneId;
        this.milestoneTaskId = event.target.dataset.milestoneTaskId;

        let response = await getShipmentDetails({ milestoneId: this.milestoneId });
        this.pickupAddress.consignor = response?.aphresisAccount?.Person_to_contact__c;
        this.pickupAddress.street = response?.aphresisAccount?.BillingStreet;
        this.pickupAddress.city = response?.aphresisAccount?.BillingCity;
        this.pickupAddress.state = response?.aphresisAccount?.BillingState;
        this.pickupAddress.postalCode = response?.aphresisAccount?.BillingPostalCode;
        this.pickupAddress.country = response?.aphresisAccount?.BillingCountry;

        this.dropoffAddress.consignee = response?.manufacturingSite?.Manufacturing_Site__r?.Person_to_contact__c;
        this.dropoffAddress.street = response?.manufacturingSite?.Manufacturing_Site__r?.BillingStreet;
        this.dropoffAddress.city = response?.manufacturingSite?.Manufacturing_Site__r?.BillingCity;
        this.dropoffAddress.state = response?.manufacturingSite?.Manufacturing_Site__r?.BillingState;
        this.dropoffAddress.postalCode = response?.manufacturingSite?.Manufacturing_Site__r?.BillingPostalCode;
        this.dropoffAddress.country = response?.manufacturingSite?.Manufacturing_Site__r?.BillingCountry;

        this.showShipmentCreateModal = true;

    }

    async handleFileInput(event) {
        const taskName = String(event.target.name).trim();
        const file = event.target.files[0];
        const fileN = String(file.name).trim();
        if (!fileN.includes(taskName)) {
            this.showToastMessage('Error', `File name should have "${taskName}" include in it.`, 'error');
            return;
        }
        let taskQuesId = event.target.dataset.taskQuestionId;
        let mileTaskId = event.target.dataset.mileTaskId;
        var reader = new FileReader();

        reader.onload = async () => {
            var base64 = reader.result.split(',')[1];
            let fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': taskQuesId
            };
            let fileInput = {
                mileTaskId: mileTaskId,
                fileData: { ...fileData }
            };

            let isAvailable = await fileValidate({ taskQuesId: taskQuesId, fileName: file.name });

            const existingFileIndex = this.files.findIndex(f => f.fileData.recordId === taskQuesId);

            if (isAvailable) {
                LightningConfirm.open({
                    message: 'File already exists. Do you want to override it?',
                    label: 'Already Exists',
                    theme: 'warning'
                }).then((result) => {
                    if (result) {
                        if (existingFileIndex !== -1) {
                            this.files[existingFileIndex] = fileInput;
                        } else {
                            this.files = [...this.files, fileInput];
                        }
                        let fileLable = this.template.querySelector('lightning-badge[data-task-ques-id="' + taskQuesId + '"]');
                        if (fileLable) {
                            fileLable.label = 'New File: ' + fileN;
                        }
                    }
                });
            } else {
                if (existingFileIndex !== -1) {
                    LightningConfirm.open({
                        message: 'File already exists. Do you want to override it?',
                        label: 'Already Exists',
                        theme: 'warning'
                    }).then((result) => {
                        if (result) {
                            this.files[existingFileIndex] = fileInput;
                            let fileLable = this.template.querySelector('lightning-badge[data-task-ques-id="' + taskQuesId + '"]');
                            if (fileLable) {
                                fileLable.label = 'New File: ' + fileN;
                            }
                        }
                    });
                } else {
                    this.files = [...this.files, fileInput];
                    let fileLable = this.template.querySelector('lightning-badge[data-task-ques-id="' + taskQuesId + '"]');
                    if (fileLable) {
                        fileLable.label = 'New File: ' + fileN;
                    }
                }
            }
        };
        reader.readAsDataURL(file);
    }
}