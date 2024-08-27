import { LightningElement, api } from 'lwc';
import bookSlot from '@salesforce/apex/SlotBookingController.bookSlot';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class SlotBooking extends LightningElement {

    @api dateStr;
    @api recordId;
    showSpinner = false;

    hideModalBox() {
        this.dispatchEvent(new CustomEvent('close', {}));
    }

    handleConfirm() {
        this.showSpinner = true;
        bookSlot({ recordId: this.recordId, dateStr: this.dateStr })
            .then(result => {
                console.log('----result----' + result);
                if (result) {
                    this.showToastMessage('Success', 'Slot Requested', 'success');
                    this.dispatchEvent(new CustomEvent('hidecalendar', {}));
                    location.reload();
                } else {
                    this.showToastMessage('Error', 'Error occurred while requesting slot', 'error');
                    console.log('Error :', JSON.stringify(this.error));
                }
            })
            .catch(error => {
                this.showToastMessage('Error', 'Error occurred while requesting slot', 'error');
                console.log('Error :', JSON.stringify(this.error));
            })
            .finally(fn => {
                this.showSpinner = false;
            })
    }

    showToastMessage(title, msg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
            }),
        );
    }
}