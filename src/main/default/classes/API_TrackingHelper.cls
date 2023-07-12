public class API_TrackingHelper {
    
    public static void  creaRecordDiTracking(List<Account> accountNew, List<Account> accountOld){
        //lista dei record di tracking da creare
        List<API_AccountTracking__c> recordTrackingList= new List<API_AccountTracking__c>();
        List<Account> updateAccount = new list<Account>();
        //mi prendo tutti i campi che devo tracciare dal custom metadata
        List<API_TrackingAccountFields__mdt> campiCM= [Select Id, MasterLabel, DeveloperName  from API_TrackingAccountFields__mdt];
        //creo la mappa degli utenti nuovo
        Map<String, Account> accountOldMap= new Map<String, Account>();
        for(Account a: accountOld){
            accountOldMap.put(a.Id, a);
        }
        //per ogni account devo controllare se il valore vecchio è diverso dal valore nuovo dei campi di interesse
        //se sì inserisce un record di tracking
        for(Account a: accountNew){
            //devo controllare ogni campo
            for(API_TrackingAccountFields__mdt trackfield: campiCM){
                String filedLabel= trackfield.MasterLabel;
                String field= trackfield.DeveloperName;
                Account old= accountOldMap.get(a.Id);
                if(a.id == old.Id){
                    if(old.get(field+'__c')!= null){
                        if(a.get(field+'__c')!= old.get(field+'__c')){
                            API_AccountTracking__c trackRecord= new API_AccountTracking__c();
                            Account acc = new Account();
                            trackRecord.API_Account__c= a.Id;
                            acc.Id = a.Id;
                            acc.API_Data_ultima_variazione_Stato__c = System.today();
                            trackRecord.API_Data_variazione__c= System.now();
                            trackRecord.API_Campo__c=field;
                            trackRecord.API_Valore_vecchio__c= String.valueOf(old.get(field+'__c'));
                            trackRecord.API_Valore_nuovo__c= String.valueOf(a.get(field+'__c'));
                            System.debug('&&&&&&' + trackRecord.API_Valore_vecchio__c+' '+trackRecord.API_Valore_nuovo__c);
                            trackRecord.API_User__c= a.LastModifiedById;
                            recordTrackingList.add(trackRecord);
                            updateAccount.add(acc);
                        }
                    }
                }
            }
        }
        Set<Account> accountSet= new Set<Account>(updateAccount);
        updateAccount= new List<Account>(accountSet); 
        update updateAccount;
        insert recordTrackingList;
    }

    public static void method529(List<Account> accountNew){
        for(Account record: accountNew){
            if(record.API_Data_richiesta_Plafond_string__c!=null){
                List<String> date2Array=record.API_Data_richiesta_Plafond_string__c.split('/');
                if(date2Array.size()==3){
                    Date dataDecorrenza= Date.valueOf(date2Array[2]+'-'+date2Array[1]+'-'+date2Array[0]);
                    //Date.valueOf(date2Array[0]+'-'+date2Array[1]+'-'+date2Array[2]);
                    record.API_Data_richiesta_Plafond__c=dataDecorrenza;
                }
                else{
                    System.debug('Errore nel formato della data!!!! '+ record.API_Data_richiesta_Plafond_string__c);
                    record.API_Data_richiesta_Plafond__c=null;
                }
            }
        }
    }
    
    /*metodo gemello sul before insert*/
        public static void updateSapBeforeInsert(List<Account> accountNew){
        System.debug('BeforeInsert');
        List<String> codiceCliente  = new List<String>();
        
        for(Account acc : accountNew){
            System.debug(acc);
            if(acc.API_CodiceCliente__c!=null)
            	codiceCliente.add(acc.API_CodiceCliente__c);
            if(String.valueOf(acc.API_RID__c) == 'Y')                acc.API_RID__c = true;
            else if(String.valueOf(acc.API_RID__c) == 'N')                acc.API_RID__c = false;
            System.debug('1');
            
            if(String.valueOf(acc.API_DataInserimentoClienteSuSap__c) != null){
                List<String> DataInserimentoClienteSuSap= String.valueof(acc.API_DataInserimentoClienteSuSap__c).split('\\/');
                System.debug('DataInserimentoClienteSuSap!!!! '+ DataInserimentoClienteSuSap);
                if(DataInserimentoClienteSuSap.size()==3){
                    Date databloc1= Date.newInstance(integer.ValueOf(DataInserimentoClienteSuSap[2]),integer.ValueOf(DataInserimentoClienteSuSap[0]), integer.ValueOf(DataInserimentoClienteSuSap[1]));
                    acc.API_DataInserimentoClienteSuSap__c=databloc1;
                }
                System.debug('2');
            }
            
            
            if(String.valueOf(acc.API_ControlloSuccessivoSap__c) != null){
                List<String> API_ControlloSuccessivoSap= String.valueOf(acc.API_ControlloSuccessivoSap__c).split('\\/');
                System.debug('API_ControlloSuccessivoSap__c!!!! '+ API_ControlloSuccessivoSap);
                if(API_ControlloSuccessivoSap.size()==3){
                    Date databloc2= Date.newInstance(integer.ValueOf(API_ControlloSuccessivoSap[2]),integer.ValueOf(API_ControlloSuccessivoSap[0]), integer.ValueOf(API_ControlloSuccessivoSap[1]));
                    acc.API_ControlloSuccessivoSap__c=databloc2;
                }
                 System.debug('3');
            }
           
            
            if(String.valueOf(acc.API_Ultima_Revisione__c) != null){
                List<String> API_Ultima_Revisione= String.valueOf(acc.API_Ultima_Revisione__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ API_Ultima_Revisione);
                if(API_Ultima_Revisione.size()==3){
                    Date databloc3= Date.newInstance(integer.ValueOf(API_Ultima_Revisione[2]),integer.ValueOf(API_Ultima_Revisione[0]), integer.ValueOf(API_Ultima_Revisione[1]));
                    acc.API_Ultima_Revisione__c=databloc3;
                }
                System.debug('4');
            }
            
            
            System.debug('&&&&'+acc.API_AutorizzazionePrivacy__c+'&&&&');
            if(acc.API_AutorizzazionePrivacy__c != null){
                if(acc.API_AutorizzazionePrivacy__c == 'Tutto' || acc.API_AutorizzazionePrivacy__c == 'Tu' || acc.API_AutorizzazionePrivacy__c == '01'){
                    acc.API_AutorizzProfilazione__c = true;
                    acc.API_AutorizzInvioMatProm__c = true;
                }else if(acc.API_AutorizzazionePrivacy__c == 'Niente' || acc.API_AutorizzazionePrivacy__c == 'Ni' || acc.API_AutorizzazionePrivacy__c == '02'){
                    acc.API_AutorizzProfilazione__c = false;
                    acc.API_AutorizzInvioMatProm__c = false;
                }else if(acc.API_AutorizzazionePrivacy__c == 'Statistico' || acc.API_AutorizzazionePrivacy__c == 'St' || acc.API_AutorizzazionePrivacy__c == '03'){
                    acc.API_AutorizzProfilazione__c = false;
                    acc.API_AutorizzInvioMatProm__c = true;
                }else if(acc.API_AutorizzazionePrivacy__c == 'Profilazione' || acc.API_AutorizzazionePrivacy__c == 'Pr' || acc.API_AutorizzazionePrivacy__c == '04'){
                    acc.API_AutorizzProfilazione__c = true;
                    acc.API_AutorizzInvioMatProm__c = false; 
                }
                System.debug('5');
            }
            
            System.debug('API_Fatturazione__c:  ' +acc.API_Fatturazione__c);
            if(acc.API_Fatturazione__c != null){
                if(acc.API_Fatturazione__c == 'T')
                    acc.API_Fatturazione__c = '15';
                else if(acc.API_Fatturazione__c == 'M')
                    acc.API_Fatturazione__c = '30';
                System.debug('6');
            }
            
            if(String.valueOf(acc.API_Data_Override__c) != null){
                List<String> API_Data_Override= String.valueOf(acc.API_Data_Override__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ API_Data_Override);
                if(API_Data_Override.size()==3){
                    Date databloc4= Date.newInstance(integer.ValueOf(API_Data_Override[2]),integer.ValueOf(API_Data_Override[0]), integer.ValueOf(API_Data_Override[1]));
                    acc.API_Ultima_Revisione__c=databloc4;
                }
                System.debug('7');
            }
            
            if(String.valueOf(acc.API_Data_Scadenza_Override__c) != null){
                List<String> API_Data_Scadenza_Override= String.valueOf(acc.API_Data_Scadenza_Override__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ API_Data_Scadenza_Override);
                if(API_Data_Scadenza_Override.size()==3){
                    Date databloc5= Date.newInstance(integer.ValueOf(API_Data_Scadenza_Override[2]),integer.ValueOf(API_Data_Scadenza_Override[0]), integer.ValueOf(API_Data_Scadenza_Override[1]));
                    acc.API_Data_Scadenza_Override__c=databloc5;
                }
                System.debug('8');
            }
            
            if(String.valueOf(acc.API_FatturazioneElettronica__c) == 'Y')                acc.API_FatturazioneElettronica__c = true;
            else if(String.valueOf(acc.API_FatturazioneElettronica__c) == 'N')                acc.API_FatturazioneElettronica__c = false;
            System.debug('9');
            
            if(String.valueOf(acc.API_SplitPubblicaAmministrazione__c) == 'Y')                acc.API_SplitPubblicaAmministrazione__c = true;
            else if(String.valueOf(acc.API_SplitPubblicaAmministrazione__c) == 'N')                acc.API_SplitPubblicaAmministrazione__c = false;
            System.debug('10');
            
            if(String.valueOf(acc.API_ClienteSensibile__c) == 'Y')                acc.API_ClienteSensibile__c = true;
            else if(String.valueOf(acc.API_ClienteSensibile__c) == 'N')                acc.API_ClienteSensibile__c = false;
            System.debug('11');
            
            if(String.valueOf(acc.API_ClienteTop__c) == 'Y')                acc.API_ClienteTop__c = true;
            else if(String.valueOf(acc.API_ClienteTop__c) == 'N')                acc.API_ClienteTop__c = false;
            System.debug('12');
            
            if(String.valueOf(acc.API_FatturazionePDF__c) == 'Y')                acc.API_FatturazionePDF__c = true;
            else if(String.valueOf(acc.API_FatturazionePDF__c) == 'N')                acc.API_FatturazionePDF__c = false;
            System.debug('13');
            
            
            if(String.valueOf(acc.API_DataSottoscrizioneContratto__c) != null){
                List<String> DataSottoscrizioneContratto= String.valueOf(acc.API_DataSottoscrizioneContratto__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ DataSottoscrizioneContratto);
                if(DataSottoscrizioneContratto.size()==3){
                    Date databloc6= Date.newInstance(integer.ValueOf(DataSottoscrizioneContratto[2]),integer.ValueOf(DataSottoscrizioneContratto[0]), integer.ValueOf(DataSottoscrizioneContratto[1]));
                    acc.API_DataSottoscrizioneContratto__c=databloc6;
                }
                System.debug('14');
            }
            
            
            
        }
        /*list<Quote> quoteList = [select id, Account.API_CodiceCliente__c, AccountId, /*API_CondizioniPagamento__c,*/ /*API_CodiceCessione__c, API_Tipo_fido__c, API_Fatturazione__c 
                                 From quote where Account.API_CodiceCliente__c in: codiceCliente]; 
        
        for(Quote quo :quoteList){
            for(Account acc :accountNew){
                if(quo.Account.API_CodiceCliente__c == acc.API_CodiceCliente__c){
                    //quo.API_CondizioniPagamento__c = acc.API_CondizioniPagamentoQuote__c;
                    quo.API_CodiceCessione__c = acc.API_CodiceCessione__c;
                    quo.API_NomeSottoscrittore__c = acc.API_NomeSottoscrittore__c;
                    quo.API_CodiceFiscaleFirmatarioSepa__c = acc.API_CodiceFiscaleFirmatarioSepa__c;
                    quo.API_DataSottoscrizioneContratto__c = acc.API_DataSottoscrizioneContratto__c;
                    //quo.API_Tipo_Contratto__c = acc.API_TipoContratto__c;
                }
            }
        }
        
        update quoteList;*/
        
       
    }
    
    public static void updateSap(List<Account> accountNew, List<Account> accountOld){
        
        List<String> codiceCliente  = new List<String>();
        
        for(Account acc : accountNew){
            if(acc.API_CodiceCliente__c!=null)
            	codiceCliente.add(acc.API_CodiceCliente__c);
            if(String.valueOf(acc.API_RID__c) == 'Y')                acc.API_RID__c = true;
            else if(String.valueOf(acc.API_RID__c) == 'N')                acc.API_RID__c = false;
            
            
            if(String.valueOf(acc.API_DataInserimentoClienteSuSap__c) != null){
                List<String> DataInserimentoClienteSuSap= String.valueof(acc.API_DataInserimentoClienteSuSap__c).split('\\/');
                System.debug('DataInserimentoClienteSuSap!!!! '+ DataInserimentoClienteSuSap);
                if(DataInserimentoClienteSuSap.size()==3){
                    Date databloc1= Date.newInstance(integer.ValueOf(DataInserimentoClienteSuSap[2]),integer.ValueOf(DataInserimentoClienteSuSap[0]), integer.ValueOf(DataInserimentoClienteSuSap[1]));
                    acc.API_DataInserimentoClienteSuSap__c=databloc1;
                }
            }
            
            if(String.valueOf(acc.API_ControlloSuccessivoSap__c) != null){
                List<String> API_ControlloSuccessivoSap= String.valueOf(acc.API_ControlloSuccessivoSap__c).split('\\/');
                System.debug('API_ControlloSuccessivoSap__c!!!! '+ API_ControlloSuccessivoSap);
                if(API_ControlloSuccessivoSap.size()==3){
                    Date databloc2= Date.newInstance(integer.ValueOf(API_ControlloSuccessivoSap[2]),integer.ValueOf(API_ControlloSuccessivoSap[0]), integer.ValueOf(API_ControlloSuccessivoSap[1]));
                    acc.API_ControlloSuccessivoSap__c=databloc2;
                }
            }
            
            if(String.valueOf(acc.API_Ultima_Revisione__c) != null){
                List<String> API_Ultima_Revisione= String.valueOf(acc.API_Ultima_Revisione__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ API_Ultima_Revisione);
                if(API_Ultima_Revisione.size()==3){
                    Date databloc3= Date.newInstance(integer.ValueOf(API_Ultima_Revisione[2]),integer.ValueOf(API_Ultima_Revisione[0]), integer.ValueOf(API_Ultima_Revisione[1]));
                    acc.API_Ultima_Revisione__c=databloc3;
                }
            }
            
            System.debug('$$$$$$'+acc.API_AutorizzazionePrivacy__c+'$$$$$$');
            if(acc.API_AutorizzazionePrivacy__c != null){
                if(acc.API_AutorizzazionePrivacy__c == 'Tutto' || acc.API_AutorizzazionePrivacy__c == 'Tu' || acc.API_AutorizzazionePrivacy__c == '01'){
                    acc.API_AutorizzProfilazione__c = true;
                    acc.API_AutorizzInvioMatProm__c = true;
                }else if(acc.API_AutorizzazionePrivacy__c == 'Niente' || acc.API_AutorizzazionePrivacy__c == 'Ni' || acc.API_AutorizzazionePrivacy__c == '02'){
                    acc.API_AutorizzProfilazione__c = false;
                    acc.API_AutorizzInvioMatProm__c = false;
                }else if(acc.API_AutorizzazionePrivacy__c == 'Statistico' || acc.API_AutorizzazionePrivacy__c == 'St' || acc.API_AutorizzazionePrivacy__c == '03'){
                    acc.API_AutorizzProfilazione__c = false;
                    acc.API_AutorizzInvioMatProm__c = true;
                }else if(acc.API_AutorizzazionePrivacy__c == 'Profilazione' || acc.API_AutorizzazionePrivacy__c == 'Pr'|| acc.API_AutorizzazionePrivacy__c == '04'){
                    acc.API_AutorizzProfilazione__c = true;
                    acc.API_AutorizzInvioMatProm__c = false; 
                }
            }
            
            System.debug('API_Fatturazione__c:  ' +acc.API_Fatturazione__c);
            if(acc.API_Fatturazione__c != null){
                if(acc.API_Fatturazione__c == 'T')
                    acc.API_Fatturazione__c = '15';
                else if(acc.API_Fatturazione__c == 'M')
                    acc.API_Fatturazione__c = '30';
            }
            
            if(String.valueOf(acc.API_Data_Override__c) != null){
                List<String> API_Data_Override= String.valueOf(acc.API_Data_Override__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ API_Data_Override);
                if(API_Data_Override.size()==3){
                    Date databloc4= Date.newInstance(integer.ValueOf(API_Data_Override[2]),integer.ValueOf(API_Data_Override[0]), integer.ValueOf(API_Data_Override[1]));
                    acc.API_Ultima_Revisione__c=databloc4;
                }
            }
            
            if(String.valueOf(acc.API_Data_Scadenza_Override__c) != null){
                List<String> API_Data_Scadenza_Override= String.valueOf(acc.API_Data_Scadenza_Override__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ API_Data_Scadenza_Override);
                if(API_Data_Scadenza_Override.size()==3){
                    Date databloc5= Date.newInstance(integer.ValueOf(API_Data_Scadenza_Override[2]),integer.ValueOf(API_Data_Scadenza_Override[0]), integer.ValueOf(API_Data_Scadenza_Override[1]));
                    acc.API_Data_Scadenza_Override__c=databloc5;
                }
            }
            
            if(String.valueOf(acc.API_FatturazioneElettronica__c) == 'Y')                acc.API_FatturazioneElettronica__c = true;
            else if(String.valueOf(acc.API_FatturazioneElettronica__c) == 'N')                acc.API_FatturazioneElettronica__c = false;
            
            
            if(String.valueOf(acc.API_SplitPubblicaAmministrazione__c) == 'Y')                acc.API_SplitPubblicaAmministrazione__c = true;
            else if(String.valueOf(acc.API_SplitPubblicaAmministrazione__c) == 'N')                acc.API_SplitPubblicaAmministrazione__c = false;
            
            
            if(String.valueOf(acc.API_ClienteSensibile__c) == 'Y')                acc.API_ClienteSensibile__c = true;
            else if(String.valueOf(acc.API_ClienteSensibile__c) == 'N')                acc.API_ClienteSensibile__c = false;
            
            
            if(String.valueOf(acc.API_ClienteTop__c) == 'Y')                acc.API_ClienteTop__c = true;
            else if(String.valueOf(acc.API_ClienteTop__c) == 'N')                acc.API_ClienteTop__c = false;
            
            if(String.valueOf(acc.API_FatturazionePDF__c) == 'Y')                acc.API_FatturazionePDF__c = true;
            else if(String.valueOf(acc.API_FatturazionePDF__c) == 'N')                acc.API_FatturazionePDF__c = false;
            
            
            
            if(String.valueOf(acc.API_DataSottoscrizioneContratto__c) != null){
                List<String> DataSottoscrizioneContratto= String.valueOf(acc.API_DataSottoscrizioneContratto__c).split('\\/');
                System.debug('API_Ultima_Revisione__c!!!! '+ DataSottoscrizioneContratto);
                if(DataSottoscrizioneContratto.size()==3){
                    Date databloc6= Date.newInstance(integer.ValueOf(DataSottoscrizioneContratto[2]),integer.ValueOf(DataSottoscrizioneContratto[0]), integer.ValueOf(DataSottoscrizioneContratto[1]));
                    acc.API_DataSottoscrizioneContratto__c=databloc6;
                }
            }
            
            
            
        }
        
        //devo richiamare il metodo se no quando importo da SAP non partonmo gli automatismi
        API_TrackingHelper.updateStatiCliente(accountNew, accountOld);

    }

    /*Metodo che fa scattare gli automatismi di aggiornamento dello stato cliente/stato factoring*/
    public static void updateStatiCliente(List<Account> accountNew, List<Account> accountOld){
      Map<String,Account> mapAccountOld= new Map<String,Account>();
      for(Account old: accountOld){
          mapAccountOld.put(old.Id, old);
      }
      
      for(Account a: accountNew){
          //In modifica del record, se viene valorizzato il Codice SAP	Valorizzazione dello stato cliente a 'Codificato SAP'
          Account old= mapAccountOld.get(a.Id);
          if(String.isEmpty(old.API_CodiceCliente__c) && !String.isEmpty(a.API_CodiceCliente__c))
              a.API_Stato_cliente__c='Codificato SAP';
          //In modifica del record, se viene valorizzato lo Stato Fido = FAC	Valorizzazione dello stato factoring = 'AFFIDATO'
          if(a.API_Stato_Fido__c=='FAC' && old.API_Stato_Fido__c!='FAC')
              a.API_Stato_Factoring__c='Affidato';
          //In modifica del record, se viene valorizzato lo Stato Fido = NNC	Valorizzazione dello stato factoring = 'NON AFFIDATO'
          else if(a.API_Stato_Fido__c=='NNC' && old.API_Stato_Fido__c!='NNC')
              a.API_Stato_Factoring__c='Non affidato';
          //In modifica del record, se viene valorizzato lo Stato Fido = REV	Valorizzazione dello stato factoring = 'REVOCATO'
          else if(a.API_Stato_Fido__c=='REV' && old.API_Stato_Fido__c!='REV')
              a.API_Stato_Factoring__c='Revocato';

            if(String.valueOf(a.API_DataCartesiaString__c) != null){
                System.debug('a.API_DataCartesiaString: ' +a.API_DataCartesiaString__c);
                List<String> cartesia= String.valueof(a.API_DataCartesiaString__c).split('\\/');
                System.debug('cartesia!!!! '+ cartesia);
                if(cartesia.size()==3){
                    Date databloc1=Date.valueOf(cartesia[2]+'-'+cartesia[1]+'-'+cartesia[0]);
                    //Date databloc1= Date.newInstance(integer.ValueOf(cartesia[1]),integer.ValueOf(cartesia[0]), integer.ValueOf(cartesia[2]));
                    a.API_Data_Inserimento_Cliente_su_Cartesia__c=databloc1;
                }
                System.debug('2');
            }

           if(String.valueOf(a.API_DataBloccoString__c) != null){
                System.debug('a.API_DataBloccoString__c: ' +a.API_DataBloccoString__c);
                List<String> blocco= String.valueof(a.API_DataBloccoString__c).split('\\/');
                System.debug('blocco!!!! '+ blocco);
                if(blocco.size()==3){
                    Date databloc1=Date.valueOf(blocco[2]+'-'+blocco[1]+'-'+blocco[0]);
                    //Date databloc1= Date.newInstance(integer.ValueOf(blocco[2]),integer.ValueOf(blocco[0]), integer.ValueOf(blocco[1]));
                    a.API_Data_di_Blocco__c=databloc1;
                }
                System.debug('2');
            }
      }
  }
    
    public static void setAcquisitoDa(List<Account> accountNew){
        String idUser=UserInfo.getUserId();
        List<User> users= [Select id, name from user where id=:idUser];
		if(users.size()>0)
            for(Account a: accountNew){
                a.API_ClienteAcquisitoDa__c= users[0].Name;
            }
    }
     public static void updateStatiClienteBeforeInsert(List<Account> accountNew){
     	for(Account a: accountNew){
          //In modifica del record, se viene valorizzato il Codice SAP	Valorizzazione dello stato cliente a 'Codificato SAP'
          if(!String.isEmpty(a.API_CodiceCliente__c))
              a.API_Stato_cliente__c='Codificato SAP';
          //In modifica del record, se viene valorizzato lo Stato Fido = FAC	Valorizzazione dello stato factoring = 'AFFIDATO'
          if(a.API_Stato_Fido__c=='FAC')
              a.API_Stato_Factoring__c='Affidato';
          //In modifica del record, se viene valorizzato lo Stato Fido = NNC	Valorizzazione dello stato factoring = 'NON AFFIDATO'
          else if(a.API_Stato_Fido__c=='NNC')
              a.API_Stato_Factoring__c='Non affidato';
          //In modifica del record, se viene valorizzato lo Stato Fido = REV	Valorizzazione dello stato factoring = 'REVOCATO'
          else if(a.API_Stato_Fido__c=='REV')
              a.API_Stato_Factoring__c='Revocato';
          

            if(String.valueOf(a.API_DataCartesiaString__c) != null){
                List<String> cartesia= String.valueof(a.API_DataCartesiaString__c).split('\\/');
                System.debug('cartesia!!!! '+ cartesia);
                if(cartesia.size()==3){
                    Date databloc1=Date.valueOf(cartesia[2]+'-'+cartesia[1]+'-'+cartesia[0]);
                    //Date databloc1= Date.newInstance(integer.ValueOf(cartesia[1]),integer.ValueOf(cartesia[0]), integer.ValueOf(cartesia[2]));
                    a.API_Data_Inserimento_Cliente_su_Cartesia__c=databloc1;
                }
                System.debug('2');
            }

            if(String.valueOf(a.API_DataBloccoString__c) != null){
                System.debug('a.API_DataBloccoString__c: ' +a.API_DataBloccoString__c);
                List<String> blocco= String.valueof(a.API_DataBloccoString__c).split('\\/');
                System.debug('blocco!!!! '+ blocco);
                if(blocco.size()==3){
                    Date databloc1=Date.valueOf(blocco[2]+'-'+blocco[1]+'-'+blocco[0]);
                    //Date databloc1= Date.newInstance(integer.ValueOf(blocco[2]),integer.ValueOf(blocco[0]), integer.ValueOf(blocco[1]));
                    a.API_Data_di_Blocco__c=databloc1;
                }
                System.debug('2');
            }
        a.API_TipoSeda__c = 'Base';
        }
     }
    
    //metodo per sharare con gli agenti gli account
    //si assegna l'owner per i record creati dall'Admin
    public static void setOwner(List<Account> accountNew){
    	List<Account> accountCreatiDallAdmin= new List<Account>();
        try{
        User admin= [Select id, name from user where Profile.Name like '%Admin%' and name like'%API%' limit 1];
        for(Account a: accountNew){
            if(a.OwnerId== admin.Id)
            	accountCreatiDallAdmin.add(a);
        }
        }catch(Exception e){
            System.debug('Sono un agente, non devo fare questo metodo');
            return;
        }
        //mi creo una mappa per gli agenti: codice -> agente
        List<User> agenti= [Select id, Profile.Name, API_Codice_Agente__c, API_Codice_Area_Manager__c from user where Profile.Name ='AgentiPartnerCommunity' and IsActive =true ];
        Map<String,User> mapAgenti= new Map<String,User>();
        for(User u: agenti){
            if(u.API_Codice_Agente__c!=null)
            mapAgenti.put(u.API_Codice_Agente__c, u);
        }
        
        //mi creo la mappa degli AreaManager
        List<User> areaManager= [Select id, Profile.Name, API_Codice_Agente__c, API_Codice_Area_Manager__c from user where Profile.Name ='Profilo Area Manager' and IsActive =true];
        Map<String,User> mapAM= new Map<String,User>();
        for(User u: areaManager){
            if(u.API_Codice_Area_Manager__c!=null)
            	mapAM.put(u.API_Codice_Area_Manager__c, u);
        }
        System.debug('MAP AREAMANGERS '+mapAM.size());
        
        //per ogni account mi prendo il valore del campo API_CodiceAddettoVendite__c
         for(Account a: accountCreatiDallAdmin){
             
             User agente= mapAgenti.get(a.API_CodiceAddettoVendite__c);
             System.debug('***** '+agente);
             if(agente!=null) a.OwnerID= agente.Id;
             else{
                 User AM= mapAM.get(a.API_Codice_area_manager__c);
                 System.debug('***** '+AM);
                 if(AM!=null) a.OwnerID= AM.Id;
             }
         } 
    }
    /*Metodo per cambiare l'owner dell'account nel caso in cui cambia l'agente*/
    public static void setOwnerUpdate(List<Account> accountNew, List<Account> accountOld){
    	List<Account> accountCreatiDallAdmin= new List<Account>();
        MAp<String, Account> mapAccountOld= new MAp<String, Account>();
       
        for(Account a: accountOld){
            mapAccountOld.put(a.id, a);
        }

        for(Account a: accountNew){
            Account old= mapAccountOld.get(a.id);
            if(old.API_CodiceAddettoVendite__c!= a.API_CodiceAddettoVendite__c)
                accountCreatiDallAdmin.add(a);
        }
    
        //mi creo una mappa per gli agenti: codice -> agente
        List<User> agenti= [Select id, Profile.Name, API_Codice_Agente__c, API_Codice_Area_Manager__c from user where Profile.Name ='AgentiPartnerCommunity' and IsActive =true ];
        Map<String,User> mapAgenti= new Map<String,User>();
        for(User u: agenti){
            if(u.API_Codice_Agente__c!=null)
            mapAgenti.put(u.API_Codice_Agente__c, u);
        }
        
        //mi creo la mappa degli AreaManager
        List<User> areaManager= [Select id, Profile.Name, API_Codice_Agente__c, API_Codice_Area_Manager__c from user where Profile.Name ='Profilo Area Manager' and IsActive =true];
        Map<String,User> mapAM= new Map<String,User>();
        for(User u: areaManager){
            if(u.API_Codice_Area_Manager__c!=null)
            	mapAM.put(u.API_Codice_Area_Manager__c, u);
        }
        System.debug('MAP AREAMANGERS '+mapAM.size());
        
        //per ogni account mi prendo il valore del campo API_CodiceAddettoVendite__c
         for(Account a: accountCreatiDallAdmin){
             
             User agente= mapAgenti.get(a.API_CodiceAddettoVendite__c);
             System.debug('***** '+agente);
             if(agente!=null) a.OwnerID= agente.Id;
             else{
                 User AM= mapAM.get(a.API_Codice_area_manager__c);
                 System.debug('***** '+AM);
                 if(AM!=null) a.OwnerID= AM.Id;
             }
         } 
    }

    public static void shareCasePerAgenti(List<Account> accountNew, List<Account> accountOld){
        List<Account> accountACuiMettereIlFlag= new List<Account>();
        if(accountOld==null) //before insert
            accountACuiMettereIlFlag=accountNew;
        else{ //before update
            //creo la solita mappa degli old
            Map<String, Account> mappaOld= new Map<String, Account>();
            for(Account a: accountOld)
                mappaOld.put(a.Id, a);
            for(Account a: accountNew){
                Account old= mappaOld.get(a.Id);
                if(old.OwnerId!= a.OwnerId)
                    accountACuiMettereIlFlag.add(a);
            } 
        }
        List<case> caseDaAggiornare= [Select id, AccountId from Case where AccountId in: accountACuiMettereIlFlag];
        for(Case c: caseDaAggiornare){
            c.API_AgenteOwnerDellAccountModificato__c=true;
        }
        update caseDaAggiornare;
    }

    public static void updateAccount(List<Account> accountNew){
        List<Profile> profileList = [select id, name from profile where Name  = 'AgentiPartnerCommunity' or Name ='Profilo Area Manager'];
        id id1 = userinfo.getProfileId();
        for(profile p : profileList){
            if(p.Id == id1){
                for(Account acc : accountNew){
                    if(acc.API_CodiceCliente__c != null){
                        acc.addError('Non puoi modificare un cliente già inserito su SAP');
                    }
                }
            }
        }
        //Controllo che l'iban su account con quote in stato diverso da Bozza
        Set<Id> accountId = new Set<Id>();
        for(Account acc : accountNew){
            accountId.add(acc.Id);
        }
        List<Quote> quoteList = [select id, Opportunity.AccountId, status from quote where Opportunity.AccountId in: accountId];
        for(Quote q : quoteList){
            if(q.status != 'Bozza'){
                for(Account acc : accountNew){
                    if(q.Opportunity.AccountId == acc.Id && acc.API_IBAN__c == null && acc.API_Condizioni_di_Pagamento__c!=null && acc.API_Condizioni_di_Pagamento__c.contains('RID'))
                        acc.addError('L\'iban non può essere vuoto');
                }
            }
        }
    }

    public static void controlloCF(List<Account> accountNew){
        
    }

    public static void ribaltaRagioneSociale (List<Account> accountNew){

        for(Account acc : accountNew){
            acc.API_RagioneSociale__c = acc.Name; 
        }
    }

    public static void dataValiditaCIG(List<Account> accountNew){
        for(Account acc : accountNew){
            if(acc.API_CodiceCIG__c != null)
                acc.API_DataInizioValiditaCIG__c = Date.valueOf(acc.API_DataSottoscrizioneContratto__c);
        }
    }

    public static void codiceCessione(List<Account> accountNew){
        for(Account acc : accountNew){
            if(acc.API_Tipo_fido__c == 'IFI')
                acc.API_CodiceCessione__c = 'SI';
        }
    }
}