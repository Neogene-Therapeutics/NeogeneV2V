import { LightningElement , track, wire } from 'lwc';
import getStudyProtocolOptions from '@salesforce/apex/SiteHomeController.getStudyProtocolOptions';
import {NavigationMixin} from "lightning/navigation";
import { createMessageContext, releaseMessageContext,publish } from 'lightning/messageService';
import messageDemoMC from "@salesforce/messageChannel/MessageChannel__c";

export default class Neo_Site_Home extends NavigationMixin(LightningElement) {
    protocolOptions = [];
    @track protocolSelected = false;
    selectedProtocol = null;
    context;

    connectedCallback() {
        this.context = createMessageContext(); // Create message context
    }

    disconnectedCallback() {
        releaseMessageContext(this.context); // Release message context when the component is destroyed
    }

    @wire(getStudyProtocolOptions)
    fetchStudyProtocolOptions({ error, data }) {
        if (data) {
            this.protocolOptions = Object.keys(data).map(key => ({
                label: data[key].name,
                value: data[key].studyId
            }));
        } else if (error) {
            console.error('Error fetching protocol options:', error);
        }
    }

    handleChange(event) {
        this.selectedProtocol = event.detail.value;
    }

    handleSubmit() {
        if (this.selectedProtocol) {
            this.protocolSelected = true;
            sessionStorage.setItem('selectedProtocol', this.selectedProtocol);
            this.publishMC();
        } else {
            alert('Please select a protocol');
        }
    }

    publishMC() {
        const payload = {
            protocol: this.selectedProtocol,
            msg: true
        };
    
        try {
            publish(this.context, messageDemoMC, payload);
            console.log('Message published:', payload.protocol);
    
            
    
            setTimeout(() => {
                this.navigateToPatient();
            }, 1000);  // 1-second delay
        } catch (error) {
            console.error('Error publishing message:', error);
        }
    }
    

    navigateToPatient() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'dashboard__c'
            }
        });
    }
}