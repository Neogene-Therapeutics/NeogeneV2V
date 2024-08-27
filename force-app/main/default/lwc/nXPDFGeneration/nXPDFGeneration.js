import { LightningElement, api } from 'lwc';
import generatePDF from '@salesforce/apex/NX_AccountPDFGenerator.generateAndAttachPDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NXPDFGeneration extends LightningElement {
@api recordId;

    generatePDF() {
        generatePDF({ accountId: this.recordId })
            .then(() => {
                // Success handling
                this.showToast('Success', 'PDF generated and attached successfully', 'success');
            })
            .catch(error => {
                // Error handling
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}