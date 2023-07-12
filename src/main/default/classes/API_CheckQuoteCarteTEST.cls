@isTest
public class API_CheckQuoteCarteTEST {

     @TestSetup static void setup(){  
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerName', 'testManagerLastN');
        manager.LocaleSidKey='it_IT';
        insert manager;       
    }
    
    @isTest
    static void testcheckCarte(){
        Account acc = API_dataFactory.createAccount('testAcc','134698','testRagioneSociale');
        acc.API_Iban__c = 'IT66C0100503382000000218020';
        insert acc;
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        Quote q3;
        q3 = API_dataFactory.createQuote(opp.id, pBook);        
        q3.API_GenerataDaContrattoQuadro__c = false;        
        q3.status = 'Bozza'; 
         q3.Stato_Approvazione__c='In attesa';
        q3.RecordTypeId= Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard_Completata').getRecordTypeId();
        insert q3;
        List<API_Allegato__c> allegati= new List<API_Allegato__c>();
        API_Allegato__c attach = new API_Allegato__c();
        attach.API_Quote__c = q3.id;
        attach.RecordTypeId = Schema.SObjectType.API_Allegato__c.getRecordTypeInfosByDeveloperName().get('API_QuoteAllegato').getRecordTypeId();
        attach.API_Tipologia__c = 'Documento di identità';
        allegati.add(attach);
        //insert attach;      
        
        API_Allegato__c attach2 = new API_Allegato__c();
        attach2.API_Quote__c = q3.id;
        attach2.RecordTypeId = Schema.SObjectType.API_Allegato__c.getRecordTypeInfosByDeveloperName().get('API_QuoteAllegato').getRecordTypeId();
        attach2.API_Tipologia__c = 'Visura camerale non più vecchia di 6 mesi';
        //insert attach2;    
        allegati.add(attach2);
        
        API_Allegato__c attach3 = new API_Allegato__c();
        attach3.API_Quote__c = q3.id;
        attach3.RecordTypeId = Schema.SObjectType.API_Allegato__c.getRecordTypeInfosByDeveloperName().get('API_QuoteAllegato').getRecordTypeId();
        attach3.API_Tipologia__c = 'Libretti';
        allegati.add(attach3);
        //insert attach3; 
        insert allegati;
        
        q3.Status='Completata';
        try{
            update q3;
        }
        catch(Exception e){}
    }
}