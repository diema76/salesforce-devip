@isTest public class API_CallSAPTEST {
    
    @testSetup
    public static void setup(){
        Account a=API_dataFactory.createAccount('nome', '12345678901', 'ragionesociale');
        a.API_FormaGiuridica__c='spa';
        a.ShippingCity='test';
        a.ShippingState='xx';
        a.ShippingCountry='xxx';
        a.ShippingStreet='yyyy';
        a.ShippingPostalCode='82019';
        a.BillingCity='test';
        a.BillingState='xx';
        a.BillingCountry='xxx';
        a.BillingStreet='yyyy';
        a.BillingPostalCode='82019';
        a.API_EsenteCIG__c=false;
        a.API_ClienteTop__c=true;
        a.API_ClienteSensibile__c=true;
        a.API_FatturazionePDF__c=true;
        a.API_DataInizioValiditaCIG__c = Date.valueOf('2019-11-26');
        a.API_GruppoClientiCartesia__c = '380001 - CONTO TERZI';
        a.API_Iban__c='AA00A0123456789012345678966';
        insert a;
        Opportunity o=API_dataFactory.createOpportunity(a.Id);
        insert o;
        Pricebook2 price=API_dataFactory.createPricebook2();
        insert price;
        Quote q= API_dataFactory.createQuote(o.Id, price);
        q.API_DataSottoscrizioneContratto__c=System.today();
        q.API_CondizioniPagamento__c = 'RID-Banca-20 gg Data Fattura FuelCard';
        q.API_CodiceFiscaleFirmatarioSepa__c='SSNNTN91R21F839O';
        insert q;
        API_Carta__c carta=API_dataFactory.createCarta(q);
        carta.API_ProdottiAutorizzati__c = 'Tutti i carburanti';
        carta.API_ServiziStazione__c = 'AdBlu da erogatore';
        insert carta;
        API_Divisione__c div= API_dataFactory.createDivisione(a.Id);
        insert div;
        API_ContoCarte__c cc=API_dataFactory.createContoCarte(div.Id, q.ID);
        cc.API_ProdottiAmmessi__c = 'Tutti i carburanti';
        cc.API_ServiziInStazione__c = 'AdBlu da erogatore';
        insert cc;
        List<Product2> products= new List<Product2>();
        Product2 p2 = new Product2(Name='Bonus');
        //insert p2;
        products.add(p2);
        Product2 p3 = new Product2(Name='Commissione IP Matic');
        //insert p3;
        products.add(p3);
        Product2 p4 = new Product2(Name='Reti partner prezzo pompa');
        //insert p4;
        products.add(p4);
        Product2 pSB = new Product2(Name='Sconto base');
        //insert pSB;
        products.add(pSB);
        insert products;
        PricebookEntry priceBookSB = new PricebookEntry();
        priceBookSB.Product2Id = pSB.Id;
        priceBookSB.Pricebook2Id = Test.getStandardPricebookId();
        priceBookSB.UnitPrice = 10;
        priceBookSB.UseStandardPrice = false;
        priceBookSB.IsActive = true;
        insert priceBookSB;  
        PricebookEntry priceBookSB2 = new PricebookEntry();
        priceBookSB2.Product2Id = pSB.Id;
        priceBookSB2.Pricebook2Id = price.Id;
        priceBookSB2.UnitPrice = 10;
        priceBookSB2.UseStandardPrice = false;
        priceBookSB2.IsActive = true;
        insert priceBookSB2;  
        //Primo bonus
        PricebookEntry priceBookX1 = new PricebookEntry();
        priceBookX1.Product2Id = p2.Id;
        priceBookX1.Pricebook2Id = Test.getStandardPricebookId();
        priceBookX1.UnitPrice = 10;
        priceBookX1.UseStandardPrice = false;
        priceBookX1.IsActive = true;
        insert priceBookX1;
        PricebookEntry priceBookX = new PricebookEntry();
        priceBookX.Product2Id = p2.Id;
        priceBookX.Pricebook2Id = price.Id;
        priceBookX.UnitPrice = 10;
        priceBookX.UseStandardPrice = false;
        priceBookX.IsActive = true;
        insert priceBookX;
        
        //Reti partner prezzo pompa
        /*PricebookEntry priceBookX3 = new PricebookEntry();
        priceBookX3.Product2Id = p4.Id;
        priceBookX3.Pricebook2Id = Test.getStandardPricebookId();
        priceBookX3.UnitPrice = 10;
        priceBookX3.UseStandardPrice = false;
        priceBookX3.IsActive = true;
        insert priceBookX3;
        PricebookEntry priceBooku = new PricebookEntry();
        priceBooku.Product2Id = p4.Id;
        priceBooku.Pricebook2Id = price.Id;
        priceBooku.UnitPrice = 10;
        priceBooku.UseStandardPrice = false;
        priceBooku.IsActive = true;
        insert priceBooku;
        
        QuoteLineItem qli24 = new QuoteLineItem();
        qli24.QuoteId = q.id;
        qli24.Quantity = 1;
        qli24.UnitPrice = 1;
        qli24.PricebookEntryId = priceBooku.Id;
        qli24.Product2Id = p4.Id;
        insert qli24;
        API_QuoteLineItemX__c qx14= API_dataFactory.createQuoteLineItemX('API_RetiPartnerProdotti', 'Prodotti', 'RETI PARTNER PREZZO POMPA', 'N6', '02	Benzine (non SELF), 03	Gasoli (non SELF), 09	ADBlue');
        qx14.API_QuoteLineItem__c=qli24.Id;
        insert qx14;
        API_QuoteLineItemX__c qx24= API_dataFactory.createQuoteLineItemX('API_RetiPartnerReti', 'Reti', 'RETI PARTNER PREZZO POMPA', 'N2', 'IP MATIC');
        qx24.API_QuoteLineItem__c=qli24.Id;
        insert qx24;*/
        
        
        //COMMISSIONE IP MATIC
        PricebookEntry priceBookX2 = new PricebookEntry();
        priceBookX2.Product2Id = p3.Id;
        priceBookX2.Pricebook2Id = Test.getStandardPricebookId();
        priceBookX2.UnitPrice = 10;
        priceBookX2.UseStandardPrice = false;
        priceBookX2.IsActive = true;
        insert priceBookX2;
        PricebookEntry priceBookz = new PricebookEntry();
        priceBookz.Product2Id = p3.Id;
        priceBookz.Pricebook2Id = price.Id;
        priceBookz.UnitPrice = 10;
        priceBookz.UseStandardPrice = false;
        priceBookz.IsActive = true;
        insert priceBookz;
        
        List<API_QuoteLineItemX__c> qlixList= new  List<API_QuoteLineItemX__c>();
        List<QuoteLineItem> listQLI= new List<QuoteLineItem>();
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = q.id;
        qli.Quantity = 1;
        qli.UnitPrice = 1;
        qli.PricebookEntryId = priceBookX.Id;
        qli.Product2Id = p2.Id;
        //insert qli;
        listQLI.add(qli);
        QuoteLineItem qli22 = new QuoteLineItem();
        qli22.QuoteId = q.id;
        qli22.Quantity = 1;
        qli22.UnitPrice = 1;
        qli22.PricebookEntryId = priceBookz.Id;
        qli22.Product2Id = p3.Id;
        listQLI.add(qli22);
        //secondo bonus
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.QuoteId = q.id;
        qli2.Quantity = 1;
        qli2.UnitPrice = 1;
        qli2.PricebookEntryId = priceBookX.Id;
        qli2.Product2Id = p2.Id;
        //insert qli2;
        listQLI.add(qli2);
         //sconto base
        QuoteLineItem qli3 = new QuoteLineItem();
        qli3.QuoteId = q.id;
        qli3.Quantity = 1;
        qli3.UnitPrice = 1;
        qli3.PricebookEntryId = priceBookX.Id;
        qli3.Product2Id = pSB.Id;
        //insert qli3;
		listQLI.add(qli3);
        insert listQLI;
        
        
        //insert qli22;
        API_QuoteLineItemX__c qx13= API_dataFactory.createQuoteLineItemX('API_CommissioneValore', 'Valore sconto €/LT esente IVA', 'Commissione IP Matic', 'N1', '0.08');
        qx13.API_QuoteLineItem__c=qli22.Id;
        qlixList.add(qx13);
        //insert qx13;
        API_QuoteLineItemX__c qx23= API_dataFactory.createQuoteLineItemX('API_CommissioneDataInizio', 'Data inizio validità', 'Commissione IP Matic', 'N2', '2019-12-12');
        qx23.API_QuoteLineItem__c=qli22.Id;
        //insert qx23;
        qlixList.add(qx23);
        API_QuoteLineItemX__c qx33= API_dataFactory.createQuoteLineItemX('API_CommissioneDataFine', 'Data fine validità', 'Commissione IP Matic', 'N3', '2019-12-12');
        qx33.API_QuoteLineItem__c=qli22.Id;
        //insert qx33;
        qlixList.add(qx33);
        API_QuoteLineItemX__c qx63= API_dataFactory.createQuoteLineItemX('API_CommissioneProdotti', 'Prodotti', 'Commissione IP Matic', 'N6', '02	Benzine (non SELF), 03	Gasoli (non SELF), 09	ADBlue');
        qx63.API_QuoteLineItem__c=qli22.Id;
        //insert qx63;
        qlixList.add(qx63);
        
        
       
        
        API_QuoteLineItemX__c qx1= API_dataFactory.createQuoteLineItemX('API_BonusValore', 'Valore sconto €/LT esente IVA', 'Bonus', 'N1', '0.08');
        qx1.API_QuoteLineItem__c=qli.Id;
        qlixList.add(qx1);
        //insert qx1;
        API_QuoteLineItemX__c qx2= API_dataFactory.createQuoteLineItemX('Api_BonusTipo', 'Tipo', 'Bonus', 'N2', 'Temporale');
        qx2.API_QuoteLineItem__c=qli.Id;
        //insert qx2;
        qlixList.add(qx2);
        API_QuoteLineItemX__c qx3= API_dataFactory.createQuoteLineItemX('API_BonusVolume', 'Volume LT', 'Bonus', 'N3', '100');
        qx3.API_QuoteLineItem__c=qli.Id;
        //insert qx3;
        qlixList.add(qx3);
        API_QuoteLineItemX__c qx4= API_dataFactory.createQuoteLineItemX('API_BonusPeriodicita', 'Periodicità', 'Bonus', 'N4', 'mensile');
        qx4.API_QuoteLineItem__c=qli.Id;
        //insert qx4;
        qlixList.add(qx4);
        API_QuoteLineItemX__c qx5= API_dataFactory.createQuoteLineItemX('API_BonusRinnovabile', 'Rinnovabile', 'Bonus', 'N5', 'NO');
        qx5.API_QuoteLineItem__c=qli.Id;
        //insert qx5;
        qlixList.add(qx5);
        API_QuoteLineItemX__c qx6= API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'Prodotti', 'Bonus', 'N6', '02	Benzine (non SELF), 03	Gasoli (non SELF), 09	ADBlue');
        qx6.API_QuoteLineItem__c=qli.Id;
        //insert qx6;
        qlixList.add(qx6);
        
        
        
        API_QuoteLineItemX__c qx12= API_dataFactory.createQuoteLineItemX('API_BonusValore', 'Valore sconto €/LT esente IVA', 'Bonus', 'N1', '0.08');
        qx12.API_QuoteLineItem__c=qli2.Id;
        qlixList.add(qx12);
        //insert qx12;
        API_QuoteLineItemX__c qx22= API_dataFactory.createQuoteLineItemX('Api_BonusTipo', 'Tipo', 'Bonus', 'N2', 'Temporale');
        qx22.API_QuoteLineItem__c=qli2.Id;
        //insert qx22;
        qlixList.add(qx22);
        API_QuoteLineItemX__c qx32= API_dataFactory.createQuoteLineItemX('API_BonusVolume', 'Volume LT', 'Bonus', 'N3', '100');
        qx32.API_QuoteLineItem__c=qli2.Id;
        //insert qx32;
        qlixList.add(qx32);
        API_QuoteLineItemX__c qx42= API_dataFactory.createQuoteLineItemX('API_BonusPeriodicita', 'Periodicità', 'Bonus', 'N4', 'mensile');
        qx42.API_QuoteLineItem__c=qli2.Id;
        //insert qx42;
        qlixList.add(qx42);
        API_QuoteLineItemX__c qx52= API_dataFactory.createQuoteLineItemX('API_BonusRinnovabile', 'Rinnovabile', 'Bonus', 'N5', 'NO');
        qx52.API_QuoteLineItem__c=qli2.Id;
        //insert qx52;
        qlixList.add(qx52);
        API_QuoteLineItemX__c qx62= API_dataFactory.createQuoteLineItemX('API_BonusProdotti', 'Prodotti', 'Bonus', 'N6', '02	Benzine (non SELF), 03	Gasoli (non SELF), 09	ADBlue');
        qx62.API_QuoteLineItem__c=qli2.Id;
        //insert qx62;
        qlixList.add(qx62);
        
        
       
        API_QuoteLineItemX__c qxS1= API_dataFactory.createQuoteLineItemX('API_Sconto_base_ValoreSconto', 'Valore sconto €/LT IVA inclusa', 'Sconto base', 'N1', '0.08');
        qxS1.API_QuoteLineItem__c=qli3.Id;
        //insert qxS1;
        qlixList.add(qxS1);
        API_QuoteLineItemX__c qxS2= API_dataFactory.createQuoteLineItemX('API_Sconto_base_Prodotti', 'Prodotti', 'Sconto base', 'N2', '02	Benzine (non SELF); 03	Gasoli (non SELF)');
        qxS2.API_QuoteLineItem__c=qli3.Id;
        //insert qxS2;
        qlixList.add(qxS2);
        API_QuoteLineItemX__c qxS3= API_dataFactory.createQuoteLineItemX('API_Sconto_base_DataInizio', 'Data inizio validità', 'Sconto base', 'N3', '2019-12-11');
        qxS3.API_QuoteLineItem__c=qli3.Id;
        //insert qxS3;
        qlixList.add(qxS3);
        API_QuoteLineItemX__c qxS4= API_dataFactory.createQuoteLineItemX('API_Sconto_base_DataFine', 'Data fine validità', 'Sconto base', 'N4', '2019-12-11');
        qxS4.API_QuoteLineItem__c=qli3.Id;
        //insert qxS4;
        qlixList.add(qxS4);
        
        insert qlixList;
    }
    
    @istest public static void testQuote(){
        Test.setMock(WebServiceMock.class, new API_SAPMock());
        test.startTest();
        List<Quote> quotes= [Select id, opportunity.Account.API_ClienteTop__c, opportunity.AccountId from Quote];
        
        quotes[0].API_Tipo_fido__c = 'Fido interno con garanzia';
        quotes[0].API_ValoreCostoAffidamento__c = null;
        quotes[0].API_DeltaPlatts__c = 2;
        update quotes;
        
        
        try{
        API_CallSAPController.getInfoSAP(quotes[0].Id);
        }catch(Exception e){}
        test.stopTest();
    }
    
    @istest public static void testQuote2(){
        Test.setMock(WebServiceMock.class, new API_SAPMock());
        test.startTest();
        List<Quote> quotes= [Select id, opportunity.Account.API_ClienteTop__c, opportunity.AccountId from Quote];
        Account acc = new Account();
        acc.id = Quotes[0].opportunity.AccountId;
        acc.API_ClienteTop__c = false;
        acc.API_ClienteSensibile__c = false;
        acc.API_FatturazionePDF__c = false;
        update acc;
        quotes[0].API_Fatturazione__c = '30';
        update quotes;
        try{
        API_CallSAPController.getInfoSAP(quotes[0].Id);
        }catch(Exception e){}
        test.stopTest();
    }
    
    @istest public static void testQuote3(){
        Test.setMock(WebServiceMock.class, new API_SAPMock());
        test.startTest();
        List<Quote> quotes= [Select id, opportunity.Account.API_ClienteTop__c, opportunity.AccountId from Quote];
        try{
        API_CallSAPController.getInfoSAP(quotes[0].Id);
        }catch(Exception e){}
        test.stopTest();
    }
    
}