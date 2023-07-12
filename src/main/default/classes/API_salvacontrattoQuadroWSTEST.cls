@isTest
private class API_salvacontrattoQuadroWSTEST {

    @isTest static void testClass(){      
        Account acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');
        insert acc;

        Account acc2 = API_dataFactory.createAccount('testAcc2','testPIVA2','testRagioneSociale2');
        insert acc2;        

        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;

        Opportunity opp2 = API_dataFactory.createOpportunity(acc2.id);
        insert opp2;        

        Pricebook2 pBook = API_dataFactory.createPricebook2();
        insert pBook;

        Pricebook2 pBook2 = API_dataFactory.createPricebook2();
        insert pBook2;

        Quote q = API_dataFactory.createQuote(opp.id, pBook);        

        Quote q2 = API_dataFactory.createQuote(opp2.id, pBook2);        

        Id recordTypeContrattoQ = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();

        q2.RecordTypeId = recordTypeContrattoQ;    

        insert q;
        insert q2;
        
        List<String> par = new List<String>();
        par.add(q.id+'-'+q2.id);

        API_salvacontrattoQuadroWithoutSharing.updateQuoteContrattoQuadro(par);
    }

}