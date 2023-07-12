public class API_QuoteTriggerHelper {
    
    /*Metodo per il controllo delle deleghe. Qui si devono aggiungere/modificare tutte le condizioni delle deleghe non gestite dai flag*/
    public static void controlloDeleghe(List<Quote> quotes){
        
        List<API_PlatformEventDeleghe__e> events= new List<API_PlatformEventDeleghe__e>();
        List<String> listaMessaggi= new List<String>();
        //mi faccio la query sullo user
        String userID= UserInfo.getUserId();
        List<User> users= [Select Id, Name, UserRole.Name, Profile.Name, ManagerId from User where id=:userID];
        if(users.size()>0){
        //mappa Quote-> QLIX
        Map<String, List<API_QuoteLineItemX__c>> mapQuoteQLIX= new Map<String, List<API_QuoteLineItemX__c>>(); 
            User u= users[0];
        //faccio una lista di id delle quote
        List<String> listaQuoteID= new List<String>();
        for(Quote q : quotes)
            listaQuoteID.add(q.Id);
            
        //mi prendo il custom metadata con le logiche delle deleghe
        List<API_DeleghePacchetto__mdt> delegheList = [select Id, API_ValoreSconto__c, API_PacchettoScelto__c, 
                                                           API_Profilo__c, API_NomeDelega__c, DeveloperName, API_Offerta__c from API_DeleghePacchetto__mdt];
            
        List<QuoteLineItem> quoteLineItemList=[select id, QuoteId, PricebookEntryId, Product2Id from QuoteLineItem where QuoteId in: listaQuoteID];
        //faccio una lista di QuoteLineItemId
        List<String> quoteLineItemIds= new List<String>();
       
        for(QuoteLineItem ql: quoteLineItemList)
            quoteLineItemIds.add(ql.Id);
        
        //mi prendo i QuoteLineItemX associati
        List<API_QuoteLineItemX__c> qliXList= new List<API_QuoteLineItemX__c>();
        qliXList= [Select id, API_QuoteLineItem__c, API_QuoteLineItem__r.QuoteId, API_NomeProdotto__c, API_NomeAttributo__c, API_Valore__c, API_DeveloperNameMetadata__c 
                   from API_QuoteLineItemX__c where API_QuoteLineItem__c in: quoteLineItemIds]; 
        //creo le mappe
        //mappa Quote-> quoteLinItem
       /* Map<String, List<QuoteLineItem>> mapQuoteQLI= new Map<String, List<QuoteLineItem>>(); 
            for(QuoteLineItem qli: quoteLineItemList){
                List<QuoteLineItem> l= mapQuoteQLI.get(qli.QuoteId);
                if(l==null) l= new List<QuoteLineItem>();
                l.add(qli);
                mapQuoteQLI.put(qli.QuoteId, l);
            }*/
       if(qliXList.size()>0){
            for(API_QuoteLineItemX__c qxz : qliXList){
                List<API_QuoteLineItemX__c> qliXlCiclo=mapQuoteQLIX.get(qxz.API_QuoteLineItem__r.QuoteId);
                if(qliXlCiclo==null) qliXlCiclo= new List<API_QuoteLineItemX__c>();
                qliXlCiclo.add(qxz);
				mapQuoteQLIX.put(qxz.API_QuoteLineItem__r.QuoteId, qliXlCiclo);   
            }}
        //se la quote è in stato Completata e non ha mai fatto il processo di approvazione possono partire con i controlli
        for(Quote q : quotes){ 
            System.debug('@@@@ start controllo deleghe '+ q.API_QuoteInDelega__c);
            if(q.Status=='Completata' && (q.Stato_Approvazione__c!='Approvata' && q.Stato_Approvazione__c!='Corretta' /*&& q.Stato_Approvazione__c!='Rifiutata'*/) && !q.API_QuoteInDelega__c){
                //devo fare i controlli
                //Delega prezzo pompa agente
                if(u.Profile.Name =='AgentiPartnerCommunity' && q.API_Offerta__c=='Prezzo Pompa'){        listaMessaggi.add(Label.API_DelegaPrezzoPompa);          q.API_QuoteInDelega__c=true;
                }
                //delega Prezzo Platts
                if((u.Profile.Name =='AgentiPartnerCommunity' || (u.Profile.Name=='Profilo Area Manager' && u.UserRole.Name.contains('Area Manager'))) && q.API_Platts__c ){       listaMessaggi.add(Label.API_DelegatPrezzoPlatts);         q.API_QuoteInDelega__c=true;
                }
                //delega dilazione di pagamento
                if((u.Profile.Name=='AgentiPartnerCommunity' && q.API_CondizioniDiPagamentoFormula__c>20) || 
                   (u.Profile.Name=='Profilo Area Manager' && u.UserRole.Name.contains('Area Manager') && q.API_CondizioniDiPagamentoFormula__c>30)
                  ||(u.Profile.Name=='Profilo Area Manager' && u.UserRole.Name.contains('CC') && q.API_CondizioniDiPagamentoFormula__c>45)){      listaMessaggi.add(Label.API_DelegaDilazioneDipagamento);      q.API_QuoteInDelega__c=true;
                }
                //delega fatturazione
                if(u.Profile.Name=='AgentiPartnerCommunity' && q.API_Fatturazione__c!='15'){ listaMessaggi.add(Label.API_DelegaFatturazione);       q.API_QuoteInDelega__c=true;
                }
                //delega libretti
                if(u.Profile.Name=='AgentiPartnerCommunity' && q.Libretti_non_presenti__c){   listaMessaggi.add(Label.API_DelegaLibrettiNonPresenti);   q.API_QuoteInDelega__c=true;
                }
                //delega costo affidamento 25 euro
                if(q.API_ValoreCostoAffidamento__c!=25 && u.Profile.Name=='AgentiPartnerCommunity' && q.API_Tipo_fido__c=='IFI'){    listaMessaggi.add(Label.API_DelegaCostoAffidamento);         q.API_QuoteInDelega__c=true;
                }
                //inizio controllo deleghe sconti/bonus con i quoteLineItemX
                List<API_QuoteLineItemX__c> listQLIDaControllare= mapQuoteQLIX.get(q.Id);
                if(listQLIDaControllare!= null){
                    for(API_QuoteLineItemX__c qlxcheck: listQLIDaControllare){
                        listaMessaggi= controlloDeleghe(qlxcheck, q, delegheList, u.Profile.Name, u.UserRole.Name, listaMessaggi);
                    }
                }
                /*File If per controllare le deleghe*/
                //se non ho beccato nessuna if delle deleghe allora e lo stato precedente era "Da scalare" allora metto che è stata approvata perchè ha fatto già un approval è process ma non ha scalato
                if(! q.API_QuoteInDelega__c && q.Stato_Approvazione__c=='Da scalare'){                	q.Stato_Approvazione__c='Approvata';
                }
                else if(! q.API_QuoteInDelega__c){ // se non ho beccato nessuna condizione al primo giro è già corretta la DDa, non deve partire nessun approval process
                    q.Stato_Approvazione__c='Corretta';
                    System.debug('@@@ Niente delega, primo giro '+ u.Name);
                }
                else{
                    //if q.Stato_Approvazione__c=='Da scalare' devo far partire il process builder che non parte -> lancio il platform event che mi fa un finto update della quote
                    if(q.Stato_Approvazione__c=='Da scalare'){
                        String message= '';
                        for(String m: listaMessaggi)
                            message= message+m+'\n';
                        q.API_ElencoMotiviDelega__c= message;
                        System.debug('@@@@@ lancio il Platform event');
                        API_PlatformEventDeleghe__e e= new API_PlatformEventDeleghe__e();
                        e.API_QuoteID__c= q.Id;
                        e.API_UserID__c=u.Id;
                        events.add(e);
                    }
                    else{
                    //else primo giro
                    System.debug('@@@ Vado in delega '+ u.Name);
                    String message= '';
                    for(String m: listaMessaggi)
                        message= message+m+'\n';
                    q.API_ElencoMotiviDelega__c= message;
                   }
                }
            }
        }
            if(events.size()>0){ //se devo lanciare dei platform events lo faccio qua  
                // Call method to publish events
                    List<Database.SaveResult> results = EventBus.publish(events);
                    
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            System.debug('@@@ Successfully published event.');
                        } else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('@@@ Error returned: ' +
                                             err.getStatusCode() +
                                             ' - ' +
                                             err.getMessage());
                            }
                        }       
                    }                
                }
        }
    	
    }
      
    public static void  creaQuoteContrattoQuadro(List<Quote> quotes){
        //mi prendo l'id del record typoe ContrattoQuadro
        //Id recordTypeIdContrattoQuadro = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Contratto_Quadro').getRecordTypeId();
        //Id recordTypeIdQuoteStandard = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard').getRecordTypeId();
        List<String> quoteIds= new List<String>();
        List<Quote> quoteToUpdate= new List<Quote>();
        for(Quote q: quotes){
            quoteIds.add(q.Id);
        }
        System.debug('@@@@@@@ '+quoteIds.size());
        //per ogni quote che sto creando mi prendo l'account
        List<Quote> quoteDaValutare= [Select id, Account.RecordType.DeveloperName, RecordType.DeveloperName, RecordTypeId from Quote 
                                      where id in: quoteIds];
        System.debug(quoteDaValutare);
        for(Quote q: quoteDaValutare){
            //se l'account è di tipo Account fittizzio allora devo settare il record type della Quopte a contratto quadro
            if(q.Account.RecordType.DeveloperName=='API_AccountFittizio' && q.RecordType.DeveloperName!='API_Contratto_Quadro'){	throw new DmlException('Non puoi creare una quote standard su un Account fittizzio. Puoi creare solo contratti quadri!');
            }
            //Se invece il record type non è fittizzio e ho inserito una quote contratto quadro allora ho commesso un errore e la devo rendere una quote normale
            //commento perchè nel flow mi da errore
            /* if(q.Account.RecordType.DeveloperName!='API_AccountFittizio' && q.RecordType.DeveloperName=='API_Contratto_Quadro'){
//q.RecordTypeId=recordTypeIdQuoteStandard;
System.debug('Quote con errore '+q);
throw new DmlException('Non puoi creare un contratto quadro su un cliente reale!!');
}*/
        }
        /*if(quoteToUpdate.size()>0)
update quoteToUpdate;*/
        //TODO sistemare perchè ti esce l'errore con l'indicazione del codice del trigger, dovrebbe uscire solo un messaggio di senso compiuto
    }
    
    
    public static void  ribaltaContrattoQuadroSuQuote(List<Quote> quotes){
        
        //delle quote inserite mi prendo il campo contrattoQuadro
        List<String> contrattiQuadriIds= new List<String>();
        List<Quote> quoteToUpdate= new List<Quote>();
        List<QuoteLineItem> qliDaInserire= new List<QuoteLineItem>();
        List<API_QuoteLineItemX__c> qliXDaInserire= new List<API_QuoteLineItemX__c>();
        List<Quote> quoteConContrattoQuadro= new List<Quote>();
        for(Quote q: quotes){
            if(q.API_Contratto_quadro__c!=null && !q.API_GenerataDaContrattoQuadro__c){
                contrattiQuadriIds.add(q.API_Contratto_quadro__c);
                quoteConContrattoQuadro.add(q);
            }
        }
        System.debug('@@@@@ QuoteCon contratto quadro '+ quoteConContrattoQuadro);
        
        //ho la lista di tutte le quote a cui ho settato un contratto quadro
        //per ognuna di queste quote mi devo ribaltare tutte le informazioni
        //mi prendo i contratti quadri
        List<Quote> contrattiQuadri =[Select Id,API_PrevisionePedaggi__c, API_Tipo_Carta__c, API_PrevisioneConsumi__c, API_Fatturazione__c, API_Dilazione_di_Pagamento_picklist__c, 
                                      API_TipoGaranzia__c, API_Garanzia__c, API_ImportoGaranzia__c,API_CondizioniPagamento__c, Quote.API_Tipo_fido__c, API_MaxNumberCardContrattoQuadro__c,
                                      API_Internazionale__c,API_Plafond_da_richiedere__c, API_Plafond_da_richiedere_ereditato__c, API_Periodo_di_spendibilita_picklist__c, API_Pacchetto__c, API_Offerta__c, API_Contratto_quadro__c, API_ContaProdotti__c 
                                      from Quote where id in:contrattiQuadriIds];
        //TODO aggiungere alla query precedente tutti i campi che saranno aggiunti sulla quote
        System.debug('@@@@@ Contratti quadri trovati '+ contrattiQuadri.size());
        //Mi creo una mappa dei contratti quadri trovati
        Map<String, Quote> contrattiQuadriMap= new Map<String, Quote>();
        for(Quote cq: contrattiQuadri)
            contrattiQuadriMap.put(cq.Id, cq);
        System.debug(contrattiQuadriMap);
        //Ora che ho i contratti quadri mi devo prendere tutti gli eventuali prodotti associati al contratto quadro
        List<QuoteLineItem> quoteLineItems= [Select Id,  PricebookEntryId, Product2Id, Product2.Name, QuoteId  from QuoteLineItem where QuoteId in: contrattiQuadriIds];
        System.debug('@@@@@ QuoteLineItems Associati ai contratti quadri '+ quoteLineItems.size());
        System.debug(quoteLineItems);
        //creo una mapaa ContrattoQuadro->Lista di tutti i quoteLineItem associati
        //e intanto mi faccio una lista di tutti i quoteLineItemsId che ho trovato
        Map<String, List<QuoteLineItem>> quoteConProdottiAssociati = new Map<String, List<QuoteLineItem>>();
        //creo anche una mappa quoteLineItem -> QuoteLineItemX, ovvero prodotto - attributi
        Map<String, List<API_QuoteLineItemX__c>> qliConAttributi = new Map<String, List<API_QuoteLineItemX__c>>();
        List<String> qliIDS = new List<String>();       
        if(quoteLineItems.size()>0){
            for(QuoteLineItem qli: quoteLineItems){
                qliIDS.add(qli.Id);
                System.debug(qli);
                List<QuoteLineItem> qulineitemsList= new  List<QuoteLineItem>();
                if(quoteConProdottiAssociati.get(qli.QuoteId)!= null)
                    qulineitemsList=quoteConProdottiAssociati.get(qli.QuoteId);
                qulineitemsList.add(qli);
                quoteConProdottiAssociati.put(qli.QuoteId, qulineitemsList);
            }
        }
        System.debug(quoteConProdottiAssociati);
        //a questo punto per ogni quotelintem che ho trovato mi devo pescare gli attributi associati, ovvero i quoteLineITemX
        List<API_QuoteLineItemX__c> qliX= [Select Id, API_QuoteLineItem__c, API_NomeProdotto__c, API_NomeAttributo__c, API_Valore__c, API_DeveloperNameMetadata__c  from API_QuoteLineItemX__c 
                                           where API_QuoteLineItem__c in: qliIDS];
        
        System.debug('@@@@@ QuoteLineItemsX Associati ai quoteLineItems dei contratti quadri '+ qliX.size());
        //Metto nella mappa gli eventuali quoteLineItemsX
        if(qliX.size()>0){
            for(API_QuoteLineItemX__c q: qliX){
                List<API_QuoteLineItemX__c> qulineitemsXList= new  List<API_QuoteLineItemX__c>();
                if(qliConAttributi.get(q.API_QuoteLineItem__c)!= null)
                    qulineitemsXList=qliConAttributi.get(q.API_QuoteLineItem__c);
                qulineitemsXList.add(q);
                qliConAttributi.put(q.API_QuoteLineItem__c, qulineitemsXList);
            }
        }
        System.debug(qliX);
        System.debug(qliConAttributi);
        // a questo punto ho tutto quello che mi serve per poter procedere al ribaltamento
        //per ogni quote inserita prendo il relativo contratto quadro e setto i campi di quote
        //(creo una mappa dove mettere i quoteLineItemX che non posso inserire subito perchè mi mancano gli id dei padri -> Creo una mappa Integer- QuoteLineItemX)
        Map<Integer,List<API_QuoteLineItemX__c>> mapQlitXStaging= new Map<Integer,List<API_QuoteLineItemX__c>>();
        
        

        for(Quote q : quoteConContrattoQuadro){
            //Prendo il contratto quadro
            Quote contrattoQuadro= contrattiQuadriMap.get(q.API_Contratto_quadro__c);
            System.debug('@@@Contrattoquadro da ribaltare '+q.API_Contratto_quadro__c);
            //Ribalto tutto
            Quote quoteRibaltata= contrattoQuadro;
            quoteRibaltata.OpportunityId=q.OpportunityId;
            quoteRibaltata.Id= q.Id;
            quoteRibaltata.API_GenerataDaContrattoQuadro__c=true;
            //q.API_GenerataDaContrattoQuadro__c=true;
            //devo controllare se il contratto quadro ha una offerta e un pacchetto settato. Se si devo popolare il relativo flag per evitare modifiche
            if(quoteRibaltata.API_Offerta__c!= null)
                quoteRibaltata.API_OffertaEreditata__c=true;
            if(quoteRibaltata.API_Pacchetto__c!= null)                quoteRibaltata.API_PacchettoEreditato__c=true;   
            if(quoteRibaltata.API_Tipo_Carta__c!= null)                quoteRibaltata.API_TipoCartaEreditato__c=true;   
            if(quoteRibaltata.API_CondizioniPagamento__c!= null)                 quoteRibaltata.API_CondizioniEreditate__c=true;
            if(quoteRibaltata.API_Fatturazione__c!= null)                 quoteRibaltata.API_FatturazioneEreditata__c=true;
            if(quoteRibaltata.API_Periodo_di_spendibilita_picklist__c!= null)                 quoteRibaltata.API_PeriodoSpendibilitaEreditata__c=true;
            if(quoteRibaltata.API_Tipo_fido__c!= null){                quoteRibaltata.API_TipoFidoEreditato__c=true;
                if(quoteRibaltata.API_Tipo_fido__c!='IFI'){                    quoteRibaltata.API_CostoAffidamentoPersonalizzato__c=true;                	quoteRibaltata.API_ValoreCostoAffidamento__c=0;
                }     
               }
            if(quoteRibaltata.API_Plafond_da_richiedere__c!=null) 		quoteRibaltata.API_Plafond_da_richiedere_ereditato__c=true;
            
            
            //Metto la quote modificata nella lista di quote da aggiornare
            quoteToUpdate.add(quoteRibaltata);
            //se il contratto quadro ha anche i quoteLineItem li inserisco
            List<QuoteLineItem> qliDaRibaltare= quoteConProdottiAssociati.get(q.API_Contratto_quadro__c);
            System.debug('KEY '+q.API_Contratto_quadro__c);
            System.debug(qliDaRibaltare);
            Integer i=0;
            if(qliDaRibaltare!= null && qliDaRibaltare.size()>0){
                for(QuoteLineItem qli: qliDaRibaltare){
                    QuoteLineItem qliI= new QuoteLineItem();
                    qliI.QuoteId= q.Id;
                    qliI.PricebookEntryId= qli.PricebookEntryId;
                    qliI.Product2Id= qli.PricebookEntryId;
                    qliI.Quantity=1;
                    qliI.UnitPrice=0;
                    qliI.API_GeneratoDaContrattoQuadro__c=true;
                    qliDaInserire.add(qliI);
                    System.debug('@@@@ Prodotto Inserito'+qliI);
                    //non posso inserire direttamente i quoteLineItemX perchè non ho l'id del quoteLineItem, visto che non l'ho inserito ancora
                    List<API_QuoteLineItemX__c> qliXDaCreare= qliConAttributi.get(qli.Id);
                    System.debug('@@@@@ '+qliXDaCreare);
                    if(qliXDaCreare!= null && qliXDaCreare.size()>0){
                        for(API_QuoteLineItemX__c qxxxx: qliXDaCreare){
                            API_QuoteLineItemX__c qxNew= qxxxx;
                            //se è un attributo di tipo data inizio la setto alla data odierna
                            if(qxNew.API_DeveloperNameMetadata__c.containsIgnoreCase('DataInizio')){
                                String day=System.today().day()+''; if(day.length()==1) day='0'+day;
                                String month=System.today().month()+''; if(month.length()==1) month='0'+month;
                                qxNew.API_Valore__c= System.today().year()+'-'+month+'-'+day;
                            }
                                
                            qxNew.Id= null;
                            List<API_QuoteLineItemX__c> listxxxxx=  new List<API_QuoteLineItemX__c>();
                            if(mapQlitXStaging.get(i)!=null)
                                listxxxxx= mapQlitXStaging.get(i);
                            //lo creo e lo metto nella mappa di staging, in attesa di settagli l'id del quotelineitem giusto
                            listxxxxx.add(qxNew);
                            mapQlitXStaging.put(i,listxxxxx);
                        }
                    } 
                    i++;
                }
            }
            
        }
        /*Skip Trigger sezione per bypassare le validation rules*/
        //Mi devo prendere il profilo perchè il custom setting è legato ad un profilo
        List<API_SkipTriggerCM__c> csList= [SELECT id, Name, Valore__c FROM API_SkipTriggerCM__c];
        for(API_SkipTriggerCM__c cs: csList){            cs.Valore__c= false;
        }
        update csList;
        
        update quoteToUpdate;
        System.debug(qliDaInserire);
        insert qliDaInserire;
        //dopo che l'insert dei quotelinitem è andato a buon fine posso inserire i quoteLineItemX settandogli l'id del giusto padre
        System.debug('@@@@@ staging '+mapQlitXStaging);
        Integer j=0;
        List<API_QuoteLineItemX__c> qlixDaInserireFinalmente= new List<API_QuoteLineItemX__c>();
        for(j=0; j<qliDaInserire.size(); j++){
            List<API_QuoteLineItemX__c> listQLXX= mapQlitXStaging.get(j);
            System.debug('@@@@@ q1lixDaInserire '+mapQlitXStaging.get(j));
            if(listQLXX!= null){
                for(API_QuoteLineItemX__c qlx: listQLXX){
                    qlx.API_QuoteLineItem__c=qliDaInserire[j].Id;
                    qlixDaInserireFinalmente.add(qlx);
                }    
            }
        }
        insert qlixDaInserireFinalmente;    
        
        for(API_SkipTriggerCM__c cs: csList){            cs.Valore__c= true;
        }
        update csList;
        
        
        //mi prendo tutti i quoteLineItem e quoteLineitemX della quote su cui sto mettendo il contratto quadro e li elimino
        List<String> idsQuote= new List<String>();
        for(Quote q: quoteConContrattoQuadro)            idsQuote.add(q.Id);
        List<QuoteLineItem> qlist= [Select id from QuoteLineItem where QuoteId in: idsQuote and API_GeneratoDaContrattoQuadro__c=false and Product2.Name='Commissione IP Matic'];
		List<String> qliIdszz= new List<String>();
        for(QuoteLineItem qz: qlist)            qliIdszz.add(qz.Id);
        List<API_QuoteLineItemX__c>toDeleteqlix  = [Select id, API_QuoteLineItem__c from API_QuoteLineItemX__c where API_QuoteLineItem__c in:qliIdszz];
        delete toDeleteqlix;
        delete qlist;
    }
    
    public static void settaIPPlusOnline(List<Quote> quotes){
        //mi prendo l'id del contratto quadro IPPlusOnline
        List<Quote> cq= [Select Id, RecordType.DeveloperName, name  from Quote where RecordType.DeveloperName='API_Contratto_Quadro' and name='IP PLUS ONLINE'];
        Id IPPlusRecordTypeId = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_IpPlusOnline').getRecordTypeId();
        if(cq.size()>0){
            for (Quote q: quotes){
                System.debug('@@@@@'+q.RecordTypeId);
                if(q.RecordTypeId==IPPlusRecordTypeId){                    q.API_Contratto_quadro__c=cq[0].Id;
                }
            }
        }
    }
    
    /*metodo che controlla i documenti obbligatori*/
    public static void checkDocumentiObbligatori(List<Quote> quotes){
        List<Quote> quoteDaControllare= new List<Quote>();
        //se la quote è di un CapoCanale, CardManager o BO i documenti obbligatori non servono
        //faccio un filtro preventivo per prendermi l'owner della quote e capire chi è
        List<String> quoteDevoQuerareUser= new List<String>();
        for(Quote q: quotes){
            if(!q.API_ControlloDocumentiObbligatori__c ){
                quoteDevoQuerareUser.add(q.OwnerId);
            }
        }
        //faccio la query per prendere le info dell'owner
        List<User> users=[select id, name, Profile.Name, UserRole.DeveloperName from User where id in:quoteDevoQuerareUser];
        Map<String, User> mapUser= new Map<String,User>();
        for(User u: users){
            if(u.Profile.Name=='BackOffice' || (u.Profile.Name=='Profilo Area Manager' && 
                                                (u.UserRole.DeveloperName=='Card_Manager' || 
                                                 u.UserRole.DeveloperName=='CC_Vendite_Indirette' || 
                                                 u.UserRole.DeveloperName=='CC_Vendite_Dirette'))){                                                     mapUser.put(u.Id, u);
                                                     System.debug('sono nell if dell utente '+u.Name);
                                                 } 
            
        }
        for(Quote q: quotes){
            User u= mapUser.get(q.OwnerId);
            if(u!= null)                q.API_ControlloDocumentiObbligatori__c= true;
            //i documenti non sono obbligatori se il tipo carta è != da IP Plus
            else if(q.API_Tipo_Carta__c!=null && q.API_Tipo_Carta__c!='00')  q.API_ControlloDocumentiObbligatori__c= true;
        }
         
        //devo controllare se lo stato è diverso da Bozza -> in tutti gli altri casi i documenti obbligatori ci devono stare (se non ho già messo il falg che ci sono)
        for(Quote q: quotes){
            System.debug(q.Status);
            if(q.Status!='Bozza' && !q.API_ControlloDocumentiObbligatori__c)                quoteDaControllare.add(q);
        }System.debug('*******'+quoteDaControllare.size());
        //per ogni quote che non sta in draft controllo i documenti obbligatori
        //Le regole sull'obbligatorietà sono: se la quote è di Telesales non ci deve essere nessun documento obbligatorio
        //per le quote standard invece tutti gli altri documenti devono essere obbligatori. solo i libretti possono non esserci
        //devo separare le quote standard da quelle di Telesales
        //me le metto in due liste (per ora Telesales non ha documenti obbligatori ma potrebbe avere il Cerved dopo quindi mi trovo già la lista fatta)
        //Il controllo dei documenti parte per le quote con record type Standard completato
        Id standardRecordTypeId = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard_Completata').getRecordTypeId();
        List<Quote> quoteTelesales= new List<Quote>();
        List<Quote> quoteStandard= new List<Quote>();
        for(Quote q: quoteDaControllare){
            if(q.RecordTypeId==standardRecordTypeId && q.API_CreatoDa__c.contains('Telesales'))                quoteTelesales.add(q);
            else if(q.RecordTypeId==standardRecordTypeId)                quoteStandard.add(q);
        }
        //Per tutte le quote Standard in stato completato controllo i documenti obbligatori
        //Mi prendo tutti gli allegati associati alle quote che sto controllando
        if(quoteStandard.size()>0){
            List<String> quoteIds= new List<String>();
            for(Quote q: quoteStandard)
                quoteIds.add(q.Id);
            List<API_Allegato__c> allegati= [Select Id, API_Tipologia__c, API_Quote__c, RecordType.DeveloperName  from API_Allegato__c where API_Quote__c in: quoteIds and RecordType.DeveloperName='API_QuoteAllegato'];
            //creo la solita mappa QuoteId-> Lista allegati
            Map<String, List<API_Allegato__c>> mapAllegati= new Map<String, List<API_Allegato__c>>();
            for(API_Allegato__c allegato: allegati){
                List<API_Allegato__c> all= new List<API_Allegato__c>();
                if(mapAllegati.get(allegato.API_Quote__c)!=null)
                    all= mapAllegati.get(allegato.API_Quote__c);
                all.add(allegato);
                mapAllegati.put(allegato.API_Quote__c, all);
            }
            //a questo punto per ogni quote c'ho tutti gli allegati -> devo solo controllare che ci siano tutti
            for(Quote q: quoteStandard){
                Boolean checkCartaIdentita= false;
                Boolean checkMisuraCamerale= false;
                Boolean checkLibretti= q.Libretti_non_presenti__c;
                if(mapAllegati.get(q.Id)!=null){
                    for(API_Allegato__c a: mapAllegati.get(q.Id)){
                        if(a.API_Tipologia__c==Label.API_DocumentoDiIdentita)
                            checkCartaIdentita=true;
                        else if(a.API_Tipologia__c==Label.API_MisuraCamerale)
                            checkMisuraCamerale=true;
                        else if( a.API_Tipologia__c==Label.API_Libretti)
                            checkLibretti=true;
                    }
                }
                System.debug('checkCartaIdentita '+ checkCartaIdentita);
                System.debug('checkMisuraCamerale '+checkMisuraCamerale);
                System.debug('checkLibretti '+checkLibretti);
                if(checkCartaIdentita && checkMisuraCamerale && checkLibretti)                    q.API_ControlloDocumentiObbligatori__c=true;
                else{                    q.API_ControlloDocumentiObbligatori__c=false;                    q.addError('Non hai inserito tutti i documenti obbligatori. Non puoi completare la domanda di adesione');
                }
            }
        }
        
    }
    
    public static void  checkCambioStato(List<Quote> quoteNew, List<Quote> quoteOld){
        Id recordTypeBozza =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard').getRecordTypeId();
        Id recordTypeCompletata =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard_Completata').getRecordTypeId();
        Id recordTypeCompletataSottoApprovalProcess =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Standard_InAttesaApprovazione').getRecordTypeId();
        Id recordTypeFirma =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard_Firma').getRecordTypeId();
        Id recordTypeCQ =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Contratto_Quadro').getRecordTypeId();
        Id recordTypeVerificaBO = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Standard_VerificaBO').getRecordTypeId();
        
        String userID= UserInfo.getUserId();
        User u= [Select id, Name, Profile.Name, UserRole.Name, ManagerId from User where id=:userID limit 1];
        List<Task> tasks= new  List<Task>();
        
        Map<String, Quote> mapQuoteOld= new Map<String, Quote>();
        for(Quote q: quoteOld)            mapQuoteOld.put(q.id, q);
        
        for(Quote q: quoteNew){
            if(q.RecordTypeId!= recordTypeCQ){
                Quote old= mapQuoteOld.get(q.Id);
                System.debug('stato old '+old.Status);
                System.debug('stato new '+q.Status);
                //BOZZA
                if(q.Status=='Bozza' && q.RecordTypeId!=recordTypeBozza){
                    q.RecordTypeId= recordTypeBozza;
                    //rimetto lo stato di approvazione in Bozza solo se prima non stava in completata così non vado a sovrascrivere l'approval process che scrive rifiutato
                    if(old.Status!='Completata' || (q.Stato_Approvazione__c!='Rifiutata' &&  old.Status=='Completata'))
                    	q.Stato_Approvazione__c='Bozza';
                    q.API_ControlloDocumentiObbligatori__c=false;
                }
                
                //se qualcuno che non è l'owner ha rimesso in bozza devo mandare una notifica a tutta la catena
                if(q.Status=='Bozza' && old.Status!='Bozza' && u.Id!= q.OwnerId){
                    //se l'ha messo in bozza l'AM mando il task solo all'agente
                    if(u.Profile.Name=='Profilo Area Manager' && u.UserRole.Name=='Area Manager Vendite Indirette')        tasks.add(creaTask(u,q,q.OwnerId));                
                    else if (u.Profile.Name=='Profilo Area Manager' && u.UserRole.Name=='CC Vendite Indirette') {tasks.add(creaTask(u,q,q.API_AreamangerID__c)); tasks.add(creaTask(u,q,q.OwnerId));}
                    else  {tasks.add(creaTask(u, q,q.API_AreamangerID__c));tasks.add(creaTask(u,q,q.OwnerId));tasks.add(creaTask(u,q,q.API_CapoCanaleId__c));}
                }
                
                //COMPLETATA //TODO gestire casistica con picklist stato approvazione
                if(q.Status=='Completata' && q.Stato_Approvazione__c!='In attesa' && q.RecordTypeId!=recordTypeCompletata){	 q.RecordTypeId=recordTypeCompletata;
                   }
                if(q.Status=='Completata' && q.Stato_Approvazione__c=='In attesa' && q.RecordTypeId!=recordTypeCompletataSottoApprovalProcess){                    q.RecordTypeId=recordTypeCompletataSottoApprovalProcess;
                }
                if(q.Status=='Completata' && (old.Status!='Bozza' && old.Status!='Completata'))        q.addError('Non puoi portare in stato completata una domanda di adesione che non è più in bozza');
                
                //FIRMA
                if(q.Status=='Firma' && q.RecordTypeId != recordTypeFirma)                    q.RecordTypeId=recordTypeFirma;
                if(q.Status=='Firma' && (old.Status!='Firma' && old.Status!='Completata'))       q.addError('Non puoi mandare in firma una Domanda di adesione non Completata');
                
                //VERIFA BO
                if(q.Status=='Verifica BO'){                    q.RecordTypeId=recordTypeVerificaBO;
                }
                
            }
        }
        //tolgo tutti i null dalla lista dei task e inserisco i task
        List<Task> taskDaInserire = new List<Task>();
            for(Task t: tasks){                if(t!=null) taskDaInserire.add(t);
            }
        if(taskDaInserire.size()>0) insert taskDaInserire;
    }
    
    public static Task creaTask(User u,Quote q, String userID){
        if(userID!='-'){
            Task tsk = new Task();
            tsk.Subject = 'La DDA '+q.Name + ' è stata rimessa in bozza da '+u.Name;
            tsk.Status = 'Open';
            tsk.Priority = 'Normal';
            tsk.WhatId = q.id;
            tsk.OwnerId = userID;
            return tsk;
        }else return null;
    }
    
    public static void  updateQuoteWithPricebook(List<Quote> quoteList){/*
id pricebookId = [select id from Pricebook2 where name = 'Price Book API' limit 1].id;
for(Quote q : quoteList)
q.Pricebook2Id = pricebookId;
*/
    }
    
    public static void  addCommissioneIPMATIC(List<Quote> quotes){
        //La commissione IP MAtic non la devo creare per le quote contratto quadro
        Id recordTypeId =  Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Contratto_Quadro').getRecordTypeId();
        List<Quote> quotesCorrette= new List<Quote>();
            for(Quote q: quotes){
                if(q.RecordTypeId!=recordTypeId) {
                    if(q.API_Contratto_quadro__c==null)
                        quotesCorrette.add(q);
                }
                   
            }
        List<QuoteLineItem> quoteLIList = new List<QuoteLineItem>();
        List<Product2> products= [select id, name from Product2 where name = 'Commissione IP Matic'];
        List<PricebookEntry> pricebookEntryList = [select id, Product2Id from PricebookEntry where Product2.Name = 'Commissione IP Matic' and Pricebook2.Name = 'Price Book API'];
        for(Quote q :quotesCorrette){
            if(products.size()>0){                Product2 product= products[0];                QuoteLineItem quoteLI = new QuoteLineItem();                quoteLI.Product2Id = product.id;
                quoteLI.Quantity = 1;
                quoteLI.QuoteId = q.Id;
                quoteLI.UnitPrice = 0;
                for(PricebookEntry pe : pricebookEntryList){
                    if(pe.Product2Id == product.id)
                        quoteLI.PricebookEntryId = pe.Id;
                }
                quoteLIList.add(quoteLI);
            }
        }
        
        insert quoteLIList;    
        
        List<API_QuoteLineItemX__c> quoteLineItemXList = new List<API_QuoteLineItemX__c>();
        for(QuoteLineItem quoteLI :quoteLIList){ 
            if(quoteLI.quote.API_GenerataDaContrattoQuadro__c != true){
                system.debug('INSERISCO COMMISSIONE IPMATIC ');
                API_QuoteLineItemX__c quoteLIX = new API_QuoteLineItemX__c();
                quoteLIX.API_QuoteLineItem__c = quoteLI.id;
                quoteLIX.API_NomeAttributo__c = 'Valore percentuale';
                quoteLIX.API_DeveloperNameMetadata__c = 'API_CommissioneValore';
                quoteLIX.API_Valore__c = '2';
                quoteLIX.API_NomeProdotto__c = 'Commissione IP Matic'; 
                quoteLineItemXList.add(quoteLIX);
                
                API_QuoteLineItemX__c quoteLIX2 = new API_QuoteLineItemX__c();
                quoteLIX2.API_QuoteLineItem__c = quoteLI.id;
                quoteLIX2.API_NomeAttributo__c = 'Famiglia Prodotti';
                quoteLIX2.API_DeveloperNameMetadata__c = 'API_CommissioneProdotti';
                quoteLIX2.API_Valore__c = '02	Benzine (non SELF); 03	Gasoli (non SELF); 06	Metano; 04	GPL; AA	Benzine e Gasoli SELF';
                quoteLIX2.API_NomeProdotto__c = 'Commissione IP Matic'; 
                quoteLineItemXList.add(quoteLIX2);
                
                /*API_QuoteLineItemX__c quoteLIX3 = new API_QuoteLineItemX__c();
quoteLIX3.API_QuoteLineItem__c = quoteLI.id;
quoteLIX3.API_NomeAttributo__c = 'Rete';
quoteLIX3.API_DeveloperNameMetadata__c = 'API_Commissione_Rete';
quoteLIX3.API_Valore__c = '	IP MATIC';
quoteLIX3.API_NomeProdotto__c = 'Commissione IP Matic'; 
quoteLineItemXList.add(quoteLIX3);*/
                
                API_QuoteLineItemX__c quoteLIX4 = new API_QuoteLineItemX__c();
                quoteLIX4.API_QuoteLineItem__c = quoteLI.id;
                quoteLIX4.API_NomeAttributo__c = 'Data inizio validità';
                quoteLIX4.API_DeveloperNameMetadata__c = 'API_CommissioneDataInizio';
                String valore = String.valueOf(System.today());
                system.debug('VALORE: ' +valore);
                quoteLIX4.API_Valore__c = valore;
                quoteLIX4.API_NomeProdotto__c = 'Commissione IP Matic';
                System.debug('quoteLIX4: '+quoteLIX4); 
                quoteLineItemXList.add(quoteLIX4);
                
                API_QuoteLineItemX__c quoteLIX5 = new API_QuoteLineItemX__c();
                quoteLIX5.API_QuoteLineItem__c = quoteLI.id;
                quoteLIX5.API_NomeAttributo__c = 'Data fine validità';
                quoteLIX5.API_DeveloperNameMetadata__c = 'API_CommissioneDataFine';
                quoteLIX5.API_Valore__c = '2199-12-31';
                quoteLIX5.API_NomeProdotto__c = 'Commissione IP Matic'; 
                quoteLineItemXList.add(quoteLIX5);  
            }
        }
        system.debug('QuoteLineItemX LIST: '+quoteLineItemXList);
        insert quoteLineItemXList;
    } 
    
    /*metodo che passa la quote in stato "Verifica BO"*/
    public static void passaggioStatoVerificaBO(List<Quote> quotes){
        
        List<Quote> quoteList = new List<Quote>();
        for(Quote q : quotes){
            if(q.Status == 'Firma' && q.API_DomandaAdesioneFirmata__c == true){                Quote quote = new Quote();                quote.id = q.id;                quote.Status = 'Verifica BO';                quoteList.add(quote);
            }
        }
        update quoteList;
    }
    
    /*metodo che passa la quote in stato "Inserita SAP"*/
    public static void cambioStatoInseritaSap(List<Quote> quotes){
        
        recordType rt = [select id from RecordType where DeveloperName ='API_Standard_Finale'];
        set<String> idSet = new set<String>();
        for(quote q : quotes){
            idSet.add(q.id);
        }
        List<quote> quoteListAccount =[SELECT id, Opportunity.Account.API_CodiceCliente__c, status from quote where id =: idSet];
        List<Quote> quoteList = new List<Quote>();
        for(Quote q : quoteListAccount){
            if(q.Status == 'Verifica BO' && q.Opportunity.Account.API_CodiceCliente__c != null){
                Quote quote = new Quote();
                quote.id = q.id;
                quote.Status = 'Inserita SAP';
                quote.RecordTypeId = rt.id;
                quoteList.add(quote);
            }
        }
        update quoteList;
    }
    
    public static void controlloCF(List<Quote> quoteNew){
        List<string> CFList = new List<String>();
        Integer i, s;
        String validi,set1, set2, setpari, setdisp;
        //String cf = c.Fiscalcode__C;
        
        /*for(Account acc : Trigger.New){
CFList.add(acc.API_CodiceFiscale__c.toUpperCase());
}*/
        
        for(Quote q : quoteNew){
            if(q.API_CodiceFiscaleFirmatarioSepa__c != null){
                String cf = q.API_CodiceFiscaleFirmatarioSepa__c.toUpperCase();
                //cf = c.Fiscalcode__C.toUpperCase();
                /*if (cf.length() != 16){
return 'La lunghezza del codice fiscale non è corretta: il codice fiscale dovrebbe essere lungo esattamente 16 caratteri.';
}*/
                validi = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                /*for (i = 0; i < 16; i++) {
if (validi.indexOf(cf.substring(i,i+1)) == -1){
return 'Il codice fiscale contiene un carattere non valido' + cf.charAt(i) + '.I caratteri validi sono le lettere e le cifre.';
}
}*/
                set1 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                set2 = 'ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ';
                setpari = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                setdisp = 'BAKPLCQDREVOSFTGUHMINJWZYX';
                s = 0;
                
                for (i = 1; i <= 13; i += 2)
                    s += setpari.indexOf(set2.substring(set1.indexOf(cf.substring(i,i+1)),set1.indexOf(cf.substring(i,i+1))+1));
                for (i = 0; i <= 14; i += 2)
                    s += setdisp.indexOf(set2.substring(set1.indexOf(cf.substring(i,i+1)),set1.indexOf(cf.substring(i,i+1))+1));
                
                system.debug('@@ Controllo codice fiscale completato');
                
                if (math.mod(s,26) != cf.charAt(15) - 'A'.charAt(0)){                    q.addError('CODICE FISCALE NON CORRETTO');
                }
            }
        }
    }
    
    
    /*Metodo di utility per il controllo delle deleghe*/
    public static List<String> controlloDeleghe(API_QuoteLineItemX__c qlix, Quote quote, List<API_DeleghePacchetto__mdt> delegheList, String profile, String roleName, List<String> listaMessaggi){
        Boolean scontoPacchetto;
        Boolean scontoPedaggio;
        Boolean delegaCommissioneValore = false;
        Boolean delegaCommissioneRete = false;
        Boolean delegaCommissione; 
        decimal ScontoBaseDelegheValore;
        String TipoBonus;
        Boolean ScontoBaseDelegheProdotto = false;
        Boolean ScontoBaseDeleghe;
        Boolean bonusDeleghe;
        Boolean BonusGaranzia;
        Boolean ScontoSiteReteDeleghe;
        
        /*Se il nome prodotto è Sconto Pacchetto devo controllare il valore che viene inserito perchè, se superiore ad una certa soglia (dipende dal profilo o ruolo dell'utente connesso),
la pratica va in delega*/
        if(qlix.API_NomeProdotto__c == 'Sconto Pacchetto'){
            system.debug('@@@sconto pacchetto');
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                /*Se il nome del profilo è uguale al nome presente nel campo API_Profilo__c del custom metadata o il campo contiene il ruolo (usato per i Capo Canale CC_) e
il valore che l'utente inserisce è maggiore di quello consentito (presente nel campo API_ValoreSconto__c del custom metadata)
e la delega si chiama "Pacchetti" (quest'ultimo controllo è usato per distinguere le diverse regole di deleghe presenti all'interno dello stesso custom metadata)
allora viene impostata una variabile booleana su quote a true. Serve per far partire l'approval process*/
                if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoPacchettoValoreSconto'){
                    if( (deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c)) && 
                       integer.valueof(qlix.API_Valore__c ) > deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Pacchetti' &&
                       deleghe.API_PacchettoScelto__c == quote.API_Pacchetto__c){
                           //scontoPacchetto = true;
                            listaMessaggi.add(Label.API_DelegaScontoPacchetto);
                    		quote.API_QuoteInDelega__c=true;
                       }
                }
            }
        }
        
        //Nel caso in cui il prodotto selezionato è "Pedaggio" e l'attributo non è "Tipo" (quindi è valore) allora effettuo gli stessi controlli dell'if precedente
        if(qlix.API_NomeProdotto__c == 'Pedaggi' && qlix.API_DeveloperNameMetadata__c == 'API_PedaggioCommissionePercentuale'){
            system.debug('@@@pedaggio');
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if( (deleghe.API_Profilo__c ==profile || roleName.contains(deleghe.API_Profilo__c)) && decimal.valueof(qlix.API_Valore__c ) < deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Pedaggi'){                  listaMessaggi.add(Label.API_DelgaPedaggio);                    quote.API_QuoteInDelega__c=true;
                }
            }
        }
        
        //Nel caso in cui il prodotto scelto è commissione e l'attributo scelto è valore, effettuo una serie di controlli simili al primo if e setto un booleano 
        if(qlix.API_NomeProdotto__c == 'Commissione IP Matic' && qlix.API_DeveloperNameMetadata__c == 'API_CommissioneValore'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if( (deleghe.API_Profilo__c == profile || 
                   roleName.contains(deleghe.API_Profilo__c)) && 
                    decimal.valueof(qlix.API_Valore__c ) < deleghe.API_ValoreSconto__c && 
                    deleghe.API_NomeDelega__c == 'Commissione'){                     listaMessaggi.add(Label.API_DelegaCommissioneIPMatic);                   	 quote.API_QuoteInDelega__c=true;
                   }
            }
        }
        
        //@@@@ SCONTO BASE
        if(qlix.API_NomeProdotto__c == 'Sconto base'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_ValoreSconto'){           ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c);
                    }
                }
            }
        }else if(qlix.API_NomeProdotto__c == 'Bonus'){
            if(qlix.API_DeveloperNameMetadata__c == 'Api_BonusTipo'){                  TipoBonus = qlix.API_Valore__c;
            }
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_BonusValore'){                 ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c);
                    }
                }
            }
        }else if(qlix.API_NomeProdotto__c == 'Bonus garanzia'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoGaranziaValoreSconto'){ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c); }
                }
            }
        }else if(qlix.API_NomeProdotto__c == 'Sconto Site/Rete'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteValoreSconto'){ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c); }
                }
            }
        }
        
        if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_Prodotti' && qlix.API_NomeProdotto__c == 'Sconto base'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    if(qlix.API_Valore__c.contains('04')){
                        //BOOLEANO GPL = TRUE;
                        if(deleghe.API_Profilo__c == profile|| roleName.contains(deleghe.API_Profilo__c)){
                            if(quote.API_Offerta__c =='Prezzo Listino' &&  deleghe.DeveloperName.contains('GPL') && deleghe.API_Offerta__c.contains('PL')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                    listaMessaggi.add(Label.API_DelegaScontoBaseGPL); quote.API_QuoteInDelega__c=true;
                                }
                            }else if(quote.API_Offerta__c =='Miglior Prezzo' &&  deleghe.DeveloperName.contains('GPL') && deleghe.API_Offerta__c.contains('PM')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                    listaMessaggi.add(Label.API_DelegaScontoBaseGPL); quote.API_QuoteInDelega__c=true;
                                }
                            }else if(quote.API_Offerta__c =='Prezzo Pompa' &&  deleghe.DeveloperName.contains('GPL') && deleghe.API_Offerta__c.contains('PP')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                    listaMessaggi.add(Label.API_DelegaScontoBaseGPL); quote.API_QuoteInDelega__c=true;
                                }
                            }
                        }
                    }else if(! qlix.API_Valore__c.contains('04')){
                        //BOOLEANO GPL = FALSE;
                        //FARE FILTRO CON I LITRI
                        if(deleghe.API_Profilo__c == profile){
                            double prevConsumi = quote.API_PrevisioneConsumi__c *12;
                            if((quote.API_Offerta__c =='Prezzo Listino' || quote.API_Offerta__c == 'Miglior Prezzo')){
                                if(prevConsumi > 0 && prevConsumi <= 30000 && 
                                   deleghe.DeveloperName.contains('SSP1') && (!deleghe.DeveloperName.contains('GPL'))){
                                       if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                           listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                       }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                           listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                       }
                                   }else if(prevConsumi > 30001 && prevConsumi <= 80000 && 
                                            deleghe.DeveloperName.contains('SSP2') && (!deleghe.DeveloperName.contains('GPL'))){
                                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                                    listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                                }   
                                            }else if(prevConsumi >= 80001 && deleghe.DeveloperName.contains('SSP3') && (!deleghe.DeveloperName.contains('GPL'))){
                                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;}
                                                                                     
                                           }
                            }
                        }else if(roleName.contains(deleghe.API_Profilo__c)){
                            system.debug('OFFERTA QUOTE: '+quote.API_Offerta__c);
                            system.debug('deleghe '+deleghe);
                            if(quote.API_Offerta__c =='Prezzo Listino' && (!deleghe.DeveloperName.contains('GPL')) && deleghe.API_Offerta__c.contains('PL')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                   listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                }
                            }else if(quote.API_Offerta__c =='Miglior Prezzo' &&  (!deleghe.DeveloperName.contains('GPL')) && deleghe.API_Offerta__c.contains('PM')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                }
                            }else if(quote.API_Offerta__c =='Prezzo Pompa' &&  (!deleghe.DeveloperName.contains('GPL'))){
                                if(!qlix.API_Valore__c.contains('AA') && deleghe.API_Offerta__c.contains('PP_SERVITO')){
                                    if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                        listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                    }
                                }else if(qlix.API_Valore__c.contains('AA') && deleghe.API_Offerta__c.contains('PP_SELF')){
                                    if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                        listaMessaggi.add(Label.API_DelegaScontoBase); quote.API_QuoteInDelega__c=true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }else if(qlix.API_DeveloperNameMetadata__c == 'API_BonusProdotti' && qlix.API_NomeProdotto__c == 'Bonus'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    if(qlix.API_Valore__c.contains('04')){
                        //BOOLEANO GPL = TRUE;
                        system.debug('BONUS CON GPL');
                        if((deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c)) 
                           && deleghe.API_PacchettoScelto__c == 'Bonus' && deleghe.DeveloperName.contains('GPL')){
                               if(deleghe.API_Profilo__c == profile && quote.API_TipoBonus__c == 'Temporale'){       listaMessaggi.add(Label.API_DelegheBonusGPL); quote.API_QuoteInDelega__c=true; 
                               }else if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c ){       listaMessaggi.add(Label.API_DelegheBonusGPL); quote.API_QuoteInDelega__c=true;
                               }
                           }
                    }else if(! qlix.API_Valore__c.contains('04')){
                        system.debug('BONUS SENZA GPL');
                        system.debug('VALORE DELEGA: '+deleghe.API_ValoreSconto__c);
                        system.debug('PACCHETTO SCELTO: '+deleghe.API_PacchettoScelto__c);
                        system.debug('DELEGHE SCELTO: '+deleghe.DeveloperName);
                        if(deleghe.API_Profilo__c == profile 
                           && deleghe.API_PacchettoScelto__c == 'Bonus' && (!deleghe.DeveloperName.contains('GPL'))){
                               if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c || quote.API_TipoBonus__c == 'Temporale'){
                                    double prevConsumi = quote.API_PrevisioneConsumi__c *12;
                                    if(prevConsumi > 0 && prevConsumi <= 30000 && deleghe.DeveloperName.contains('SSP4')){
                                        listaMessaggi.add(Label.API_DelegheBonus); quote.API_QuoteInDelega__c=true;
                                    }
                                    if(prevConsumi > 30000 && prevConsumi <= 80000 && deleghe.DeveloperName.contains('SSP5')){                                        listaMessaggi.add(Label.API_DelegheBonus); quote.API_QuoteInDelega__c=true;
                                    }
                                    if(prevConsumi > 80000 && deleghe.DeveloperName.contains('SSP6')){                                        listaMessaggi.add(Label.API_DelegheBonus); quote.API_QuoteInDelega__c=true;
                                    }
                               }
                        }else if( roleName.contains(deleghe.API_Profilo__c)
                           && deleghe.API_PacchettoScelto__c == 'Bonus' && (!deleghe.DeveloperName.contains('GPL'))){
                               if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c ){
                                  listaMessaggi.add(Label.API_DelegheBonus); quote.API_QuoteInDelega__c=true;
                               }
                           }
                    }
                }
            }
        }else if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoGaranziaValoreSconto' && qlix.API_NomeProdotto__c == 'Bonus garanzia'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    system.debug('BONUS GARANZIA');
                    if((deleghe.API_Profilo__c == profile || roleName.contains(deleghe.API_Profilo__c) )
                       && deleghe.API_PacchettoScelto__c == 'Bonus garanzia'){
                           if(decimal.valueof(qlix.API_Valore__c ) > deleghe.API_ValoreSconto__c){
                               listaMessaggi.add(Label.API_DelegaGaranzia); quote.API_QuoteInDelega__c=true;
                               system.debug('SONO NEL TRUE E IL VALORE NUOVO e: ' +quote.API_ScontoBaseDelegheValoreNEW__c);
                               system.debug('VALORE DI DELEGA: ' +deleghe.API_ValoreSconto__c);
                               system.debug('BONUS GARANZIA: '+BonusGaranzia);
                           }
                       }
                }
            }
        }else if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_sito_rete_Prodotti' && qlix.API_NomeProdotto__c == 'Sconto Site/Rete'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    if(deleghe.API_Profilo__c == profile && deleghe.API_PacchettoScelto__c == 'Sconto site' && qlix.API_Valore__c.contains('04')){
                        if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                            listaMessaggi.add(Label.API_DelegaScontosite); quote.API_QuoteInDelega__c=true;
                        }
                    }else if(deleghe.API_Profilo__c == profile && deleghe.API_PacchettoScelto__c == 'Sconto site' && (!qlix.API_Valore__c.contains('04'))){
                                 listaMessaggi.add(Label.API_DelegaScontosite); quote.API_QuoteInDelega__c=true;
                             }else if(roleName.contains(deleghe.API_Profilo__c) && deleghe.API_PacchettoScelto__c == 'Sconto site'){
                                 if( deleghe.API_PacchettoScelto__c == 'Sconto site' && deleghe.DeveloperName.contains('GPL') && qlix.API_Valore__c.contains('04')){
                                     if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                         listaMessaggi.add(Label.API_DelegaScontosite); quote.API_QuoteInDelega__c=true;
                                     }
                                 }else if( deleghe.API_PacchettoScelto__c == 'Sconto site' && (!deleghe.DeveloperName.contains('GPL')) && (!qlix.API_Valore__c.contains('04'))){
                                     if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                         listaMessaggi.add(Label.API_DelegaScontosite); quote.API_QuoteInDelega__c=true;
                                     }
                                 }
                             }
                }
            }
        }
        
        
        system.debug('Sconto base deleghe: ' +ScontoBaseDeleghe);
        if(ScontoBaseDelegheValore == null){
            system.debug('SCONTO BASE DELEGHE E NULL');
            ScontoBaseDelegheValore = quote.API_ScontoBaseDelegheValoreNEW__c;
            system.debug('quote.API_ScontoBaseDeleghe__c: ' +quote.API_ScontoBaseDelegheValoreNEW__c);
            system.debug('ScontoBaseDeleghe : ' +ScontoBaseDelegheValore);
        }
        
        
        //SE I NUOVI VALORI SONO NULL VUOL DIRE CHE NON HO CAMBIATO LE CONDIZIONI DI DELEGA, QUINDI RESTANO QUELLI GIA' PRESENTI
        if(scontoPacchetto == null){
            scontoPacchetto = quote.API_ScontoPacchetto__c;
        }
        if(scontoPedaggio == null){
            scontoPedaggio = quote.API_CommissionePedaggio__c;
        }
        if(delegaCommissione == null){
            delegaCommissione = quote.API_DelegaCommissione__c;
        }
        if(ScontoBaseDeleghe == null){
            system.debug('SCONTO BASE DELEGHE E NULL');
            ScontoBaseDeleghe = quote.API_ScontoBaseDeleghe__c;
            system.debug('quote.API_ScontoBaseDeleghe__c: ' +quote.API_ScontoBaseDeleghe__c);
            system.debug('ScontoBaseDeleghe : ' +ScontoBaseDeleghe);
        }
        if(bonusDeleghe == null){
            system.debug('SCONTO BASE DELEGHE E NULL');
            bonusDeleghe = quote.API_BonusDeleghe__c;
            system.debug('quote.API_ScontoBaseDeleghe__c: ' +quote.API_BonusDeleghe__c);
            system.debug('ScontoBaseDeleghe : ' +bonusDeleghe);
        }
        if(BonusGaranzia == null){
            system.debug('SCONTO BASE DELEGHE E NULL');
            BonusGaranzia = quote.API_BonusGaranzia__c;
            system.debug('quote.API_ScontoBaseDeleghe__c: ' +quote.API_BonusGaranzia__c);
            system.debug('ScontoBaseDeleghe : ' +BonusGaranzia);
        }
        if(ScontoSiteReteDeleghe == null){
            system.debug('SCONTO BASE DELEGHE E NULL');
            ScontoSiteReteDeleghe = quote.API_ScontoSiteReteDeleghe__c;
            system.debug('quote.API_ScontoBaseDeleghe__c: ' +quote.API_ScontoSiteReteDeleghe__c);
            system.debug('ScontoBaseDeleghe : ' +ScontoSiteReteDeleghe);
        }
        if(TipoBonus == null){
            TipoBonus = quote.API_TipoBonus__c;
        }
        
        system.debug('SCONTO BASE DELEGHE FINALE: ' +ScontoBaseDeleghe);
        

        quote.API_ScontoBaseDelegheValoreNEW__c = ScontoBaseDelegheValore;
        quote.API_TipoBonus__c = TipoBonus;
        
        Set<String> setString = new Set<String>(listaMessaggi);
        listaMessaggi= new List<String>(setString);
        return listaMessaggi;
    }

    /*Metodo utilizzato per incrementare il numero di versione*/
    public static void numeroVersione(List<Quote> quoteList){
        for(Quote quote : quoteList){
            if(quote.status == 'Bozza'){
                if(quote.API_NumeroVersione__c == null)                    quote.API_NumeroVersione__c = 0;
                else
                    quote.API_NumeroVersione__c++;
            }
        }
    }

    public static void ribaltaFido(List<Quote> quoteList){
        Set<ID> quoteID = new Set<ID>();
        for(Quote quote : quoteList){
            quoteID.add(quote.Id);
        }
        List<Quote> qList = [select id, status, API_Plafond_Calcolato__c, Opportunity.AccountId, Opportunity.Account.API_Importo_richiesto__c 
                                    from quote where id =: quoteID];

        List<Account> accountUpdate = new List<Account>();
        for(Quote quote : qList){
            if(quote.status == 'Firma'){
                System.debug('Sono nell if');
                Account acc = new Account();
                acc.id = quote.Opportunity.AccountId;
                acc.API_Importo_richiesto__c = quote.API_Plafond_Calcolato__c;
                accountUpdate.add(acc);
            }
        }
        system.debug('Account update: '+accountUpdate);
        if(!accountUpdate.isEmpty())            update accountUpdate;
    }

    public static void ribaltaCampiSuAccount(List<Quote> quoteList){
        Set<Id> quoteID = new Set<Id>();
        for(Quote quote : quoteList){
            quoteID.add(quote.Id);
        }
        List<Quote> qList = [select Opportunity.AccountId,opportunity.Account.API_CodiceCliente__c, API_Data_Fine_Garanzia__c,API_Data_Inizio_Garanzia__c, 
                            API_DataSottoscrizioneContratto__c, API_CodiceFiscaleFirmatarioSepa__c, API_Fatturazione__c, status, API_Plafond_Calcolato__c, 
                            API_ImportoGaranzia__c, API_NomeSottoscrittore__c, API_TipoGaranzia__c, API_Tipo_fido__c from quote where id in: quoteID];
        List<Account> accToUpdate = new List<Account>();
        for(Quote quote : qList){
            if(quote.status == 'Firma' && quote.opportunity.Account.API_CodiceCliente__c != ''){
                account acc = new account();
                acc.id = quote.Opportunity.AccountId;
                acc.Data_fine_garanzia__c = quote.API_Data_Fine_Garanzia__c;
                acc.Data_inizio_garanzia__c = quote.API_Data_Inizio_Garanzia__c;
                acc.API_DataSottoscrizioneContratto__c = quote.API_DataSottoscrizioneContratto__c;
                acc.API_CodiceFiscaleFirmatarioSepa__c = quote.API_CodiceFiscaleFirmatarioSepa__c;
                acc.API_Fatturazione__c = quote.API_Fatturazione__c;
                acc.API_Importo_richiesto__c = quote.API_Plafond_Calcolato__c;
                acc.Importo_garanzia__c = quote.API_ImportoGaranzia__c;
                acc.API_NomeSottoscrittore__c = quote.API_NomeSottoscrittore__c;
                acc.Tipo_garanzia__c = quote.API_TipoGaranzia__c;
                acc.API_Tipo_fido__c = quote.API_Tipo_fido__c;

                accToUpdate.add(acc);
            }
        }
        update accToUpdate;
    }

    public static void platts (List<Quote> quoteList){
        for(Quote q : quoteList){
            if(q.API_Listino__c == 'L2 PLATTS')                q.API_Platts__c = true;
            else                                               q.API_Platts__c = false;
        }
    }
}