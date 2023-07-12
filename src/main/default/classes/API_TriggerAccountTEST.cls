@isTest
private class API_TriggerAccountTEST {
	@isTest static void API_TriggerAccountTEST(){ 
        
        /*Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
    	insert  a;
        a.Name='TESTAC';
        user u=API_dataFactory.createUser('','sdfge');
        insert u;
        update a;
        a.API_NominativoAreaManager__c='sdfge';
        a.API_AutorizzazionePrivacy__c='01';
        update a;
        a.API_AutorizzazionePrivacy__c='02';
        update a;
        a.API_AutorizzazionePrivacy__c='03';
        update a;
        a.API_AutorizzazionePrivacy__c='04';
        update a;
        a.API_DataInserimentoClienteSuSap__c = date.newinstance(1960, 2, 17);
        update a;
        a.API_ControlloSuccessivoSap__c = date.newinstance(1960, 2, 17);
        update a;
        a.API_Ultima_Revisione__c = date.newinstance(1960, 2, 17);
        update a;
        a.API_Data_Override__c = date.newinstance(1960, 2, 17);
        update a;
        a.API_Data_Scadenza_Override__c = date.newinstance(1960, 2, 17);
        update a;
        a.API_DataSottoscrizioneContratto__c = date.newinstance(1960, 2, 17);
        update a;
        a.API_Fatturazione__c = 'T';
        update a;
        a.API_Fatturazione__c = 'M';
        update a;
        Opportunity opp=API_dataFactory.createOpportunity(a.Id);
        insert opp;
        Pricebook2 pric=API_dataFactory.createPricebook2();
       	Quote q=API_dataFactory.createQuote(opp.Id,pric);
        insert q;
        Quote q2=API_dataFactory.createQuote(opp.Id,pric);
        insert q2;
       	a.API_Data_richiesta_Plafond_string__c='22-10-2018';
        update a;*/
	}
    
   /* @isTest static void TestTracking(){ 
        API_TrackingAccountFields__mdt t= new API_TrackingAccountFields__mdt ();
        t.MasterLabel='Stato Factoring';
        t.DeveloperName='API_Stato_cliente';
        Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        a.API_Stato_cliente__c='Attivo';
    	insert  a;
        a.API_Stato_cliente__c='Inattivo';
        update a;
    }
    
     @isTest static void TestupdateStatiCliente(){ 
         Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
         a.API_Stato_Fido__c='FAC';
         a.API_CodiceCliente__c='424234';
         insert a;
         Account a1=API_dataFactory.createAccount('citgh','125222','NapoliSRL');
         a1.API_Stato_Fido__c='REV';
         insert a1;
         Account a2=API_dataFactory.createAccount('citgh','1253333','NapoliSRL');
         a2.API_Stato_Fido__c='NNC';
         insert a2;
         a2.API_Stato_Fido__c='FAC';
         update a2;
         a2.API_CodiceCliente__c='424234234';
         update a2;
         a1.API_Stato_Fido__c='NNC';
         update a1;
         a.API_Stato_Fido__c='REV';
         update a;
     }*/
    
}