@isTest
private class API_GestioneClientiDuplicatiContTest {

    @isTest static void testClass(){        
        Account acc;

        User manager, uAg, uAm, uAt, uTe;
        
        User admin = [ select Id from User where Id = :UserInfo.getUserId() ];
        

        //Workaround per evitare l'errore MIXED_DML_OPERATION
        System.runAs (admin){
            manager = API_dataFactory.createUser('testManagerName', 'TestManagerLastN');
            insert manager;    

            acc = API_dataFactory.createAccount('testAccName', '12345678987', 'testPIva');
            insert acc;

            uAg = API_dataFactory.createUser('testName', 'TestLastName', 'AgentiPartnerCommunity', 'testAccName', 'testContactName');
            uAg.ManagerId = manager.Id;
            update uAg;


            uAm = API_dataFactory.createUser('testName1', 'TestLastName1', 'Profilo Area Manager', 'Area Manager Vendite dirette');
            uAm.ManagerId = manager.Id;
            update uAm;

            uAt = API_dataFactory.createUser('testName2', 'TestLastName2', 'Profilo Area Manager', 'Telesales');
            uAt.ManagerId = manager.Id;
            update uAt;

            uTe = API_dataFactory.createUser('testName3', 'TestLastName3', 'Profilo Telesales', 'Area Manager Vendite dirette');
            uTe.ManagerId = manager.Id;
            update uTe;
        }

        System.runAs(uAg){
            List<String> clienteDuplicato = API_GestioneClientiDuplicatiController.clienteDuplicato(acc.API_Iva__c);
        }


        System.runAs(uAm){
            List<String> clienteDuplicato = API_GestioneClientiDuplicatiController.clienteDuplicato(acc.API_Iva__c);
        }        

        System.runAs(uAt){
            List<String> clienteDuplicato = API_GestioneClientiDuplicatiController.clienteDuplicato(acc.API_Iva__c);
        }        

        System.runAs(uTe){
            List<String> clienteDuplicato = API_GestioneClientiDuplicatiController.clienteDuplicato(acc.API_Iva__c);
        }                
        
    }

}