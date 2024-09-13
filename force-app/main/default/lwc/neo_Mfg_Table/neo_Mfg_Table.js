import { LightningElement, track, wire } from 'lwc';
import getManufacturingSiteOptions from '@salesforce/apex/MfgSlotController.getManufacturingSiteOptions';
import getClinicalSiteOptions from '@salesforce/apex/MfgSlotController.getClinicalSiteOptions';
import getMFGSlots from '@salesforce/apex/MfgSlotController.getMFGSlots';
import updateManufacturingSlots from '@salesforce/apex/MfgSlotController.updateManufacturingSlots';

export default class ManufacturingSlotsOverview extends LightningElement {
    @track manufacturingSiteOptions = [];
    @track clinicalSiteOptions = [];
    @track filteredData = [];
    @track draftValues = [];
    @track isDataAvailable = false;
    @track selectedStudy;
    @track studyOptions = [];

    columns = [
        { label: 'Slot Name', fieldName: 'Name' },
        { label: 'Slot Quantity', fieldName: 'Slot_Quantity__c' },
        { label: 'Study Protocol', fieldName: 'Study_ID__r.Display_Name__c' },
        {
            label: 'Clinical Site',
            fieldName: 'Clinical_Site__c',
            type: 'picklist',
            typeAttributes: {
                placeholder: 'Select Clinical Site',
                options: { fieldName: 'clinicalSiteOptions' },
                value: { fieldName: 'Clinical_Site__c' },
                context: { fieldName: 'Id' }
            },
            editable: true
        },
        {
            label: 'Manufacturing Site',
            fieldName: 'Manufacturing_Site__c',
            type: 'picklist',
            typeAttributes: {
                placeholder: 'Select Manufacturing Site',
                options: { fieldName: 'manufacturingSiteOptions' },
                value: { fieldName: 'Manufacturing_Site__c' },
                context: { fieldName: 'Id' }
            },
            editable: true
        },
        { label: 'Booking Status', fieldName: 'Booking_Status__c' },
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' }
    ];

    connectedCallback() {
        this.loadOptions();
        this.loadData();
    }

    // Load options for manufacturing and clinical sites
    async loadOptions() {
        try {
            const [manufacturingSites, clinicalSites] = await Promise.all([
                getManufacturingSiteOptions(),
                getClinicalSiteOptions()
            ]);

            this.manufacturingSiteOptions = manufacturingSites.map(option => ({
                label: option.label,
                value: option.value
            }));
            this.clinicalSiteOptions = clinicalSites.map(option => ({
                label: option.label,
                value: option.value
            }));
        } catch (error) {
            console.error('Error loading options:', error);
        }
    }

    // Load Manufacturing Slots data and create study options dynamically
    async loadData() {
        try {
            const slots = await getMFGSlots();
            console.log('Loaded slots: ', slots); // Log to check if slots are being fetched

            // Create studyOptions dynamically based on Study_ID__r.Display_Name__c
            const studySet = new Set();
            slots.forEach(slot => {
                if (slot.Study_ID__r && slot.Study_ID__r.Display_Name__c) {
                    studySet.add(slot.Study_ID__r.Display_Name__c);
                }
            });

            this.studyOptions = Array.from(studySet).map(studyName => ({
                label: studyName,
                value: studyName
            }));

            this.filteredData = this.filterDataByStudy(slots);
            console.log('Filtered Data: ', this.filteredData); // Log to check filtered data

            this.isDataAvailable = this.filteredData.length > 0;
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // Filter data by selected study
    filterDataByStudy(slots) {
        if (!this.selectedStudy) {
            return slots.map(slot => ({
                ...slot,
                clinicalSiteOptions: this.clinicalSiteOptions,
                manufacturingSiteOptions: this.manufacturingSiteOptions
            }));
        }

        return slots
            .filter(slot => slot.Study_ID__r && slot.Study_ID__r.Display_Name__c === this.selectedStudy)
            .map(slot => ({
                ...slot,
                clinicalSiteOptions: this.clinicalSiteOptions,
                manufacturingSiteOptions: this.manufacturingSiteOptions
            }));
    }

    handleFilterChange(event) {
        this.selectedStudy = event.detail.value;
        console.log('Selected Study: ', this.selectedStudy); // Log to check the selected study
        this.loadData(); // Refilter the data based on the new study
    }

    // Handle save action
    async handleSave(event) {
        const draftValues = event.detail.draftValues;
        console.log('Draft values: ', draftValues); // Log the draft values before saving

        try {
            await updateManufacturingSlots(draftValues);
            await this.loadData(); // Refresh the data after saving
        } catch (error) {
            console.error('Error saving changes:', error);
        }
    }

    handlePicklistChange(event) {
        const { value, context } = event.detail.data;
        const updatedData = this.filteredData.map(record => {
            if (record.Id === context) {
                record[event.detail.type] = value;
            }
            return record;
        });
        this.filteredData = updatedData;
    }
}