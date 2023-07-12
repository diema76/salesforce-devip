@isTest
private class API_QuoteTriggerHelperTEST {
    
    @TestSetup static void setup(){  
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerName', 'testManagerLastN');
        manager.LocaleSidKey='it_IT';
        insert manager;   
        
        u = API_dataFactory.createUser('testAgentName', 'testAgentLastName', 'AgentiPartnerCommunity', 'AgentiPartnerCommunityAccount', 'testContactName', manager.Id);
    	
    }
    
    
    @isTest static void testClassAssunta(){
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
        q3.API_CheckControlloCarte__c=true;
        update q3;
       
        
        //test commissione IPMATIC
        /*Product2 p=new Product2();
        p.Name='Commissione IP Matic';
        insert p;
		List<PricebookEntry> peList= new List<PricebookEntry>();
        PricebookEntry pe= new PricebookEntry();
        pe.Pricebook2Id=Test.getStandardPricebookId();
        pe.Product2Id=p.Id;
        pe.UnitPrice=10;
		peList.add(pe);
        //insert pe;
        PricebookEntry pe2= new PricebookEntry();
        pe2.Pricebook2Id=pBook.Id;
        pe2.IsActive=true;
        pe2.Product2Id=p.Id;
        pe2.UnitPrice=10;
        peList.add(pe2);
        insert peList;*/
        List<Quote> listQuote= new List<Quote>();
        listQuote.add(q3);
        
        API_QuoteTriggerHelper.addCommissioneIPMATIC(listQuote);
         q3.status='Verifica BO';
        acc.API_CodiceCliente__c = '34234';
        acc.API_Iban__c='AA00A0123456789012345678900';
        update acc;
        update q3;
        API_QuoteTriggerHelper.cambioStatoInseritaSap(listQuote);
    }
    
    @isTest private static void creaTask(){
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
        User u= [Select id, managerId, firstName, User.Name from user limit 1];
        API_QuoteTriggerHelper.creaTask(u, q3, u.Id);
    }
    
    @isTest private static void controlloDeleghe1(){
        
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerNamedd', 'testManagerLastNdd');
        manager.LocaleSidKey='it_IT';
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
            
            acc = API_dataFactory.createAccount('testAcc','32165487','testRagioneSociale');
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
            q.Stato_Approvazione__c='Bozza';
            
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
        
        Quote q = [Select Id, API_ScontoBaseDelegheValoreNEW__c,API_ScontoPacchetto__c, API_CommissionePedaggio__c, API_DelegaCommissione__c,
                   API_ScontoBaseDeleghe__c,API_BonusDeleghe__c,API_BonusGaranzia__c,API_ScontoSiteReteDeleghe__c,API_TipoBonus__c,API_Pacchetto__c,
                   API_Offerta__c,API_PrevisioneConsumi__c
                   from Quote Limit 1];
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoPacchettoValoreSconto', 'test', 'Sconto Pacchetto', 'nameTest', '1');
        itemList.add(item); 
        item = API_dataFactory.createQuoteLineItemX('API_CommissioneValore', 'test', 'Commissione IP Matic', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'test', 'Bonus', 'nameTest', '04');
        itemList.add(item); 
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'test', 'Bonus', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_ScontoGaranziaValoreSconto', 'test', 'Bonus garanzia', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_PedaggioCommissionePercentuale', 'test', 'Pedaggi', 'nameTest', '04');
        itemList.add(item);
        
        
        List<API_DeleghePacchetto__mdt> delegheList = [select DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, API_NomeDelega__c, API_Offerta__c, API_PacchettoScelto__c, API_Profilo__c, API_ValoreSconto__c  
                                                       from API_DeleghePacchetto__mdt];
        
        Profile p = API_dataFactory.getProfileByName('AgentiPartnerCommunity');
        Profile p2 = API_dataFactory.getProfileByName('System Administrator');
        List<String>stringList = new List<String>();
        API_QuoteTriggerHelper.controlloDeleghe(itemList[0], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[1], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[2], q, delegheList,p.Name, 'test', stringList);
        //API_QuoteTriggerHelper.controlloDeleghe(itemList[3], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[4], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[5], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[6], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[7], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[8], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[9], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[2], q, delegheList,p.Name, 'test', stringList);
        
        
        
        q.API_Offerta__c = 'Miglior Prezzo';
        q.API_ScontoBaseDelegheValoreNEW__c= 10;
        API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
        q.API_ScontoBaseDelegheValoreNEW__c= 0.1;
        API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
        q.API_Offerta__c = 'Prezzo Pompa';
        q.API_ScontoBaseDelegheValoreNEW__c = 10;
        
        API_QuoteTriggerHelper.controlloDeleghe(itemList[2], q, delegheList,p.Name, 'test', stringList);  
    }
    
   /* @isTest static void testClassAntonio(){
        Account acc = API_dataFactory.createAccount('testAcc','32154987','testRagioneSociale');
        insert acc;
       
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        
        Product2 p2 = new Product2(Name='Bonus');
        insert p2;
        
        PricebookEntry priceBookE = new PricebookEntry();
        priceBookE.Product2Id = p2.Id;
        priceBookE.Pricebook2Id = Test.getStandardPricebookId();
        priceBookE.UnitPrice = 10;
        priceBookE.UseStandardPrice = false;
        priceBookE.IsActive = true;
        insert priceBookE;
        
        PricebookEntry priceBookE2 = new PricebookEntry();
        priceBookE2.Product2Id = p2.Id;
        priceBookE2.Pricebook2Id = pBook.Id;
        priceBookE2.UnitPrice = 10;
        priceBookE2.UseStandardPrice = false;
        priceBookE2.IsActive = true;
        insert priceBookE2;        
        
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        q.API_GenerataDaContrattoQuadro__c = false;
        q.status='Bozza';
        insert q;       
        
        List<Quote> quotesss= new List<Quote>();
        Quote q2 = API_dataFactory.createQuote(opp.id, pBook);        
        q2.API_GenerataDaContrattoQuadro__c = false;
        q2.API_Contratto_quadro__c = q.id;      
        quotesss.add(q2);
        //insert q2;
        
        Quote q3;
        q3 = API_dataFactory.createQuote(opp.id, pBook);        
        q3.API_GenerataDaContrattoQuadro__c = false;        
        q3.status = 'Affidato';                    
        //insert q3;
        quotesss.add(q3);
        insert quotesss;
        
        List<API_Allegato__c> allegati=new List<API_Allegato__c>();
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
        allegati.add(attach2);
        //insert attach2;    
        
        API_Allegato__c attach3 = new API_Allegato__c();
        attach3.API_Quote__c = q3.id;
        attach3.RecordTypeId = Schema.SObjectType.API_Allegato__c.getRecordTypeInfosByDeveloperName().get('API_QuoteAllegato').getRecordTypeId();
        attach3.API_Tipologia__c = 'Libretti';
        allegati.add(attach3);
        //insert attach3;  
        insert allegati;
        
        q3.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard_Completata').getRecordTypeId();
        update q3;
        
        List<Quote> quoteList = new List<Quote>();
        quoteList.add(q);
        
        update q2;
        
        API_QuoteTriggerHelper.creaQuoteContrattoQuadro(quoteList);
        
        API_QuoteTriggerHelper.addCommissioneIPMATIC(quoteList);
        
        //API_QuoteTriggerHelper.checkDocumentiObbligatori(new List<Quote>{q3});
    }*/
    
    @isTest static void testClassAntonio2(){
        Account acc = API_dataFactory.createAccount('testAcc','498751','testRagioneSociale');
        insert acc;
        
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        Product2 p2 = new Product2(Name='Bonus');
        insert p2;
        
        PricebookEntry priceBookE = new PricebookEntry();
        priceBookE.Product2Id = p2.Id;
        priceBookE.Pricebook2Id = Test.getStandardPricebookId();
        priceBookE.UnitPrice = 10;
        priceBookE.UseStandardPrice = false;
        priceBookE.IsActive = true;
        insert priceBookE;
        
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        q.API_GenerataDaContrattoQuadro__c = false;
        q.status='Bozza';
        insert q;  
        
        List<Quote> quoteList = new List<Quote>();
        q.API_CodiceFiscaleFirmatarioSepa__c = 'SSNNTN91R21F839O';
        update q;
        quoteList.add(q);
        
        API_QuoteTriggerHelper.creaQuoteContrattoQuadro(quoteList);
        
    }
    
    @isTest static void testClassAntonio3(){
        Account acc = API_dataFactory.createAccount('testAcc','87452','testRagioneSociale');
        insert acc;
        
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        Product2 p2 = new Product2(Name='Bonus');
        insert p2;
        
        PricebookEntry priceBookE = new PricebookEntry();
        priceBookE.Product2Id = p2.Id;
        priceBookE.Pricebook2Id = Test.getStandardPricebookId();
        priceBookE.UnitPrice = 10;
        priceBookE.UseStandardPrice = false;
        priceBookE.IsActive = true;
        insert priceBookE;
        
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        q.API_GenerataDaContrattoQuadro__c = false;
        q.status='Bozza';
        insert q;  
        
        List<Quote> quoteList = new List<Quote>();
        q.API_CodiceFiscaleFirmatarioSepa__c = 'SSNNTN91R21F839O';
        update q;
        quoteList.add(q);
        
        q.Name = 'IP PLUS ONLINE';
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Contratto_Quadro').getRecordTypeId();
        update q;
        API_QuoteTriggerHelper.settaIPPlusOnline(quoteList);

        
    }
     @isTest static void testClassCQ(){
        Account acc = API_dataFactory.createAccount('testAcc','87452','testRagioneSociale');
        insert acc;
        
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        Product2 p2 = new Product2(Name='Bonus');
        insert p2;
        

        
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        q.API_GenerataDaContrattoQuadro__c = false;
        q.status='Bozza'; 
        q.API_CodiceFiscaleFirmatarioSepa__c = 'SSNNTN91R21F839O';
        q.Name = 'IP PLUS ONLINE';
        insert q;  
      
         
        List<Quote> quoteList = new List<Quote>();
       
        Quote q1 = API_dataFactory.createQuote(opp.id, pBook);
        q1.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Standard-Bozza').getRecordTypeId();
        q1.API_GenerataDaContrattoQuadro__c = false;
        q1.status='Bozza'; 
         q1.API_Contratto_quadro__c=q.Id;
        q1.API_CodiceFiscaleFirmatarioSepa__c = 'SSNNTN91R21F839O';
        q1.Name = 'IP ';
        insert q1;  
        quoteList.add(q1);
        
        API_QuoteTriggerHelper.ribaltaContrattoQuadroSuQuote(quoteList);

        
    }
    
   /* @isTest static void testClassAntonio4(){
        Account acc = API_dataFactory.createAccount('testAcc','5346847','testRagioneSociale');
        insert acc;
        
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        Product2 p2 = new Product2(Name='Bonus');
        insert p2;
        
        PricebookEntry priceBookE2 = new PricebookEntry();
        priceBookE2.Product2Id = p2.Id;
        priceBookE2.Pricebook2Id = Test.getStandardPricebookId();
        priceBookE2.UnitPrice = 10;
        priceBookE2.UseStandardPrice = false;
        priceBookE2.IsActive = true;
        insert priceBookE2;
        
        PricebookEntry priceBookE = new PricebookEntry();
        priceBookE.Product2Id = p2.Id;
        priceBookE.Pricebook2Id = pBook.Id;
        priceBookE.UnitPrice = 10;
        priceBookE.UseStandardPrice = false;
        priceBookE.IsActive = true;
        insert priceBookE;
        
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        q.API_GenerataDaContrattoQuadro__c = false;
        q.status='Bozza';
        insert q;  
        QuoteLineItem qliQ = new QuoteLineItem();
        qliQ.QuoteId = q.id;
        qliQ.Quantity = 1;
        qliQ.UnitPrice = 1;
        qliQ.PricebookEntryId = priceBookE.Id;
        qliQ.Product2Id = p2.Id;
        insert qliQ;
        

        
        List<Quote> quoteList = new List<Quote>();
        q.API_CodiceFiscaleFirmatarioSepa__c = 'SSNNTN91R21F839O';	
        update q;
        
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = q.id;
        qli.Quantity = 1;
        qli.UnitPrice = 1;
        qli.PricebookEntryId = priceBookE.Id;
        qli.Product2Id = p2.Id;
        insert qli;
        quoteList.add(q);
        q.status='Firma';
        acc.API_CodiceCliente__c = '';
        acc.API_Iban__c='AA00A0123456789012345678900';
        update acc;
        update q;
        
        API_QuoteTriggerHelper.ribaltaCampiSuAccount(quoteList);
       
        
    }*/
    /***@isTest static void testClassaaaaa(){

        List<Quote> quoteList = new List<Quote>();
        Account acc = API_dataFactory.createAccount('testAcc','5346847','testRagioneSociale');
        List<Account> accs=new List<Account>();
        accs.add(acc);
        Account accQ = API_dataFactory.createAccount('testAcc','87452','testRagioneSociale');
        accQ.API_Iban__c='AA00A0123456789012345678922';
        accs.add(accQ);
        insert accs;
        
        List<Opportunity> opps= new List<Opportunity>();
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        opps.add(opp);
        Opportunity oppQ = API_dataFactory.createOpportunity(accQ.id);
        opps.add(oppQ);
        insert opps; 
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        Product2 p2 = new Product2(Name='Bonus');
        insert p2;
        
        PricebookEntry priceBookE2 = new PricebookEntry();
        priceBookE2.Product2Id = p2.Id;
        priceBookE2.Pricebook2Id = Test.getStandardPricebookId();
        priceBookE2.UnitPrice = 10;
        priceBookE2.UseStandardPrice = false;
        priceBookE2.IsActive = true;
        insert priceBookE2;
        
        PricebookEntry priceBookE = new PricebookEntry();
        priceBookE.Product2Id = p2.Id;
        priceBookE.Pricebook2Id = pBook.Id;
        priceBookE.UnitPrice = 10;
        priceBookE.UseStandardPrice = false;
        priceBookE.IsActive = true;
        insert priceBookE;
        
        Quote q = API_dataFactory.createQuote(opp.id, pBook);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        q.API_GenerataDaContrattoQuadro__c = false;
        q.status='Bozza';
        q.Name='CQ';
        insert q;  
        QuoteLineItem qliQ = new QuoteLineItem();
        qliQ.QuoteId = q.id;
        qliQ.Quantity = 1;
        qliQ.UnitPrice = 1;
        qliQ.PricebookEntryId = priceBookE.Id;
        qliQ.Product2Id = p2.Id;
        insert qliQ;
        
        Quote qN = API_dataFactory.createQuote(oppQ.id, pBook);
        qN.API_Contratto_quadro__c=q.Id;
        q.Name='AA';
        insert qN;
       
        quoteList.add(q);
        quoteList.add(qN);
        
        API_QuoteTriggerHelper.ribaltaContrattoQuadroSuQuote(quoteList); 
        
    }*/
    
    @isTest private static void insertQLIX(){
        
        User manager, u, areaManager, userTwo;
        manager = API_dataFactory.createUser('testManagerNamedd', 'testManagerLastNdd');
        manager.LocaleSidKey='it_IT';
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
            
            acc = API_dataFactory.createAccount('testAcc','32165487','testRagioneSociale');
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
            Quote q1;
            q1 = API_dataFactory.createQuote(opp.id, pBook);
            q1.API_ScontoBaseDelegheValoreNEW__c = 10000;
            q1.API_Offerta__c = 'Prezzo Listino';  
            q1.API_Pacchetto__c = 'Base';
            q1.API_PrevisioneConsumi__c=100;
            qList.add(q1);
            
            insert qList;
            
            
        
        
        Quote q = [Select Id,Status,API_NumeroVersione__c, API_ScontoBaseDelegheValoreNEW__c,API_ScontoPacchetto__c, API_CommissionePedaggio__c, API_DelegaCommissione__c,
                   API_ScontoBaseDeleghe__c,API_BonusDeleghe__c,API_BonusGaranzia__c,API_ScontoSiteReteDeleghe__c,API_TipoBonus__c,API_Pacchetto__c,
                   API_Offerta__c,API_PrevisioneConsumi__c
                   from Quote Limit 1];
        
        List<API_QuoteLineItemX__c> itemList = new List<API_QuoteLineItemX__c>();
        
        API_QuoteLineItemX__c item = API_dataFactory.createQuoteLineItemX('API_ScontoPacchettoValoreSconto', 'test', 'Sconto Pacchetto', 'nameTest', '1');
        itemList.add(item); 
        item = API_dataFactory.createQuoteLineItemX('API_CommissioneValore', 'test', 'Commissione IP Matic', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'test', 'Sconto base', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'test', 'Bonus', 'nameTest', '04');
        itemList.add(item); 
        item = API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'test', 'Bonus', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_ScontoGaranziaValoreSconto', 'test', 'Bonus garanzia', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '04');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_Sconto_sito_rete_Prodotti', 'test', 'Sconto Site/Rete', 'nameTest', '05');
        itemList.add(item);
        item = API_dataFactory.createQuoteLineItemX('API_PedaggioCommissionePercentuale', 'test', 'Pedaggi', 'nameTest', '04');
        itemList.add(item);
        
        
        List<API_DeleghePacchetto__mdt> delegheList = [select DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, API_NomeDelega__c, API_Offerta__c, API_PacchettoScelto__c, API_Profilo__c, API_ValoreSconto__c  
                                                       from API_DeleghePacchetto__mdt];
        
        Profile p = API_dataFactory.getProfileByName('AgentiPartnerCommunity');
        Profile p2 = API_dataFactory.getProfileByName('System Administrator');
        List<String>stringList = new List<String>();
        API_QuoteTriggerHelper.controlloDeleghe(itemList[0], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[1], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[2], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[3], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[4], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[5], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[6], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[7], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[8], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[9], q, delegheList,p.Name, 'test', stringList);
        API_QuoteTriggerHelper.controlloDeleghe(itemList[2], q, delegheList,p.Name, 'test', stringList);
        
        
        
        q.API_Offerta__c = 'Miglior Prezzo';
        q.API_ScontoBaseDelegheValoreNEW__c= 0;
        q.API_PrevisioneConsumi__c=100;
        API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
        API_prodottiController.controlloDeleghe(itemList[3], q, delegheList,p, 'test');
        q.API_ScontoBaseDelegheValoreNEW__c= 0;
        q.API_PrevisioneConsumi__c=4000;
        API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
        API_prodottiController.controlloDeleghe(itemList[3], q, delegheList,p, 'test');
        q.API_ScontoBaseDelegheValoreNEW__c= 0.1;
        q.API_PrevisioneConsumi__c=26000;
        API_prodottiController.controlloDeleghe(itemList[2], q, delegheList,p, 'test');
        API_prodottiController.controlloDeleghe(itemList[3], q, delegheList,p, 'test');
        q.API_Offerta__c = 'Prezzo Pompa';
        q.API_ScontoBaseDelegheValoreNEW__c = 10;
        List<Quote> quotesss= new List<Quote>();
        quotesss.add(q);
        API_QuoteTriggerHelper.numeroVersione(quotesss);
        
        API_QuoteTriggerHelper.controlloDeleghe(itemList[2], q, delegheList,p.Name, 'test', stringList);  
            }
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
        q.API_ScontoBaseDelegheValoreNEW__c = 1;
        q.Stato_Approvazione__c='Da scalare';
        //q.API_QuoteInDelega__c=true;
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
}