@isTest
private class API_ModaleUploadDatiControllerTEST  {
    @isTest static void testClass(){ 
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','01213','testRagioneSociale');
        acc.API_Tipo_fido__c ='IFI';
        acc.API_CodiceCliente__c = '1234';
        acc.BillingStreet = 'prova';
        acc.BillingCity = 'prova';
        acc.BillingPostalCode = '0124';
        acc.BillingState = 'l';
        acc.BillingCountry = 'prova';
        acc.API_CodiceFiscale__c = 'SSNNTN91R21F839O';
        acc.API_Telefono__c = '234234234';
        acc.Fax = '24234';
        acc.API_Iban__c = 'IT66C0100503382000000218020';
        acc.Banca_del_debitore__c = 'test';
        acc.API_EmailPec__c = 'test@test.com';
        acc.API_Note__c = 'werewrw';
        acc.API_CodiceCessione__c = 'SI';
        acc.API_Stato_Factoring__c = 'Da inviare';
        acc.API_Importo_richiesto__c = 3;
        acc.API_Verifica_Cerved__c = 'Verde';
        acc.API_DataCreazioneVerificaCerved__c = system.today();
        insert acc;
        
        
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        List<Quote> qList = new List<Quote>();
        Quote q;
        q = API_dataFactory.createQuote(opp.id, pBook);
        q.API_ScontoBaseDelegheValoreNEW__c = 0;
        q.API_Offerta__c = 'Prezzo Listino';  
        q.API_Pacchetto__c = 'Base';
        qList.add(q);
        insert qList;
        API_ContoCarte__c cc = new API_ContoCarte__c();
        cc.API_TipoPIN__c = '1-PIN standard';
        insert cc;
        
        API_Carta__c carta = API_DataFactory.createCarta(q);
        carta.API_TipoPIN__c = '1-PIN standard';
        carta.API_ContoCarte__c = cc.id;
        carta.API_Numero_di_targa__c = 'de456rt';
        carta.API_Tipo_Operazione__c = '0 - solo PIN';
        carta.API_TipoVeicolo__c = 'Camion/Bus (1.300 €)';
        carta.API_ServiziStazione__c ='Lavaggio';
        carta.API_ProdottiAutorizzati__c = 'Benzina';
        
        API_Parco_mezzi__c parco = new API_Parco_mezzi__c();
        parco.Name ='234';
        parco.API_Quote__c =q.id;
        insert parco;
        List<API_Carta__c> cartaList = new List<API_Carta__c>();
       	cartaList.add(carta);
        API_ModaleUploadDatiController.caricaCarte(cartaList ,q.id);
        
        API_Carta__c carta2 = API_DataFactory.createCarta(q);
        carta2.API_TipoPIN__c = '1-PIN standard';
        carta2.API_ContoCarte__c = cc.id;
        carta2.API_Tipo_Operazione__c = '0 - solo PIN';
        carta2.API_TipoVeicolo__c = 'Camion/Bus (1.300 €)';
        carta2.API_ServiziStazione__c ='Lavaggio';
        carta2.API_ProdottiAutorizzati__c = 'Benzina';
        carta2.API_NomeParco__c = '234';
        List<API_Carta__c> cartaList2 = new List<API_Carta__c>();
       	cartaList2.add(carta2);
        API_ModaleUploadDatiController.caricaCarte(cartaList2 ,q.id);
    }
}