import { LightningElement, track } from 'lwc';
import getManufacturingSiteOptions from '@salesforce/apex/MfgSlotController.getManufacturingSiteOptions';
import getClinicalSiteOptions from '@salesforce/apex/MfgSlotController.getClinicalSiteOptions';
import getMFGSlots from '@salesforce/apex/MfgSlotController.getMFGSlots';
import updateManufacturingSlots from '@salesforce/apex/MfgSlotController.updateManufacturingSlots';

export default class neo_Mfg_Table extends LightningElement {
    @track manufacturingSiteOptions = [];
    @track clinicalSiteOptions = [];
    @track filteredData = [];
    @track isDataAvailable = false;
    @track selectedStudy;
    @track studyOptions = [];
    @track isModalOpen = false;
    @track selectedRecordId;
    @track selectedClinicalSite;
    @track selectedManufacturingSite;
    @track isClinicalSite = false;
    @track isManufacturingSite = false;

    columns = [
        { label: 'Slot Name', fieldName: 'Name' },
        { label: 'Slot Quantity', fieldName: 'Slot_Quantity__c' },
        {
            label: 'Clinical Site',
            type: 'button',
            typeAttributes: {
                label: 'Assign Clinical Site',
                name: 'assign_clinical_site',
                variant: 'neutral'
            }
        },
        {
            label: 'Manufacturing Site',
            type: 'button',
            typeAttributes: {
                label: 'Assign Manufacturing Site',
                name: 'assign_manufacturing_site',
                variant: 'neutral'
            }
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
            console.log('Loaded slots: ', slots);

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
            this.isDataAvailable = this.filteredData.length > 0;
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // Filter data by selected study
    filterDataByStudy(slots) {
        if (!this.selectedStudy) {
            return slots;
        }

        return slots.filter(slot => slot.Study_ID__r && slot.Study_ID__r.Display_Name__c === this.selectedStudy);
    }

    handleFilterChange(event) {
        this.selectedStudy = event.detail.value;
        this.loadData();
    }

    // Handle row action for opening modal
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedRecordId = row.Id;

        // Reset both modals
        this.isClinicalSite = false;
        this.isManufacturingSite = false;

        if (actionName === 'assign_clinical_site') {
            this.selectedClinicalSite = row.Clinical_Site__c;
            this.isClinicalSite = true;  // Show Clinical Site modal
            this.openModal();
        } else if (actionName === 'assign_manufacturing_site') {
            this.selectedManufacturingSite = row.Manufacturing_Site__c;
            this.isManufacturingSite = true;  // Show Manufacturing Site modal
            this.openModal();
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleClinicalSiteChange(event) {
        this.selectedClinicalSite = event.detail.value;
    }

    handleManufacturingSiteChange(event) {
        this.selectedManufacturingSite = event.detail.value;
    }

    // Save the selected site values to the record
    async handleSave() {
        let updatedRecord = { Id: this.selectedRecordId };

        if (this.isClinicalSite) {
            updatedRecord.Clinical_Site__c = this.selectedClinicalSite;
        } else if (this.isManufacturingSite) {
            updatedRecord.Manufacturing_Site__c = this.selectedManufacturingSite;
        }

        try {
            await updateManufacturingSlots([updatedRecord]);
            this.closeModal();
            this.loadData(); // Reload the data after saving
        } catch (error) {
            console.error('Error saving changes:', error);
        }
    }
}