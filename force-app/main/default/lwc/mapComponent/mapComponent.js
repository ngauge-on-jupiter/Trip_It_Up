import { LightningElement, api } from 'lwc';

export default class MapComponent extends LightningElement {

    @api recordId;
    @api cordinates;
    mapMarkers = [];
    
    connectedCallback(){ 
        console.log('recordId:', this.recordId);
        console.log('cordinates:', this.cordinates);
        
        this.mapMarkers = [
            {
                location: {
                    Latitude: '37.790197',
                    Longitude: '-122.396879',

                },
                
            },
        ];
    }
    
}