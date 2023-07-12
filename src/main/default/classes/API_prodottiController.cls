public class API_prodottiController {
    
    @AuraEnabled
    public static List<Product2> getProdotti(String offerta){
        /*return [select Id, Name, API_ProdottoSecondario__c, API_Pacchetto__c, API_ProdottoSecondario__r.Name, API_Pacchetto__r.Name  from API_ProductX__c
where API_Pacchetto__r.Name =: offerta];*/
        return [Select Id, Name, API_ProdottoLabel__c, API_Index__c, IsActive from Product2 where IsActive =true order by API_Index__c ];
        
    }
    
    @AuraEnabled
    public static list <attributeWrapper> getAttributi(String prodotto, Boolean isUpdate, ID idProduct, String quoteId){
        system.debug('PRODOTTO:  '+ prodotto);
        //prima di prendere gli attributi devo controllare la molteplicità del prodotto
        //se è 1 e il record è già presente devo segnalare l'errore
        //1) faccio la query su Prduct per prendere la molteplicità
        Product2 p=[Select id,Name, API_Molteplicita__c from Product2 where API_ProdottoLabel__c=:prodotto limit 1];
        if(!isUpdate){
            if(p== null)
                throw new AuraException('Nessun prodotto trovato');
            System.debug('****');
            System.debug(p);
            if(p.API_Molteplicita__c =='1'){
                //2) faccio la query per prendere i quoteLineItem che potrebbero già essere associati a quel prodotto
                List<QuoteLineItem> qli=[select id, Product2.Name, QuoteId from QuoteLineItem 
                                         where Product2.API_ProdottoLabel__c=: prodotto and QuoteId=: quoteId];
                if(qli.size()>0)
                    throw new AuraException('Non puoi inserire una nuova opzione '+ prodotto +' per questa domanda di adesione. Modifica quella esistente');
            }
        }
        
        list<API_ProductAttribute__mdt> attributeList = new List<API_ProductAttribute__mdt>();
        /*list<API_QuoteLineItemX__c> attrList = new List<API_QuoteLineItemX__c>();
String attributiReturn;*/
        //if(String.isNotBlank(prodotto)){
        attributeList = [select Id, Label, API_NomeProdotto__c, API_Ordine__c, API_Obbligatorio__c, API_Attributo__c, API_Tipologia__c, 
                         API_ElencoValori__c, DeveloperName
                         from API_ProductAttribute__mdt where API_NomeProdotto__c=:p.Name order by API_Ordine__c];
        list <API_QuoteLineItemX__c > quoteLineItemXList = new List <API_QuoteLineItemX__c>();
        system.debug('isUPDATE: ' +isUpdate);
        system.debug('idProduct: ' +idProduct);
        if(isUpdate){
            quoteLineItemXList = [select Id, Name, API_QuoteLineItem__c, API_NomeProdotto__c, API_NomeAttributo__c, API_Valore__c, 
                                  API_DeveloperNameMetadata__c from API_QuoteLineItemX__c where API_QuoteLineItem__c  =:idProduct];
        }
        system.debug('QuotelineitemX: ' +quoteLineItemXList);
        list<attributeWrapper> attWrp = new list <attributeWrapper>();
        for(API_ProductAttribute__mdt a : attributeList){
            attributeWrapper aw = new attributeWrapper();
            aw.id = a.id;
            aw.Label = a.Label; 
            aw.API_NomeProdotto = a.API_NomeProdotto__c;
            aw.API_Attributo = a.API_Attributo__c;
            aw.API_Tipologia = a.API_Tipologia__c;
            aw.API_Obbligatorio = a.API_Obbligatorio__c;
            aw.API_DeveloperNameMetadata = a.DeveloperName;
            aw.API_ElencoValori = (a.API_ElencoValori__c!=null) ? a.API_ElencoValori__c : '';
            if(!quoteLineItemXList.isEmpty()){
                system.debug('CI sono valori di quote line item');
                for(API_QuoteLineItemX__c qli : quoteLineItemXList){
                    if(aw.API_NomeProdotto == qli.API_NomeProdotto__c && aw.API_Attributo == qli.API_NomeAttributo__c){
                        system.debug('sono nell if');
                        //controllo anche nell'update se valore è vuoto, in quel caso metto stringa vuota
                        aw.Valore = (!String.isBlank(qli.API_Valore__c)) ? qli.API_Valore__c :  '';
                        aw.quoteLineItemXId = qli.Id;
                    }
                }
            }else{
                aw.Valore = '';
                aw.quoteLineItemXId = '';
            }
            attWrp.add(aw);
        }
        //attributiReturn = JSON.serialize(attributeList);
        /*}else{
attrList = [select Id, Name, API_QuoteLineItem__c, API_NomeProdotto__c, API_NomeAttributo__c, API_Valore__c from API_QuoteLineItemX__c 
where API_QuoteLineItem__c  =:idProduct];
system.debug('attribute list: ' +attrList);
attributiReturn = JSON.serialize(attrList);
}*/
        system.debug('WRAPPER ATTRIBUTI:  '+attWrp);
        return attWrp;
    }
    
    //wrapper class
    public class attributeWrapper{
        @AuraEnabled
        public ID Id						    {get;set;}
        @AuraEnabled
        public String Label                     {get;set;}
        @AuraEnabled
        public String API_NomeProdotto          {get;set;}
        @AuraEnabled
        public String API_Attributo             {get;set;}
        @AuraEnabled
        public String API_Tipologia             {get;set;}
        @AuraEnabled
        public String API_ElencoValori          {get;set;}
        @AuraEnabled
        public Boolean API_Obbligatorio          {get;set;}
        @AuraEnabled
        public String Valore                    {get;set;}
        @AuraEnabled
        public String quoteLineItemXId			{get;set;}
        @AuraEnabled
        public String API_DeveloperNameMetadata {get;set;}
    }
    
    //metodo che inserisce un quoteLineItem e i relativi quoteLineItemX
    @AuraEnabled
    public static Integer addProduct(String quoteId, String prodotto, String developerName, List<String> attributi, boolean updateData){
        //ist<String> attributi= new List<String> ();
        System.debug('@@@@@@ Start method addProduct');
        System.debug('@@@@@@ Prodotto '+ prodotto+'-----');
        System.debug('@@@@@@ attributi '+attributi);
        Date dataInizio;
        Date dataFine;
        Integer response;
        Decimal valore;
        Decimal valoreScontoPacchetto;
        //1) per il prodotto che sto inserendo devo recuperare il pricebookEntryId associato allo standard Pricebook
        List<PricebookEntry> pricebookentries=[select Id, Name, Pricebook2.Name from PricebookEntry where Pricebook2.Name='Price Book API' and name=: developerName];
        //se ho trovato la pricebookEntry posso continuare con l'inserimento
        if(pricebookentries.size()>0){
            System.debug('@@@@@@ PricebookEntry '+pricebookentries[0]);
            //mi serve l'id del prodotto per cui devo inserire il quoteLineItem
            List<Product2> products= [select Id, Name from Product2 where Name=:developerName]; 
            //se ho trovato il prodotto posso procedere all'inserimento
            system.debug('updateData: ' +updateData);
            
            List<API_DeleghePacchetto__mdt> delegheList = [select Id, API_ValoreSconto__c, API_PacchettoScelto__c, 
                                                           API_Profilo__c, API_NomeDelega__c, DeveloperName, API_Offerta__c from API_DeleghePacchetto__mdt];
            Product2 productList = [select API_ProdottoLabel__c from Product2 where name =: developerName][0];
            Quote quoteDaAggiornare = [select id, API_Offerta__c, Account.API_Consumo__c, Account.API_Valore__c,
                                       API_ScontoPacchetto__c, API_CommissionePedaggio__c, API_DelegaCommissione__c, 
                                       API_ScontoBaseDeleghe__c, API_Pacchetto__c,API_BonusDeleghe__c, API_PrevisioneConsumi__c,
                                       API_BonusGaranzia__c, API_ScontoBaseDelegheValoreNEW__c, API_ScontoSiteReteDeleghe__c,
                                       API_TipoBonus__c from Quote where id =: quoteId][0];
            id id1 = userinfo.getProfileId();
            id roleID = UserInfo.getUserRoleId();
            Profile profile = [select name from Profile where id =: id1][0];
            UserRole role = [select name from UserRole where id =: roleID][0];
            String roleName = string.valueOf(role);
            
            if(products.size()>0 && updateData != true){
                PricebookEntry pricebookEntry= pricebookentries[0];
                //creo il quoteLineItem
                QuoteLineItem quoteLineItem= new QuoteLineItem();
                quoteLineItem.QuoteId= quoteId;
                quoteLineItem.PricebookEntryId= pricebookEntry.Id;
                quoteLineItem.Product2Id= products[0].Id;
                quoteLineItem.Quantity=1;
                quoteLineItem.UnitPrice=0;
                
                //il metodo deve essere transazionale: se inserisco il quote line item devo inserire correttamente anche tutti i sui attributi
                Savepoint sp = Database.setSavepoint();
                try{
                    insert quoteLineItem;
                    system.debug('@@@@@@ QuoteLineItem '+quoteLineItem);
                    //per ogni attributo del prodotto che sto inserendo creo un quoteLineItemX
                    List<API_QuoteLineItemX__c> listQlix= new List<API_QuoteLineItemX__c>();
                    for(String s: attributi){
                        //converto la stringa con tutti i valori dell'attributo in una mappa
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(s);
                        System.debug('@@@@@@ Attributo da inserire'+m);
                        //creo il quoteLineItemX
                        API_QuoteLineItemX__c  qlix= new API_QuoteLineItemX__c ();
                        qlix.API_QuoteLineItem__c= quoteLineItem.Id;
                        qlix.API_NomeProdotto__c= developerName;
                        qlix.API_NomeAttributo__c= (String)m.get('API_Attributo');
                        qlix.API_Valore__c  = (String)m.get('Valore');
                        qlix.API_DeveloperNameMetadata__c = (String)m.get('API_DeveloperNameMetadata');
                        
                        //Mi salvo il valore per verificare che sia minore di 0.5
                        if(qlix.API_NomeAttributo__c.contains('€/LT') /*|| qlix.API_NomeAttributo__c.contains('Valore sconto percentuale IVA inclusa')*/){
                            valore = decimal.valueOf(qlix.API_Valore__c); 
                        }
                         //Mi salvo il valore del canone utenza web per verificare, se è 100, se la data di fine è <= di 6*data inizio
                        if(qlix.API_NomeAttributo__c.contains('Valore sconto in %')){
                            valoreScontoPacchetto = decimal.valueOf(qlix.API_Valore__c); 
                        }
                        system.debug('DEVELOPERNAME: ' +(String)m.get('API_DeveloperNameMetadata'));
                        if((String)m.get('API_DeveloperNameMetadata') == 'API_ScontoPack_dataInizio'){
                            System.debug('DATA INIZIO SET: ' +qlix.API_Valore__c);
                            dataInizio = Date.valueOf(qlix.API_Valore__c); 
                        }
                        if((String)m.get('API_DeveloperNameMetadata') == 'API_ScontoPack_dataFine'){
                            dataFine = Date.valueOf(qlix.API_Valore__c); 
                        }
                        
                        //Chiamo il metodo per la gestione delle deleghe
                        quoteDaAggiornare = controlloDeleghe(qlix, quoteDaAggiornare, delegheList, profile, roleName);
                        
                        listQlix.add(qlix);
                    }
                    
                    system.debug('listQlix ' +listQlix);
                    system.debug('DATA INIZIO: '+dataInizio);
                    system.debug('DATA FINE: '+dataFine);
                    system.debug('VALORE: '+valore);
                    if(dataInizio != null && dataFine!= null){
                        Date dataIniziox6 = dataInizio.addMonths(6);
                        system.debug('DATAINIZIOX6: '+dataIniziox6);
                        if(dataFine <= dataIniziox6){
                            System.debug('FINE <= INIZIO x6');
                            if(valore != null && valore <= 0.5){
                                update quoteDaAggiornare;
                                insert listQlix;
                                response = 1;
                            }else if(valore == null){
                                update quoteDaAggiornare;
                                insert listQlix;
                                response = 1;
                            }else if(valore != null && valore > 0.5){
                                delete quoteLineItem;
                                response = 2;
                            }
                        }else if(dataFine > dataIniziox6 && valoreScontoPacchetto < 100){
                            System.debug('SONO NEL POSTO GIUSTO!!');
                            update quoteDaAggiornare;
                            insert listQlix;
                            response = 1;
                        }else{
                            delete quoteLineItem;
                            response = 0;
                        }
                    }else if(dataInizio == null && dataFine== null ){
                        if(valore != null && valore <= 0.5){
                            update quoteDaAggiornare;
                            insert listQlix;
                            response = 1;
                        }else if(valore == null){
                            update quoteDaAggiornare;
                            insert listQlix;
                            response = 1;
                        }else if(valore != null && valore > 0.5){
                            delete quoteLineItem;
                            response = 2;
                        }
                    }
                    
                }
                catch (Exception e){
                    System.debug(e.getMessage());
                    Database.rollback(sp);
                    //devo cmq far arrivare al component il motivo dell'errore,se ad esempio ha violato una validation rule
                    throw new AuraHandledException(e.getMessage());
                }
            }else if(updateData){
                system.debug('Sono nell update dei valori');
                List<API_QuoteLineItemX__c> listQlix= new List<API_QuoteLineItemX__c>();
                for(String s: attributi){
                    //converto la stringa con tutti i valori dell'attributo in una mappa
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(s);
                    System.debug('@@@@@@ Attributo da inserire'+m);
                    //creo il quoteLineItemX
                    API_QuoteLineItemX__c  qlix= new API_QuoteLineItemX__c (
                        API_Valore__c  = (String)m.get('Valore'),
                        Id 			   = (String) m.get('quoteLineItemXId'),
                        API_NomeProdotto__c = (String) m.get('API_NomeProdotto'),
                        API_NomeAttributo__c = (String)m.get('API_Attributo'),
                        API_DeveloperNameMetadata__c = (String)m.get('API_DeveloperNameMetadata')
                    );
                    
                    //Mi salvo il valore per verificare che sia minore di 0.5
                    if(qlix.API_NomeAttributo__c.contains('€/LT')){                        valore = decimal.valueOf(qlix.API_Valore__c); 
                    }
                    //Mi salvo il valore del canone utenza web per verificare, se è 100, se la data di fine è <= di 6*data inizio
                    if(qlix.API_NomeAttributo__c.contains('Valore sconto in %')){                        valoreScontoPacchetto = decimal.valueOf(qlix.API_Valore__c); 
                    }
                    if((String)m.get('API_DeveloperNameMetadata') == 'API_ScontoPack_dataInizio'){                        dataInizio = Date.valueOf(qlix.API_Valore__c); 
                    }
                    if((String)m.get('API_DeveloperNameMetadata') == 'API_ScontoPack_dataFine'){                        dataFine = Date.valueOf(qlix.API_Valore__c); 
                    }
                    //Chiamo il metodo per la gestione delle deleghe
                    quoteDaAggiornare = controlloDeleghe(qlix, quoteDaAggiornare, delegheList, profile, roleName);
                    
                    listQlix.add(qlix);
                }
                system.debug('listQlix'+listQlix);
                system.debug('SCONTO BASE DELEGHE PRIMA DE UPDATE: ' +quoteDaAggiornare.API_ScontoBaseDeleghe__c);
                
                if(dataInizio != null && dataFine!= null){
                    Date dataIniziox6 = dataInizio.addMonths(6);
                    system.debug('DATAINIZIOX6: '+dataIniziox6);
                    if(dataFine <= dataIniziox6){
                        if(valore != null && valore <= 0.5){
                            update quoteDaAggiornare;
                            upsert listQlix;
                            response = 1;
                        }else if(valore == null){
                            update quoteDaAggiornare;
                            upsert listQlix;
                            response = 1;
                        }else if(valore != null && valore > 0.5){
                            response = 2;
                        }
                    }else if(dataFine > dataIniziox6 && valoreScontoPacchetto < 100){
                            System.debug('SONO NEL POSTO GIUSTO!!');
                            update quoteDaAggiornare;
                            upsert listQlix;
                            response = 1;
                    }else{
                        response = 0;
                    }
                }else if(dataInizio == null && dataFine== null){
                    if(valore != null && valore <= 0.5){
                        update quoteDaAggiornare;
                        upsert listQlix;
                        response = 1;
                    }else if(valore == null){
                        update quoteDaAggiornare;
                        upsert listQlix;
                        response = 1;
                    }else if(valore != null && valore > 0.5){
                        response = 2;
                    }
                }
                
            }
        }
        return response;
    }
    
    //Metodo utilizzato per controllare se con le opzioni aggiunte bisogna andare in delega
    @AuraEnabled
    public static Quote controlloDeleghe(API_QuoteLineItemX__c qlix, Quote quote, List<API_DeleghePacchetto__mdt> delegheList, Profile profile, String roleName){
        
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
                    if( (deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) && 
                       integer.valueof(qlix.API_Valore__c ) > deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Pacchetti' &&
                       deleghe.API_PacchettoScelto__c == quote.API_Pacchetto__c){
                           system.debug('if true');
                           scontoPacchetto = true;
                       }/*Stessa condizione di sopra con la differenza che viene controllato se il valore è minore o uguale dal  */
                    else if ( (deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) && 
                             integer.valueof(qlix.API_Valore__c ) <= deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Pacchetti' &&
                             deleghe.API_PacchettoScelto__c == quote.API_Pacchetto__c){                                 scontoPacchetto = false;
                             }
                }
            }
        }
        
        //Nel caso in cui il prodotto selezionato è "Pedaggio" e l'attributo non è "Tipo" (quindi è valore) allora effettuo gli stessi controlli dell'if precedente
        if(qlix.API_NomeProdotto__c == 'Pedaggi' && qlix.API_DeveloperNameMetadata__c == 'API_PedaggioCommissionePercentuale'){
            system.debug('@@@pedaggio');
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if( (deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) && decimal.valueof(qlix.API_Valore__c ) < deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Pedaggi'){
                    scontoPedaggio = true;
                }else if ((deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) && decimal.valueof(qlix.API_Valore__c ) >= deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Pedaggi'){
                    scontoPedaggio = false;
                }
            }
        }
        
        //Nel caso in cui il prodotto scelto è commissione e l'attributo scelto è valore, effettuo una serie di controlli simili al primo if e setto un booleano 
        if(qlix.API_NomeProdotto__c == 'Commissione IP Matic' && qlix.API_DeveloperNameMetadata__c == 'API_CommissioneValore'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if( (deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) && 
                   decimal.valueof(qlix.API_Valore__c ) < deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Commissione'){
                       //delegaCommissioneValore = true;
                       delegaCommissione = true;
                   }else if((deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) && 
                            decimal.valueof(qlix.API_Valore__c ) >= deleghe.API_ValoreSconto__c && deleghe.API_NomeDelega__c == 'Commissione'){
                                //delegaCommissioneValore = false;
                                delegaCommissione = false;
                            }
            }
        }
        
        //@@@@ SCONTO BASE
        if(qlix.API_NomeProdotto__c == 'Sconto base'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_ValoreSconto'){                        ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c);
                    }
                }
            }
        }else if(qlix.API_NomeProdotto__c == 'Bonus'){
            if(qlix.API_DeveloperNameMetadata__c == 'Api_BonusTipo'){                TipoBonus = qlix.API_Valore__c;
            }
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_BonusValore'){                        ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c);
                    }
                }
            }
        }else if(qlix.API_NomeProdotto__c == 'Bonus garanzia'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoGaranziaValoreSconto'){
                        ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c);
                    }
                }
            }
        }else if(qlix.API_NomeProdotto__c == 'Sconto Site/Rete'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)){
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteValoreSconto'){
                        ScontoBaseDelegheValore = Decimal.valueOf(qlix.API_Valore__c);
                    }
                }
            }
        }
        
        if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_Prodotti' && qlix.API_NomeProdotto__c == 'Sconto base'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    if(qlix.API_Valore__c.contains('04')){
                        //BOOLEANO GPL = TRUE;
                        if(deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)){
                            if(quote.API_Offerta__c =='Prezzo Listino' &&  deleghe.DeveloperName.contains('GPL') && deleghe.API_Offerta__c.contains('PL')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                    ScontoBaseDeleghe = true;
                                }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c ){
                                    ScontoBaseDeleghe = false;
                                }
                            }else if(quote.API_Offerta__c =='Miglior Prezzo' &&  deleghe.DeveloperName.contains('GPL') && deleghe.API_Offerta__c.contains('PM')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                    ScontoBaseDeleghe = true;
                                }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                    ScontoBaseDeleghe = false;
                                }
                            }else if(quote.API_Offerta__c =='Prezzo Pompa' &&  deleghe.DeveloperName.contains('GPL') && deleghe.API_Offerta__c.contains('PP')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                    ScontoBaseDeleghe = true;
                                }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                    ScontoBaseDeleghe = false;
                                }
                            }
                        }
                    }else if(! qlix.API_Valore__c.contains('04')){
                        //BOOLEANO GPL = FALSE;
                        //FARE FILTRO CON I LITRI
                        if(deleghe.API_Profilo__c == String.valueOf(profile.name)){
                            if((quote.API_Offerta__c =='Prezzo Listino' || quote.API_Offerta__c == 'Miglior Prezzo')){
                                if(quote.API_PrevisioneConsumi__c > 0 && quote.API_PrevisioneConsumi__c <= 30000 && 
                                   deleghe.DeveloperName.contains('SSP1') && (!deleghe.DeveloperName.contains('GPL'))){
                                       if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                           system.debug('SCONTO BASE DELEGHE TRUE: ');
                                           ScontoBaseDeleghe = true;
                                       }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                           ScontoBaseDeleghe = false;
                                           system.debug('SCONTO BASE DELEGHE FALSE');
                                       }
                                   }else if(quote.API_PrevisioneConsumi__c > 30001 && quote.API_PrevisioneConsumi__c <= 80000 && 
                                            deleghe.DeveloperName.contains('SSP2') && (!deleghe.DeveloperName.contains('GPL'))){
                                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c)   ScontoBaseDeleghe = true;
                                                else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c)  ScontoBaseDeleghe = false;
                                                
                                            }else if(quote.API_PrevisioneConsumi__c >= 80001 && deleghe.DeveloperName.contains('SSP3') && (!deleghe.DeveloperName.contains('GPL'))){
                                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c) ScontoBaseDeleghe = true;
                                                else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c)  ScontoBaseDeleghe = false;                                      
                                           }
                            }
                        }else if(roleName.contains(deleghe.API_Profilo__c)){
                            system.debug('OFFERTA QUOTE: '+quote.API_Offerta__c);
                            system.debug('deleghe '+deleghe);
                            if(quote.API_Offerta__c =='Prezzo Listino' && (!deleghe.DeveloperName.contains('GPL')) && deleghe.API_Offerta__c.contains('PL')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                    ScontoBaseDeleghe = true;
                                }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c ){
                                    ScontoBaseDeleghe = false;
                                }
                            }else if(quote.API_Offerta__c =='Miglior Prezzo' &&  (!deleghe.DeveloperName.contains('GPL')) && deleghe.API_Offerta__c.contains('PM')){
                                if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                ScontoBaseDeleghe = true;
                                }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                    ScontoBaseDeleghe = false;
                                }
                            }else if(quote.API_Offerta__c =='Prezzo Pompa' &&  (!deleghe.DeveloperName.contains('GPL'))){
                                if(!qlix.API_Valore__c.contains('AA') && deleghe.API_Offerta__c.contains('PP_SERVITO')){
                                    if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                        ScontoBaseDeleghe = true;
                                    }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                        ScontoBaseDeleghe = false;
                                    }
                                }else if(qlix.API_Valore__c.contains('AA') && deleghe.API_Offerta__c.contains('PP_SELF')){
                                    if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){                                        ScontoBaseDeleghe = true;
                                    }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                        ScontoBaseDeleghe = false;
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
                        if((deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c)) 
                           && deleghe.API_PacchettoScelto__c == 'Bonus' && deleghe.DeveloperName.contains('GPL')){
                               if(deleghe.API_Profilo__c == String.valueOf(profile.name) && quote.API_TipoBonus__c == 'Temporale'){        bonusDeleghe = true; 
                               }else if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c ){       bonusDeleghe = true;
                               }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c || quote.API_TipoBonus__c != 'Temporale'){
                                   bonusDeleghe = false;
                                   system.debug('@@BONUS DELEGHE false ');
                               }
                           }
                    }else if(! qlix.API_Valore__c.contains('04')){
                        system.debug('BONUS SENZA GPL');
                        system.debug('VALORE DELEGA: '+deleghe.API_ValoreSconto__c);
                        system.debug('PACCHETTO SCELTO: '+deleghe.API_PacchettoScelto__c);
                        system.debug('DELEGHE SCELTO: '+deleghe.DeveloperName);
                        if(deleghe.API_Profilo__c == String.valueOf(profile.name)  
                           && deleghe.API_PacchettoScelto__c == 'Bonus' && (!deleghe.DeveloperName.contains('GPL'))){
                               if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c || quote.API_TipoBonus__c == 'Temporale'){
                                   system.debug('VALORE MAGGIORE');
                                   bonusDeleghe = true;
                               }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c || quote.API_TipoBonus__c == 'Temporale'){
                                   system.debug('VALORE MINORE');
                                   bonusDeleghe = false;
                               }
                        }else if( roleName.contains(deleghe.API_Profilo__c)
                           && deleghe.API_PacchettoScelto__c == 'Bonus' && (!deleghe.DeveloperName.contains('GPL'))){
                               if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c ){
                                   system.debug('VALORE MAGGIORE');
                                   bonusDeleghe = true;
                               }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c ){
                                   system.debug('VALORE MINORE');
                                   bonusDeleghe = false;
                               }
                           }
                    }
                }
            }
        }else if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoGaranziaValoreSconto' && qlix.API_NomeProdotto__c == 'Bonus garanzia'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    system.debug('BONUS GARANZIA');
                    if((deleghe.API_Profilo__c == String.valueOf(profile.name) || roleName.contains(deleghe.API_Profilo__c) )
                       && deleghe.API_PacchettoScelto__c == 'Bonus garanzia'){
                           if(decimal.valueof(qlix.API_Valore__c ) > deleghe.API_ValoreSconto__c){
                               BonusGaranzia = true;
                               system.debug('SONO NEL TRUE E IL VALORE NUOVO e: ' +quote.API_ScontoBaseDelegheValoreNEW__c);
                               system.debug('VALORE DI DELEGA: ' +deleghe.API_ValoreSconto__c);
                               system.debug('BONUS GARANZIA: '+BonusGaranzia);
                           }else{
                               BonusGaranzia = false;
                               system.debug('BONUS GARANZIA: '+BonusGaranzia);
                               system.debug('SONO NEL FALSE E IL VALORE NUOVO e: ' +quote.API_ScontoBaseDelegheValoreNEW__c);
                               system.debug('VALORE DI DELEGA: ' +deleghe.API_ValoreSconto__c);
                           }
                       }
                }
            }
        }else if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_sito_rete_Prodotti' && qlix.API_NomeProdotto__c == 'Sconto Site/Rete'){
            for(API_DeleghePacchetto__mdt deleghe : delegheList){
                if(quote.API_ScontoBaseDelegheValoreNEW__c != null){
                    if(deleghe.API_Profilo__c == String.valueOf(profile.name) && deleghe.API_PacchettoScelto__c == 'Sconto site' && qlix.API_Valore__c.contains('04')){
                        if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                            ScontoSiteReteDeleghe = true;
                        }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                            ScontoSiteReteDeleghe = false;
                        }
                    }else if(deleghe.API_Profilo__c == String.valueOf(profile.name) && deleghe.API_PacchettoScelto__c == 'Sconto site' && (!qlix.API_Valore__c.contains('04'))){
                                 ScontoSiteReteDeleghe = true;
                             }else if(roleName.contains(deleghe.API_Profilo__c) && deleghe.API_PacchettoScelto__c == 'Sconto site'){
                                 if( deleghe.API_PacchettoScelto__c == 'Sconto site' && deleghe.DeveloperName.contains('GPL') && qlix.API_Valore__c.contains('04')){
                                     if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                         ScontoSiteReteDeleghe = true;
                                     }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                         ScontoSiteReteDeleghe = false;
                                     }
                                 }else if( deleghe.API_PacchettoScelto__c == 'Sconto site' && (!deleghe.DeveloperName.contains('GPL')) && (!qlix.API_Valore__c.contains('04'))){
                                     if(quote.API_ScontoBaseDelegheValoreNEW__c > deleghe.API_ValoreSconto__c){
                                         ScontoSiteReteDeleghe = true;
                                     }else if(quote.API_ScontoBaseDelegheValoreNEW__c <= deleghe.API_ValoreSconto__c){
                                         ScontoSiteReteDeleghe = false;
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
        
        system.debug('SCONTO BASE DELEGHE VALORE: ' +ScontoBaseDelegheValore);
        system.debug('SCONTO PACCHETTO: ' +scontoPacchetto);
        system.debug('SCONTO PEDAGGIO: ' +scontoPedaggio);
        system.debug('SCONTO COMMISSIONE: ' +delegaCommissione);
        system.debug('SCONTO BASE DELEGHE: ' +ScontoBaseDeleghe);
        
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
        
        quote.API_ScontoPacchetto__c = scontoPacchetto;
        quote.API_CommissionePedaggio__c = scontoPedaggio;
        quote.API_DelegaCommissione__c = delegaCommissione;
        quote.API_ScontoBaseDeleghe__c = ScontoBaseDeleghe;
        quote.API_BonusDeleghe__c = bonusDeleghe;
        quote.API_BonusGaranzia__c = BonusGaranzia;
        quote.API_ScontoBaseDelegheValoreNEW__c = ScontoBaseDelegheValore;
        quote.API_TipoBonus__c = TipoBonus;
        quote.API_ScontoSiteReteDeleghe__c = ScontoSiteReteDeleghe;
        
        return quote;
    }
    
    //Metodo utilizzato per recuperare tutti i QuoteLineItemX associati ad un QuoteLineItem
    @AuraEnabled
    public static List<API_QuoteLineItemX__c> getAttributeList(List<String> qliIds){
        return [select Id, Name,  API_QuoteLineItem__c, API_NomeProdotto__c, API_NomeAttributo__c, API_Valore__c  from API_QuoteLineItemX__c where API_QuoteLineItem__c in: qliIds];
    }
    
    // metodo utilizzato per recuperare tutti i quoteLineItems di una Quote
    @AuraEnabled
    public static List<QuoteLineItem> getQuoteLineItems(String quoteId){
        return [select Id, QuoteId, PricebookEntryId,   Product2Id, Product2.Name, Product2.API_ProdottoLabel__c, API_GeneratoDaContrattoQuadro__c   from QuoteLineItem where QuoteId=: quoteId];
    }
    
    //metodo utilizzato per recuperare le offerte disponibili
    @AuraEnabled
    public static List<String> getOfferte(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Quote.API_Offerta__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    //metodo utilizzato per recuperare l'offerta selezionata
    @AuraEnabled
    public static String getOffertaSelezionata(Id quoteId){
        List<Quote> listQ=[select Id, API_Offerta__c from Quote where id=: quoteId];
        if(listQ.size()>0){
            return listQ[0].API_Offerta__c;
        }
        return null;
    }
    
    //metodo utilizzato per recuperare lla quote
    @AuraEnabled
    public static Quote getQuote(Id quoteId){
        List<Quote> listQ=[select Id, API_Offerta__c,  API_Pacchetto__c from Quote where id=: quoteId];
        if(listQ.size()>0){
            return listQ[0];
        }
        return null;
    }
    
    //metodo utilizzato salvare una Quote
    @AuraEnabled
    public static void saveQuote(Quote quote){
        update quote;
    }
    
    //metodo utilizzato per recuperare le offerte disponibili
    @AuraEnabled
    public static List<String> getPacchetti(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Quote.API_Pacchetto__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static Integer deleteQuoteLineItem(String quoteLineItemId){
        Integer response = editQuoteLineItem(quoteLineItemId);
        if(response == 1){
            system.debug('quoteLineItemId: '+quoteLineItemId);
            List<API_QuoteLineItemX__c> qliXList = [select Id from API_QuoteLineItemX__c where API_QuoteLineItem__c =: quoteLineItemId];
            system.debug('qliXList: '+qliXList);
            delete qliXList;
            system.debug('qliXListafter: '+qliXList);
            List<QuoteLineItem > qliList = [select id from QuoteLineItem  where id =: quoteLineItemId];
            system.debug('qliList: '+qliList);
            delete qliList;
            system.debug('qliListafter: '+qliList);
            response = 1;
        }
        
        return response;
    }
    
    @AuraEnabled
    public static Integer editQuoteLineItem(String quoteLineItemId){
       system.debug('QUOTELINEITEM ID: '+quoteLineItemId);
        QuoteLineItem quoteLI = [select quoteId, quote.Status from QuoteLineItem where id =:quoteLineItemId][0];
        Integer response;
        if(quoteLI.quote.Status == 'Bozza')
            response = 1;
        else
            response = 0;
        
        return response;
    }
    
    @AuraEnabled
    public static String updateDeveloperName(String idQLI){
        String resp = [select Product2.Name from QuoteLineItem where id =:idQLI].Product2.Name;
        return resp;
    }
}