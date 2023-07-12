@isTest
public class Trigger912Test {

    @isTest static void testClass(){
	Account a=API_dataFactory.createAccount('mario rossi','32132131', 'rewrwere');
	a.API_CodiceCliente__c= '123456';
	insert a;
	API_dataFactory.create912();
}
}