import { LightningElement, wire, api } from 'lwc';
import getPatientIntegrationLog from '@salesforce/apex/PatientJourneyController.getPatientIntegrationLog';
import checkPatientJourneyRegistration from '@salesforce/apex/PatientJourneyController.checkPatientJourneyRegistration';
import { refreshApex } from '@salesforce/apex';
import LightningAlert from 'lightning/alert';
import {
    subscribe,
    unsubscribe,
    onError,
} from 'lightning/empApi';

export default class PatientIntegrationLog extends LightningElement {
    @api recordId;
    channelName = '/data/Integration_Log__ChangeEvent';
    subscription = {};
    logs = [];
    logResult;

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            this.handleResponse(response);
        };
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, (response) => {
        });
    }

    async handleResponse(response) {
        if (response?.data) {
            let data = response.data;
            if (data?.payload) {
                let payload = data.payload;
                if (payload?.ChangeEventHeader) {
                    let statusCode = payload?.Status_Code__c == 200;
                    if (payload.ChangeEventHeader.changeType == 'CREATE' && payload?.API_Name__c == 'Protrac_Patient_Registration') {
                        let recordIds = [...payload.ChangeEventHeader.recordIds];
                        let isRegistered = await checkPatientJourneyRegistration({ recordId: this.recordId, logId: recordIds[0] })
                        if (isRegistered) {
                            LightningAlert.open({
                                message: statusCode ? 'Patient registration details sent to Protrac successfully.' : 'Failed to send patient registration details to Protrac.',
                                theme: statusCode ? 'success' : 'error',
                                label: statusCode ? 'Patient Registered Successfully' : 'Patient Failed to Register',
                            }).then(() => {
                                refreshApex(this.logResult);
                            });
                        }
                    }
                }
            }
        }
    }

    registerErrorListener() {
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    @wire(getPatientIntegrationLog, { recordId: '$recordId' })
    patientIntegrationLogHandler(result) {
        this.logResult = result;
        if (result.data) {
            this.logs = result.data.map(apiRecord => {
                const isSuccess = apiRecord.Status_Code__c === 200;
                return {
                    apiName: apiRecord.API_Name__c,
                    recordId: apiRecord.Record_Id__c,
                    class: isSuccess ? 'success-theme slds-var-m-around_small slds-box slds-theme_shade' : 'error-theme slds-var-m-around_small slds-box slds-theme_shade',
                    title: isSuccess ? 'Patient Registered Successfully' : 'Patient Failed to Register',
                    statusMessage: isSuccess
                        ? `Patient registration details sent to Protrac successfully.`
                        : `Failed to send patient registration details to Protrac.`
                };
            });
        } else if (result.error) {
            console.error(result.error);
        }
    }
}