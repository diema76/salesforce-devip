@isTest
private class API_CaseTriggerHelperTEST {
@isTest static void testClass(){ 
        
     	API_TripletteInformazioni__c triplins = new API_TripletteInformazioni__c();
        insert triplins;
        User userSet = API_dataFactory.createUser('Mario','Nervi');
        insert userSet;
        User userSetsecond = API_dataFactory.createUser('Pippo','Neri');
        insert userSetsecond;
       
            Account ad=API_dataFactory.createAccount('sdffsd','1245','sdfnlsdk');
            insert ad;
            API_Business__c bHour = new API_Business__c(); 
            insert bHour;
            Case caseSet = API_dataFactory.createCase('Aperto');
            caseSet.AccountId=ad.Id;
        	Case caseSet2 = API_dataFactory.createCase('Aperto scalato');
            list<Case> Case_up = new list<Case>();
            caseSet.API_Tipo_utente__c ='PROSPECT';
        	caseSet.API_Tipologia__c ='ALTRE';
            
        	caseSet.API_Sottotipologia__c ='ANOMALIA IMPORTI'; 
        	caseSet2.API_Tipo_utente__c ='PROSPECT';
        	caseSet2.API_Tipologia__c ='ALTRE';
        	caseSet2.API_Sottotipologia__c ='ANOMALIA IMPORTI';
        	insert caseSet2;
        	String infoSuggerita= 'informazione suggerita'; 
        	caseSet.API_Informazione_suggerita__c=infoSuggerita;
        	caseSet.API_Da_inoltrare_a__c='Nessun suggerimento';
            caseSet.Status='Aperto';
            caseSet.Origin='Phone';
        	caseSet.Status='In attesa';
            caseSet.OwnerId=userSet.Id;
            insert caseSet;
            caseSet.OwnerId=userSetsecond.Id;
            caseSet.Origin='Web';
            update caseSet;
            
    }
    @isTest static void testSharing(){ 
        User u = API_dataFactory.createUser('testAgentName', 'testAgentLastName', 'AgentiPartnerCommunity', 'AgentiPartnerCommunityAccount', 'testContactName', null);
        Case c= API_dataFactory.createCase('Chiuso');
        insert c;
        Account a= API_dataFactory.createAccount('frefref', '6456484', 'frefrefref');
         a.OwnerId=u.ID;
        insert a;
        c.AccountId=a.Id;
        update c;
        c.API_AgenteOwnerDellAccountModificato__c=true;
        update c;
        
        
    }
}