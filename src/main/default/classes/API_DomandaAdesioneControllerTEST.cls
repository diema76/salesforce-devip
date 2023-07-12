@isTest
private class API_DomandaAdesioneControllerTEST {
    
    @isTest static void testClass1(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Bonus'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','123456789','testRagioneSociale');        
        insert acc;        
        
        API_Divisione__c div = API_dataFactory.createDivisione(acc.id);
        insert div;
        
        Contact c = API_dataFactory.createContact('testContactName',acc.id, 'Debitore');
        
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
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        API_ContoCarte__c cCarte = API_dataFactory.createContoCarte(div.id, qList[0].Id);
        insert cCarte;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoPacchettoValoreSconto', 'testNomeAttributo', 'Sconto Pacchetto', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(String.valueOf(q.id), item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Profilo Area Manager'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        }
    }
    
    @isTest static void testClass2(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Bonus'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','123456789','testRagioneSociale');
        insert acc;        
        
        Contact c = API_dataFactory.createContact('testContactName',acc.id, 'Principale');
        
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
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;        
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoSiteReteValoreSconto', 'testNomeAttributo', 'Sconto Site/Rete', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        
    }    
    
    
    @isTest static void testClass3(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Bonus'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','147852369','testRagioneSociale');
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
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;        
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_ValoreSconto', 'testNomeAttributo', 'Sconto base', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        
    }      
    
    
    @isTest static void testClass4(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Bonus'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','147852369','testRagioneSociale');
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
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;        
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_BonusValore', 'testNomeAttributo', 'Bonus', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        
    }     
    
    
    @isTest static void testClass5(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Bonus'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','145236987','testRagioneSociale');
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
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;        
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoGaranziaValoreSconto', 'testNomeAttributo', 'Bonus Garanzia', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        
    }     
    
    @isTest static void testClass6(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Bonus'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','147852369','testRagioneSociale');
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
        User u = API_dataFactory.createUser('ciao', 'lastName', 'AgentiPartnerCommunity', 'accountName', 'ContactName');
        List<Quote> qList = new List<Quote>();
        Quote q;
        q = API_dataFactory.createQuote(opp.id, pBook);
        q.API_ScontoBaseDelegheValoreNEW__c = 0;
        q.API_Offerta__c = 'Prezzo Listino';  
        q.API_Pacchetto__c = 'Base';
        q.API_Fatturazione__c='15';
        q.ownerId =u.id;
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;        
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_PedaggioCommissionePercentuale', 'testNomeAttributo', 'Pedaggi', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        
    }  
   
    @isTest static void testClass7(){        
        
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name='Reti partner prezzo pompa'));
        prodList.add(new Product2(Name='Sconto Pacchetto'));    
        prodList.add(new Product2(Name='Pedaggi'));
        prodList.add(new Product2(Name='Commissione IP Matic'));
        prodList.add(new Product2(Name='Sconto base'));
        prodList.add(new Product2(Name='Bonus garanzia'));
        prodList.add(new Product2(Name='Sconto Site/Rete'));
        insert prodList;
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','12365478569','testRagioneSociale');
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
        User u = API_dataFactory.createUser('ciao', 'lastName', 'AgentiPartnerCommunity', 'accountName', 'ContactName');
        List<Quote> qList = new List<Quote>();
        Quote q;
        q = API_dataFactory.createQuote(opp.id, pBook);
        q.API_ScontoBaseDelegheValoreNEW__c = 0;
        q.API_Offerta__c = 'Prezzo Listino';  
        q.API_Pacchetto__c = 'Base';
        q.ownerId =u.id;
        q.Pricebook2Id = pBook.id;
        q.API_DataSottoscrizioneContratto__c= System.now();
        qList.add(q);
        
        insert qList;
        
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
        for(Quote qot : qList){
            API_Carta__c car = API_dataFactory.createCarta(qot);
            cartaList.add(car);            
        }
        insert cartaList;        
        
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_RetiPartnerProdotti', 'testNomeAttributo', 'Reti partner prezzo pompa', 'testName', '50');
        QuoteLineItem qli = new quoteLineItem();
        qli.Quote = q;
        qli.QuoteId= q.id;
        qli.PricebookEntryId = [select Pricebook2Id, id from PricebookEntry where Pricebook2Id =:pBook.id Limit 1].id; 
        qli.Quantity = 1;
        qli.UnitPrice= 1;
        qli.Product2Id= prodList[0].id;
        insert qli;
        
        item.API_QuoteLineItem__c = qli.id;            
        insert item;
        
        Map<String, Object> attributiMap = new Map<String, Object>();
        List<String> attributiList = new List<String>();
        attributiMap.put('Valore', item.API_Valore__c);        
        attributiMap.put('API_NomeProdotto', item.API_NomeProdotto__c);
        attributiMap.put('API_Attributo', item.API_NomeAttributo__c);
        attributiMap.put('API_DeveloperNameMetadata', item.API_DeveloperNameMetadata__c);                            
        attributiList.add(JSON.serialize(attributiMap));                    
        
        API_prodottiController.addProduct(q.id, item.API_NomeProdotto__c, item.API_DeveloperNameMetadata__c, attributiList, false);   

        
        ApexPages.StandardController sc = new ApexPages.StandardController(qList[0]);
        
        API_DomandaAdesioneController domandaAdescioneC= new API_DomandaAdesioneController(sc);                        
        
    }  
}