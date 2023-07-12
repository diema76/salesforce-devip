public class API_LeadTriggerHelper {
	
	public static void checkIVA(List<Lead> leadList){
        //creo una lista dei lead per poter fare eventualmente addError sulla pagina di inserimento
        Map<String, Lead> leadMap= new Map<String, Lead>();
        for(Lead l :leadList){
			leadMap.put(l.API_Iva__c, l);
		} 
        
		//creo la lista in cui mettere i platform event
		List<API_PlatformEventLeadDuplicato__e> inkEvents= new List<API_PlatformEventLeadDuplicato__e>();
		List<String> ivaList = new List<String>();
		for(Lead l :leadList){
			ivaList.add(l.API_Iva__c);
		} 
		system.debug('@@ivaList'+ivaList);
		List<Account> accList = [select id, API_Iva__c from Account where API_Iva__c IN: ivaList];
		List<Lead> leadL = [select id, API_Iva__c, Email from Lead where API_Iva__c IN: ivaList AND
						   CreatedDate = LAST_N_DAYS:15 AND Id NOT IN :leadList];
		EmailTemplate emailTemp = [Select id from EmailTemplate where name = 'Lead advertising' limit 1];

		system.debug('@@@accList'+accList);
				system.debug('@@@leadL'+leadL);
		Set<String> leadSet = new Set<String>();
		Set<Id> leadIdSet = new Set<Id>();
		for(Lead l : leadList){
			system.debug('@@@l.API_Iva__c'+l.API_Iva__c);
			if(!accList.isEmpty()){
				for(Account acc :accList){
					system.debug('@@@acc.API_Iva__c'+acc.API_Iva__c);
					if(acc.API_Iva__c == l.API_Iva__c){
                        //se sono uguali aggiungo il platform event
                        inkEvents.add(createPlatformevent(l.API_Iva__c, l.Email, acc.Id, 'Account'));
/*
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTargetObjectId(l.id); 
				        mail.setSenderDisplayName('Salesforce Support'); 
				        mail.setUseSignature(true); 
				        mail.setBccSender(false); 
				        mail.setSaveAsActivity(false);
				        mail.setTemplateId(emailTemp.id);
				        //mail.setTargetObjectId(l.id);
				        mail.setToAddresses(new List<Id>{l.id}); 
				        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
				        leadSet.add(l.Email);
				        leadIdSet.add(l.Id);
						
						//l.addError('Cliente già censito. Partita iva già presente a sistema');
					}
				}
				break;
			}
			if (!leadL.isEmpty()){
				for(Lead lea :leadL){
					system.debug('@@@lea.API_Iva__c'+lea.API_Iva__c);

					if(lea.API_Iva__c == l.API_Iva__c && (leadL.size())>1){
                         inkEvents.add(createPlatformevent(lea.API_Iva__c, lea.Email, lea.Id, 'Lead'));
						
				        				        leadSet.add(l.Email);
				        				        				        leadIdSet.add(l.Id);
				    }
				}
				break;
			}
		}
        //chiamo il metodo per lanciare i platform event creati
        if(inkEvents.size()>0){
            //lancio i platform event
            throwPlatformEvents(inkEvents);
            //per ogni lead che ha dato errore faccio addError
            for(API_PlatformEventLeadDuplicato__e pe: inkEvents){
                leadMap.get(pe.API_PartitaIVA__c).addError('Cliente già presente: partitia iva duplicata');
            }
        }
		
	}

    public class MyException extends Exception {}
    
    public static API_PlatformEventLeadDuplicato__e createPlatformevent(String PartitaIVA, String email, String accId, String Oggetto){
        API_PlatformEventLeadDuplicato__e pe= new API_PlatformEventLeadDuplicato__e();
        pe.API_Email__c=email;
        pe.API_PartitaIVA__c = PartitaIVA;
        pe.API_IdAccountDuplicato__c= accID;
        pe.API_Oggetto__c = Oggetto;
        return pe;
    }
    
    public static void throwPlatformEvents(List<API_PlatformEventLeadDuplicato__e> inkEvents){
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(inkEvents);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            System.debug('@@@@@@ Error'+sr.getErrors());
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +err.getStatusCode() + ' - ' +err.getMessage());
                }
            }   
        }
    }

    public static void webToLeadCompany(List<Lead> leadList){
    	for(Lead l : leadList){
    		l.company = l.API_RagioneSociale__c;
    	}
    }

}