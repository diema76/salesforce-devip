@isTest
public class API_CalcolaFidoUtilityTEST {

  @isTest static void testCalcoloFido(){     
    Account acc = API_dataFactory.createAccount('testAcc','134698','testRagioneSociale');
        acc.API_Iban__c = 'IT66C0100503382000000218020';
        insert acc;
        Opportunity opp = API_dataFactory.createOpportunity(acc.id);
        insert opp;  
        Pricebook2 pBook = API_dataFactory.createPricebook2();
        pBook.Name = 'Price Book API';
        insert pBook;
        Quote q3;
        q3 = API_dataFactory.createQuote(opp.id, pBook);        
        q3.API_GenerataDaContrattoQuadro__c = false; 
        q3.API_Fatturazione__c='30';
        q3.API_Periodo_di_spendibilita_picklist__c='30';
        q3.API_CondizioniPagamento__c='RID-Banca-30 gg Data Fattura FuelCard';
        q3.API_PrevisioneConsumi__c=2000;
        q3.API_CodiceFiscaleFirmatarioSepa__c='RPLSNT92E45I197L';
        q3.status = 'Bozza'; 
        insert q3;
  }
}