@isTest
private class API_QueryAccountWithoutSharingTEST {

    @isTest static void testClass(){      
        Account acc = API_dataFactory.createAccount('testAcc', '123456789', 'testRSociale');
        acc.API_Stato_cliente__c = 'Nuovo';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('PostVerificaCerved').getRecordTypeId();
        insert acc;

        Lead l = API_dataFactory.createLead('testLead', '123456789', 'testMail');
        insert l;

        List<String> listPiva = new List<String>();
        listPiva.add('123456789');
        
        API_QueryAccountWithoutSharing.getAccountIds(listPiva);
    }

}