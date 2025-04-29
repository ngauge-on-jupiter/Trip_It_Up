@isTest
public with sharing class ItineraryCmpHandlerTest {
    @isTest
    public static void testGetItinerary() {
        // Create Itnerary Listing data 
        //Name, Destination__c, Is_Active__c, Min_Price__c, Details__c, Max_Price__c, Image_Link__c, Image_ID__c, Interest__c
        Itinerary_Listing__c itineraryList = new Itinerary_Listing__c();
        itineraryList.Name = 'Test Itinerary';
        itineraryList.Image_ID__c = 'test_image_url';
        itineraryList.Destination__c = 'Test Destination';
        itineraryList.Is_Active__c = true;
        itineraryList.Min_Price__c = 100;
        itineraryList.Max_Price__c = 500;
        itineraryList.Details__c = 'Test Details';
        itineraryList.Image_Link__c = 'test_image_link';
        itineraryList.IsRequest__c = false;
        insert itineraryList;
        // create activity listing data
        //Name, Description__c, Place__c, Images__c, Additional_Info__c FROM Activity_Listing__c
        Activity_Listing__c activityList = new Activity_Listing__c();
        activityList.Name = 'Test Activity';
        activityList.Description__c = 'Test Description';
        activityList.Place__c = 'Test Place';
        activityList.Additional_Info__c = 'Test Additional Info';
        insert activityList;
        
        // Create Line Item data
        // Name, Detail__c, Itinerary__c, Short_Title__c, Additional_Information__c, 
        // Day__c, Type__c, Sequence__c, HotelListing__c, FlightListing__c, Activity_Listing__c, 
        // Duration__c FROM LineItem__c
        LineItem__c lineItem = new LineItem__c();
        //lineItem.Name = 'Test Line Item';
        lineItem.Itinerary__c = itineraryList.Id;
        lineItem.Short_Title__c = 'Test Short Title';
        lineItem.Detail__c = 'Test Detail';
        lineItem.Additional_Information__c = 'Test Additional Information';
        lineItem.Day__c = 1;
        lineItem.Type__c = 'Stay';
        lineItem.Sequence__c = 1;
        lineItem.activity_Listing__c = activityList.Id;
        lineItem.Duration__c = 2;
        insert lineItem;
        // Content version data
        // Create Content Version data
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Content Version';
        contentVersion.PathOnClient = 'Test Document.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.ContentLocation = 'S';
        contentVersion.IsMajorVersion = true;
        insert contentVersion;
        // Query the Content version to get the ContentDocumentId
        contentVersion v= [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Content Version' LIMIT 1];
        // Create Content Document Link data
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = v.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = itineraryList.Id;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;
        // Call the method
        Test.startTest();
        String result = ItineraryCmpHandler.getItinerary();
        Test.stopTest();
        // Verify the result
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertNotEquals('', result, 'The result should not be empty');
        // Verify the itinerary listing
        List<Itinerary_Listing__c> itineraryListResult = [SELECT Id, Name, Destination__c, Is_Active__c, Min_Price__c, 
                                                          Details__c, Max_Price__c, Image_Link__c, Image_ID__c, Interest__c 
                                                          FROM Itinerary_Listing__c WHERE Id = :itineraryList.Id];
        System.assertEquals(1, itineraryListResult.size(), 'There should be one itinerary listing');
        Itinerary_Listing__c itinerary = itineraryListResult[0];
        System.assertEquals('Test Itinerary', itinerary.Name, 'The itinerary name should match');
        System.assertEquals('Test Destination', itinerary.Destination__c, 'The itinerary destination should match');
        System.assertEquals(true, itinerary.Is_Active__c, 'The itinerary should be active');
        System.assertEquals(100, itinerary.Min_Price__c, 'The itinerary min price should match');
        System.assertEquals(500, itinerary.Max_Price__c, 'The itinerary max price should match');
        System.assertEquals('Test Details', itinerary.Details__c, 'The itinerary details should match');
        System.assertEquals('test_image_link', itinerary.Image_Link__c, 'The itinerary image link should match');   
        System.assertEquals('test_image_url', itinerary.Image_ID__c, 'The itinerary image ID should match');
        
    }    
    @isTest
    public static void testGetIcon() {
        // Test the getIcon method
        String iconName = 'Stay';
        String expectedIcon = 'standard:household';
        String actualIcon = ItineraryCmpHandler.getIcon(iconName);
        System.assertEquals(expectedIcon, actualIcon, 'The icon should match the expected value');
        
        iconName = 'Activity';
        expectedIcon = 'standard:sales_channel';
        actualIcon = ItineraryCmpHandler.getIcon(iconName);
        System.assertEquals(expectedIcon, actualIcon, 'The icon should match the expected value');

        iconName = 'Travel';
        expectedIcon = 'standard:work_order';
        actualIcon = ItineraryCmpHandler.getIcon(iconName);
        System.assertEquals(expectedIcon, actualIcon, 'The icon should match the expected value');
    }
}