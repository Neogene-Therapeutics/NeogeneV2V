import { LightningElement, wire, track } from 'lwc';
import getCurrentUser from '@salesforce/apex/UserProfileController.getCurrentUser';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import messageDemoMC from "@salesforce/messageChannel/MessageChannel__c";
import {NavigationMixin} from "lightning/navigation";

export default class Neo_Site_Header extends NavigationMixin(LightningElement) {
    userName;
    userRole;
    @track isDropdownVisible = false;
    msg = false;
    subscription;
    protocol;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.fetchUserProfile();
        this.subscribeToMessageChannel(); // Ensure subscription to message channel
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel(); // Unsubscribe to prevent memory leaks
    }

    fetchUserProfile() {
        getCurrentUser()
            .then((result) => {
                this.userName = result.Name;
                this.userRole = result.UserRole.Name;
            })
            .catch((error) => {
                console.error('Error fetching user data:', error);
            });
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                messageDemoMC,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        this.msg = message.msg;
        this.protocol = message.protocol;
        console.log('Message received in header:', this.protocol);
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    // Toggle the dropdown when clicking on the profile section
    toggleDropdown(event) {
        event.stopPropagation(); // Stop propagation to prevent closing the dropdown immediately
        this.isDropdownVisible = !this.isDropdownVisible;
        console.log('isDropdownVisible:', this.isDropdownVisible);
    }

    // Handle the logout functionality
    handleLogout(){
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }
}