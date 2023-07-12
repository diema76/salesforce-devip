public class API_AllegatiTriggerHelper {
    public static void deleteRecord(Map<ID, API_Allegato__c> allegatoOld){
        set<Id> quoteID = new Set<Id>();
        
        List<API_Allegato__c> allegatoList =[select id, API_Quote__c, API_Quote__r.Status, RecordType.DeveloperName, API_Tipologia__c 
                                            from API_Allegato__c where id in : allegatoOld.KeySet()]; 
        List<ContentDocumentLink> CDLList = [select Id, LinkedEntityId from ContentDocumentLink where LinkedEntityId in : allegatoOld.KeySet()];

        system.debug('AllegatoList: '+allegatoList);
        for(API_Allegato__c allegato :allegatoList){
            if(allegato.API_Quote__c != null && allegato.API_Quote__r.Status != 'Bozza' && allegato.RecordType.DeveloperName != 'API_QuoteAllegatoFirma'){
                for(ContentDocumentLink cdl : CDLList){
                    if(cdl.LinkedEntityId == allegato.Id){
                        API_Allegato__c actualRecord = allegatoOld.get(allegato.Id); 
                        actualRecord.addError('Non puoi cancellare l\'allegato perchè la quote non è in stato Bozza'); 
                    }
                }
            }
            if(allegato.API_Tipologia__c == 'Domanda di adesione firmata'){		quoteID.add(allegato.API_Quote__c); }
        }

        List<Quote> quoteList = new List<Quote>();
        quoteList = [select id, API_DomandaAdesioneFirmata__c from Quote where id =:quoteID];
        for(Quote q : quoteList){
            q.API_DomandaAdesioneFirmata__c = false;
        }
        system.debug('QuoteList: '+quoteList);
        update quoteList;
    }

    public static void insertRecord(List<API_Allegato__c> allegatoList){

        Set<Id> quoteList = new Set<Id>();
        Set<Id> accountList = new Set<Id>();
        List<API_Allegato__c> allegatoUpdate = new List<API_Allegato__c>();

        for(API_Allegato__c allegato : allegatoList) {
            if(allegato.API_Account__c != null && allegato.API_Quote__c == null){
                accountList.add(allegato.API_Account__c);
            }else if(allegato.API_Account__c == null && allegato.API_Quote__c != null){
                quoteList.add(allegato.API_Quote__c);
            }
        }

        List<Quote> quoteAllegati = [select id, Opportunity.Account.Id from quote where Opportunity.AccountId =:accountList];
        List<Quote> accountAllegati = [select Opportunity.accountId, id from quote where id =:quoteList];
        //system.debug('ACCOUNT ID: '+quoteAllegati[0].Opportunity.Account.Id);
        system.debug('QUOTE ALLEGATI, serve per mettere gli id delle quote: '+quoteAllegati);
        system.debug('Account ALLEGATI, serve per mettere gli id degli account: '+accountAllegati);
        String idRecordType = [select id, developername, SobjectType from recordtype where developername ='API_QuoteAllegato' limit 1].Id;

        for(API_Allegato__c allegato : allegatoList){
            if(allegato.API_Account__c != null && allegato.API_Quote__c == null){
                if(!quoteAllegati.isEmpty()){
                    API_Allegato__c a = new API_Allegato__c();
                    a.id = allegato.Id;
                    for(Quote q : quoteAllegati){
                        system.debug('Mi giro le quote per trovare quella giusta');
                        if(allegato.API_Account__c == q.Opportunity.Account.Id){
                            System.debug('Quote trovata, procedo all assegnazione');
                            a.API_Quote__c = q.id;
                            a.API_Account__c = q.Opportunity.Account.Id;
                        }
                    }
                    system.debug('ALLEGATO A: '+a);
                    allegatoUpdate.add(a);
                }
            }else if(allegato.API_Account__c == null && allegato.API_Quote__c != null){
                if(!accountAllegati.isEmpty()){
                    API_Allegato__c a = new API_Allegato__c();
                    a.id = allegato.Id;
                    for(Quote q : accountAllegati){
                        if(allegato.API_Quote__c == q.id){
                            a.API_Account__c = q.Opportunity.AccountId;
                            a.API_Quote__c = q.id;
                        }
                    }
                    allegatoUpdate.add(a);
                }
            }
        }
        System.debug('ALLEGATO UPDATE: '+allegatoUpdate);
        update allegatoUpdate;
    }
}