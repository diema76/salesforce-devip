@isTest
public class API_RichiestaFidoControllerTEST {
    
    @isTest private static void addProductTEST1(){
              Account a = API_dataFactory.createAccount('acc', '99999999999', 'test');
         insert a;
         
         Opportunity opp =  API_dataFactory.createOpportunity(a.id);
         insert opp;
         
         Pricebook2 p =  API_dataFactory.createPricebook2();
         insert p;
         
     	 Quote q = API_dataFactory.createQuote(opp.id, p);
         insert q;
         ApexPages.StandardController sc = new ApexPages.StandardController(q);
         API_RichiestaFidoController page = new API_RichiestaFidoController (sc);
    }
    
}