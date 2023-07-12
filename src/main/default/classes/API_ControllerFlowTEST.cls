@isTest
private class API_ControllerFlowTEST {
    @isTest static void testClass(){ 
        
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');
        insert acc;
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;
        
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        Quote quote = new Quote();        
        quote = API_dataFactory.createQuote(opp.id, pBook);
        quote.API_ScontoBaseDelegheValoreNEW__c = 0;
        quote.API_Offerta__c = 'Prezzo Listino';  
        quote.API_Pacchetto__c = 'Base';
        quote.status = 'Bozza';
        quote.API_Tipo_fido__c = 'IFI';
        quote.API_ValoreCostoAffidamento__c =0;
        insert quote;
        API_controllerFlow.picklistValues();
        API_controllerFlow.getParchiMezzi(quote.Id);
        API_controllerFlow.salvaParcoMezzi(quote.Id, 'ciao', 'ciao');
        
    }
}