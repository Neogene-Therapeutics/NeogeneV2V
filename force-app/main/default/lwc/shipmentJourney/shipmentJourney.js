import { api, LightningElement, wire } from 'lwc';
import getShipmentStatus from '@salesforce/apex/ShipmentJourneyController.getShipmentStatus';
export default class ShipmentTracker extends LightningElement {
    @api recordId;
    events = [];
    isLoading = false;

    async connectedCallback() {
        this.getStatuses();
    }

    openShipmentDetails(event) {
        let deliveryCode = event.currentTarget.dataset.deliveryCode;
        let eventCopy = [...this.events];
        eventCopy.map(e => {
            if (e.eventTypeCode == deliveryCode) {
                e.dropDownIcon = e.dropDownIcon == 'utility:chevronright' ? 'utility:chevrondown' : 'utility:chevronright';;
                e.showDeliveryDetails = e.dropDownIcon == 'utility:chevrondown';
            }
            return e;
        })
        this.events = [...eventCopy];
    }

    async getStatuses() {
        this.isLoading = true;
        let response = await getShipmentStatus({ recordId: this.recordId })
        this.events = JSON.parse(response)?.responseData?.events?.map(e => {
            let showDeliveryDetails = false;
            let dropDownIcon = 'utility:chevronright';
            let deliveryDateTime = this.formatDateTime(e.eventDateTime);
            return { ...e, showDeliveryDetails, dropDownIcon, deliveryDateTime };
        });
        this.isLoading = false;
    }

    formatDateTime(datetimeStr) {
        const date = new Date(datetimeStr);
        let hours = date.getUTCHours();
        const minutes = date.getUTCMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;
        const minutesStr = minutes < 10 ? '0' + minutes : minutes;
        const day = date.getUTCDate();
        const month = date.toLocaleString('default', { month: 'long', timeZone: 'UTC' });
        const year = date.getUTCFullYear();
        return `${hours}:${minutesStr} ${ampm}, ${day} ${month}, ${year}`;
    }
}