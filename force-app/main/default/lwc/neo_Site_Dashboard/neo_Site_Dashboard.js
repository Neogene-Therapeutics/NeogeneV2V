import { LightningElement, track, wire } from 'lwc';
import getJourneyOverview from '@salesforce/apex/SiteHomeController.getJourneyOverview';
import getOpenPatientTasks from '@salesforce/apex/SiteHomeController.getOpenPatientTasks';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import chartJS from '@salesforce/resourceUrl/ChartJS';

export default class Neo_Site_Dashboard extends NavigationMixin(LightningElement) {
    protocol = '';
    ApheresisCompletedCount = 0;
    IPInfusionCompletedCount = 0;
    IPPackOutCompletedCount = 0;
    ManufacturingStartedCount = 0;
    totalJourney = 0;
    activeJourney = 0;
    openTasks = [];
    chart;
    journeyData = [];
    @track isChartJsInitialized = false;

    connectedCallback() {
        this.protocol = sessionStorage.getItem('selectedProtocol');
    }

    @track isChartJsInitialized = false;
    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        Promise.all([loadScript(this, chartJS)])
            .then(() => {
                console.log('script loaded');
                this.isChartJsInitialized = true;
            })
            .catch(error => {
                console.log('Error loading Chart.js');
                console.error(error.message);
            });
    }

    @wire(getOpenPatientTasks, { studyId: '$protocol' })
    openPatientTasks({ data, error }) {
        if (data) {
            this.openTasks = data.map(d => {
                let taskName = d.Name;
                let yob = d?.Patient_Milestone__r?.Patient_Journey__r?.Patient__r?.Year_of_Birth__c;
                let subjectId = d?.Patient_Milestone__r?.Patient_Journey__r?.Patient__r?.Subject_Id__c;
                let journeyId = d?.Patient_Milestone__r?.Patient_Journey__r?.Id;
                return { taskName, yob, subjectId, journeyId };
            });
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getJourneyOverview, { studyId: '$protocol', isChartJsInitialized: '$isChartJsInitialized' })
    journeyOverview({ data, error }) {
        if (data) {
            console.log(data);
            this.ApheresisCompletedCount = data?.ApheresisCompletedCount;
            this.IPInfusionCompletedCount = data?.IPInfusionCompletedCount;
            this.IPPackOutCompletedCount = data?.IPPackOutCompletedCount;
            this.ManufacturingStartedCount = data?.ManufacturingStartedCount;
            this.totalJourney = data?.totalJourney;
            this.activeJourney = data?.activeJourney;
            this.journeyData = [];
            this.journeyData = [this.totalJourney, this.ApheresisCompletedCount, this.ManufacturingStartedCount, this.IPPackOutCompletedCount, this.IPInfusionCompletedCount, this.activeJourney];
            this.initializeDonutChart();
        } else if (error) {
            console.log(error);
        }
    }

    initializeDonutChart() {
        const ctx = this.template.querySelector('canvas');
        const data = {
            labels: [
                'Total Patients Journey',
                'Apheresis Completed',
                'Manufacturing Started',
                'IP Pack-Out Completed',
                'IP Infusion Completed',
                'Active Patients Completed'
            ],
            datasets: [{
                label: 'V2V Overview',
                data: [...this.journeyData],
                backgroundColor: [
                    'rgb(131, 0, 81)',
                    'rgb(196, 214, 0)',
                    'rgb(240, 171, 0)',
                    'rgb(0, 56, 101)',
                    'rgb(208, 0, 111)',
                    'rgb(60, 16, 83)'
                ],
                hoverOffset: 70
            }]
        };

        const config = {
            type: 'doughnut',
            data: data,
            options: {
                legend: {
                    display: false
                },
            }
        };
        console.log(JSON.stringify(config));
        this.chart = new window.Chart(ctx, config);
    }

    navigateToV2V(event) {
        let patientJourneyId = event.target.dataset.journeyId;
        sessionStorage.setItem('patientJourneyId', patientJourneyId);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'V2V_Journey__c'
            }
        });
    }
}