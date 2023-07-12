public without sharing class API_CaseTriggerHelper {
	
	public static void  updateValueInfo(List<Case> caseListNew){

        List<API_TripletteInformazioni__c> triplCase=[Select id, API_Tipologia__c, API_TipoUtente__c, API_Sottotipologia__c, API_Informazione_suggerita__c, 
        											Informazione_suggerita_WEB__c, API_Inoltrare_a__c 
                                                 	from API_TripletteInformazioni__c ];

		//creo una mappa con chiave la tripletta e valore l'info suggerita
        Map<String, String> mappaInfoSuggerite= new Map<String, String>();
        Map<String, String> mappaDaInoltrareA= new Map<String, String>();
        
	    for(Case ca:caseListNew){
	    	if(ca.Origin ==null){
	    		ca.Origin ='Phone';
	    	}
	    	for(API_TripletteInformazioni__c tripletta: triplCase){
		        	if(ca.Origin =='Phone')
		            	mappaInfoSuggerite.put(tripletta.API_TipoUtente__c+'-'+tripletta.API_Tipologia__c+'-'+tripletta.API_Sottotipologia__c, tripletta.API_Informazione_suggerita__c);
		            else /*if(ca.Origin =='Web')*/
		            	mappaInfoSuggerite.put(tripletta.API_TipoUtente__c+'-'+tripletta.API_Tipologia__c+'-'+tripletta.API_Sottotipologia__c, tripletta.Informazione_suggerita_WEB__c);
	        		
	        		mappaDaInoltrareA.put(tripletta.API_TipoUtente__c+'-'+tripletta.API_Tipologia__c+'-'+tripletta.API_Sottotipologia__c, tripletta.API_Inoltrare_a__c);
	        }
	    }
        //per ogni case inserito/modificato controllo se c'è l'informazione suggerita
        for(Case c: caseListNew){
            if(c.API_Tipo_utente__c!=null && c.API_Tipologia__c!=null && c.API_Sottotipologia__c!=null){
                String infoSuggerita= mappaInfoSuggerite.get(c.API_Tipo_utente__c+'-'+c.API_Tipologia__c+'-'+c.API_Sottotipologia__c);
                if(infoSuggerita!=null) 		c.API_Informazione_suggerita__c=infoSuggerita;
                else
                    c.API_Informazione_suggerita__c='Nessun suggerimento';
                String daInoltrareA= mappaDaInoltrareA.get(c.API_Tipo_utente__c+'-'+c.API_Tipologia__c+'-'+c.API_Sottotipologia__c);
                if(daInoltrareA!=null && daInoltrareA!='bo1')		c.API_Da_inoltrare_a__c=daInoltrareA;
                else
                   c.API_Da_inoltrare_a__c='Nessun suggerimento'; 
            }
        }

	}
    
    public static void  changeRecordType(List<Case> caseListNew){
    	Id caseAperto = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('API_Case_Aperto').getRecordTypeId();
        Id caseChiuso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('API_Case_Chiuso').getRecordTypeId();
        
        for(Case c: caseListNew){
            if((c.Status=='Closed' || c.Status=='Chiuso' || c.Status=='Annullato')  && c.RecordTypeId!=caseChiuso) 		c.RecordTypeId=caseChiuso;
            else if(c.RecordTypeId!=caseAperto)                c.RecordTypeId=caseAperto;
        }
    }
    
    public static void  emailAccount(List<Case> caseListNew){
        List<String> accounts= new List<String>();
        List<Case> caseConEmail= new List<Case>();
        for(Case c: caseListNew){
            //per ogni case controllo se c'ha l'account, se si metto l'id dell'account in una lista perchè dopo mi devo recuperare la mail
            if(c.AccountId!=null){
                accounts.add(c.AccountId);
                caseConEmail.add(c);
            }
        }
        List<Account> accountEmails= [Select id, API_Email__c from Account where Id in: accounts];
        //faccio la mappa Id-Email
        Map<String,String> mapMails= new Map<String,String>();
        for(Account a: accountEmails){            mapMails.put(a.Id, a.API_Email__c);
        }
        
        for(Case c: caseConEmail){
            if(mapMails.get(c.AccountId)!=null)
            c.Email_Account__c=mapMails.get(c.AccountId);
        }
    }

    public static void  updateValueStatus(Map<Id,Case> newMapCase,Map<Id,Case> oldMapCase){
    	/*METODO CHE SERVE PER LA CREAZIONE DELLE BUSINESS HOUR E PER IL TRACCIAMENTO DEL CAMBIO OWNER DEL CASE*/
		List<API_Business__c> butoAdd = new List<API_Business__c>();
		set<Id> idCase = new Set<Id>();
		Map<Id,API_Business__c> bHourMap = new Map<Id,API_Business__c>(); 
		BusinessHours defaultbHour = [select Id,CreatedDate, Name from BusinessHours where Name='Api_BH' limit 1];
		set<Id> idUser = new Set<Id>();
		for (Id idNew : newMapCase.keySet()){
			idUser.add(newMapCase.get(idNew).OwnerId);
		}
		for (Id idOld : oldMapCase.keySet()){
			idUser.add(oldMapCase.get(idOld).OwnerId);
		}

		system.debug('@@@@@@@@@@idUser'+idUser);
		Map<Id,User> userMap = new Map<Id,User>([Select id,  Name from User where id=:idUser]); 

		Map<Id,Group> groupMap = new Map<Id,Group>([Select id,  Name from Group where id=:idUser]); 
		
		List<CaseHistory> caseHistoryList =[select Id, CaseId,OldValue,NewValue,CreatedDate 
											from CaseHistory 
											WHERE CaseId IN :newMapCase.keySet()
											order by CreatedDate DESC];

		Map<Id,Case> caseUser = new Map<Id,Case>([select Id, Owner.Type
											from Case
											WHERE Id IN :newMapCase.keySet()
											order by CreatedDate DESC]);


		

		Map<Id,List<CaseHistory>> mapCH = new Map<Id,List<CaseHistory>>();
		for(CaseHistory ch : caseHistoryList){
				if(!mapCH.containsKey(ch.CaseId)) mapCH.put(ch.CaseId, new List<CaseHistory>());
				mapCH.get(ch.CaseId).add(ch);

		}

		list<User> userList =[SELECT id, isActive FROM user WHERE id IN ( SELECT userOrGroupId FROM groupmember WHERE Group.DeveloperName= 'Case_II_Livello') And
							 isActive = true];
		String queueSobjectList =[select id from QueueSobject where queue.DeveloperName ='Case_II_Livello' limit 1].id;
		List<Case> caseToUpdate = new List<Case>();

		for (Id idNew : newMapCase.keySet()){
			API_Business__c bHour = new API_Business__c(); 
			/*for (Id idOld : oldMapCase.keySet()){
					if(idNew==idOld){*/
						if(newMapCase.get(idNew).Status != oldMapCase.get(idNew).Status){
								bHour.Name = 'Cambio stato';
								bHour.Api_Case__c = oldMapCase.get(idNew).Id;
								bHour.Api_Stato_precedente__c = oldMapCase.get(idNew).Status;
								bHour.Api_Stato_successivo__c = newMapCase.get(idNew).Status;

								if(mapCH.containsKey(idNew)){
									for(CaseHistory ch : mapCH.get(idNew)){
										system.debug('@@@@@@@@@@ch'+ch);
										system.debug('@@@@@@@@@@ch.NewValue'+ch.NewValue);
										system.debug('@@@@@@@@@@oldMapCase.get(idNew).Status'+oldMapCase.get(idNew).Status);
										if(ch.NewValue == oldMapCase.get(idNew).Status || ch.NewValue==null){
											system.debug('sono entrato nellif');

												Long min = Math.abs(BusinessHours.diff(defaultbHour.Id,  newMapCase.get(idNew).LastModifiedDate, ch.CreatedDate)/1000/60);
												Long orarioCalc = min/60;
												Integer minCalc = Math.mod(Integer.valueOf(min),Integer.valueof(60));

												String orario =  String.valueof(orarioCalc)+':'+String.valueof(minCalc)+' ore';

												bHour.Api_Tempo_di_lavoro__c = orario;

												break; 
											}
										}
                            	}
								butoAdd.add(bHour);
							
						}
						if(newMapCase.get(idNew).OwnerId != oldMapCase.get(idNew).OwnerId){
							if(oldMapCase.get(idNew).Status != 'Closed' || oldMapCase.get(idNew).Status!='Annullato'){
								for(user u :userList){
									if(newMapCase.get(idNew).OwnerId == queueSobjectList || newMapCase.get(idNew).OwnerId == u.id){
										Case c = new Case();
										c.id = idNew;
										c.Status = 'Aperto scalato';
										caseToUpdate.add(c);
									}
								}
							}
							bHour.Name = 'Cambio Owner';
							bHour.Api_Case__c = oldMapCase.get(idNew).Id;	

							Id oldCaseOwnerId=oldMapCase.get(idNew).OwnerId;
							system.debug(' oldCaseOwnerId'+ oldCaseOwnerId);

							if(userMap.get(oldCaseOwnerId)!= null) 
									bHour.Api_Owner_Precedente__c =userMap.get(oldCaseOwnerId).Name;

							else if(groupMap.get(oldCaseOwnerId)!= null)
									 bHour.Api_Owner_Precedente__c =groupMap.get(oldCaseOwnerId).Name;

							if(caseUser.get(idNew).Owner.Type == 'User')
								bHour.Api_Owner_Successivo__c =userMap.get(newMapCase.get(idNew).OwnerId).Name;		
							else if(caseUser.get(idNew).Owner.Type == 'Queue')
								bHour.Api_Owner_Successivo__c =groupMap.get(newMapCase.get(idNew).OwnerId).Name;		
							butoAdd.add(bHour);
						}


		}

		update caseToUpdate;
		insert butoAdd;   
	}
	public static void  insertValuegroup(List<Case> caseListNew){
		/*METODO CHE SERVE PER INSERIRE IL LIVELLO DEL BACK OFFICE CHE HA PRESO IN CARICO UN CASE*/
		system.debug('@@@@@@@@@@caseListNew'+caseListNew);
		set<Id> idUser = new Set<Id>();
		for (Case newCase : caseListNew){
			idUser.add(newCase.OwnerId);
		}
		
		Map<Id,Group> groupMap = new Map<Id,Group>([Select id, Name from Group where id=:idUser]); 
		Map<Id,User> userMap = new Map<Id,User>([Select Id, Name,API_livelloBackoffice__c from User where id=:idUser]); 
        
		for (Case newCase : caseListNew){
            newCase.API_Data_apertura__c=system.now();
            if(newCase.Status == 'Chiuso' || newCase.Status == 'Annullato' ){
            	newCase.API_Data_chiusura__c=system.now();
                newCase.RecordTypeId =Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('API_Case_Chiuso').getRecordTypeId(); 
            }
            if(userMap!=null && userMap.get(newCase.OwnerId)!=null && newCase.OwnerId == userMap.get(newCase.OwnerId).Id && (newCase.Status=='Chiuso' || newCase.Status=='Annullato')){
            	newCase.Gruppo_chiusura__c = userMap.get(newCase.OwnerId).API_livelloBackoffice__c;
            }
            else if(groupMap!=null && groupMap.get(newCase.OwnerId)!=null && newCase.OwnerId == groupMap.get(newCase.OwnerId).Id && (newCase.Status=='Chiuso' || newCase.Status=='Annullato')){
				newCase.Gruppo_chiusura__c = groupMap.get(newCase.OwnerId).Name;
            }
            
            system.debug('@@@@@@@@@@newCase.API_Data_apertura__c'+newCase.API_Data_apertura__c);
			system.debug('@@@@@@@@@@newCase'+newCase);
				if(userMap.get(newCase.OwnerId)!=null){
					for (Id userId : userMap.keySet()){
						if(newCase.OwnerId == userMap.get(userId).Id){
							system.debug('@@@@@@@@@@sono uguali inserisco userMap.get(userId).API_livelloBackoffice__c' +userMap.get(userId).API_livelloBackoffice__c);
							newCase.API_Gruppo_apertura__c = userMap.get(userId).API_livelloBackoffice__c;
                            
						}
				}
					
				}
				if(groupMap.get(newCase.OwnerId)!=null){
					for (Id queueId : groupMap.keySet()){
						if(newCase.OwnerId == groupMap.get(queueId).Id){
							system.debug('@@@@@@@@@@sono uguali inserisco groupMap.get(queueId).Name' +groupMap.get(queueId).Name);
							newCase.API_Gruppo_apertura__c = groupMap.get(queueId).Name;
                           
						}
					}
				}
			
		}

	}

	public static void  insertValueClosedgroup(List<Case> caseListNew, Map<Id,Case> oldcaseMap){
		/*METODO CHE SERVE PER AGGIORNARE IL LIVELLO DEL BACK OFFICE CHE HA PRESO CHIUSO UN CASE*/
		system.debug('@@@@@@@@@@caseListNew'+caseListNew);
		set<Id> idUser = new Set<Id>();
		for (Case newCase : caseListNew){
			idUser.add(newCase.OwnerId);
		}
		Map<Id,Group> groupMap = new Map<Id,Group>([Select id, Name from Group where id=:idUser]);
		Map<Id,User> userMap = new Map<Id,User>([Select Id, Name,API_livelloBackoffice__c from User where id=:idUser]); 
		for (Case newCase : caseListNew){
			system.debug('@@@@@@@@@@newCase'+newCase);
            if((newCase.Status=='Chiuso' || newCase.Status=='Annullato') &&(newCase.Status != oldcaseMap.get(newCase.Id).Status)){
                    newCase.API_Data_chiusura__c=system.now();
            }
			
			if(userMap!=null && userMap.get(newCase.OwnerId)!=null && newCase.OwnerId == userMap.get(newCase.OwnerId).Id && (newCase.Status=='Chiuso' || newCase.Status=='Annullato') &&(newCase.Status != oldcaseMap.get(newCase.Id).Status)){
					system.debug('@@@@@@@@@@sono uguali');
					system.debug('@@@@@@@@@@newCase.OwnerId'+newCase.OwnerId);
					
					newCase.Gruppo_chiusura__c = userMap.get(newCase.OwnerId).API_livelloBackoffice__c;
					system.debug('@@@@@@@@@@newCase.Gruppo_chiusura__c '+newCase.Gruppo_chiusura__c );
					system.debug('@@@@@@@@@@userMap.get(userId).API_livelloBackoffice__c '+userMap.get(newCase.OwnerId).API_livelloBackoffice__c);
			}
            
			else if(groupMap!=null && groupMap.get(newCase.OwnerId)!=null && newCase.OwnerId == groupMap.get(newCase.OwnerId).Id && (newCase.Status=='Chiuso' || newCase.Status=='Annullato') && (newCase.Status != oldcaseMap.get(newCase.Id).Status)){
					system.debug('@@@@@@@@@@sono uguali inserisco groupMap.get(queueId).Name' +groupMap.get(newCase.OwnerId).Name);
					newCase.Gruppo_chiusura__c = groupMap.get(newCase.OwnerId).Name;
            }
			   
			
            if(newCase.Status!='Chiuso' && newCase.Status!='Annullato'){
               system.debug('newCase.API_Data_chiusura__c '+newCase.API_Data_chiusura__c);
               newCase.API_Data_chiusura__c = null;
               newCase.Gruppo_chiusura__c =null;
            }
		}

	}
	/*metodo utilizzato per fare lo sharing del singolo record l'agente se l'owner dell'account a cui è associato il case è un agente */
	public static void sharingRecordWithAgente(List<Case> caseNew, List<Case> caseOld){
		//Caso 1: è cambiato l'account a cui ho associato il case
		//faccio la solita mappa trigger old
		Map<String, Case> caseOldMap= new Map<String, Case>();
		List<String> ownerListaId= new List<String>();
		List<String> ownerOldListaId= new List<String>();
		List<String> accountListaId= new List<String>();
		List<String> accountOldListaId= new List<String>();
		for(Case c: caseOld)
			caseOldMap.put(c.Id, c);
		//mi prendo tutti i case per cui è cambiato l'account
		List<Case> caseDaSharare= new List<Case>();
		for(Case c: caseNew){
			Case old= caseOldMap.get(c.Id);
			if((old!=null && old.AccountId!= c.AccountId) || (c.AccountId!=null && c.API_AgenteOwnerDellAccountModificato__c)){
				caseDaSharare.add(c);
				c.API_AgenteOwnerDellAccountModificato__c=false;
				accountListaId.add(c.AccountId);
			}
		}
		System.debug('CASE DA SHARARE '+caseDaSharare.size());
		//mi devo prendere gli owner degli account che sono cambiati
		List<Account> accounts=[Select id, OwnerId from Account where Id in:accountListaId]; 
		Map<String,String> mapXOwner= new Map<String,String>();
		for(Account a: accounts){
			ownerListaId.add(a.OwnerId);
			mapXOwner.put(a.Id, a.OwnerId);
		}
		System.debug('OWNER LIST '+ownerListaId.size());
		//per tutti i case per cui è cambiato l'account devo creare una sharing rule se l'owner dell'account è un agente
		List<User> ownerLista= [select id, Profile.Name from User where Profile.Name='AgentiPartnerCommunity' and Id in: ownerListaId];
		//se c'ho qualche owner agente devo fare lo sharing
		System.debug('OWNER LIST AGENTI'+ownerLista.size());
		//per tutti i case da sharare (anche quelli con owner non agente) mi vado a prendere le sharing manuali già presenti
		List<CaseShare> caseShareList= [select Id, CaseId, UserOrGroupId, UserOrGroup.Name,  CaseAccessLevel, RowCause  
						from CaseShare where RowCause  =: 'Manual' and CaseId in:caseDaSharare] ;
		delete caseShareList;
		if(ownerLista.size()>0){
			Map<String, User> mapAgenti= new Map<String, User>();
			for(User u: ownerLista)
				mapAgenti.put(u.Id, u);
			System.debug(mapAgenti);
			//devo togliere dalla lista dei case da sharare tutti quelli che non sono sharati con gli agenti
			List<Case> caseDaSharareAgenti= new List<Case>();
			for(Case c: caseDaSharare)
				if(mapAgenti.get(mapXOwner.get(c.AccountId))!=null)
				caseDaSharareAgenti.add(c);
			System.debug('caseDaSharareAgenti'+caseDaSharareAgenti.size());
			
			//mi creo una mappa dei casesharing
			Map<String,List<CaseShare>> mappaCaseSharePerCase= new  Map<String,List<CaseShare>>();
			for(CaseShare cs: caseShareList){
				List<CaseShare> csList=mappaCaseSharePerCase.get(cs.CaseId);
				if(csList==null)
					csList= new List<CaseShare>();
				csList.add(cs);
				mappaCaseSharePerCase.put(cs.CaseId, csList);
			}
			System.debug('caseShareList'+caseShareList.size());
			//finalmente per ogni case da sherare  creo quello nuovo
			List<CaseShare> caseShareDaInserire= new List<CaseShare>();
			for(Case c: caseDaSharareAgenti){
				//mi prendo i case share associati e li metto nella lista di quelli da cancellare
				List<CaseShare> csList= mappaCaseSharePerCase.get(c.Id);
				//creo il nuovo caseShare
				CaseShare  caseShr  = new CaseShare();
				// Set the ID of record being shared.
				caseShr.CaseId = c.Id;
				// Set the ID of user or group being granted access.
				caseShr.UserOrGroupId = mapAgenti.get(mapXOwner.get(c.AccountId)).Id;
				// Set the access level.
				caseShr.CaseAccessLevel = 'Read';	
				// Set rowCause to 'manual' for manual sharing.
				// This line can be omitted as 'manual' is the default value for sharing objects.
				caseShr.RowCause = Schema.CaseShare.RowCause.Manual;
				caseShareDaInserire.add(caseShr);
			}
			System.debug('caseShareDaInserire'+caseShareDaInserire.size());
			insert caseShareDaInserire; 
		}

	}

/*metodo utilizzato per fare lo sharing del singolo record l'agente se l'owner dell'account a cui è associato il case è un agente */
/*public static void sharingRecordWithAgenteInsert(List<Case> caseNew){
	List<String> ownerListaId= new List<String>();
	List<String> accountListaId= new List<String>();
	//mi prendo tutti i case per cui è inserito l'account
	List<Case> caseDaSharare= new List<Case>();
	for(Case c: caseNew){
		if(c.accountId!=null){
			caseDaSharare.add(c);
			accountListaId.add(c.AccountId);
		}
	}
	System.debug('CASE DA SHARARE '+caseDaSharare.size());
	//mi devo prendere gli owner degli account relativi ai case inseriti
	List<Account> accounts=[SELECT id, OwnerId FROM Account WHERE Id IN:accountListaId]; 
	Map<String,String> mapXOwner= new Map<String,String>();
	for(Account a: accounts){
		ownerListaId.add(a.OwnerId);
		mapXOwner.put(a.Id, a.OwnerId);
	}
	System.debug('OWNER LIST '+ownerListaId.size());

	//Seleziono SOLO gli agenti tra gli owner degli account
	Set<Id> ownerAgentiSet = new Set<Id>();
	for(User user : [SELECT id FROM User WHERE Profile.Name='AgentiPartnerCommunity' AND Id IN: ownerListaId]){
		ownerAgentiSet.add(user.Id);
	}
	System.debug('OWNER LIST AGENTI'+ownerAgentiSet.size());

	if(!ownerAgentiSet.isEmpty()){
	//per tutti i case per cui è inserito l'account devo creare una sharing rule SSE l'owner dell'account è un agente
	List<Case> caseDaSharareAgenti= new List<Case>();
		for(Case c: caseDaSharare)
			if(ownerAgentiSet.contains(mapXOwner.get(c.AccountId))){
				caseDaSharareAgenti.add(c);
			}
		System.debug('caseDaSharareAgenti'+caseDaSharareAgenti.size());
		
		//Per ogni case da sharare  creo un nuovo CaseShare Obj
		List<CaseShare> caseShareDaInserire= new List<CaseShare>();
		for(Case c: caseDaSharareAgenti){
			//creo il nuovo caseShare
			CaseShare  caseShr  = new CaseShare();
			caseShr.CaseId = c.Id;
			caseShr.UserOrGroupId = mapXOwner.get(c.AccountId);
			caseShr.CaseAccessLevel = 'Read';	
			caseShr.RowCause = Schema.CaseShare.RowCause.Manual;
			caseShareDaInserire.add(caseShr);
		}
		System.debug('caseShareDaInserire'+caseShareDaInserire.size());
		insert caseShareDaInserire; 
	}

}
*/

}