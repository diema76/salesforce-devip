@isTest
private class API_BatchCreateOpprtunityAndQuoteTEST {
	@isTest static void API_BatchCreateOpprtunityAndQuoteTEST(){
        Account a2=API_dataFactory.createAccount('ci4563tgh','544','gfjhfdg');
        a2.API_Codice_Cartesia__c=null;
        a2.API_QuoteDaCreare__c=true;
        a2.API_Ex_Cliente__c ='Ex cliente IP';
    	insert  a2;
        Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        a.API_Codice_Cartesia__c='1234';
        a.API_QuoteDaCreare__c=true;
        a.API_Ex_Cliente__c ='Ex cliente IP';
    	insert  a;
      	Opportunity opp=API_dataFactory.createOpportunity(a.Id);
        insert opp;
        Pricebook2 pric=API_dataFactory.createPricebook2();
        pric.Name= 'Price Book API';
        insert pric;
       	Quote q=API_dataFactory.createQuote(opp.Id,pric);
        q.API_ScontoBaseDelegheValoreNEW__c = 0;
        q.API_Offerta__c = 'Prezzo Listino';  
        q.API_Pacchetto__c = 'Base';
        q.status = 'Bozza';	
        q.API_Tipo_fido__c = 'IFI';
        q.API_ValoreCostoAffidamento__c =0;
        insert q;
        test.startTest();
        Id batchJobId = Database.executeBatch(new API_BatchCreateOpprtunityAndQuote(), 200);
        test.stopTest();
		
    }
}