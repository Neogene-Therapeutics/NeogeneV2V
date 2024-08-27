import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class VerificationUser extends LightningElement {
    @api userInfo;
    comments = '';
    @api taskId;
    userInput = '';

    handleInputChange(event) {
        console.log(event.target.value);
        this.userInput = event.target.value;
    }

    handleVerifyClick() {
        if (this.userInput === this.userInfo.password) {
            this.showToast('Verification Succeed', '', 'success')
            this.dispatchEvent(new CustomEvent("verify", { detail: { taskId: this.taskId, comment: this.comments } }));
        } else {
            this.showToast('Verification Failed', '', 'error')
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    commentHandler(event) {
        this.comments = event.target.value;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}