import { LightningElement,wire,track } from 'lwc';
// import { CurrentPageReference } from 'lightning/navigation';
// import { subscribe, MessageContext } from 'lightning/messageService';

// import TripItUpMC from '@salesforce/messageChannel/TripItUpMC__c';
export default class ItineraryDetailPage extends LightningElement {
    // @wire(MessageContext) messageContext;
    // wpr;
    // subscription = null;
    // // Subscribe to the message channel
    // subscribeToMessageChannel(){
    //     if(this.subscription==null){
    //        this.subscription= subscribe(this.messageContext, TripItUpMC, (message) => this.wpr=message.message );
    //        console.log(this.wpr);
    //     }

    //}

    // @wire(CurrentPageReference)
    // currentPageReference;

    @track myWrapper;

    connectedCallback() {
        // This line ensures URLSearchParams is used correctly
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        console.log('1 ===> '+urlParams);
        console.log('2 ===> '+urlParams.get('data'));
        this.myWrapper= JSON.parse(urlParams.get('data'));
        // this.subscribeToMessageChannel();
        // if (this.currentPageReference.state && this.currentPageReference.state.c__myWrapper) {
        //     // Parse the JSON string back into an object
        //     this.myWrapper = JSON.parse(this.currentPageReference.state.c__myWrapper);
        //     console.log(this.myWrapper);
        // } else {
        //     console.log("No wrapper data found in state");
        // }
    }
}