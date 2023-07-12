public class API_CallSAPController {
    
    @AuraEnabled
    public static String getInfoSAP(String quoteID){
        system.debug('SOAP CONTROLLER!!!');
        system.debug('QuoteID: '+quoteID);
        String returnCode = API_CallSAP.callSAP(quoteID);
        
        String code;

        Quote quote = [Select id, Opportunity.Account.API_Stato_cliente__c, Opportunity.AccountId, RecordTypeId, API_NumeroVersione__c  from Quote where id =: quoteID LIMIT 1];
        RecordType rt = [select Id, Name, DeveloperName from RecordType where DeveloperName =: 'Standard_InseritaSAP' LIMIT 1];

        if(returnCode == 'OK'){
            Account acc = new Account();
            acc.Id = quote.Opportunity.AccountId;
            acc.API_Stato_cliente__c = 'Codificato SAP';
            quote.status = 'Inserita SAP';
            quote.RecordTypeId = rt.Id;
            update acc;
            update quote;
        }
        Decimal versione = quote.API_NumeroVersione__c;
        quote.API_NumeroVersione__c = versione + 1;
        system.debug('Numero Versione: ' +quote.API_NumeroVersione__c);
        update quote;

        system.debug('@@Return code: ' +returnCode);
        return returnCode;
    }
}