import { LightningElement, wire } from 'lwc';
import getJourneyOverview from '@salesforce/apex/SiteHomeController.getJourneyOverview';

export default class Neo_Site_Dashboard extends LightningElement {
    protocol = '';
    ApheresisCompletedCount = 0;
    IPInfusionCompletedCount = 0;
    IPPackOutCompletedCount = 0;
    ManufacturingStartedCount = 0;
    totalJourney = 0;
    activeJourney = 0;

    connectedCallback() {
        this.protocol = sessionStorage.getItem('selectedProtocol');
    }

    @wire(getJourneyOverview, { studyId: '$protocol' })
    journeyOverview({ data, error }) {
        if (data) {
            console.log(data);
            this.ApheresisCompletedCount = data?.ApheresisCompletedCount;
            this.IPInfusionCompletedCount = data?.IPInfusionCompletedCount;
            this.IPPackOutCompletedCount = data?.IPPackOutCompletedCount;
            this.ManufacturingStartedCount = data?.ManufacturingStartedCount;
            this.totalJourney = data?.totalJourney;
            this.activeJourney = data?.activeJourney;
            console.log(this.ApheresisCompletedCount);
            console.log(this.IPInfusionCompletedCount);
            console.log(this.IPPackOutCompletedCount);
            console.log(this.ManufacturingStartedCount);
            console.log(this.totalJourney);
            console.log(this.activeJourney);
        } else if (error) {
            console.log(error);
        }
    }
}