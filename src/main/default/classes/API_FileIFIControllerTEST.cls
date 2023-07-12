@isTest
private class API_FileIFIControllerTEST {
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
        
        SchedulableContext sc2 = null;
        API_FileIFIController tsc2 = new API_FileIFIController();
        tsc2.execute(sc2);
        
        
        
    }
    @isTest static void testClass2(){ 
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
        
        acc.API_RagioneSociale__c = 'sad';
        acc.BillingStreet = '123456789098765432123456789098';
        acc.BillingCity = '123456789098765432123456789098';
        acc.BillingPostalCode ='12345';
        acc.BillingState = 'MK';
        acc.API_Iva__c = '12345678987';
        acc.API_CodiceCliente__c = '54645';
        acc.API_Telefono__c = '123456789876543';
        acc.fax = '123456789876543';
        string banca = '';
        for(integer i = 0; i < 50; i++)
            banca = banca + 'g';
        acc.Banca_del_debitore__c = banca;
        string email = '';
        for(integer i = 0; i < 30; i++){
            if(i == 20)
                email = email + '@';
            if(i == 25)
                email = email + '.'; 
            email = email + 'g';
        }
        acc.API_EmailPec__c = email;
        string note = '';
        for(integer i = 0; i < 100; i++)
            note = note + 'g';
        acc.API_Note__c = note;
        
        update acc;       
        
        SchedulableContext sc = null;
        API_FileIFIController tsc = new API_FileIFIController();
        tsc.execute(sc);
        
    }
}