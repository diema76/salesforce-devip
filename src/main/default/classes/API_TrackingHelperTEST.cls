@isTest

private class API_TrackingHelperTEST {
    @isTest static void testClass(){      
		Test.startTest();
        Account acc = API_dataFactory.createAccount('API','012345','testRagioneSociale');           
        acc.API_Importo_concesso__c = 10;
        acc.API_CodiceCliente__c = '04';
        acc.API_Data_richiesta_Plafond_string__c = '28/08/2019';
        acc.API_DataInserimentoClienteSuSap__c = Date.newInstance(2019, 08, 28);
        acc.API_ControlloSuccessivoSap__c = Date.newInstance(2019, 08, 28);
        acc.API_Ultima_Revisione__c = Date.newInstance(2019, 08, 28);
        acc.API_Data_Override__c = Date.newInstance(2019, 08, 28);
        acc.API_Data_Scadenza_Override__c = Date.newInstance(2019, 08, 28);
        acc.API_DataSottoscrizioneContratto__c = Date.newInstance(2019, 08, 28);
        acc.API_Fatturazione__c = 'T';
        acc.API_AutorizzazionePrivacy__c = '01';
        acc.API_CodiceCIG__c ='23';
        acc.API_SoggettoTracciabilita__c =true;
        insert acc;    

        Account acc2 = acc;
        acc.API_Importo_concesso__c = 11;

        API_TrackingHelper.creaRecordDiTracking(new List<Account>{acc}, new List<Account>{acc2});

        API_TrackingHelper.method529(new List<Account>{acc});

        API_TrackingHelper.updateSap(new List<Account>{acc}, new List<Account>{acc2});

        API_TrackingHelper.updateStatiCliente(new List<Account>{acc}, new List<Account>{acc2});
        
        acc.API_AutorizzazionePrivacy__c = '02';
        acc.API_Stato_Fido__c = 'FAC';        
        acc.API_Fatturazione__c = 'M';     
        Account acc3 = acc.clone(false, false, false, false);
        insert acc3;
        
        update acc;

        API_TrackingHelper.updateStatiClienteBeforeInsert(new List<Account>{acc});
        API_TrackingHelper.updateSap(new List<Account>{acc}, new List<Account>{acc2});       
        Test.stopTest();
    }
    
    @isTest static void testClass2(){ 
        Test.startTest();
    	Account acc = API_dataFactory.createAccount('API','85687','testRagioneSociale');           
        acc.API_Importo_concesso__c = 10;
        acc.API_CodiceCliente__c = '04';
        acc.API_Data_richiesta_Plafond_string__c = '28/08/2019';
        acc.API_DataInserimentoClienteSuSap__c = Date.newInstance(2019, 08, 28);
        acc.API_ControlloSuccessivoSap__c = Date.newInstance(2019, 08, 28);
        acc.API_Ultima_Revisione__c = Date.newInstance(2019, 08, 28);
        acc.API_Data_Override__c = Date.newInstance(2019, 08, 28);
        acc.API_Data_Scadenza_Override__c = Date.newInstance(2019, 08, 28);
        acc.API_DataSottoscrizioneContratto__c = Date.newInstance(2019, 08, 28);
        acc.API_Fatturazione__c = 'T';
        acc.API_AutorizzazionePrivacy__c = '01';
        insert acc;    


        acc.API_AutorizzazionePrivacy__c = '03';
        acc.API_Stato_Fido__c = 'NNC';   
        Account acc4 = acc.clone(false, false, false, false);
        insert acc4;        
        update acc;
        API_TrackingHelper.updateStatiClienteBeforeInsert(new List<Account>{acc});    
        API_TrackingHelper.updateSap(new List<Account>{acc}, new List<Account>{acc});    

        acc.API_AutorizzazionePrivacy__c = '04';
        acc.API_Stato_Fido__c = 'REV';
        acc.API_DataCartesiaString__c='10/10/2010';
        acc.API_DataBloccoString__c='10/10/2010';

        Account acc5 = acc.clone(false, false, false, false);
        insert acc5;                
        update acc;
        API_TrackingHelper.updateStatiClienteBeforeInsert(new List<Account>{acc});  
        API_TrackingHelper.updateSap(new List<Account>{acc}, new List<Account>{acc});   
        Test.stopTest();
    }
}