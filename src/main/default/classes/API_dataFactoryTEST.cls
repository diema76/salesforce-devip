@isTest
private class API_dataFactoryTEST {
    @isTest static void API_dataFactory2(){ 
    	API_dataFactory.createUser('Roberto','Migliore');
        API_dataFactory.createUser('Roberto33','Miglior33e');
        API_dataFactory.createUser('R33oberto','Mig33liore', 'Profilo Area Manager', 'CC Vendite Indirette');
        try{
        API_dataFactory.createUser('fsdf', 'dfsdfsd', 'Profilo Area Manager', 'efewwef', 'fsaff');
        }catch(Exception e){
            
        }
    }
	@isTest static void API_dataFactory(){ 
		API_dataFactory.createLead('125','citgh','sdfhgbf@api.com');
        Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        upsert a;
        API_dataFactory.createCase('Aperto');
        Opportunity opp=API_dataFactory.createOpportunity(a.Id);
        insert opp;
        Pricebook2 p=API_dataFactory.createPricebook2();
        insert p;
        Quote q=API_dataFactory.createQuote(opp.Id,p);
        upsert q;
        API_dataFactory.createProduct();
        API_dataFactory.createCarta(q);
        API_dataFactory.create512();
        API_dataFactory.create529();
        API_dataFactory.create912();
        API_dataFactory.create912second();
        API_Divisione__c d=API_dataFactory.createDivisione(a.Id);
        insert d;
        API_dataFactory.createContoCarte(d.Id,q.Id);
        Contact c= API_dataFactory.createContact('dwdwq', a.Id, 'Principale');
    }

}