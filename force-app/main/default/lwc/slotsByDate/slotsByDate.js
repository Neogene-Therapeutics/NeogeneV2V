import { LightningElement, track, api } from 'lwc';
import getSlots from '@salesforce/apex/SlotBookingController.getSlotsByDate';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class SlotsByDate extends LightningElement {

    @api dateStr;
    @track slots;
    @track error;
    @api recordId;
    showSpinner = false;
    @api manufacturingSite;

    @track columns = [{
        label: 'Name',
        fieldName: 'name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Courier',
        fieldName: 'courier',
        type: 'text',
        sortable: true
    },
    {
        label: 'Start Time',
        fieldName: 'startTime',
        type: 'text',
        sortable: true
    },
    {
        label: 'End Time',
        fieldName: 'endTime',
        type: 'text',
        sortable: true
    },
    {
        type: "button", label: 'Action', initialWidth: 100, typeAttributes: {
            label: {fieldName: 'buttonName'},
            name: {fieldName: 'buttonName'},
            title: {fieldName: 'buttonName'},
            disabled: {fieldName: 'buttonDisabled'},
            value: {fieldName: 'buttonName'},
            variant:'Brand'
        } 
    }
];

    connectedCallback(){
        this.refreshData();
    }

    refreshData(){
        console.log('-----slots----' + this.dateStr);
        console.log('-----recordId----' + this.recordId);
        console.log('-----manufacturingId----' + this.manufacturingSite);
        
        getSlots({dateStr  : this.dateStr, recordId: this.recordId, manufacturingId : this.manufacturingSite})
        .then(result => {
            this.slots = result;
            this.error = undefined;
            console.log('-----slots----' + JSON.stringify(this.slots));
        //   this.setColumns();
        })
        .catch(error => {
            this.error = error;
            console.log('-----error----' + JSON.stringify(this.error));
            this.patientList = undefined;
        })
        .finally(fn => {
            this.showSpinner = false;
        })
    }

    callRowAction(event){ 
        this.showSpinner = true;
        console.log(JSON.stringify(event.detail.action.name));
    //    if(event.detail.action.name === 'Book') {
            let slotId = event.detail.row.Id;
            console.log('----slotId----' + slotId);
            this.updateBooking(slotId);
    //    }
    }

    showToastMessage(title , msg, variant){
        this.dispatchEvent(
            new ShowToastEvent({
              title: title,
              message: msg,
              variant: variant,
            }),
          );
    }

    updateBooking(slotId){
      const fields = {};
      fields['Id'] = slotId;
      fields['Booking_Status__c'] = 'Requested';
      const recordInput = { fields };
      updateRecord(recordInput)
        .then(() => {
          this.showToastMessage('Success', 'Slot Requested', 'success' );
          this.updatePatientJourney(slotId);
       //   this.refreshData();
        })
        .catch((error) => {
            this.showToastMessage('Error', 'Error while booking slot', 'error' );
            this.showSpinner = false;
        });   
    }

    updatePatientJourney(slotId){
        const fields = {};
        fields['Id'] = this.recordId;
        fields['Manufacturing_Slot__c'] = slotId;
        const recordInput = { fields };
        updateRecord(recordInput)
          .then(() => {
            this.refreshData();
          })
          .catch((error) => {
              this.showToastMessage('Error', 'Error while booking slot', 'error' );
              this.showSpinner = false;
          });   
      }
    

}