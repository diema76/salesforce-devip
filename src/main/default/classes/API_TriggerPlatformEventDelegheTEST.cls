@isTest
public class API_TriggerPlatformEventDelegheTEST {
    
@isTest private static void test1(){
    List<API_PlatformEventDeleghe__e> events= new List<API_PlatformEventDeleghe__e>();
	API_PlatformEventDeleghe__e e= new API_PlatformEventDeleghe__e();
    e.API_QuoteID__c= '324324324';
    e.API_UserID__c='4324324';
    events.add(e);
    Test.startTest();
     List<Database.SaveResult> results = EventBus.publish(events);
                    
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            System.debug('@@@ Successfully published event.');
                        } else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('@@@ Error returned: ' +
                                             err.getStatusCode() +
                                             ' - ' +
                                             err.getMessage());
                            }
                        }       
                    } 
    Test.stopTest();
}
}