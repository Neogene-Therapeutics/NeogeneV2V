import { LightningElement, wire, track, api } from 'lwc';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendar';
import FullCalendarCustom from '@salesforce/resourceUrl/FullCalendarCustom';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from '@salesforce/apex';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import LightningConfirm from 'lightning/confirm';
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getAvailableSlots from '@salesforce/apex/SlotBookingController.getAvailableSlots';
//import getManufacturingSites from '@salesforce/apex/SlotBookingController.getManufacturingSites';
import getRequestedSlot from '@salesforce/apex/SlotBookingController.getRequestedSlot';
//import getAllMeetingsData from '@salesforce/apex/CustomCalendarController.getAllMeetingsData';

export default class CustomCalendar extends NavigationMixin(LightningElement) {

    calendar;
    calendarTitle;
    objectApiName = 'Meetings__c';
    objectLabel = '';
    eventsList = [];
    @track showBooking;
    @track manufacturingSlots = []; // Placeholder for manufacturing slots dates
    @track availableDates = [];
    @api recordId;
    showSpinner = false;
    showCalendar = true;
    isInitialized = false;
    // @track manufacturingOptions = [] ;
    // @track manufacturingSite;
    //[{ label: "Y", value: "Y"},
    //           { label: "Z", value: "Z"}];
    /*  viewOptions = [
          {
              label: 'Day',
              viewName: 'timeGridDay',
              checked: false
          },
          {
              label: 'Week',
              viewName: 'timeGridWeek',
              checked: false
          },
          {
              label: 'Month',
              viewName: 'dayGridMonth',
              checked: true
          },
          {
              label: 'Table',
              viewName: 'listView',
              checked: false
          }
      ]; */

    /*   @wire(getAllMeetingsData)
       wiredMeetings(result) {
           if(result.data) {
               const eventList = [];
               for(let meeting of result.data) {
                   const event = {
                       id: meeting.Id,
                       editable: true, 
                       allDay : false,
                       start: meeting.Start_Date_Time__c,
                       end: meeting.End_Date_Time__c,
                       title: meeting.Purpose__c
                   }
                   eventList.push(event);
               }
               this.eventsList = eventList;
               this.dataToRefresh = result;
           } else if(result.error){
               console.log(error);
           }
       } */

    /*  get buttonLabel() {
          return 'New ' + this.objectLabel;
      } */

    /* changeViewHandler(event) {
         const viewName = event.detail.value;
         if(viewName != 'listView') {
             this.calendar.changeView(viewName);
             const viewOptions = [...this.viewOptions];
             for(let viewOption of viewOptions) {
                 viewOption.checked = false;
                 if(viewOption.viewName === viewName) {
                     viewOption.checked = true;
                 }
             }
             this.viewOptions = viewOptions;
             this.calendarTitle = this.calendar.view.title;
         } else {
             this.handleListViewNavigation(this.objectApiName);
         }
     } */

    /*   handleListViewNavigation(objectName) {
           this[NavigationMixin.Navigate]({
               type: 'standard__objectPage',
               attributes: {
                   objectApiName: objectName,
                   actionName: 'list'
               },
               state: {
                   filterName: 'Recent' 
               }
           });
       } */

    @wire(getRequestedSlot, { recordId: '$recordId', isInitialized: '$isInitialized' })
    requestedSlots({ data, error }) {
        if (data) {
            this.eventsList = data.map(slot => {
                const event = {
                    id: slot.Id,
                    editable: false,
                    allDay: true,
                    start: slot.Value__c,
                    end: slot.Value__c,
                    title: 'Requested Slot'
                }
                return event;
            })
            if (this.isInitialized) {
                this.initializeCalendar();
            }
        }
        else if (error) {
            console.log(error);
        }
    }

    calendarActionsHandler(event) {
        const actionName = event.target.value;
        if (actionName === 'previous') {
            this.calendar.prev();
            this.loadCalendar();
        } else if (actionName === 'next') {
            this.calendar.next();
            this.loadCalendar();
            //   } else if(actionName === 'today') {
            //       this.calendar.today();
            //    } else if(actionName === 'new') {
            //       this.navigateToNewRecordPage(this.objectApiName);
        } else if (actionName === 'refresh') {
            this.refreshHandler();
        }
        this.calendarTitle = this.calendar.view.title;
    }

    connectedCallback() {
        this.showSpinner = true;
        Promise.all([
            loadStyle(this, FullCalendarJS + '/lib/main.css'),
            loadScript(this, FullCalendarJS + '/lib/main.js'),
            /*loadScript(this, FullCalendarJS + '/FullCalenderV3/jquery.min.js'),
            loadScript(this, FullCalendarJS + '/FullCalenderV3/moment.min.js'),
            loadScript(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.js'),
            loadStyle(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.css'), */
            loadStyle(this, FullCalendarCustom)
        ])
            .then(() => {
                this.isInitialized = true;
                // this.initializeCalendar();
                // this.loadMunufacturingSites();
            })
            .catch(error => console.log(error))
    }

    refreshHandler() {
        this.showSpinner = true;
        this.initializeCalendar();
    }

    initializeCalendar() {
        const calendarEl = this.template.querySelector('div.fullcalendar');
        const copyOfOuterThis = this;
        const calendar = new FullCalendar.Calendar(calendarEl, {
            headerToolbar: false,
            initialDate: new Date(),
            timeZone: 'UTC',
            showNonCurrentDates: false,
            fixedWeekCount: false,
            allDaySlot: false,
            navLinks: false,
            events: copyOfOuterThis.eventsList,
            eventDisplay: 'block',
            eventColor: '#f36e83',
            eventTimeFormat: {
                hour: 'numeric',
                minute: '2-digit',
                omitZeroMinute: true,
                meridiem: 'short'
            },
            dayMaxEventRows: true,
            eventTextColor: 'rgb(3, 45, 96)',
            dateClick: function (info) {
                const defaultValues = encodeDefaultFieldValues({
                    Start_Date_Time__c: info.dateStr
                });
                if (copyOfOuterThis.availableDates.indexOf(info.dateStr) !== -1) {
                    // copyOfOuterThis.showBooking = true;
                    copyOfOuterThis.dateStr = info.dateStr;
                }
                // copyOfOuterThis.navigateToNewRecordPage(copyOfOuterThis.objectApiName, defaultValues);
            }
            /*   eventClick: function(info) {
                   copyOfOuterThis.showConfirmWindow(info.event);
               },*/
            //  this.template['data-date' + ].addClass('greenColor')
        });
        calendar.render();
        calendar.setOption('contentHeight', 550);
        this.calendarTitle = calendar.view.title;
        this.calendar = calendar;
        setTimeout(() => {
            this.loadCalendar();
        }, 2000);

    }

    loadCalendar() {
        this.showSpinner = true;
        var ele = this.template.querySelectorAll('[data-date]');
        for (var i = 0; i < ele.length; i++) {
            ele[i].classList.add('fc-day-disabled');
            ele[i].classList.remove('greenColor');
            //    let textElement = ele[i].querySelector('.fc-daygrid-day-bottom');
            //   console.log('------' + textElement.value);
            //    textElement.innerHTML = '';
        }
        //    if(this.manufacturingSite){
        // this.fetchSlots();
        //    } else {
        //      this.showSpinner = false;
        //    }
        this.showSpinner = false;
    }
    // Combined @wire method to fetch manufacturing slots based on recordId
    /*  @wire(getAvailableManufacturingSlots, { recordId: '$recordId'})
      wiredSlots({ error, data }) {
          if (data) {
              this.manufacturingSlots = data;
              console.log('---this.manufacturingSlots---' + JSON.stringify(this.manufacturingSlots));
         //     this.colorCoding(); // Call colorCoding method after data is fetched
          } else if (error) {
              console.error('Error fetching manufacturing slots:', error);
          }
      } */

    /* loadMunufacturingSites(){
        getManufacturingSites({recordId  : this.recordId})
        .then(result => {
            this.manufacturingOptions = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            console.log('Error Manufacturing Slots:', JSON.stringify(this.error));
        });
    } */

    fetchSlots() {
        getAvailableSlots({ recordId: this.recordId })
            .then(result => {
                this.manufacturingSlots = result;
                this.error = undefined;
                this.colorCoding();
            })
            .catch(error => {
                this.error = error;
                this.manufacturingSlots = undefined;
            })
            .finally(fn => {
                this.showSpinner = false;
            })
    }

    // Method to apply color coding based on manufacturing slots dates
    colorCoding() {
        // Iterate through manufacturingSlots array and apply greenColor or greyColor class
        //  let currentDate = new Date();
        this.manufacturingSlots.forEach(slot => {
            //  let slotDate = new Date(slot.dateStr);
            if (slot.isAvailable) {
                //   let dateStr = slotDate.toISOString().split('T')[0]; // Get date in yyyy-mm-dd format
                this.availableDates.push(slot.dateStr);
                let element = this.template.querySelector('[data-date="' + slot.dateStr + '"]');
                if (element) {
                    element.classList.add('greenColor');
                    element.classList.remove('fc-day-disabled');
                    //     let bottomElement = element.querySelector('.fc-daygrid-day-bottom');
                    //     console.log('bottomElement----' + bottomElement);
                    //  bottomElement.classList.add('slots');
                    // bottomElement.value="";
                    //   bottomElement.append(slot.availableSlots +  '/' + slot.totalSlots); 
                }
            }
        });
    }

    handleClose() {
        this.showBooking = false;
    }

    handleHide() {
        this.showBooking = false;
        this.showCalendar = false;
    }

    /*  hanldeManufacturingSiteChange(event){
          this.manufacturingSite = event.detail.value;
          this.showSpinner = true;
          this.initializeCalendar();
      } */

    /*    async showConfirmWindow(event) {
            const result = await LightningConfirm.open({
                message: 'Are you sure you want to delete this Meeting?',
                variant: 'header',
                label: 'Delete Meeting',
                theme: 'brand'
            });
    
            if(result) {
                const eventToDelete = this.calendar.getEventById(event.id);
                eventToDelete.remove();
    
                deleteRecord(event.id)
                .then(() => {
                    const event = new ShowToastEvent({
                        title: 'Deleted!',
                        message: 'Record deleted successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error occured!',
                        message: error.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                })
            } 
        } */
}