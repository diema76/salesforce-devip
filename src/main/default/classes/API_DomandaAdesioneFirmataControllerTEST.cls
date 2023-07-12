@isTest
private class API_DomandaAdesioneFirmataControllerTEST {
    @isTest static void testClass(){ 
        API_Allegato__c allegato = new API_Allegato__c();
        
        insert allegato;
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');        
        insert acc;        
        
        API_Divisione__c div = API_dataFactory.createDivisione(acc.id);
        insert div;
        
        Contact c = API_dataFactory.createContact('testContactName',acc.id, 'Debitore');
        
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.Status ='Bozza';
        insert q;
        allegato.API_Quote__c=q.Id;
        update allegato; 
        ContentVersion contentVersion = new ContentVersion(
          Title = 'documento identita',
          PathOnClient = 'documento.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        try{
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = q.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility='AllUsers';
        insert cdl;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        API_DomandaAdesioneFirmataController.getFiles(q.Id);
        API_DomandaAdesioneFirmataController.getAllegatoID(q.Id);
        API_DomandaAdesioneFirmataController.setFlagQuote(allegato.Id);
        API_DomandaAdesioneFirmataController.deleteAllegato();
    }
}