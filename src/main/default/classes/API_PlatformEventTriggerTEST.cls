@isTest
private class API_PlatformEventTriggerTEST {
	@isTest static void testClass(){ 
        Account acc=API_dataFactory.createAccount('pippo','124','fruttivendolo');
        API_PlatformEventLeadDuplicato__e platfor = new API_PlatformEventLeadDuplicato__e(API_Email__c='asfa@email.com', 
                                             API_IdAccountDuplicato__c=acc.Id, 
                                             API_Oggetto__c='Account',API_PartitaIVA__c='124');
       	Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(platfor);
        
        
        
        Lead lea=API_dataFactory.createLead('124','asfd','sfd@email.com');
        API_PlatformEventLeadDuplicato__e platfor2 = new API_PlatformEventLeadDuplicato__e(API_Email__c='sfd@email.com', 
                                             API_IdAccountDuplicato__c=lea.Id, 
                                             API_Oggetto__c='Lead',API_PartitaIVA__c='124');
        
        // Publish test event
        Database.SaveResult sr2 = EventBus.publish(platfor2);
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess());
        System.assertEquals(true, sr2.isSuccess());
        
        
    }
}