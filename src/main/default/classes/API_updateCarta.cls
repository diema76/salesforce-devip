public class API_updateCarta {

    
    // quando inserisco una carta devo valorizzare i campi dell'indirizzo se non sono inseriti in modo specifico per a carta
    //public static void  updateIndirizzi(List<API_Carta__c> carte){
        /*//mi prendo tutti gli id delle carte
        List<String> idCarteInserite= new List<String>();
        for(API_Carta__c c : carte)
            idCarteInserite.add(c.Id);
        //faccio una query di tutti i campi che mi servono per settare gli indirizzi
        List<API_Carta__c> carteConIndirizzi =[select id, API_Cap__c, API_Citta__c, API_Nazione__c, API_Provincia__c, API_Via__c, API_Parco__c, API_Parco__r.API_Cap__c, 
                                   API_Parco__r.API_Citta__c, API_Parco__r.API_Codice__c,  API_Parco__r.API_Nazione__c, API_Parco__r.API_Provincia__c, 
                                   API_Parco__r.API_Via__c, API_Quote__r.Account.BillingStreet, API_Quote__r.Account.BillingCity, API_Quote__r.Account.BillingCountry, 
                                   API_Quote__r.Account.BillingPostalCode,  API_Quote__r.Account.BillingState, API_Quote__r.Account.ShippingCity, 
                                   API_Quote__r.Account.ShippingCountry, API_Quote__r.Account.ShippingPostalCode, 
                                   API_Quote__r.Account.ShippingState, API_Quote__r.Account.ShippingStreet, API_Quote__r.Account.API_SedeOperativa__c 
                                   from API_Carta__c where Id in:idCarteInserite];
        System.debug(carteConIndirizzi);
        //Per ogni carta nella lista setto eventualmente l'indirizzo della carta
        for(API_Carta__c c: carteConIndirizzi){
            // valuto solo il campo città perchè tanto c'è la validatin rule che mi obbliga a valorizzare tutti i campi dell'indirizzo
            if(c.API_Citta__c ==null){
                //se non ho valorizzato l'indirizzo devo controllare:
                //1) c'ho un parco
                if(c.API_Parco__c!= null){
                    //setto l'indirizzo della carta uguale a quello del parco
                    c.API_Cap__c=c.API_Parco__r.API_Cap__c;
                    c.API_Citta__c=c.API_Parco__r.API_Citta__c;
                    c.API_Via__c= c.API_Parco__r.API_Via__c;
                    c.API_Nazione__c=c.API_Parco__r.API_Nazione__c;
                    c.API_Provincia__c=c.API_Parco__r.API_Provincia__c;
                }
                //2) c'ha uno indirizzo di sede operativa
                else if(c.API_Quote__r.Account.API_SedeOperativa__c){
                    //setto l'indirizzo della carta uguale a quello della ede operativa ShippingAddress
                    c.API_Cap__c=c.API_Quote__r.Account.ShippingPostalCode;
                    c.API_Citta__c=c.API_Quote__r.Account.ShippingCity;
                    c.API_Via__c= c.API_Quote__r.Account.ShippingStreet;
                    c.API_Nazione__c=c.API_Quote__r.Account.ShippingState;
                    c.API_Provincia__c=c.API_Quote__r.Account.ShippingCountry;
                }
                //3) metto l'indirizzo di fatturazione
                else{
                    c.API_Cap__c=c.API_Quote__r.Account.BillingPostalCode;
                    c.API_Citta__c=c.API_Quote__r.Account.BillingCity;
                    c.API_Via__c= c.API_Quote__r.Account.BillingStreet;
                    c.API_Nazione__c=c.API_Quote__r.Account.BillingState;
                    c.API_Provincia__c=c.API_Quote__r.Account.BillingCountry;
                }       
            }
        }
        update carteConIndirizzi;*/
    //}
    
    /*Metodo utilizzato per far si che una carta abbia sempre un contoCarta*/
     public static void  checkContoCarta(List<API_Carta__c> carte){
         List<String> contiCarte= new List<String>();
         List<String> quoteIds= new List<String>();
         for(API_Carta__c c: carte){
             //mi prendo l'id della quote
             quoteIds.add(c.API_Quote__c);
             //mi prendo tutti i conti carta che sono stati associati alle carte
             if(c.API_ContoCarte__c!=null)
             contiCarte.add(c.API_ContoCarte__c);
         }
         system.debug('QUOTEIDS: '+quoteIds);
         system.debug('contiCarte: '+contiCarte);
         //di ogni contocarta che ho messo sulle carte mi faccio una query e lo metto nella mappa
    	List<API_ContoCarte__c> ccList= [Select Id, name, API_TipoPIN__c, API_DescrizioneGruppoCarte__c from API_ContoCarte__c where id=:contiCarte];
        system.debug('ccList: '+ccList);
        Map<String,API_ContoCarte__c> mapContiCarta= new  Map<String,API_ContoCarte__c>();
        for(API_ContoCarte__c cc: ccList)
            mapContiCarta.put(cc.Id, cc);
        system.debug('mapContiCarta: '+mapContiCarta);

         //di ogni quote su cui sto mettendo la carta mi faccio una query per prendermi i conti carta
         List<API_ContoCarte__c> listaCCxQuote= [Select Id, API_Quote__c, API_TipoPIN__c from API_ContoCarte__c where API_Quote__c in: quoteIds];
         system.debug('listaCCxQuote: '+listaCCxQuote);
         //mi devo creare la mappa
         Map<String,List<API_ContoCarte__c>> mapCCxQuote= new Map<String,List<API_ContoCarte__c>>();
         for(API_ContoCarte__c cc: listaCCxQuote){
             String idQuote= cc.API_Quote__c;
             List<API_ContoCarte__c> listCCQuote= mapCCxQuote.get(idQuote);
             if(listCCQuote == null){
                 listCCQuote= new List<API_ContoCarte__c>();
             }
             listCCQuote.add(cc);
             mapCCxQuote.put(cc.API_Quote__c,listCCQuote);
         }
         system.debug('mapCCxQuote: '+mapCCxQuote);
		
        //mappa in cui metto tutte le carte per cui devo settare la lookup dopo il for, raggruppate per ID
        Map<String, List<API_Carta__c>> mapCarteLookup= new Map<String, List<API_Carta__c>>();
        //mappa in cui metto i cc PIN autista da creareper poi farci la lookup su carta
        Map<String, API_ContoCarte__c> mapCCStandardDaCreare= new Map<String, API_ContoCarte__c>();
        //mappa in cui metto i cc PIN standard da creareper poi farci la lookup su carta
        Map<String, API_ContoCarte__c> mapCCAutistaDaCreare= new Map<String, API_ContoCarte__c>(); 
        
        //a questo punto controllo per ogni carta le varie casistiche possibili:
        for(API_Carta__c c: carte){
            //1) ho messo un conto carta sulla carta -> controllo che il tipo PIN sia uguale
            if(c.API_ContoCarte__c!=null){
                API_ContoCarte__c currentCC= mapContiCarta.get(c.API_ContoCarte__c);
                if(currentCC!= null && currentCC.API_TipoPIN__c==c.API_TipoPin__c)
                    System.debug('Il tipo PIN del CC e quello della carta corrispondono');
                else //se è diverso errore
                    c.addError('Il Tipo PIN della carta non corrisponde al tipo PIN del conto carta selezionato. Impossibile inserire la carta');
            }
            //2)se non ho messo il conto carta posso devo cercare se ci sono già conti carta con quel tipo di PIN
            else{
                //mi prendo i conti carta associati a quella quote
                List<API_ContoCarte__c> contiCarteG= mapCCxQuote.get(c.API_Quote__c);
                system.debug('contiCarteG: '+contiCarteG);
                if(contiCarteG==null){//2.1 non ho trovato nessun conto carta -> lo creo (la creo fuori dal for)
                    List<API_Carta__c> carteMAP= mapCarteLookup.get(c.API_Quote__c);
                    if(carteMAP==null)
                        carteMAP= new List<API_Carta__c>();
                    carteMAP.add(c);
                    mapCarteLookup.put(c.API_Quote__c, carteMAP);
                    system.debug('mapCarteLookup: '+mapCarteLookup);
                    if(c.API_TipoPin__c.contains('1')){
                        API_ContoCarte__c standard= creaContoCartaPINStandard(c.API_Quote__c);
                        mapCCStandardDaCreare.put(c.API_Quote__c, standard);
                    }else{
                        API_ContoCarte__c autista= creaContoCartaPINAutista(c.API_Quote__c);
                        mapCCAutistaDaCreare.put(c.API_Quote__c, autista);       
                    }

                    system.debug('mapCCStandardDaCreare: '+mapCCStandardDaCreare);
                    system.debug('mapCCAutistaDaCreare: '+mapCCAutistaDaCreare);
                }else if(!contiCarteG.isEmpty()){
                    System.debug('CONTO CARTA GIA PRESENTE!!!');
                    //mi creo due liste: una per i pin standard e uno per i pin autista
                    List<API_ContoCarte__c> ccPINStandard= new List<API_ContoCarte__c>();
                    List<API_ContoCarte__c> ccPINAutista= new List<API_ContoCarte__c>();
                    for(API_ContoCarte__c cc1: contiCarteG){
                        if(cc1.API_TipoPIN__c.contains('1'))
                            ccPINStandard.add(cc1);
                        else
                            ccPINAutista.add(cc1);
                    }
                    
                    System.debug('ccPINStandard: ' +ccPINStandard);
                    System.debug('ccPINAutista: ' +ccPINAutista);
                    List<API_ContoCarte__c> daControllare= new List<API_ContoCarte__c>();
                    if(c.API_TipoPin__c.contains('1'))                        daControllare=ccPINStandard;                    else                        daControllare=ccPINAutista;
                    System.debug('daControllare: ' +daControllare);
                    //2.2 se trovo un unico contocarta con quel tipo pin lo metto e salvo
                    if(daControllare.size()==1){
                        System.debug('Ho trovato il conto carta unico lo associo');
                        c.API_ContoCarte__c= daControllare[0].Id;
                    }else if(daControllare.size()==0){
                        System.debug('Non ho trovato un conto carta lo devo creare');
                        List<API_Carta__c> carteMAP= mapCarteLookup.get(c.API_Quote__c);
                        if(carteMAP==null)
                            carteMAP= new List<API_Carta__c>();
                        carteMAP.add(c);
                        mapCarteLookup.put(c.API_Quote__c, carteMAP);
                        if(c.API_TipoPin__c.contains('1')){
                            API_ContoCarte__c standard= creaContoCartaPINStandard(c.API_Quote__c);
                            mapCCStandardDaCreare.put(c.API_Quote__c, standard);
                        }else{
                            API_ContoCarte__c autista= creaContoCartaPINAutista(c.API_Quote__c);
                            mapCCAutistaDaCreare.put(c.API_Quote__c, autista);       
                        }
                        
                    //2.3 ne trovo più di uno -> errore non posso decidere per l'utente
                    }else                     	c.addError('è necessario selezionare un conto carta tra quelli disponibili da collegare alla carta. Il sistema non è in grado di poterlo associare in modo univoco');
                }              
            } 
        }
        // devo inserire i contiCarta creati e mettere le lookup
        List<API_ContoCarte__c> contiCartaCreateS=mapCCStandardDaCreare.values();
        insert contiCartaCreateS;
        List<API_ContoCarte__c> contiCartaCreateA=mapCCAutistaDaCreare.values();
        insert contiCartaCreateA;
        /////////////////
        //continuare con la lookup
        List<API_carta__c> carteDaAggiornare = new List<API_carta__c>();
        for(String key : mapCarteLookup.keySet()){
            List<API_carta__c> cartaList = new List<API_carta__c>();
            cartaList = mapCarteLookup.get(key);
            for(API_carta__c carta : cartaList){
                if(carta.API_TipoPin__c == '1-PIN standard'){
                    for(API_ContoCarte__c contoCarta : contiCartaCreateS){
                        if(contoCarta.API_Quote__c == key){
                           carta.API_ContoCarte__c = contoCarta.Id;
                           carteDaAggiornare.add(carta); 
                        }
                    }
                }
                if(carta.API_TipoPin__c == '4-PIN driver'){
                    for(API_ContoCarte__c contoCarta : contiCartaCreateA){
                        if(contoCarta.API_Quote__c == key){
                           carta.API_ContoCarte__c = contoCarta.Id;
                           carteDaAggiornare.add(carta); 
                        }
                    }
                }
            }
        }
     }

    /*Utility method*/
    public static API_ContoCarte__c  creaContoCartaPINStandard(String quoteId){
    	API_ContoCarte__c standard= new API_ContoCarte__c();
        standard.API_ProdottiAmmessi__c= 'Tutti i carburanti';
        standard.API_DescrizioneGruppoCarte__c='Conto carta PIN Autista default';
        standard.API_Quote__c= quoteId;
        standard.API_ServiziInStazione__c='Nessuno';
        standard.API_TipoCarta__c='Nazionale';
        standard.API_TipoOperat__c='1 - km + PIN';
        standard.API_TipoPIN__c='1-PIN standard';
        standard.API_TipologiaVeicoli__c='1';
        return standard;
    }
    /*Utility method*/
    public static API_ContoCarte__c  creaContoCartaPINAutista(String quoteId){
            API_ContoCarte__c autista= new API_ContoCarte__c();
            autista.API_ProdottiAmmessi__c= 'Tutti i carburanti';
            autista.API_DescrizioneGruppoCarte__c='Conto carta PIN Autista default';
            autista.API_Quote__c= quoteId;
            autista.API_ServiziInStazione__c='Nessuno';
            autista.API_TipoCarta__c='Nazionale';
            autista.API_TipoOperat__c='3 - km + codice autista + PIN';
            autista.API_TipoPIN__c='4-PIN driver';
            autista.API_TipologiaVeicoli__c='1';
        	return autista;
    }
    
    /*Metodo utilizzato per associare ad un parco creato mentre si crea la carta la stessa quote dela carta
    In modo che sulle carte si possano associare solo i parchi specifici della quote non tutti i parchi del mondo*/
    public static void  updateParchi(List<API_Carta__c> carte){
        //per ogni carta inserita devo vedere se ha un parco. Se il parco non ha la quote settata la setto uguale a quella della carta
        List<String> idCarteInserite= new List<String>();
        for(API_Carta__c c : carte)
            idCarteInserite.add(c.Id);
        List<API_Carta__c> carteConParchi=[select id, API_Quote__c, API_ContoCarte__c, API_ContoCarte__r.API_Quote__c  from API_Carta__c 
                                          where id in: idCarteInserite];
        //creo una mappa ID Parco e Id quote da associare perchè non posso fare l0update direttamente dentro al for
        Map<String,String> mapParchiQuote= new Map<String,String>();
        
        //per ogni carta inserit controllo se ha un parco
        for(API_Carta__c carta: carteConParchi){
            if(carta.API_ContoCarte__c!= null){
                //controllo se il parco ha una quote associata se non ce l'ha lo aggiungo alla mappa così poi faccio l'update
                if(carta.API_ContoCarte__r.API_Quote__c==null){                    mapParchiQuote.put(carta.API_ContoCarte__c, carta.API_Quote__c);
                }//altrimenti non faccio niente
            }
        }
        
        //Per ogni parco trovato aggiorno La quote
        List<String> parchiId= new List<String>();
        parchiId.addAll(mapParchiQuote.keySet());
        System.debug('Parchi da aggiornare');
        System.debug(parchiId);
        List<API_ContoCarte__c> parchiDaAggiornare= new List<API_ContoCarte__c>();
        for(String parcoId : parchiId){
            API_ContoCarte__c parco= new API_ContoCarte__c();
            parco.Id= parcoId;
            parco.API_Quote__c = mapParchiQuote.get(parcoId);
            parchiDaAggiornare.add(parco);
        }
        
        update parchiDaAggiornare;
    }
   /*public static void  inputCarta(List<API_Carta__c> carte){
    /*    System.debug('triggerexecute sono nel trigger!!!! ');
        Set<String> numeroCliente = new Set<String>();
        System.debug('cartesize !!!! '+ carte.size());
        //mi estraggo tutti i numeri clienti dalle carte e li inserisco in una lista
        for(API_Carta__c car:carte){
            if(car.API_Codice_Cartesia__c!='')
                numeroCliente.add(car.API_Codice_Cartesia__c);
        }
       
        //mi prendo tutti gli maccount che hanno lo stesso codice cartesia delle carte
        
        List<Account> accList=[select id,API_Codice_Cartesia__c from Account where API_Codice_Cartesia__c IN:numeroCliente];
        System.debug('accList !!!! '+ accList.size());
        List<Quote> quList =[select AccountId, Account.API_Codice_Cartesia__c from Quote where Account.API_Codice_Cartesia__c IN:numeroCliente];
        System.debug('quList !!!! '+ quList.size());
        Map<Id, Quote> qMap = new Map<Id, Quote>();
        for(Quote qqStringId : quList){
            qMap.put(qqStringId.AccountId, qqStringId);
        }
        List<String> numeroClienteNoAccount = new List<String>();
        String numerodaInserire;
        
        for(String num:numeroCliente){
            Boolean bol = false;
            for(Account accL:accList){
                if(num==accL.API_Codice_Cartesia__c){
                    bol=true;
                }
            }
            if(bol!=true){
                numeroClienteNoAccount.add(num);
            }
        }
        
        System.debug('numeroClienteNoAccount!!!!'+ numeroClienteNoAccount.size());
        List<String> accNoQuote =new List<String>();
        //for(Id idMap:accountMap.keySet()){
            for(Account a:accList){            
                if(qMap.containsKey(a.Id)){
                    
                }else{
                    accNoQuote.add(a.Id);
                    
                }
            }
      //  }
        
        /*
for(Account ac:accList){
Boolean boll = false;
for(Quote qu:quList){
if(ac.id!=qu.AccountId){
boll=true;
}
}
if(boll==true){
accNoQuote.add(ac.id);
}
}*/
     /*   System.debug('accNoQuote!!!!'+ accNoQuote);        
        List<Opportunity> oppList=new List<Opportunity>();
        List<Quote> quotList = new List<Quote>();
        for(String accountString : accNoQuote){
            Opportunity opp = new Opportunity();
            opp.AccountId= accountString;
            opp.Name ='OpportDummy';
            opp.StageName='Chiuse/Conseguite';
            opp.CloseDate =date.Today();
            oppList.add(opp);
        }
        insert oppList;
        for(Opportunity opport: oppList){
            Quote q =new Quote();
            q.OpportunityId = opport.Id;
            q.API_Offerta__c='Cliente IP'; 
            q.Name ='Cliente IP'; 
            quotList.add(q);
        }
        insert quotList;
        
        List<Quote> quoteList = new List<Quote>();
        //prendo le quote associate a questi account
        System.debug('accList !!!! '+ accList.size());
        quoteList =[Select Id,AccountId from Quote where AccountId IN: accList];
        
        Map<String,Id> mapQuoteAcc= new Map<String,Id>();
        for(Account a: accList){
            for(Quote quo:quoteList){
                if(quo.AccountId==a.Id){
                    //creo una mappa formata da codice cartesia dell'account ed id della quote ad esso associato
                    mapQuoteAcc.put(a.API_Codice_Cartesia__c, quo.Id);
                }
            }
        }
        List<API_Carta__c> carteNoAccount = new List<API_Carta__c>();
        for(API_Carta__c car : carte){
            if(!mapQuoteAcc.containsKey(car.API_Codice_Cartesia__c)){
                carteNoAccount.add(car);
            }
        }
        Quote q =new Quote();
        if(!carteNoAccount.isEmpty()){    
            Account accountFittizio= new Account();
            RecordType recT=[select Id, DeveloperName from RecordType where DeveloperName='API_AccountFittizio']; 
            accountFittizio.Name ='Account Fittizio';
            accountFittizio.RecordTypeId =recT.Id;
            accountFittizio.API_RagioneSociale__c='Account Fittizio';
            accountFittizio.API_Iva__c='PartitaIVADum';
            accountFittizio.API_Verifica_Cerved__c='Rosso';
            insert accountFittizio;
            Opportunity opp = new Opportunity();
            opp.AccountId= accountFittizio.Id;
            opp.Name ='OpportDummyNoCodiceCartesia';
            opp.StageName='Chiuse/Conseguite';
            opp.CloseDate =date.Today();
            insert opp;
            q.OpportunityId = opp.Id;
            q.API_Offerta__c='Cliente IP no cartesia'; 
            q.Name ='Cliente IP no cartesia'; 
            insert q;
        }
        for(API_Carta__c cartNocartes : carteNoAccount){
            cartNocartes.API_Quote__c=q.Id;
            if(cartNocartes.API_Nome_autista__c!=null && cartNocartes.API_Numero_di_targa_string__c==null){
                if(cartNocartes.API_Nome_autista__c.length()>12){
                    String nominativoString = cartNocartes.API_Nome_autista__c.substring(0,12);
                    cartNocartes.API_Numero_di_targa__c=nominativoString;
                }else
                    cartNocartes.API_Numero_di_targa__c=cartNocartes.API_Nome_autista__c;
            }else if(cartNocartes.API_Nome_autista__c!=null && cartNocartes.API_Numero_di_targa_string__c!=null){
                	String nominativoString = cartNocartes.API_Nome_autista__c.substring(0,5);
                    cartNocartes.API_Numero_di_targa__c=cartNocartes.API_Numero_di_targa_string__c+nominativoString;
            }else if(cartNocartes.API_Nome_autista__c==null && cartNocartes.API_Numero_di_targa_string__c!=null)
                    cartNocartes.API_Numero_di_targa__c=cartNocartes.API_Numero_di_targa_string__c;
                    
        }
        System.debug('mapQuoteAcc!!!! '+ mapQuoteAcc);
        //ciclo la mappa e inserisco i codici cartesia in idNew
        for (String idNew : mapQuoteAcc.keySet()){
            for(API_Carta__c car : carte){
                //verifico che il codice cartesia della carta è uguale al codice cartesia dell'account
                if(car.API_Codice_Cartesia__c==idNew){
                    //prendo l'id della quote associata a quel codice cartesia               
                    Id quoteID= mapQuoteAcc.get(car.API_Codice_Cartesia__c);
                    System.debug('quoteID!!!! '+ quoteID);
                    car.API_Quote__c=quoteID;
                    System.debug('quote!!!! '+ car.API_Quote__c); 
                    if(car.API_Nome_autista__c!=null && car.API_Numero_di_targa_string__c==null){
                		if(car.API_Nome_autista__c.length()>12){
                    		String nominativoString = car.API_Nome_autista__c.substring(0,12);
                    		car.API_Numero_di_targa__c=nominativoString;
                		}else
                        	car.API_Numero_di_targa__c=car.API_Nome_autista__c;
            		}
                       else if(car.API_Nome_autista__c!=null && car.API_Numero_di_targa_string__c!=null){
                        String nominativoString = car.API_Nome_autista__c.substring(0,5);
                        car.API_Numero_di_targa__c=car.API_Numero_di_targa_string__c+nominativoString;
            		}
                    else if(car.API_Nome_autista__c==null && car.API_Numero_di_targa_string__c!=null)
                        car.API_Numero_di_targa__c=car.API_Numero_di_targa_string__c;
                    
                    if(car.API_Data_Blocco_Carta_String__c==null)
                        car.API_Data_Blocco_Carta__c=null;
                    else{
                        //devo settare la data. dal CSv ho una data con il seguente formato gg.mm.yyyy, poichè APEX è limitato non posso usare un DateFormat custom, devo fare a mano
                        List<String> dateArray= car.API_Data_Blocco_Carta_String__c.split('\\.');
                        System.debug('dateArray!!!! '+ dateArray);
                        if(dateArray.size()==3){
                            Date databloc= Date.newInstance(integer.ValueOf(dateArray[2]),integer.ValueOf(dateArray[0]), integer.ValueOf(dateArray[1]));
                            car.API_Data_Blocco_Carta__c=databloc;
                        }
                        else{
                            System.debug('Errore nel formato della data!!!! '+ car.API_Data_Blocco_Carta__c);
                            car.API_Data_Blocco_Carta__c=null;
                        }
                    }
                    if(car.API_Data_di_creazione_carta_String__c==null)
                        car.API_Data_di_creazione_carta__c=null;
                    else{
                        //devo settare la data. dal CSv ho una data con il seguente formato gg.mm.yyyy, poichè APEX è limitato non posso usare un DateFormat custom, devo fare a mano
                        List<String> dateArray= car.API_Data_di_creazione_carta_String__c.split('\\.');
                        if(dateArray.size()==3){
                            Date datacart= Date.newInstance(integer.ValueOf(dateArray[2]),integer.ValueOf(dateArray[0]), integer.ValueOf(dateArray[1]));
                            car.API_Data_di_creazione_carta__c=datacart;
                        }
                        else{
                            System.debug('Errore nel formato della data!!!! '+ car.API_Data_di_creazione_carta__c);
                            car.API_Data_di_creazione_carta__c=null;
                        }
                    }
                    if(car.API_Data_di_sblocco_carta_String__c==null)
                        car.API_Data_di_sblocco_carta__c=null;
                    else{
                        //devo settare la data. dal CSv ho una data con il seguente formato gg.mm.yyyy, poichè APEX è limitato non posso usare un DateFormat custom, devo fare a mano
                        
                        List<String> dateArray= car.API_Data_di_sblocco_carta_String__c.split('\\.');
                        if(dateArray.size()==3){
                            Date datacart= Date.newInstance(integer.ValueOf(dateArray[2]),integer.ValueOf(dateArray[0]), integer.ValueOf(dateArray[1]));
                            car.API_Data_di_sblocco_carta__c=datacart;
                        }
                        else{
                            System.debug('Errore nel formato della data!!!! '+ car.API_Data_di_sblocco_carta__c);
                            car.API_Data_di_sblocco_carta__c=null;
                        }
                    }
                    if(car.API_Data_rinnovo_String__c==null)
                        car.API_Data_rinnovo__c=null;
                    else{
                        //devo settare la data. dal CSv ho una data con il seguente formato gg.mm.yyyy, poichè APEX è limitato non posso usare un DateFormat custom, devo fare a mano
                        List<String> dateArray= car.API_Data_rinnovo_String__c.split('\\.');
                        if(dateArray.size()==3){
                            Date datacart= Date.newInstance(integer.ValueOf(dateArray[2]),integer.ValueOf(dateArray[0]), integer.ValueOf(dateArray[1]));
                            car.API_Data_rinnovo__c=datacart;
                        }
                        else{
                            System.debug('Errore nel formato della data!!!! '+ car.API_Data_rinnovo__c);
                            car.API_Data_rinnovo__c=null;
                        }
                    }
                    if(car.API_Data_ultimo_aggiornamento_String__c==null)
                        car.API_Data_ultimo_aggiornamento__c=null;
                    else{
                        //devo settare la data. dal CSv ho una data con il seguente formato gg.mm.yyyy, poichè APEX è limitato non posso usare un DateFormat custom, devo fare a mano
                        List<String> dateArray= car.API_Data_ultimo_aggiornamento_String__c.split('\\.');
                        if(dateArray.size()==3){
                            Date datacart= Date.newInstance(integer.ValueOf(dateArray[2]),integer.ValueOf(dateArray[0]), integer.ValueOf(dateArray[1]));
                            car.API_Data_ultimo_aggiornamento__c=datacart;
                        }
                        else{
                            System.debug('Errore nel formato della data!!!! '+ car.API_Data_ultimo_aggiornamento__c);
                            car.API_Data_ultimo_aggiornamento__c=null;
                        }
                    }
                }
            }
        }*/
    //}
    public static void ribaltaLimiteGiornaliero(List<API_Carta__c> cartaList){
        System.debug('Sono nel metodo ');
        for(API_Carta__c carta : cartaList){
            system.debug('TIPO VEICOLO: '+carta.API_TipoVeicolo__c);
            if(carta.API_Stato_carta__c == 'Inserita CRM'){
                if(carta.API_TipoVeicolo__c == '1'){                    carta.API_LimiteGiornalieroSAP__c = 200.00;
                }if(carta.API_TipoVeicolo__c == '2'){                    carta.API_LimiteGiornalieroSAP__c = 650.00;
                }if(carta.API_TipoVeicolo__c == '3'){                    carta.API_LimiteGiornalieroSAP__c = 1800.00;
                }if(carta.API_TipoVeicolo__c == '4'){                    carta.API_LimiteGiornalieroSAP__c = 1300.00;
                }if(carta.API_TipoVeicolo__c == '9'){                    carta.API_LimiteGiornalieroSAP__c = 200.00;
                }if(carta.API_TipoVeicolo__c == '5'){                    carta.API_LimiteGiornalieroSAP__c = 50.00;
                }
            }
        }
    }
    /*controllo sul numero massimo di carte se ereditato da contratto quadro*/
    public static void checkNumeroMaxCarte(List<API_Carta__c> cartaList){
        //raggruppo le carte per padre  e mi prendo gli id delle varie quote (che in linea di massima è 1)
        Map<String,List<API_Carta__c>> mapQuoteCarte= new Map<String,List<API_Carta__c>>();
        Set<String> setQuote= new Set<String>();
        for(API_Carta__c c: cartaList){
            setQuote.add(c.API_Quote__c);
            List<API_Carta__c> carte= mapQuoteCarte.get(c.API_Quote__c);
            if(carte==null)                carte= new List<API_Carta__c>();
            carte.add(c);
            mapQuoteCarte.put(c.API_Quote__c,carte);
        }
        //mi prendo il numero massimo di carte accettato per le varie quote se sono in un contratto quadro
        List<Quote> quotes= [Select id, API_MaxNumberCardContrattoQuadro__c, API_Contratto_quadro__c from Quote where Id in: setQuote];
        //se c'è il contratto quadro ed è settato il numero massimo di carte mi devo contare le carte
        List<Quote> quoteConLimite= new List<Quote> ();
        Map<String,Decimal> quoteNumMAx= new Map<String,Decimal>();
        for(Quote q: quotes){
            if(q.API_Contratto_quadro__c != null && q.API_MaxNumberCardContrattoQuadro__c!= null){
                quoteNumMAx.put(q.Id, q.API_MaxNumberCardContrattoQuadro__c);
                quoteConLimite.add(q);
            }
        }
        //a questo punto per ogni quote che ha il limite mi devo contare quante carte ha
        if(quoteConLimite.size()>0){
            List<API_Carta__c> carteTrovateList= [Select id, API_Quote__c from API_Carta__c where API_Quote__c in: quoteConLimite];
            Map<String, List<API_Carta__c>> carteTrovate= new  Map<String, List<API_Carta__c>>();
            for(API_Carta__c c: carteTrovateList){
                List<API_Carta__c> carte= carteTrovate.get(c.API_Quote__c);
                if(carte==null)
                    carte= new List<API_Carta__c>();
                carte.add(c);
                carteTrovate.put(c.API_Quote__c,carte);
            }
            
            /*conto a questo punto ogni quote quante carte ha*/
            Map<String, Integer> quoteConNumeroCarte= new Map<String, Integer>();
            System.debug('@@@@@@ '+carteTrovate.keySet());
            for(String qId: carteTrovate.keySet()){
                quoteConNumeroCarte.put(qId, carteTrovate.get(qId).size());
                System.debug('@@@@@@@@');
                System.debug('Quote id '+qId);
                System.debug('numero carte '+carteTrovate.get(qId).size());
            }
            
            System.debug(quoteConNumeroCarte);
            for(API_Carta__c c: cartaList){
                if(quoteNumMAx.get(c.API_Quote__c)!=null){
                    Integer num=quoteConNumeroCarte.get(c.API_Quote__c);
                    System.debug(num);
                    if(num==null)
                        num=0;
                    if(num< quoteNumMax.get(c.API_Quote__c))                        quoteConNumeroCarte.put(c.API_Quote__c, num+1);
                    else                        throw new MaxCardException('Hai superato il limite massimo di carte consentito per questa tipologia di contratto quadro');
                }
            }
            
        }
        
        
        
    }
    public class MaxCardException extends Exception {}

}