@isTest
private class API_ContrattiQuadriWithoutSharingTEST {

    @isTest static void testClass(){      
        User user1, user2, user3;

        user1 = API_dataFactory.createUser('name1', 'lastName1', 'BackOffice');
        user2 = API_dataFactory.createUser('name2', 'lastName2', 'Profilo Telesales');
        user3 = API_dataFactory.createUser('name3', 'lastName3', 'Profilo Area Manager');        

        System.runAs(user1){
            API_ContrattiQuadriWithoutSharing.getContrattiQuadri();
        }
        System.runAs(user2){
            API_ContrattiQuadriWithoutSharing.getContrattiQuadri();
        }        
        System.runAs(user3){
            API_ContrattiQuadriWithoutSharing.getContrattiQuadri();
        }        
    }

}