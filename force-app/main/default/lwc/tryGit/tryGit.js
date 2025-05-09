import { LightningElement, api } from 'lwc';

export default class TryGit extends LightningElement {
    @api recordId;
    @api cordinates;
    mapMarkers = [];
    connectedCallback(){
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