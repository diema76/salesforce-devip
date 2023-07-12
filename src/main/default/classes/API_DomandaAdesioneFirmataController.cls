public with sharing class API_DomandaAdesioneFirmataController {
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId){ 
        List<API_Allegato__c> allegatoList = [select id, CreatedDate from API_Allegato__c 
                                            where API_Tipologia__c = 'Domanda di adesione firmata' and API_Quote__c =: recordId];
        Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>(); 
        if(allegatoList.size() == 0){
            List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds];  
            for(ContentDocumentLink cdLink:cdl){  
                documentIds.add(cdLink.ContentDocumentId);  
            }      
        }

        return [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds]; 
    } 

    @AuraEnabled  
    public static String getAllegatoID(string recordId){ 
        List<API_Allegato__c> allegatoList = [select id from API_Allegato__c where API_Tipologia__c = 'Domanda di adesione firmata' and API_Quote__c =: recordId];
        String response;
        if(allegatoList.size() == 0){
            RecordType rt = [select id, name from recordType where DeveloperName = 'API_QuoteAllegatoFirma'];
            API_Allegato__c allegato = new API_Allegato__c();
            allegato.API_Tipologia__c = 'Domanda di adesione firmata';
            allegato.API_Quote__c = recordId;
            allegato.RecordTypeId = rt.id;
            allegato.Name = 'Domanda di adesione firmata';
            insert allegato; 
            response = allegato.id;
        }else{
            response = '1';
        }

        return response;
    }

    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];
        List<API_Allegato__c> allegatoList = [Select id from API_Allegato__c where API_Tipologia__c = 'Domanda di adesione firmata'];
        delete allegatoList;     
    }  

    @AuraEnabled  
    public static String setFlagQuote(string recordId){ 
        system.debug('RECORDID: '+recordId);
        List<ContentDocumentLink> CDL = [select Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility, ContentDocument.Description
                                    from ContentDocumentLink where LinkedEntityId =: recordId];
        system.debug('DOCUMENT: '+CDL);
        String quoteId = [select API_Quote__c from API_Allegato__c where id =:recordId][0].API_Quote__c;
        if (CDL.size() > 0){
            Quote quote = [Select id, API_DomandaAdesioneFirmata__c from Quote where id =:quoteId][0];
            quote.API_DomandaAdesioneFirmata__c = true;
            update quote;
        }else if(CDL.size() == 0){
            System.debug('NON e presente allegato ');
            API_Allegato__c allegato = [select id from API_Allegato__c where id =: recordId];
            System.debug('ALLEGATO: '+allegato);
            delete allegato;
        }
        system.debug('QuoteID: '+quoteId);
        return quoteId;
    }

    @AuraEnabled  
    public static void deleteAllegato(){ 
        API_Allegato__c allegato = [select id from API_Allegato__c where API_Tipologia__c = 'Domanda di adesione firmata'];
        delete allegato;
    }
}