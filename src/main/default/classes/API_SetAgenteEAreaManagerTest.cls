@isTest
private class API_SetAgenteEAreaManagerTest {
    
    @isTest static void AgentiPartnerCommunityTest(){      
 		Account acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');
        insert acc;

        Account acc2 = API_dataFactory.createAccount('testAcc2','testPIVA2','testRagioneSociale2');
        insert acc2;        
		
        List<String> accList = new List<String>();
        accList.add(acc.Id);
        accList.add(acc2.Id);
        Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        upsert a;
        
        Contact c= API_dataFactory.createContact('dwdwq', a.Id, 'Principale');
        User u = API_dataFactory.createUser('firstName', 'lastName', 'AgentiPartnerCommunity', a.name, 'Ciao');
        
        system.runAs(u){
            API_SetAgenteEAreaManager.setAgenteEAreaManager(accList);
        }
        
    }
    
     @isTest static void profiloAreaManagerTest(){      
 		Account acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');
        insert acc;

        Account acc2 = API_dataFactory.createAccount('testAcc2','testPIVA2','testRagioneSociale2');
        insert acc2;        
		
        List<String> accList = new List<String>();
        accList.add(acc.Id);
        accList.add(acc2.Id);
        Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        upsert a;
        
        Contact c= API_dataFactory.createContact('dwdwq', a.Id, 'Principale');
        User u = API_dataFactory.createUser('firstName', 'lastName', 'Profilo Area Manager');
        
        system.runAs(u){
            API_SetAgenteEAreaManager.setAgenteEAreaManager(accList);
        }
        
    }
}