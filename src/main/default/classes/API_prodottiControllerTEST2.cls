@isTest
private class API_prodottiControllerTEST2 {	    
    
    @TestSetup static void setup(){
        
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerName', 'testManagerLastN');
        insert manager;   
      
        u = API_dataFactory.createUser('testName5','testLastName5', 'Profilo Area Manager','Area Manager Vendite dirette');
        
        
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
            
            acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');
            insert acc;
            
            
            Opportunity opp = API_dataFactory.createOpportunity(acc.id);
            insert opp;
            
            Pricebook2 pBook = API_dataFactory.createPricebook2();
            pBook.Name = 'Price Book API';
            insert pBook;
            
            
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
            }
            
            List<Quote> qList = new List<Quote>();
            Quote q;
            q = API_dataFactory.createQuote(opp.id, pBook);
            q.API_ScontoBaseDelegheValoreNEW__c = 0;
            q.API_Offerta__c = 'Prezzo Listino';  
            q.API_Pacchetto__c = 'Base';
            qList.add(q);
            
            q = API_dataFactory.createQuote(opp.id, pBook);
            q.API_ScontoBaseDelegheValoreNEW__c = 0;
            q.API_Offerta__c = 'Miglior Prezzo';    
            q.API_Pacchetto__c = 'Base';
            qList.add(q);      
          
            q = API_dataFactory.createQuote(opp.id, pBook);
            q.API_ScontoBaseDelegheValoreNEW__c = 0;
            q.API_Offerta__c = 'Prezzo Pompa';            
            q.API_Pacchetto__c = 'Base';
            qList.add(q);      
            insert qList;

        }  
    }
    
    
   /* @isTest private static void addProductTEST1(){
        
        //User u = API_dataFactory.createUserwithoutInsert('testName5','testLastName5', 'Profilo Area Manager','Area Manager Canale Diretto');
        
        User u = [Select id from user where UserRole.Name = 'Area Manager Vendite dirette' limit 1];                    
        
        
        Quote q = [Select Id from Quote Where API_Offerta__c = 'Prezzo Listino' AND API_ScontoBaseDelegheValoreNEW__c = 0 Limit 1];
        Quote q1 = [Select Id from Quote Where API_Offerta__c = 'Miglior Prezzo' AND API_ScontoBaseDelegheValoreNEW__c = 0 Limit 1];
        Quote q2 = [Select Id from Quote Where API_Offerta__c = 'Prezzo Pompa' AND API_ScontoBaseDelegheValoreNEW__c = 0 Limit 1];
        
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'testNomeAttributo', 'Sconto base', 'testName', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'testNomeAttributo1', 'Sconto base', 'testName1', '04');
        itemList.add(item);
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        for(API_QuoteLineItemX__c i : itemList){
            attributiMap.put('Valore', i.API_Valore__c);        
            attributiMap.put('API_NomeProdotto', i.API_NomeProdotto__c);
            attributiMap.put('API_Attributo', i.API_NomeAttributo__c);
            attributiMap.put('API_DeveloperNameMetadata', i.API_DeveloperNameMetadata__c);                            
            attributiList.add(JSON.serialize(attributiMap));                    
        }
        
        System.runAs(u){
        Test.startTest();
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, false);
            API_prodottiController.addProduct(q1.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, false);
            API_prodottiController.addProduct(q2.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, false);
        Test.stopTest();       
        }
        
        
        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);     
        attributiList.add(JSON.serialize(attributiMap));      
        System.runAs(u){
		
        	API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, true);
            API_prodottiController.addProduct(q1.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, true);
            API_prodottiController.addProduct(q2.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, true);
        
        }
        
    }
    
    
    @isTest private static void addProductTEST2(){
    
        User u = [Select id from user where UserRole.Name = 'Area Manager Vendite dirette' limit 1];         
        Quote q = [Select Id from Quote Limit 1];
       
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'testNomeAttributo', 'Sconto Site/Rete', 'testName', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'testNomeAttributo1', 'Sconto Site/Rete', 'testName1', '03');
        itemList.add(item);
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        for(API_QuoteLineItemX__c i : itemList){
            attributiMap.put('Valore', i.API_Valore__c);        
            attributiMap.put('API_NomeProdotto', i.API_NomeProdotto__c);
            attributiMap.put('API_Attributo', i.API_NomeAttributo__c);
            attributiMap.put('API_DeveloperNameMetadata', i.API_DeveloperNameMetadata__c);                            
            attributiList.add(JSON.serialize(attributiMap));                    
        }
        
        System.runAs(u){
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Pedaggi', attributiList, false);
        }
        
        
        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);      
        attributiList.add(JSON.serialize(attributiMap));     
        System.runAs(u){
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, true);
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Pedaggi', attributiList, true);
        }
    }  
    
    
    @isTest private static void addProductTEST3(){
    
        User u = [Select id from user where UserRole.Name = 'Area Manager Vendite dirette' limit 1];         
        Quote q = [Select Id from Quote Limit 1];
       
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
                    
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_ValoreSconto', 'test', 'Sconto base', 'nameTest', '0.1');
        itemList.add(item);   
        item = API_dataFactory.createQuoteLineItemX('Api_BonusTipo', 'test', 'Bonus', 'nameTest', '0.1');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_ScontoGaranziaValoreSconto', 'test', 'Bonus garanzia', 'nameTest', '0.1');
        itemList.add(item);
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        for(API_QuoteLineItemX__c i : itemList){
            attributiMap.put('Valore', i.API_Valore__c);        
            attributiMap.put('API_NomeProdotto', i.API_NomeProdotto__c);
            attributiMap.put('API_Attributo', i.API_NomeAttributo__c);
            attributiMap.put('API_DeveloperNameMetadata', i.API_DeveloperNameMetadata__c);                            
            attributiList.add(JSON.serialize(attributiMap));                    
        }
        
        System.runAs(u){
            Test.startTest();
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Sconto base', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Bonus', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[2].API_NomeProdotto__c,'Bonus garanzia', attributiList, false);
            Test.stopTest();
        }

        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);      
        attributiList.add(JSON.serialize(attributiMap));     
        System.runAs(u){
           
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Sconto base', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Bonus', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[2].API_NomeProdotto__c,'Bonus garanzia', attributiList, false);
         
        }
    }
    
    
     @isTest private static void addProductTEST4(){
    
        User u = [Select id from user where UserRole.Name = 'Area Manager Vendite dirette' limit 1];         
        Quote q = [Select Id from Quote Limit 1];
       
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
                    
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '0.1');
        itemList.add(item);   
       item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '0.1');
        itemList.add(item);
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        for(API_QuoteLineItemX__c i : itemList){
            attributiMap.put('Valore', i.API_Valore__c);        
            attributiMap.put('API_NomeProdotto', i.API_NomeProdotto__c);
            attributiMap.put('API_Attributo', i.API_NomeAttributo__c);
            attributiMap.put('API_DeveloperNameMetadata', i.API_DeveloperNameMetadata__c);                            
            attributiList.add(JSON.serialize(attributiMap));                    
        }
        
        System.runAs(u){
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Sconto Site/Rete', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Sconto base', attributiList, false);
        }

        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);      
        attributiList.add(JSON.serialize(attributiMap));     
        System.runAs(u){
           
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Sconto Site/Rete', attributiList, false);
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Sconto base', attributiList, false);         
        }
    }*/
    
     @isTest private static void controlloDeleghe1(){
    
        Quote q = [Select Id, API_ScontoBaseDelegheValoreNEW__c,API_ScontoPacchetto__c, API_CommissionePedaggio__c, API_DelegaCommissione__c,
                   API_ScontoBaseDeleghe__c,API_BonusDeleghe__c,API_BonusGaranzia__c,API_ScontoSiteReteDeleghe__c,API_TipoBonus__c,API_Pacchetto__c,
                   API_Offerta__c,API_PrevisioneConsumi__c
                   from Quote Limit 1];
       
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
                    
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoPacchettoValoreSconto', 'test', 'Sconto Pacchetto', 'nameTest', '1');
        itemList.add(item); 
        item = API_dataFactory.createQuoteLineItemX('API_CommissioneValore', 'test', 'Commissione IP Matic', 'nameTest', '1');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'test', 'Bonus', 'nameTest', '04');
        itemList.add(item); 
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'test', 'Bonus', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto base', 'nameTest', '05');
        itemList.add(item);
         
         

		List<API_DeleghePacchetto__mdt> delegheList = [select DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, API_NomeDelega__c, API_Offerta__c, API_PacchettoScelto__c, API_Profilo__c, API_ValoreSconto__c  
    	 												from API_DeleghePacchetto__mdt];
         
         Profile p = API_dataFactory.getProfileByName('AgentiPartnerCommunity');
         Profile p2 = API_dataFactory.getProfileByName('System Administrator');
         
         API_prodottiController.controlloDeleghe(itemList[0], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[1], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'cccc');
         API_prodottiController.controlloDeleghe(itemList[3], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[4], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[5], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[6], q, delegheList,p, 'test');
         API_prodottiController.controlloDeleghe(itemList[5], q, delegheList,p2, 'AgentiPartnerCommunity');
         API_prodottiController.controlloDeleghe(itemList[6], q, delegheList,p2, 'Area Manager Vendite');
         API_prodottiController.controlloDeleghe(itemList[7], q, delegheList,p2, 'test');
                
         
         q.API_Offerta__c = 'Miglior Prezzo';
         q.API_ScontoBaseDelegheValoreNEW__c= 10;
 		 API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
         q.API_ScontoBaseDelegheValoreNEW__c= 0.1;
         API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
         q.API_Offerta__c = 'Prezzo Pompa';
         q.API_ScontoBaseDelegheValoreNEW__c = 10;
         API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');  
    }
    
     @isTest private static void controlloDeleghe2(){
    
        Quote q = [Select Id, API_ScontoBaseDelegheValoreNEW__c,API_ScontoPacchetto__c, API_CommissionePedaggio__c, API_DelegaCommissione__c,
                   API_ScontoBaseDeleghe__c,API_BonusDeleghe__c,API_BonusGaranzia__c,API_ScontoSiteReteDeleghe__c,API_TipoBonus__c,API_Pacchetto__c,
                   API_Offerta__c,API_PrevisioneConsumi__c
                   from Quote Limit 1];
       
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
                    
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', 'AAB');
        itemList.add(item); 
         

		List<API_DeleghePacchetto__mdt> delegheList = [select DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, API_NomeDelega__c, API_Offerta__c, API_PacchettoScelto__c, API_Profilo__c, API_ValoreSconto__c  
    	 												from API_DeleghePacchetto__mdt];
         
         Profile p = API_dataFactory.getProfileByName('AgentiPartnerCommunity');
         Profile p2 = API_dataFactory.getProfileByName('System Administrator');
         
         API_prodottiController.controlloDeleghe(itemList[0], q, delegheList,p, 'test');
         q.API_Offerta__c ='Prezzo Listino';
         q.API_PrevisioneConsumi__c=1500;
         API_prodottiController.controlloDeleghe(itemList[0], q, delegheList,p, 'test');
  

         API_prodottiController.controlloDeleghe(itemList[0], q, delegheList,p2, 'Area Manager Vendite');
         q.API_Offerta__c ='Prezzo Pompa';
         API_prodottiController.controlloDeleghe(itemList[0], q, delegheList,p2, 'Area Manager Vendite');
         API_prodottiController.controlloDeleghe(itemList[1], q, delegheList,p2, 'Area Manager Vendite'); 
         q.API_Offerta__c ='Miglior Prezzo';
         API_prodottiController.controlloDeleghe(itemList[0], q, delegheList,p2, 'Area Manager Vendite');
         

    }
    
    
}