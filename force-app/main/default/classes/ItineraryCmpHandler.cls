public without sharing class ItineraryCmpHandler {
    public static String getIcon(String iconName) {
        String icon = '';
        if(iconName == 'Activity'){
            icon = 'standard:sales_channel';
        }
        else if(iconName == 'Travel'){
            icon = 'standard:work_order';
        }
        else if(iconName == 'Stay'){
            icon = 'standard:household';
        }
        return icon;
    }
    @AuraEnabled(cacheable=true)
    public static String getItinerary(){
        List<Itinerary_Listing__c> itineryList = [SELECT Id, Name, Destination__c, Is_Active__c, Min_Price__c, 
                                                  Details__c, Max_Price__c, Image_Link__c, Image_ID__c, Interest__c 
                                                  FROM Itinerary_Listing__c WHERE IsRequest__c = false];
        Set<Id> itineryIds = new Set<Id>();
        
        for(Itinerary_Listing__c itinery : itineryList){
            itineryIds.add(itinery.Id);
        }
        System.debug(itineryIds.size());
        //this is the part to show ittenary details
        List<LineItem__c> lineItemList = [SELECT Id, Name, Detail__c, Itinerary__c, Short_Title__c, Additional_Information__c, 
                                          Day__c, Type__c, Sequence__c, Activity_Listing__c, 
                                          Duration__c
                                          FROM LineItem__c WHERE Itinerary__c IN :itineryIds];
        
        Map<String,List<LineItem__c>> itiIdVsLineItem = new Map<String,List<LineItem__c>>();
        Set<Id> actIdSet = new Set<Id>();
        for(LineItem__c lineItem : lineItemList){
            if(itiIdVsLineItem.keySet().contains(lineItem.Itinerary__c)){
                itiIdVsLineItem.get(lineItem.Itinerary__c).add(lineItem);
            }
            else{
                itiIdVsLineItem.put(lineItem.Itinerary__c,new List<LineItem__c>());
                itiIdVsLineItem.get(lineItem.Itinerary__c).add(lineItem);
            }
            //collecting Activity Ids
            System.debug('Activity_Listing__c: '+lineItem.Activity_Listing__c);
            //if(lineItem.Activity_Listing__c!='' && lineItem.Activity_Listing__c != null){
            actIdSet.add(lineItem.Activity_Listing__c);
            //}
        }
        
        //geting map of activity Listings using SOQL
        Map<String,Activity_Listing__c> actMap = new Map<String,Activity_Listing__c>();
        if(actIdSet.size()>0){
            List<Activity_Listing__c> actList = [SELECT Id, Name, Description__c, Place__c, Images__c, Additional_Info__c FROM Activity_Listing__c WHERE Id IN :actIdSet];
            for(Activity_Listing__c act : actList){
                actMap.put(act.Id,act);
            }
        }
        
        List<ContentDocumentLink> conDocLinkList =[SELECT LinkedEntityId, ContentDocumentId, Id, ShareType, SystemModstamp, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: itineryIds];
        //ContentVersion 
        Map<String,ContentDocumentLink> conDocLinkMap = new Map<string,ContentDocumentLink>();
        Map<String,String> itiIdVsconDocLinkID = new Map<String,String>();
        for(ContentDocumentLink cDocLink : conDocLinkList){
            conDocLinkMap.put(cDocLink.ContentDocumentId,cDocLink);
            itiIdVsconDocLinkID.put(cDocLink.LinkedEntityId,cDocLink.ContentDocumentId);
        }
        System.debug(conDocLinkMap.size());
        System.debug(itiIdVsconDocLinkID.size());
        List<ContentVersion> conVer =[SELECT Id, ContentDocumentId, ContentUrl FROM ContentVersion WHERE ContentDocumentId IN: conDocLinkMap.keySet()];
        Map<String,ContentVersion> cvMap = new Map<String,ContentVersion>();
        for(ContentVersion cv : conVer){
            cvMap.put(cv.ContentDocumentId,cv);
        }
        System.debug(cvMap.size());
        List<Itinerary> wrapper = new List<Itinerary>();
        // Map<string,LineItem__c> seqVsLineItem = new Map<string,LineItem__c>();
        // Map<String,Map<string,LineItem__c>> dayVsSeq = new Map<String,Map<string,LineItem__c>>();
        // Temporary map to build for one parent
        // Map<String, Map<String, LineItem__c>> dayMap = new Map<String, Map<String, LineItem__c>>();
        // Map<String, Map<String, LineItem>> evtDay = new Map<String, Map<String, LineItem>>();
        
        for(Itinerary_Listing__c itinery : itineryList){
            Map<String, Map<String, LineItem__c>> dayMap = new Map<String, Map<String, LineItem__c>>();
        Map<String, Map<String, LineItem>> evtDay = new Map<String, Map<String, LineItem>>();
        
            Itinerary wpr = new Itinerary();
            wpr.key = itinery.Id;
            wpr.name = itinery.Destination__c;
            wpr.image = 'https://orgfarm-6a88e00ad3-dev-ed.develop.my.salesforce.com/sfc/dist/version/renditionDownload?'+itinery.Image_Link__c; // '/sfc/servlet.shepherd/document/download/'+itiIdVsconDocLinkID.get(itinery.Id);
            //wpr.lineItems =new List<LineItem>();
            //wpr.evtDay = new Map<String,Map<String,LineItem>>();
            wpr.evDay =new List<EventDay>();
            if(itiIdVsLineItem.keySet().contains(itinery.Id) && itiIdVsLineItem.get(itinery.Id).size()>0){ 
                // for(LineItem__c li : itiIdVsLineItem.get(itinery.Id)){ 
                //     if(li.Day__c!=null){   
                //         String day = String.valueOf(li.Day__c);
                
                
                //         // If the day is not already in the dayMap, add it
                //         if (!dayMap.containsKey(day)) {
                //             dayMap.put(day, new Map<String, LineItem__c>());
                //         }
                //         if(li.Sequence__c!=null){
                //             String seq = String.valueOf(li.Sequence__c);
                //             // Add the li record under the correct day and seq
                //             dayMap.get(day).put(seq, li);
                //         }
                //     }
                // }  
                //System.debug(JSON.serialize(dayMap));            
                for(LineItem__c li : itiIdVsLineItem.get(itinery.Id)){
                    LineItem liWpr = new LineItem();
                    liWpr.keyLI = li.Id;
                    liWpr.info = li.Detail__c;
                    liWpr.shortTitle = li.Short_Title__c;
                    liWpr.dayNo = String.valueOf(li.Day__c);
                    liWpr.type = getIcon(li.Type__c);
                    liWpr.sequence = String.valueOf(li.Sequence__c);
                    if(actMap.get(li.Activity_Listing__c)!=null){
                    liWpr.activity = new Activity();
                    
                    Activity_Listing__c act = actMap.get(li.Activity_Listing__c)??new Activity_Listing__c();
                    liWpr.activity.keyAct = act.Id;
                    liWpr.activity.name = act.Name;
                    liWpr.activity.info = act.Additional_Info__c;
                    liWpr.activity.description = act.Description__c;
                    liWpr.activity.place = act.Place__c;
                    }
                    if(evtDay.keySet().contains(liWpr.dayNo))
                    {
                        if(!evtDay.get(liWpr.dayNo).keySet().contains(String.valueOf(li.Sequence__c))){
                            evtDay.get(liWpr.dayNo).put(liWpr.sequence,liWpr);
                        }
                    }
                    else
                    {
                        if(liWpr.dayNo!=null && liWpr.dayNo !=''){
                            evtDay.put(liWpr.dayNo,new Map<String,LineItem>());
                            if(liWpr.sequence!=null && liWpr.sequence !=''){
                                evtDay.get(liWpr.dayNo).put(liWpr.sequence,liWpr);
                            }
                        }
                    }    
                }
                
                //System.debug(JSON.serialize(evtDay));
            }
            List<String> sortedDays = new List<String>(evtDay.keySet());
            sortedDays.sort();
            for(String day:sortedDays){
                List<Sequence> seqList = new List<Sequence>();
                List<String> sortedSeq = new List<String>(evtDay.get(day).keySet());
                sortedSeq.sort();
                for(String seq:sortedSeq){
                    Sequence sequ = new Sequence();
                    sequ.seqNo = seq;
                    sequ.lineItems = evtDay.get(day).get(seq);
                    seqList.add(sequ);
                }
                EventDay eventDay = new EventDay();
                eventDay.dayNo=day;
                eventDay.sequence=seqList;
                //eventDay.sequence.sort();
                wpr.evDay.add(eventDay);
            }
            //wpr.evDay.sort();
            wrapper.add(wpr);
        }
        return JSON.serialize(wrapper);
    }
    class Itinerary{
        public String key;
        public String name;
        public String image;
        //Map<String,Map<String,LineItem>> evtDay;
        //public List<LineItem> lineItems;
        public List<EventDay> evDay;
    }
    class EventDay{
        public String dayNo;
        public List<Sequence> sequence;
    }
    class Sequence{
        public String seqNo;
        public LineItem lineItems;
    }
    class LineItem{
        public String keyLI;
        public String shortTitle;
        public String info;
        public String dayNo;
        public String type;
        public String sequence;
        public Activity activity;
        public String description;
    }
    class Activity{
        public String keyAct;
        public String name;
        public String info;
        public String description;
        public String place;
    }
}