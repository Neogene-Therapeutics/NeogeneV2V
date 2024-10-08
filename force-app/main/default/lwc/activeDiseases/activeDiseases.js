import { LightningElement, wire } from 'lwc';
import getActiveDiseases from '@salesforce/apex/DiseaseHandler.getActiveDiseases';

export default class ActiveDiseases extends LightningElement {
    diseasesOptions = [];
    diseases = [];
    @wire(getActiveDiseases)
    activeDiseasesHandler({ data, error }) {
        if (data) {
            this.diseases = [...data];
            this.diseasesOptions = data.map(d => {
                return { label: d.Disease_Name__c, value: d.Id };
            })
        } else if (error) {
            console.error(error);
        }
    }

    get showDualBox() {
        return this.diseasesOptions.length > 0;
    }

    selectedDiseaseHandler(event) {
    }
}