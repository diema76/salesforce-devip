@isTest
public class API_FlowUtilityTEST {
    @isTest static void API_FlowUtilityTEST(){
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');        
        insert acc;        

        API_Divisione__c div = API_dataFactory.createDivisione(acc.id);
        insert div;

        Contact c = API_dataFactory.createContact('testContactName',acc.id, 'Debitore');
        User u = API_DataFactory.createUser('firstName', 'lastName', 'AgentiPartnerCommunity', acc.Name, 'prar');
        API_FlowUtility.getOpzioni();
        API_FlowUtility.getPausedFlow();
        API_FlowUtility.getTipoFido2();
    }
    
    @isTest static void API_FlowUtility2TEST(){
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','testPIVA','testRagioneSociale');        
        insert acc;        

        API_Divisione__c div = API_dataFactory.createDivisione(acc.id);
        insert div;

        Contact c = API_dataFactory.createContact('testContactName',acc.id, 'Debitore');
        User u = API_DataFactory.createUser('firstName', 'lastName', 'AgentiPartnerCommunity', acc.Name, 'prar');
        System.runAs(u) {
              	API_FlowUtility.getOpzioni();
        		API_FlowUtility.getPausedFlow();
        		API_FlowUtility.getTipoFido2();
        }
        
    }
    
}