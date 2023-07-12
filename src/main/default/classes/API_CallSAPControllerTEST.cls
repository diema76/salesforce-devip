@isTest public class API_CallSAPControllerTEST {

    @isTest static void setup(){
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
        a.API_IBAN__c='AA00A0123456789012345678900';
        a.API_GruppoClientiCartesia__c = '380001 - CONTO TERZI';
        insert a;
        Opportunity o=API_dataFactory.createOpportunity(a.Id);
        insert o;
        Pricebook2 price=API_dataFactory.createPricebook2();
        insert price;
        Quote q= API_dataFactory.createQuote(o.Id, price);
        q.API_DataSottoscrizioneContratto__c=System.today();
        insert q;
        API_Divisione__c d = new API_Divisione__c();
		d.API_Account__c = a.Id;
		d.Name = 'testNameDivisione';
		d.API_Descrizione__c = 'testDescrizioneDivisione';
		d.Ordine__c = 10;
        insert d;
        API_prodottiController.addProduct(q.id, 'API_Sconto_sito_rete_Prodotti','Sconto Site/Rete', null, false);
        API_prodottiController.addProduct(q.id, 'API_BonusProdotti','Bonus', null, false);
        //API_CallSAPController.getInfoSAP(q.Id);
        Test.setMock(WebServiceMock.class, new API_SAPMock());
        test.startTest();
        API_CallSAPController.getInfoSAP(q.Id);
        test.stopTest();
    }
}