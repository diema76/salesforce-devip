@isTest
private class API_CheckFileAllegatoTEST{
    @isTest static void testClass(){      
        Quote quote = new Quote();
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','012345','testRagioneSociale');
        insert acc;
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;

        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        
        quote = API_dataFactory.createQuote(opp.id, pBook);
        quote.API_ScontoBaseDelegheValoreNEW__c = 0;
        quote.API_Offerta__c = 'Prezzo Listino';  
        quote.API_Pacchetto__c = 'Base';
        quote.status = 'Bozza';
        quote.API_Tipo_fido__c = 'IFI';
        quote.API_ValoreCostoAffidamento__c =10;
        insert quote;
        API_Allegato__c allegato = new API_Allegato__c();
        allegato.API_Quote__c = quote.id;
        API_Allegato__c allegato2 = new API_Allegato__c();
        allegato2.API_Account__c = acc.id;
		insert allegato2;
        insert allegato;
        List<String> allegatoList = new List<String>();
        allegatoList.add(allegato.Id);
        API_CheckFileAllegato.getAllegatoIDS(allegatoList);
    }

}