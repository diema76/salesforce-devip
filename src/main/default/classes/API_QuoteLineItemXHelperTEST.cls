@isTest
private class API_QuoteLineItemXHelperTEST {
     @TestSetup static void setup(){
        
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerName', 'testManagerLastN');
         manager.LocaleSidKey='it_IT';
        insert manager;   
      
        u = API_dataFactory.createUser('testAgentName', 'testAgentLastName', 'AgentiPartnerCommunity', 'AgentiPartnerCommunityAccount', 'testContactName', manager.Id);
        
        //areaManager = API_dataFactory.createUser('testName2','testLastName2', 'Profilo Area Manager');   
        
        //userTwo = API_dataFactory.createUser('testName5','testLastName5', 'Profilo Area Manager','Area Manager Canale Diretto');
        
        
        API_prodottiController.getProdotti('offerta');
        
        System.runAs(u){                
            
            List<Product2> prodList = new List<Product2>();
            prodList.add(new Product2(Name='Bonus',API_ProdottoLabel__c='Bonus'));
            prodList.add(new Product2(Name='Sconto Pacchetto',API_ProdottoLabel__c='Sconto Pacchetto'));    
            prodList.add(new Product2(Name='Pedaggi',API_ProdottoLabel__c='Pedaggi'));
            prodList.add(new Product2(Name='Commissione IP Matic',API_ProdottoLabel__c='Commissione IP Matic'));
            prodList.add(new Product2(Name='Sconto base',API_ProdottoLabel__c='Sconto base'));
            prodList.add(new Product2(Name='Bonus garanzia',API_ProdottoLabel__c='Bonus garanzia'));
            prodList.add(new Product2(Name='Sconto Site/Rete',API_ProdottoLabel__c='Sconto Site/Rete'));
            insert prodList;
            
            Account acc;
            
            acc = API_dataFactory.createAccount('testAcc','1234567896','testRagioneSociale');
            insert acc;
            
            
            Opportunity opp = API_dataFactory.createOpportunity(acc.id);
            insert opp;
            
            Pricebook2 pBook = API_dataFactory.createPricebook2();
            pBook.Name = 'Price Book API';
            insert pBook;
            PricebookEntry priceBookEEE;
            
            for(Product2 p : prodList){
                PricebookEntry priceBookE = new PricebookEntry();
                priceBookE.Product2Id = p.Id;
                priceBookE.Pricebook2Id = Test.getStandardPricebookId();
                priceBookE.UnitPrice = 10;
                priceBookE.UseStandardPrice = false;
                priceBookE.IsActive = true;
                insert priceBookE;
                
                PricebookEntry priceBookE2 = new PricebookEntry();
                priceBookE2.Product2Id = p.Id;
                priceBookE2.Pricebook2Id = pBook.Id;
                priceBookE2.UnitPrice = 10;
                priceBookE2.UseStandardPrice = false;
                priceBookE2.IsActive = true;
                insert priceBookE2;    
                priceBookEEE=priceBookE2;
            }
            
            Id devRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Standard-Bozza').getRecordTypeId();
            List<Quote> qList = new List<Quote>();
            Quote qc = API_dataFactory.createQuote(opp.id, pBook);
            qc.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
            qc.API_GenerataDaContrattoQuadro__c = false;
            qc.status='Bozza';
            insert qc; 
            qList.add(qc);
            API_QuoteTriggerHelper.addCommissioneIPMATIC(qList);
            qList = new List<Quote>();
            Quote q;
            q = API_dataFactory.createQuote(opp.id, pBook);
            q.RecordTypeId=devRecordTypeId;
            q.API_ScontoBaseDelegheValoreNEW__c = 0;
            q.API_Offerta__c = 'Prezzo Listino';  
            q.API_Pacchetto__c = 'Base';
            q.API_Contratto_quadro__c=qc.Id;
            q.API_GenerataDaContrattoQuadro__c = true;
            qList.add(q);
            
            insert qList;
            
            QuoteLineItem qliQ = new QuoteLineItem();
         qliQ.QuoteId = q.id;
         qliQ.Quantity = 1;
         qliQ.UnitPrice = 1;
         qliQ.PricebookEntryId = priceBookEEE.Id;
         qliQ.Product2Id = prodList[0].Id;
        insert qliQ;
         API_QuoteLineItemX__c quoteLIX = new API_QuoteLineItemX__c();
                quoteLIX.API_QuoteLineItem__c = qliQ.id;
                quoteLIX.API_NomeAttributo__c = 'Valore percentuale';
                quoteLIX.API_DeveloperNameMetadata__c = 'API_CommissioneValore';
                quoteLIX.API_Valore__c = '2';
                quoteLIX.API_NomeProdotto__c = 'Commissione IP Matic'; 
         insert quoteLIX;
            
        }  
    }
    
     @isTest static void test1(){
          List<API_QuoteLineItemX__c> listQuote=[Select Id, Name, API_NomeAttributo__c, API_NomeProdotto__c, API_QuoteLineItem__c, API_Valore__c, API_DeveloperNameMetadata__c, API_QuoteID__c  from API_QuoteLineItemX__c ];
          API_QuoteLineItemXHelper.checkCommissioneScontoIPMATIC(listQuote);
          QuoteLineItem qlit=[Select id from QuoteLineItem limit 1];
          API_QuoteLineItemXHelper.eliminaCommissioneIPMatic(qlit);
        
         
     }
    
}