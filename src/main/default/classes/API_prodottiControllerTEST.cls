@isTest
private class API_prodottiControllerTEST {	    
    
    @TestSetup static void setup(){
        
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerName', 'testManagerLastN');
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
    
    @isTest private static void getAttributiTEST(){
        
        Product2 prod = [Select Id, Name from Product2 where Name = 'Bonus' Limit 1];
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_prodottiController.getAttributi(prod.Name, false, prod.Id, q.id);
        API_prodottiController.getAttributi(prod.Name, true, prod.Id, q.id);
        
    }
    
    @isTest private static void addProductTEST1(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_PedaggioCommissionePercentuale', 'testNomeAttributo', 'Pedaggi', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id,item.API_NomeProdotto__c,'Pedaggi', attributiList, false);
        
        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);       
        attributiList.add(JSON.serialize(attributiMap));    
        API_prodottiController.addProduct(q.id,item.API_NomeProdotto__c,'Pedaggi', attributiList, true);
        
    }
    
    @isTest private static void addProductTEST2(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_CommissioneValore', 'testNomeAttributo', 'Commissione IP Matic', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        System.runAs(u){
            API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c,'Pedaggi', attributiList, false);
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
            API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, true);
        }
        
    }    
    
    @isTest private static void addProductTEST3(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_ValoreSconto', 'testNomeAttributo', 'Sconto base', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, false);
        
        
        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);       
        attributiList.add(JSON.serialize(attributiMap));    
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, true);
        
    }    
    
    @isTest private static void addProductTEST4(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_BonusValore', 'testNomeAttributo', 'Bonus', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, false);
        
        
        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);  
        attributiList.add(JSON.serialize(attributiMap));         
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, true);
        
    }    
    
    @isTest private static void addProductTEST5(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoGaranziaValoreSconto', 'testNomeAttributo', 'Bonus garanzia', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        System.runAs(u){
            API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c,'Pedaggi', attributiList, false);
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
            API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, true);
        }
        
    }        
    
    @isTest private static void addProductTEST6(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoSiteReteValoreSconto', 'testNomeAttributo', 'Sconto Site/Rete', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, false);
        
        
        attributiMap.clear();
        attributiList.clear();
        item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);      
        attributiList.add(JSON.serialize(attributiMap));     
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, true);
        
    }        
    
    @isTest private static void addProductTEST(){    
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];        
        
        
        Quote q = [Select Id from Quote Where API_Offerta__c = 'Prezzo Listino' AND API_ScontoBaseDelegheValoreNEW__c = 0 Limit 1];
        Quote q1 = [Select Id from Quote Where API_Offerta__c = 'Miglior Prezzo' AND API_ScontoBaseDelegheValoreNEW__c = 0 Limit 1];
        Quote q2 = [Select Id from Quote Where API_Offerta__c = 'Prezzo Pompa' AND API_ScontoBaseDelegheValoreNEW__c = 0 Limit 1];
        
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'testNomeAttributo', 'Sconto base', 'testName', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'testNomeAttributo1', 'Sconto base', 'testName1', '03');
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
    
      
    
    @isTest private static void addProductTEST8(){
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];       
        
        Quote q = [Select Id from Quote Limit 1];
        
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'testNomeAttributo', 'Bonus', 'testName', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'testNomeAttributo', 'Bonus', 'testName', '03');
        itemList.add(item);
        //insert itemList;
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        for(API_QuoteLineItemX__c i : itemList){
            attributiMap.put('Valore', i.API_Valore__c);        
            attributiMap.put('API_NomeProdotto', i.API_NomeProdotto__c);
            attributiMap.put('API_Attributo', i.API_NomeAttributo__c);
            attributiMap.put('API_DeveloperNameMetadata', i.API_DeveloperNameMetadata__c);                            
            attributiList.add(JSON.serialize(attributiMap));                    
        }        
        
        attributiMap.clear();
        attributiList.clear();
        //item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];     
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);      
        attributiList.add(JSON.serialize(attributiMap));     
        System.runAs(u){
            try{
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, true);
            }catch(Exception e){}
            try{
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Pedaggi', attributiList, true);
             }catch(Exception e){}
        }
    }       
    
    @isTest private static void addProductTEST8_1(){
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];       
        
        Quote q = [Select Id from Quote Limit 1];
        
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'testNomeAttributo', 'Bonus', 'testName', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'testNomeAttributo', 'Bonus', 'testName', '03');
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
        
    }       
    
 
    
    @isTest private static void addProductTEST9_1(){
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];       
        
        Quote q = [Select Id from Quote Limit 1];
        
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'testNomeAttributo', 'Sconto Site/Rete', 'testName', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'testNomeAttributo1', 'Sconto Site/Rete', 'testName1', '03');
        itemList.add(item);
        //insert itemList;
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        for(API_QuoteLineItemX__c i : itemList){
            attributiMap.put('Valore', i.API_Valore__c);        
            attributiMap.put('API_NomeProdotto', i.API_NomeProdotto__c);
            attributiMap.put('API_Attributo', i.API_NomeAttributo__c);
            attributiMap.put('API_DeveloperNameMetadata', i.API_DeveloperNameMetadata__c);                            
            attributiList.add(JSON.serialize(attributiMap));                    
        }
        
        
        attributiMap.clear();
        attributiList.clear();
        //item = [Select Id, API_Valore__c, API_NomeProdotto__c, API_NomeAttributo__c, API_DeveloperNameMetadata__c from API_QuoteLineItemX__c][0];        
        attributiMap.put('quoteLineItemXId', item.Id);        
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);      
        attributiList.add(JSON.serialize(attributiMap));     
        System.runAs(u){
            try{
            API_prodottiController.addProduct(q.id, itemList[0].API_NomeProdotto__c,'Pedaggi', attributiList, true);
            }catch(Exception e){}
            try{
            API_prodottiController.addProduct(q.id, itemList[1].API_NomeProdotto__c,'Pedaggi', attributiList, true);
            }catch(Exception e){}
        }
        
        
    }    
    
     @isTest private static void addProductTEST9_2(){
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];       
        
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
        
    }    
    
    @isTest private static void addProductTEST10(){
        
        User u = [Select id from user where FirstName = 'testAgentName' AND LastName = 'testAgentLastName' limit 1];        
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'testNomeAttributo', 'Sconto Pacchetto', 'testName', '04');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        System.runAs(u){
            API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Sconto Pacchetto',attributiList, false);
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
            API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, true);
        }
        
    }          
    
    @isTest private static void getAttributeListTEST(){        
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_PedaggioCommissionePercentuale', 'testNomeAttributo', 'Pedaggi', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c,'Pedaggi', attributiList, false);
        
        QuoteLineItem qLitem = [Select id from QuoteLineItem limit 1];
        List<String> qliIds = new List<String>();
        qliIds.add(qLitem.id);
        
        API_prodottiController.getAttributeList(qliIds);
        
    }
    
    @isTest private static void getQuoteLineItemsTEST(){
        Quote q = [Select Id from Quote Limit 1];
        
        API_prodottiController.getQuoteLineItems(q.Id);
    }
    
    @isTest private static void getOfferteTEST(){
        API_prodottiController.getOfferte();
        
    }
    
    @isTest private static void getOffertaSelezionataTEST(){
        Quote q = [Select Id from Quote Limit 1];
        
        API_prodottiController.getOffertaSelezionata(q.Id);
        
        API_prodottiController.getOffertaSelezionata(null);
        
    }
    
    @isTest private static void getQuoteTEST(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_prodottiController.getQuote(q.Id);        
        
        API_prodottiController.getQuote(null);        
        
    }
    
    @isTest private static void saveQuoteTEST(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_prodottiController.saveQuote(q);
        
    }
    
    @isTest private static void getPacchettiTEST(){
        
        API_prodottiController.getPacchetti();
        
    }
    
    @isTest private static void deleteQuoteLineItemTEST(){
        
        Quote q = [Select Id from Quote Limit 1];
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_PedaggioCommissionePercentuale', 'testNomeAttributo', 'Pedaggi', 'testName', '50');
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, 'Pedaggi',attributiList, false);
        
        API_QuoteLineItemX__c qLineItemX = [Select API_QuoteLineItem__c from API_QuoteLineItemX__c where API_QuoteLineItem__c != null limit 1];
        
        API_prodottiController.deleteQuoteLineItem(qLineItemX.API_QuoteLineItem__c);
        
    }
    
}