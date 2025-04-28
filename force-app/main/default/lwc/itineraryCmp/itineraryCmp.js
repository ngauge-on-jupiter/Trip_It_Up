import { LightningElement,api,track,wire } from 'lwc';
import getItinerary from '@salesforce/apex/ItineraryCmpHandler.getItinerary';
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import TripItUpMC from '@salesforce/messageChannel/TripItUpMC__c';

export default class ItineraryCmp extends NavigationMixin(LightningElement) {
    @track itinerary;
    @wire(getItinerary) profileResult({ data, error }){
        if(data){
            this.itinerary =JSON.parse(data);
            console.log(this.itinerary)
        }
        if(error){
            console.log(error);
        }
    }
    @wire(MessageContext)

    messageContext;

    // Method to publish the message
    publishMessage(input) {
    const payload = { message: input};
    publish(this.messageContext, TripItUpMC, payload);
    
    }
    layoutClickHandler(event){
        const currentItem = this.itinerary.find(item => item.key === event.currentTarget.dataset.id);
        //this.publishMessage(JSON.stringify(currentItem));
        console.log(currentItem);
        this[NavigationMixin.Navigate](
            {
              type: "standard__webPage",
              attributes: {
    
                url: `https://orgfarm-6a88e00ad3-dev-ed.develop.my.site.com/TripItUp/detail?data=${encodeURIComponent(JSON.stringify(currentItem))}`,
              },
            //   state: {
            //     c__myWrapper: JSON.stringify(currentItem)  // Store the wrapper as a JSON string
            //   },
            },
            true, // Replaces the current page in your browser history with the URL
          );
        
    }
}