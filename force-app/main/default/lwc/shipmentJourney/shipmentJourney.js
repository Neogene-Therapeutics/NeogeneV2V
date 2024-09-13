import { api, LightningElement, wire } from 'lwc';
import getShipmentStatus from '@salesforce/apex/ShipmentJourneyController.getShipmentStatus';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CREATED_DATE from "@salesforce/schema/Shipment__c.CreatedDate";

const FIELDS = [CREATED_DATE];

export default class ShipmentTracker extends LightningElement {
    @api recordId;
    events = [];
    isLoading = false;
    showDefault = false;
    hasStatuses = false;
    createdDate;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    shipmentFields({ data, error }) {
        if (data) {
            this.createdDate = this.formatDateTime(data?.fields?.CreatedDate?.value)
        }
    }

    async connectedCallback() {
        this.getStatuses();
    }

    openDefault(event) {
        event.target.iconName = event.target.iconName == 'utility:chevronright' ? 'utility:chevrondown' : 'utility:chevronright';
        this.showDefault = !this.showDefault;
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
        if (response) {
            this.events = JSON.parse(response)?.responseData?.events?.map(e => {
                let showDeliveryDetails = false;
                let dropDownIcon = 'utility:chevronright';
                let deliveryDateTime = this.formatDateTime(e.eventDateTime);
                return { ...e, showDeliveryDetails, dropDownIcon, deliveryDateTime };
            });
            this.hasStatuses = true;
        } else {
            this.hasStatuses = false;
        }
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