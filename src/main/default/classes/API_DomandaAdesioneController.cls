public with sharing class API_DomandaAdesioneController {
    
    public wrapperObject objWRP {get; set;}
    
    public String ragione {get; set;}
    public String offerta {get; set;}
    public String nazionale {get; set;}
    public String fonte {get; set;}
    public String bonus {get; set;}
    public String quoteID {get; set;}
    public List<Integer> listCl {get; set;}
    public List<String> mapValue{get; set;}
    
    public API_DomandaAdesioneController(ApexPages.StandardController controller) {
        
        offerta = System.currentPagereference().getParameters().get('offerta');  
        system.debug('offerta'+offerta);
        nazionale = System.currentPagereference().getParameters().get('nazionale'); 
        fonte = System.currentPagereference().getParameters().get('fonte');
        system.debug('nazionale'+nazionale);
        system.debug('fonte'+fonte);
        bonus = System.currentPagereference().getParameters().get('bonus'); 
        system.debug('bonus'+bonus);
        objWRP = new wrapperObject();
        Map<String,List<String>> mapAttributi =  new Map<String,List<String>>(); 
        Map<Id,Map<String,String>> mapQLIX = new Map<Id,Map<String,String>>(); 
        ID quoteID = controller.getRecord().Id;
        String paese;
        String pedaggioValore;
        String pedaggioValoreItalia;
        String pedaggioValoreInteroperabile;
        List<wrapperContoCarte> contocarteListWrapper = new List<wrapperContoCarte>();
        List<wrapperCarte> carteListWrapper = new List<wrapperCarte>();
        List<wrapperInternazionale> listInternazionale = new List<wrapperInternazionale>();
        objWRP.API_quoteinWrap = quoteID;
        objWRP.numeroRipetizioni = 5;
        List<String> valueMap = new List<String>();
        List<String> scontoBaseValueList = new List<String>(); 
        List<String> retiPartnerValueList = new List<String>(); 
        List<String> canoneValueList = new List<String>();
        List<String> bonusValueList = new List<String>(); 
        List<String> scontoPacchettoValueList = new List<String>(); 
        List<String> scontoSiteReteValueList = new List<String>(); 
        List<String> bonusGaranziaList = new List<String>(); 
        List<String> commissioneValoreList = new List<String>();
        List<String> pedaggioValoreList = new List<String>(); 
        List<String> pedaggioValoreListInteroperabile = new List<String>(); 
        List<String> qlistValueofMap = new List<String>();
        if(quoteID!=null){
            Quote q = [select Id, AccountId,  API_PrevisionePedaggi__c, API_PrevisioneConsumi__c, API_Tipo_fido__c, 
                       API_CondizioniDiPagamentoFormula__c, API_Periodo_di_spendibilita_picklist__c, API_TipoGaranzia__c, API_Garanzia__c, 
                       API_ImportoGaranzia__c, API_Internazionale__c, API_Pacchetto__c, 
                       API_Offerta__c, API_Contratto_quadro__c, API_ContaProdotti__c, API_GenerataDaContrattoQuadro__c, 
                       Account.API_Iban__c, API_CodiceFiscaleFirmatarioSepa__c, Description,
                       API_RiferimentoMandato__c, API_NomeSottoscrittore__c, 
                       API_NomeEffettivoDebitore__c, API_CodiceIdentificativoEffettivoDebitor__c, 
                       API_SplitFattureDivisioneVERO__c, Account.Banca_del_debitore__c,
                       API_Fatturazione__c, API_Plafond_Calcolato__c, API_Plafond_da_richiedere__c, 
                       Account.API_ABI__c, Account.API_CIN__c, Account.API_CAB__c, Account.SEPA_Direct_Debit_SDD__c,
                       API_Listino__c, API_CostoAffidamentoPersonalizzato__c, 
                       API_ValoreCostoAffidamento__c,  API_PacchettoEreditato__c, 
                       API_OffertaEreditata__c, API_CounterCarte__c, Account.name, Account.BillingStreet, 
                       Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                       Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, 
                       Account.ShippingCountry, Account.API_RagioneSociale__c, Account.API_Telefono__c, 
                       Account.API_CodiceFiscale__c, Account.API_Iva__c, Account.fax, Account.CreatedDate, Account.API_EmailPec__c,
                       Account.API_Tipo_Attivita__c,Account.Data_Inizio_Attivit__c,Account.API_Codice_SDI__c,
                       Account.API_AutorizzInvioMatProm__c,Account.API_FaxInterno__c,Account.Phone,
                       Account.API_AutorizzProfilazione__c, Account.API_EmailCMOnline__c, API_DataSottoscrizioneContratto__c,API_Lugo_sottoscrizione__c,
                       Account.API_Agenzia__c, Account.API_Telefono_banca__c, Account.API_Email_Portale_Sicurezza__c, Owner.name, OwnerId, owner.Profile.Name,
                       Account.API_CodiceCliente__c, Account.API_FormaGiuridica__c, Account.API_CounterDivisioni__c,
                       Account.API_CodiceCIG__c, Account.API_DataInizioValiditaCIG__c, Account.API_EsenteCIG__c, Account.API_CodiceCUU__c,
                       Account.API_Cup__c, Account.API_Numero_ordine__c, Account.API_Determina_di_Spesa__c, Account.API_SplitPubblicaAmministrazione__c,
                       Account.API_SoggettoTracciabilita__c, Account.API_SocietaPartecipata__c, Account.API_TipoPINDema__c, Account.API_Visualizza_PIN__c, API_Paga_PIN_cartaceo__c
                       from quote
                       where id =: quoteID LIMIT 1];
            
            List<Contact> contactQuote = [select Id, Name, Phone, API_TipoContatto__c, AccountId,API_Codice_fiscaleReferente__c  from Contact 
                                          where AccountId =: q.AccountId];
            
            List<API_ContoCarte__c > contocarteQuote = [select Id, API_Quote__c, Name, API_ProdottiAmmessi__c,
                                                        API_ServiziInStazione__c, API_TipoPIN__c, API_TipoOperat__c, API_TipologiaVeicoli__c,
                                                        API_TipoCarta__c, API_Citta__c, API_Via__c, API_Nazione__c, API_Provincia__c, API_Cap__c,
                                                        API_RiferimentoDivisione__r.API_Descrizione__c, API_RiferimentoDivisione__r.Name 
                                                        from API_ContoCarte__c where API_Quote__c=:quoteID];
            List<API_Carta__c > carteQuote = [select Id,API_Quote__c, API_ContoCarte__r.Name,  API_Parco_mezzi__r.Name, API_ProdottiAutorizzati__c, API_ProdottiServiziInStazione__c,
                                              API_Numero_di_targa__c, API_InformazioniAggiuntive__c, API_TipoPin__c, API_ServiziStazione__c, API_TipoVeicolo__c, API_Rete__c,
                                              API_Numero_di_PIN_Autista__c, API_Tipo_Operazione__c
                                              from API_Carta__c where API_Quote__c=:quoteID];
            
            /*List<API_QuoteLineItemX__c > QLIX = [select API_NomeAttributo__c,API_QuoteLineItem__c,API_QuoteLineItem__r.QuoteId,API_QuoteLineItem__r.Product2.Name, 
API_Valore__c, API_NomeProdotto__c from API_QuoteLineItemX__c  
where /*API_QuoteLineItem__r.Product2.Name='Sconto internazionale' 
AND*/ /*API_QuoteLineItem__r.QuoteId =:quoteID ];*/
            List<Iva_stati__mdt> ivaStati = [select Id,API_Stato__c, API_IVA__c from Iva_stati__mdt];
            
            List<API_QuoteLineItemX__c > QLIX = [select Id, API_QuoteLineItem__c, API_NomeProdotto__c, API_NomeAttributo__c, API_Valore__c, API_DeveloperNameMetadata__c
                                                 from API_QuoteLineItemX__c
                                                 where API_QuoteLineItem__r.QuoteId =:quoteID]; 
            
            Map<String, List<API_QuoteLineItemX__c>> reteMap = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> bonusMap = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> garanziaMap = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> SitoMap = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> commissioneMap = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> canoneWEB = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> pedaggiMap = new Map<String, List<API_QuoteLineItemX__c>>();
            Map<String, List<API_QuoteLineItemX__c>> partnerMap = new Map<String, List<API_QuoteLineItemX__c>>();
            
            //INSERISCO RETI PARTNER NELLA MAPPA DA MOSTRARE IN PAGINA
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Reti partner prezzo pompa'){
                    if(partnerMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = partnerMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        partnerMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        partnerMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetPartner = partnerMap.keySet();
            for(String key : keySetPartner){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = partnerMap.get(key);
                API_QuoteLineItemX__c reti = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c prodotti = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_RetiPartnerReti'){
                        reti = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_RetiPartnerProdotti'){
                        prodotti = old;
                    }
                }
                newQLIX.add(reti);
                newQLIX.add(prodotti);
                partnerMap.put(key, newQLIX);
            }
            objWRP.partnerMap = partnerMap;
            
            //INSERISCO PEDAGGI TELEPASS NELLA MAPPA DA MOSTRARE IN PAGINA
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Pedaggi'){
                    if(pedaggiMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = pedaggiMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        pedaggiMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        pedaggiMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetPedaggi = pedaggiMap.keySet();
            for(String key : keySetPedaggi){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = pedaggiMap.get(key);
                API_QuoteLineItemX__c tipo = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_PedaggioTipo'){
                        tipo = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_PedaggioCommissionePercentuale'){
                        valore = old;
                    }
                }
                newQLIX.add(tipo);
                newQLIX.add(valore);
                pedaggiMap.put(key, newQLIX);
            }
            objWRP.pedaggiMap = pedaggiMap;
            
            //INSERISCO COMMISSIONE IP MATIC NELLA MAPPA DA MOSTRARE IN PAGINA
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Commissione IP Matic'){
                    if(commissioneMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = commissioneMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        commissioneMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        commissioneMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetCommissione = commissioneMap.keySet();
            for(String key : keySetCommissione){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = commissioneMap.get(key);
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c prodotti = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c inizio = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c fine = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_CommissioneValore'){
                        valore = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_CommissioneProdotti'){
                        prodotti = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_CommissioneDataInizio'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        inizio = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_CommissioneDataFine'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        fine = old;
                    }
                }
                newQLIX.add(valore);
                newQLIX.add(prodotti);
                newQLIX.add(inizio);
                newQLIX.add(fine);
                commissioneMap.put(key, newQLIX);
            }
            objWRP.commissioneMap = commissioneMap;
            
            //INSERISCO BONUS GARANZIA NELLA MAPPA DA MOSTRARE IN PAGINA
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Bonus Garanzia'){
                    if(garanziaMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = garanziaMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        garanziaMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        garanziaMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetGaranzia = garanziaMap.keySet();
            for(String key : keySetGaranzia){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = garanziaMap.get(key);
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoGaranziaValoreSconto'){
                        valore = old;
                    }
                }
                valore = valore;
                newQLIX.add(valore);
                
                garanziaMap.put(key, newQLIX);
            }
            objWRP.garanziaMap = garanziaMap;
            
            //INSERISCO TUTTI I BONUS NELLA MAPPA DA MOSTRARE IN PAGINA
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Bonus'){
                    if(bonusMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = bonusMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        bonusMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        bonusMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySet = bonusMap.keySet();
            for(String key : keySet){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = bonusMap.get(key);
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c tipo = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c inizio = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c fine = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c volume = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c periodicita = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c sito = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c prodotti = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusValore'){
                        valore = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'Api_BonusTipo'){
                        tipo = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusDataInizioValidita'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        inizio = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusDataFineValidita'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        fine = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusVolume'){
                        volume = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusPeriodicita'){
                        periodicita = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusSitoRete'){
                        sito = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_BonusProdotti'){
                        prodotti = old;
                    }
                }
                newQLIX.add(valore);
                newQLIX.add(tipo);
                newQLIX.add(inizio);
                newQLIX.add(fine);
                newQLIX.add(volume);
                newQLIX.add(periodicita);
                newQLIX.add(sito);
                newQLIX.add(prodotti);
                bonusMap.put(key, newQLIX);
            }
            system.debug('BONUS MAP: '+bonusMap);
            objWRP.bonusMap = bonusMap;
            
            //INSERISCO TUTTI GLI SCONTI BASE IN MAPPA PER MOSTRARLI IN PAGINA 
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Sconto base'){
                    if(SitoMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = SitoMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        SitoMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        SitoMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetBase = SitoMap.keySet();
            for(String key : keySetBase){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = SitoMap.get(key);
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c prodotti = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c inizio = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c fine = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_Sconto_base_ValoreSconto'){
                        valore = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_Sconto_base_Prodotti'){
                        prodotti = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_Sconto_base_DataInizio'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        inizio = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_Sconto_base_DataFine'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        fine = old;
                    }
                }
                newQLIX.add(valore);
                newQLIX.add(prodotti);
                newQLIX.add(inizio);
                newQLIX.add(fine);
                SitoMap.put(key, newQLIX);
            }
            //system.debug('BONUS MAP: '+bonusMap);
            //objWRP.bonusMap = bonusMap;
            objWRP.SitoMap = SitoMap;
            
            //INSERISCO TUTTI GLI SCONTI SITE/RETE IN MAPPA PER MOSTRARLI IN PAGINA 
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Sconto Site/Rete'){
                    if(reteMap.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = reteMap.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        reteMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        reteMap.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetRete = reteMap.keySet();
            for(String key : keySetRete){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = reteMap.get(key);
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c prodotti = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c codice = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c tipo = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteTipo'){
                        tipo = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteCodice'){
                        codice = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteValoreSconto'){
                        valore = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_Sconto_sito_rete_Prodotti'){
                        prodotti = old;
                    }
                }
                newQLIX.add(tipo);
                newQLIX.add(codice);
                newQLIX.add(valore);
                newQLIX.add(prodotti);
                reteMap.put(key, newQLIX);
            }
            //system.debug('BONUS MAP: '+bonusMap);
            //objWRP.bonusMap = bonusMap;
            objWRP.reteMap = reteMap;

            //INSERISCO TUTTI GLI SCONTI CANONE UTENZA WEB IN MAPPA PER MOSTRARLI IN PAGINA 
            for(API_QuoteLineItemX__c qlixbonus :QLIX){
                if(qlixbonus.API_NomeProdotto__c == 'Sconto Pacchetto'){
                    if(canoneWEB.containsKey(qlixbonus.API_QuoteLineItem__c)){
                        List<API_QuoteLineItemX__c> mapList = canoneWEB.get(qlixbonus.API_QuoteLineItem__c);
                        maplist.add(qlixbonus);
                        canoneWEB.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }else{
                        List<API_QuoteLineItemX__c> mapList = new List<API_QuoteLineItemX__c>();
                        maplist.add(qlixbonus);
                        canoneWEB.put(qlixbonus.API_QuoteLineItem__c, mapList);
                    }
                }
            }
            Set<String> keySetCanone = canoneWEB.keySet();
            for(String key : keySetCanone){
                List<API_QuoteLineItemX__c> newQLIX = new List<API_QuoteLineItemX__c>();
                List<API_QuoteLineItemX__c> oldQLIX = canoneWEB.get(key);
                API_QuoteLineItemX__c valore = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c inizio = new API_QuoteLineItemX__c();
                API_QuoteLineItemX__c fine = new API_QuoteLineItemX__c();
                for(API_QuoteLineItemX__c old : oldQLIX){
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoPacchettoValoreSconto'){
                        valore = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoPack_dataInizio'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        inizio = old;
                    }
                    if(old.API_DeveloperNameMetadata__c == 'API_ScontoPack_dataFine'){
                        String API_dataCont = String.valueOf(old.API_Valore__c);
                        API_dataCont = API_dataCont.substring(0,10);
                        String anno = API_dataCont.substring(0,4);
                        String mese = API_dataCont.substring(4,8);
                        String giorno = API_dataCont.substring(8,10);
                        String data = giorno+mese+anno; 
                        old.API_Valore__c = data;
                        fine = old;
                    }
                }
                newQLIX.add(valore);
                newQLIX.add(inizio);
                newQLIX.add(fine);
                canoneWEB.put(key, newQLIX);
            }
            objWRP.canoneWEB = canoneWEB;
            system.debug('CANONEWEB: '+canoneWEB);

            for(API_QuoteLineItemX__c qlixvalue:QLIX){
                List<String> qlistValue =  mapAttributi.get(qlixvalue.API_NomeAttributo__c);
                system.debug('qlistValue da verificare' + qlistValue);
                system.debug('valore da capire' +qlixvalue.API_NomeAttributo__c);
                system.debug('valore da capire della mappa' +mapAttributi.get(qlixvalue.API_NomeAttributo__c));
                if(qlistValue != null){
                    if(qlixvalue.API_Valore__c==null)
                        qlixvalue.API_Valore__c=' ';
                    qlistValue.add(qlixvalue.API_Valore__c);
                    mapAttributi.put(qlixvalue.API_NomeAttributo__c, qlistValue);
                    system.debug('nomeattibuto diverso da null' + qlixvalue.API_NomeAttributo__c);
                    system.debug('valoreattibuto diverso da null' + qlistValue);
                }else if(qlistValue == null){
                    qlistValue = new List<String>();
                    if(qlixvalue.API_Valore__c==null)
                        qlixvalue.API_Valore__c=' ';
                    qlistValue.add(qlixvalue.API_Valore__c);
                    mapAttributi.put(qlixvalue.API_NomeAttributo__c,qlistValue);
                    system.debug('nomeattibuto uguale a null' +qlixvalue.API_NomeAttributo__c);
                    system.debug('valoreattibuto uguale a null' + qlistValue);
                }
                If(qlixvalue.API_DeveloperNameMetadata__c == 'API_RetiPartnerReti' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        retiPartnerValueList.add(qlixvalue.API_Valore__c);
                    }
                }
                If(qlixvalue.API_DeveloperNameMetadata__c == 'API_Sconto_base_ValoreSconto' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        scontoBaseValueList.add(qlixvalue.API_Valore__c);
                    }
                }If(qlixvalue.API_DeveloperNameMetadata__c == 'API_ScontoPacchettoValoreSconto' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        canoneValueList.add(qlixvalue.API_Valore__c);
                    }
                }else If(qlixvalue.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteValoreSconto' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        scontoSiteReteValueList.add(qlixvalue.API_Valore__c);
                    }
                }else If(qlixvalue.API_DeveloperNameMetadata__c == 'API_BonusValore' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        system.debug('@@@BONUS PRESENTE');
                        bonusValueList.add(qlixvalue.API_Valore__c);
                    }
                }else If(qlixvalue.API_DeveloperNameMetadata__c == 'API_ScontoGaranziaValoreSconto' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        bonusGaranziaList.add(String.valueOf(Decimal.valueOf(qlixvalue.API_Valore__c)*12));
                    }
                }else If(qlixvalue.API_DeveloperNameMetadata__c == 'API_CommissioneValore' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){
                        commissioneValoreList.add(qlixvalue.API_Valore__c);
                    }
                }else If(qlixvalue.API_DeveloperNameMetadata__c == 'API_PedaggioCommissionePercentuale' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null){         
                        pedaggioValore = qlixvalue.API_Valore__c;
                    }
                }else if(qlixvalue.API_DeveloperNameMetadata__c == 'API_PedaggioTipo' && qlixvalue.API_DeveloperNameMetadata__c != null){
                    if(qlixvalue.API_Valore__c != null && qlixvalue.API_Valore__c != ''){         
                        paese = qlixvalue.API_Valore__c;
                    }
                }
                system.debug('PAESE: '+paese);
                system.debug('pedaggioValore: '+pedaggioValore  );
                if(paese == 'Italia' && pedaggioValore != null){
                    pedaggioValoreItalia = pedaggioValore;
                }else if(paese == 'Interoperabile' && pedaggioValore != null){
                    pedaggioValoreInteroperabile = pedaggioValore;
                }
            }
            system.debug('pedaggioValoreITALIA: '+pedaggioValoreItalia  );
            system.debug('pedaggioValoreINTEROPERABILE: '+pedaggioValoreInteroperabile  );
            objWRP.scontoBaseValueList = scontoBaseValueList;
            objWRP.retiPartnerValueList = retiPartnerValueList;
            objWRP.canoneValueList = canoneValueList;
            objWRP.scontoSiteReteValueList = scontoSiteReteValueList;
            objWRP.bonusValueList = bonusValueList;
            objWRP.bonusGaranziaList = bonusGaranziaList;
            objWRP.commissioneValoreList = commissioneValoreList;
            objWRP.pedaggioValoreItalia = pedaggioValoreItalia;
            objWRP.pedaggioValoreInteroperabile = pedaggioValoreInteroperabile;
            //objWRP.pedaggioValoreList = pedaggioValoreList;
            system.debug('COMMERCIALE: '+objWRP.API_Commerciale);
            if(q.owner.Profile.Name == 'AgentiPartnerCommunity'){
                User u = [select Manager.Name from user where id =: q.OwnerId];
              objWRP.API_Agente = q.Owner.name;
                objWRP.API_Commerciale = u.Manager.name;
                system.debug('SONO DELL if');
            }else{
                objWRP.API_Commerciale = q.owner.name;
            }            
            objWRP.API_codiceCliente = q.Account.API_codiceCliente__c;
            
            if(!mapAttributi.isEmpty()){
                system.debug('mappa da cercare' +mapQLIX);
                wrapperInternazionale objInter = new wrapperInternazionale();
                Set<String> setKey = new Set<String>();
                system.debug('mappa attributi' +mapAttributi);
                
                setKey = mapAttributi.keySet();
                //mapValue = new List<String>();
                for(String keyofMap:setKey){
                    mapValue = mapAttributi.get(keyofMap);
                }
                system.debug('set di chiavi mapValue' +mapValue);
                objWRP.mappList = mapValue;
                List<Integer> listInteger = new List<Integer>();
                Integer intC = mapValue.size();
                Integer i;
                listInteger.add(0);
                for(i=1;i<(intC);i++){
                    if(listInteger!=null)
                        listInteger.add(i);
                    
                }
                listCl=listInteger;
                system.debug('indice per ciclare' +listCl);
                system.debug('set di chiavi' +setKey);
                List<String> setValueOfMap= new List<String>();
            }
            
            
            for(Contact contattiAccount:contactQuote){
                if(contattiAccount.API_TipoContatto__c=='Principale'){
                    //objWRP.API_NameReferente = contattiAccount.Name;
                    objWRP.API_TelefonoReferente = contattiAccount.Phone;
                }
                if(contattiAccount.API_TipoContatto__c=='Debitore'){
                    objWRP.API_NameDebitore = contattiAccount.Name;
                    objWRP.API_TelefonoDebitore = contattiAccount.Phone;
                    //objWRP.API_CodFiscaleDeb =contattiAccount.API_Codice_fiscaleReferente__c;
                }
            }
            for(API_ContoCarte__c contoCar:contocarteQuote){
                wrapperContoCarte objContoCarte = new wrapperContoCarte();
                objContoCarte.API_CarteName = contoCar.Name;
                objContoCarte.API_DivisioneCarte = contoCar.API_RiferimentoDivisione__r.Name;
                objContoCarte.API_ProdottiAmmessi = contoCar.API_ProdottiAmmessi__c;
                objContoCarte.API_ServiziInStazione = contoCar.API_ServiziInStazione__c;
                objContoCarte.API_TipoPIN = contoCar.API_TipoPIN__c;
                objContoCarte.API_TipoOperat = contoCar.API_TipoOperat__c;
                objContoCarte.API_TipologiaVeicoli = contoCar.API_TipologiaVeicoli__c;
                objContoCarte.API_TipoCarta = contoCar.API_TipoCarta__c;
                objContoCarte.API_ViaCarta = contoCar.API_Via__c;
                objContoCarte.API_Citta = contoCar.API_Citta__c;
                objContoCarte.API_Provincia = contoCar.API_Provincia__c;
                objContoCarte.API_Nazione = contoCar.API_Nazione__c;
                objContoCarte.API_DivisioneName = contoCar.API_RiferimentoDivisione__r.Name;
                objContoCarte.API_DivisioneDescrizione = contoCar.API_RiferimentoDivisione__r.API_Descrizione__c;
                
                contocarteListWrapper.add(objContoCarte);
                system.debug('OGGETTO WRAPPER contocarte: ' +contocarteListWrapper);
            }

            for(API_Carta__c carQuote:carteQuote){
                system.debug('sono nel ciclo for con carQuote' +carQuote);
                wrapperCarte objCarte = new wrapperCarte();
                objCarte.API_NomeContoCarte = carQuote.API_ContoCarte__r.Name;
                objCarte.API_ParcoMezziCarte = carQuote.API_Parco_mezzi__r.Name;
                objCarte.API_ProdottiAutorizzati = carQuote.API_ProdottiAutorizzati__c;
                objCarte.API_ProdottiServiziInStazione = carQuote.API_ProdottiServiziInStazione__c;
                objCarte.API_TipoPin = carQuote.API_TipoPin__c;
                objCarte.API_Numero_di_targa = carQuote.API_Numero_di_targa__c;
                objCarte.API_InformazioniAggiuntive = carQuote.API_InformazioniAggiuntive__c;
                
                if(carQuote.API_TipoVeicolo__c == '1' || carQuote.API_TipoVeicolo__c =='Auto (200€)'){                    objCarte.API_TipoVeicolo = 'Auto (200€)';
                }else if(carQuote.API_TipoVeicolo__c == '2' || carQuote.API_TipoVeicolo__c =='Furgone (650€)'){                    objCarte.API_TipoVeicolo = 'Furgone (650€)';
                }else if(carQuote.API_TipoVeicolo__c == '3' || carQuote.API_TipoVeicolo__c == 'Doppio serbatoio (1.800 €)'){                    objCarte.API_TipoVeicolo = 'Doppio serbatoio (1.800 €)';
                }else if(carQuote.API_TipoVeicolo__c == '4' || carQuote.API_TipoVeicolo__c =='Camion/Bus (1.300 €)'){                    objCarte.API_TipoVeicolo = 'Camion/Bus (1.300 €)';
                }else if(carQuote.API_TipoVeicolo__c == '9' || carQuote.API_TipoVeicolo__c =='Tutti i veicoli (200 €)'){                    objCarte.API_TipoVeicolo = 'Tutti i veicoli (200 €)';
                }else if(carQuote.API_TipoVeicolo__c == '5' ||carQuote.API_TipoVeicolo__c =='Motocicli (50 €)'){                    objCarte.API_TipoVeicolo = 'Motocicli (50 €)';
                }
                objCarte.API_ServiziStazione = carQuote.API_ServiziStazione__c;
                objCarte.API_Rete = carQuote.API_Rete__c;
                objCarte.API_Numero_di_PIN_Autista = carQuote.API_Numero_di_PIN_Autista__c;
                objCarte.API_Tipo_Operazione = carQuote.API_Tipo_Operazione__c;
                carteListWrapper.add(objCarte);
                system.debug('OGGETTO WRAPPER carte: ' +carteListWrapper);
            }
            objWRP.carteBoolean = true;
            
            objWRP.contocarteList = contocarteListWrapper;
            objWRP.carteList = carteListWrapper;
            objWRP.internazionaleWrapperList = mapAttributi;
            objWRP.API_DilazionePagamento = q.API_CondizioniDiPagamentoFormula__c;
            objWRP.API_NumeroDivisioni = q.Account.API_CounterDivisioni__c;
            if(objWRP.API_NumeroDivisioni > 0){
                objWRP.API_countDivisioni = true;
            }else {
                objWRP.API_countDivisioni = false;
            }
            objWRP.API_CodFiscaleDeb = q.API_CodiceFiscaleFirmatarioSepa__c;
            objWRP.API_Luogo_sottoscrizione=q.API_Lugo_sottoscrizione__c;
            objWRP.API_NomeSottoscrittore = q.API_NomeSottoscrittore__c;
            objWRP.API_FormaGiuridica = q.Account.API_FormaGiuridica__c;
            objWRP.API_NameReferente = q.API_NomeEffettivoDebitore__c;
            objWRP.API_NameDebitore=q.API_NomeSottoscrittore__c;
            system.debug('DATA CONTRATTO: ' +q.API_DataSottoscrizioneContratto__c);
            String API_dataCont = String.valueOf(q.API_DataSottoscrizioneContratto__c);
            API_dataCont = API_dataCont.substring(0,10);
            String anno = API_dataCont.substring(0,4);
            String mese = API_dataCont.substring(4,8);
            String giorno = API_dataCont.substring(8,10);
            String data = giorno+mese+anno; 
            objWRP.API_dataCont = data;
            objWRP.API_EmailCM = q.Account.API_EmailCMOnline__c;
            objWRP.Name = q.Account.name;
            objWRP.BillingStreet = q.Account.BillingStreet;
            objWRP.BillingCity = q.Account.BillingCity;
            objWRP.API_Telefono = q.Account.Phone;
            objWRP.API_TelefonoOperat = q.Account.API_Telefono__c;
            objWRP.BillingPostalCode = q.Account.BillingPostalCode;
            objWRP.BillingState = q.Account.BillingState;
            objWRP.API_Fax = q.Account.Fax;
            objWRP.API_SEPA = q.Account.SEPA_Direct_Debit_SDD__c;
            objWRP.API_FaxInterno =q.Account.API_FaxInterno__c;
            String dateAttivita = String.valueOfGmt(q.Account.CreatedDate);
            objWRP.API_EmailPec = q.Account.API_EmailPec__c;
            objWRP.API_Iva = q.Account.API_Iva__c;
            objWRP.API_Banca_del_debitore = q.Account.Banca_del_debitore__c;
            objWRP.API_Telefono_banca = q.Account.API_Telefono_banca__c;
            objWRP.API_Agenzia = q.Account.API_Agenzia__c;
            objWRP.API_CodiceFiscale = q.Account.API_CodiceFiscale__c;  
            objWRP.API_Codice_SDI = q.Account.API_Codice_SDI__c;
            objWRP.API_CodiceCIG = q.Account.API_CodiceCIG__c;
            objWRP.API_DataInizioValiditaCIG = String.valueOf(q.Account.API_DataInizioValiditaCIG__c);
            objWRP.API_EsenteCIG = q.Account.API_EsenteCIG__c;
            objWRP.API_CodiceCUU = q.Account.API_CodiceCUU__c;
            objWRP.API_Cup = q.Account.API_Cup__c;
            objWRP.API_Numero_ordine = q.Account.API_Numero_ordine__c;
            objWRP.API_Determina_di_Spesa = q.Account.API_Determina_di_Spesa__c;
            objWRP.API_SplitPubblicaAmministrazione = q.Account.API_SplitPubblicaAmministrazione__c;
            objWRP.API_SoggettoTracciabilita = q.Account.API_SoggettoTracciabilita__c;
            objWRP.API_SocietaPartecipata = q.Account.API_SocietaPartecipata__c;
            objWRP.ShippingStreet = q.Account.ShippingStreet;            
            objWRP.API_Offerta = q.API_Offerta__c;
            objWRP.ShippingCity = q.Account.ShippingCity;
            objWRP.ShippingPostalCode = q.Account.ShippingPostalCode;
            objWRP.ShippingState = q.Account.ShippingState;
            objWRP.API_Tipo_Attivita = q.Account.API_Tipo_Attivita__c;
            objWRP.API_TipoPINDema = q.Account.API_TipoPINDema__c;
            objWRP.API_Visualizza_PIN = q.Account.API_Visualizza_PIN__c;
            objWRP.API_Paga_PIN_cartaceo = q.API_Paga_PIN_cartaceo__c;
            
            if(q.Account.Data_Inizio_Attivit__c!=null){
                Datetime dt = datetime.newInstance(q.Account.Data_Inizio_Attivit__c.year(), q.Account.Data_Inizio_Attivit__c.month(),q.Account.Data_Inizio_Attivit__c.day());
                String dateStr =  dt.format('dd/MM/yyyy') ;
                objWRP.API_dataInizioAttivita = dateStr;
            }else{
                
                objWRP.API_dataInizioAttivita = '';
            }
            
            //objWRP.API_dataInizioAttivita = q.Account.Data_Inizio_Attivit__c.format();
            objWRP.API_Email_Portale_Sicurezza = q.Account.API_Email_Portale_Sicurezza__c;
            objWRP.API_PrevisionePedaggi = q.API_PrevisionePedaggi__c;
            objWRP.API_PrevisioneConsumi = q.API_PrevisioneConsumi__c;
            //objWRP.API_Trasporto = q.Account.API_Trasporto__c;
            //objWRP.API_FlottaAuto = q.Account.API_FlottaAuto__c;
            // objWRP.API_AltreAttivita = q.Account.API_AltreAttivita__c;
            objWRP.API_AutorizzInvioMatProm = q.Account.API_AutorizzInvioMatProm__c;
            objWRP.API_AutorizzProfilazione = q.Account.API_AutorizzProfilazione__c;            
            objWRP.API_Iban = q.Account.API_Iban__c;  
            objWRP.Description = q.Description;           
            objWRP.BillingCountry = q.Account.BillingCountry;
            objWRP.ShippingCountry = q.Account.ShippingCountry;
            objWRP.API_RagioneSociale = q.Account.Name;        
            objWRP.API_Pacchetto = q.API_Pacchetto__c;
            objWRP.API_SplitFattureDivisione = q.API_SplitFattureDivisioneVERO__c;
            objWRP.API_Internazionale = q.API_Internazionale__c;
            objWRP.API_PeriodoSpendibilita = String.valueOf(q.API_Periodo_di_spendibilita_picklist__c);
            objWRP.API_TipoGaranzia = q.API_TipoGaranzia__c; 
            objWRP.API_ImportoGaranzia = q.API_ImportoGaranzia__c;
            if(objWRP.API_SEPA == 'Business to Business')                objWRP.API_checkB2B = true;
            else
                objWRP.API_checkB2B = false;
            if(objWRP.API_SEPA == 'Core')                objWRP.API_checkCore = true;
            else
                objWRP.API_checkCore = false;
            
            if(objWRP.API_Tipo_Attivita == 'Conto terzi > 1000 m3/anno')                objWRP.API_contoterzimille = true;
            else
                objWRP.API_contoTerziMille = false;
            if(objWRP.API_Tipo_Attivita == 'Conto terzi tra 500 m3 e 1000 m3/anno')                objWRP.API_contoTerziMed = true;
            else
                objWRP.API_contoTerziMed = false;
            if(objWRP.API_Tipo_Attivita == 'Flotte Medie tra 50m3 e 300 m3/anno')                objWRP.API_flotMed = true;
            else
                objWRP.API_flotMed = false;
            if(objWRP.API_Tipo_Attivita == 'Conto terzi < 500 m3/anno')                objWRP.API_contoTerzicinq = true;
            else
                objWRP.API_contoTerzicinq = false;
            if(objWRP.API_Tipo_Attivita == 'Conto proprio oltre 300 m3/anno')                objWRP.API_contoMagTrec = true;
            else
                objWRP.API_contoMagTrec = false;
            if(objWRP.API_Tipo_Attivita == 'Conto proprio sino a 300 m3/anno')                objWRP.API_contoMinTrec = true;
            else
                objWRP.API_contoMinTrec = false;
            if(objWRP.API_Tipo_Attivita == 'Trasporto furgoni conto proprio')                objWRP.API_furgProp = true;
            else
                objWRP.API_furgProp = false;
            if(objWRP.API_Tipo_Attivita == 'Grandi flotte auto > 300 m3/anno')                objWRP.API_grandFlot = true;
            else
                objWRP.API_grandFlot = false;
            if(objWRP.API_Tipo_Attivita == 'Piccole flotte < 50 m3/anno')                objWRP.API_picFlot = true;
            else
                objWRP.API_picFlot = false;
            if(objWRP.API_Tipo_Attivita == 'PMI e artigiano < 4 carte')                objWRP.API_PMI= true;
            else
                objWRP.API_PMI = false;
            if(objWRP.API_Tipo_Attivita == 'Trasporto furgoni conto terzi')                objWRP.API_furgTerz= true;
            else
                objWRP.API_furgTerz = false;
            if(objWRP.API_Tipo_Attivita == 'Trasporto persone BUS')                objWRP.API_traspBUS= true;
            else
                objWRP.API_traspBUS = false;
            if(objWRP.API_Tipo_Attivita == 'Noleggiatori NTL e breve termine')                objWRP.API_NTL= true;
            else
                objWRP.API_NTL = false;
            if(objWRP.API_Tipo_Attivita == 'Amministrazione pubblica')                objWRP.API_pubAmmin= true;
            else
                objWRP.API_pubAmmin = false;
            if(objWRP.API_Tipo_Attivita == 'Trasporto furgoni artigianato')                objWRP.API_furgArtig= true;
            else
                objWRP.API_furgArtig = false;
            if(objWRP.API_Tipo_Attivita == 'Altro o non conosciuto')                objWRP.API_altro= true;
            else
                objWRP.API_altro = false;
            system.debug('@@FATTURAZIONE: '+objWRP.API_Fatturazione);
            if(q.API_Fatturazione__c =='15'){
                objWRP.API_Fatturazione15 = true;
                objWRP.API_Fatturazione30 = false;
            }else if(q.API_Fatturazione__c=='30'){
                objWRP.API_Fatturazione15 = false;
                objWRP.API_Fatturazione30 = true;
            }
             system.debug('@@FATTURAZIONE15: '+objWRP.API_Fatturazione15);
            system.debug('@@FATTURAZIONE30: '+objWRP.API_Fatturazione30);
            if(objWRP.API_Pacchetto == 'Base')
                objWRP.API_PacchettoBase = true;
            else
                objWRP.API_PacchettoBase = false;
            if(objWRP.API_Pacchetto == 'Extra')
                objWRP.API_PacchettoExtra = true;
            else
                objWRP.API_PacchettoExtra = false;
            if(objWRP.API_Pacchetto == 'Premium')
                objWRP.API_PacchettoPremium = true;
            else
                objWRP.API_PacchettoPremium = false;    
            
            system.debug('OGGETTO WRAPPER: ' +objWRP);
            
            
        }else{
            
            if(objWRP.carteList == null)
                objWRP.carteBoolean = false;
            
            objWRP.scontoBaseValueList = scontoBaseValueList;
            objWRP.retiPartnerValueList = retiPartnerValueList;
            objWRP.canoneValueList = canoneValueList;
            objWRP.scontoSiteReteValueList = scontoSiteReteValueList;
            objWRP.bonusValueList = bonusValueList;
            objWRP.bonusGaranziaList = bonusGaranziaList;
            objWRP.commissioneValoreList = commissioneValoreList;
            objWRP.pedaggioValoreItalia = '';
            objWRP.pedaggioValoreInteroperabile = '';
        }
        
    }
    public class wrapperInternazionale{
        
        public String API_InternazionaleName                               {get; set;}
        public String API_TipologiaPrezzo                                  {get; set;}
        public String API_TipoInternazionale                               {get; set;}
        public String API_GruppiimpiantiInternazionale                     {get; set;}
        public String API_ImportoScontoInternazionale                      {get; set;}
        public String API_ListiMese                                        {get; set;}
        
        
        
        public wrapperInternazionale(){}
    }
    public class wrapperContoCarte{
        
        public String API_CarteName                                        {get; set;}
        public String API_DivisioneCarte                                   {get; set;}
        public String API_ProdottiAmmessi                                  {get; set;}
        public String API_ServiziInStazione                                {get; set;}
        public String API_TipoPIN                                          {get; set;}
        public String API_TipoOperat                                       {get; set;}
        public String API_TipologiaVeicoli                                 {get; set;}
        public String API_TipoCarta                                        {get; set;}
        public String API_ViaCarta                                         {get; set;}
        public String API_Citta                                            {get; set;}
        public String API_Provincia                                        {get; set;}
        public String API_DivisioneName                                    {get; set;}
        public String API_DivisioneDescrizione                             {get; set;}
        public String API_Nazione                                          {get; set;}
        
        
        public wrapperContoCarte(){}
    }
    
    public class wrapperDivisione{
        
        public String API_Nome                                             {get; set;}
        public String API_Divisione                                        {get; set;}
        public wrapperDivisione(){}
    }
    public class wrapperCarte{
        
        public String API_NomeContoCarte                                   {get; set;}
        public String API_ParcoMezziCarte                                  {get; set;}
        public String API_ProdottiAutorizzati                              {get; set;}
        public String API_ProdottiServiziInStazione                        {get; set;}
        public String API_TipoPin                                          {get; set;}
        public String API_InformazioniAggiuntive                            {get; set;}
        public String API_Numero_di_targa                                  {get; set;}
        public String API_TipoVeicolo                                      {get; set;}
        public String API_Rete                                             {get; set;}
        public String API_ServiziStazione                                  {get; set;}
        public Decimal API_Numero_di_PIN_Autista                           {get; set;}
        public String API_Tipo_Operazione                                  {get; set;}
        
        
        public wrapperCarte(){}
    }
    public class wrapperObject{
        public String API_codiceCliente                    {get; set;}
        public String API_Agente                      {get; set;}
        public String API_Commerciale                     {get; set;}
        public Integer numeroRipetizioni                  {get; set;}
        public Boolean carteBoolean                      {get; set;}
        public Boolean API_countDivisioni                                   {get; set;}
        public Decimal API_ImportoGaranzia                                  {get; set;} 
        public String API_TipoGaranzia                                      {get; set;} 
        public String API_PeriodoSpendibilita                               {get; set;}      
        public String API_Fatturazione                                      {get; set;}
        public String Description                                           {get; set;}
        public Boolean API_Fatturazione15                                   {get; set;}
        public Boolean API_Fatturazione30                                   {get; set;}
        public Decimal API_DilazionePagamento                               {get; set;}
        public String API_quoteinWrap                                       {get; set;}
        public Decimal API_NumeroDivisioni                                  {get; set;}
        public String AccountId                                             {get; set;}
        public String API_Luogo_sottoscrizione                              {get; set;}
        public String API_NomeSottoscrittore                                {get; set;}
        public Decimal API_PrevisionePedaggi                                {get; set;}
        public Decimal API_PrevisioneConsumi                                {get; set;}
        public String API_Tipo_fido                                         {get; set;}
        public String name                                                  {get; set;}
        public String API_CodiceFiscale                                     {get; set;}
        public String API_Iva                                               {get; set;}
        public String API_Iban                                              {get; set;}
        public Boolean API_Internazionale                                   {get; set;}
        public String API_Fax                                               {get; set;}
        public String API_FaxInterno                                        {get; set;}
        public String API_dataInizioAttivita                                  {get; set;}
        public String API_SEPA                                              {get; set;}
        public String API_Codice_SDI                                        {get; set;}
        public String BillingStreet                                         {get; set;}
        public String BillingCity                                           {get; set;}
        public String BillingState                                          {get; set;}
        public String BillingPostalCode                                     {get; set;}
        public String BillingCountry                                        {get; set;}
        public String ShippingStreet                                        {get; set;}
        public String ShippingCity                                          {get; set;}
        public String ShippingState                                         {get; set;}
        public String ShippingPostalCode                                    {get; set;}
        public String ShippingCountry                                       {get; set;}
        public String API_RagioneSociale                                    {get; set;}
        public String API_Telefono                                          {get; set;}
        public String API_Pacchetto                                         {get; set;}
        public String API_EmailPec                                          {get; set;}
        public String  API_Banca_del_debitore                               {get; set;}
        public String API_Agenzia                                           {get; set;}
        public String API_Telefono_banca                                    {get; set;}
        public String API_Tipo_Attivita                                     {get; set;}
        public String API_Email_Portale_Sicurezza              {get; set;}
        //public String API_Trasporto                                       {get; set;}
        //public String API_FlottaAuto                                      {get; set;}
        //public String API_AltreAttivita                                   {get; set;}
        public Boolean API_AutorizzInvioMatProm                             {get; set;}
        public Boolean API_AutorizzProfilazione                             {get; set;}
        public String API_CodiceDestinatario                                {get; set;}
        public Boolean API_PacchettoBase                                    {get; set;}
        public Boolean API_PacchettoExtra                                   {get; set;}
        public Boolean API_PacchettoPremium                                 {get; set;}
        public String API_Offerta                                           {get; set;}
        public String API_NameReferente                                     {get; set;}
        public String API_TelefonoReferente                                 {get; set;}
        public String API_TelefonoOperat                                    {get; set;}
        public String API_EmailCM                                           {get; set;}
        public String API_FormaGiuridica                                    {get; set;}
        public Boolean API_contoterzimille                                  {get; set;}
        public Boolean API_contoTerziMed                                    {get; set;}
        public Boolean API_contoTerzicinq                                   {get; set;}
        public Boolean API_contoMagTrec                                     {get; set;}
        public Boolean API_contoMinTrec                                     {get; set;}
        public Boolean API_furgProp                                         {get; set;}
        public Boolean API_grandFlot                                        {get; set;}
        public Boolean API_picFlot                                          {get; set;}
        public Boolean API_PMI                                              {get; set;}
        public Boolean API_furgTerz                                         {get; set;}
        public Boolean API_traspBUS                                         {get; set;}
        public Boolean API_NTL                                              {get; set;}
        public Boolean API_pubAmmin                                         {get; set;}
        public Boolean API_furgArtig                                        {get; set;}
        public Boolean API_altro                                            {get; set;}
        public Boolean API_flotMed                                          {get; set;}
        public Boolean API_checkB2B                                         {get; set;}
        public Boolean API_checkCore                                        {get; set;}
        public String API_dataCont                                          {get; set;}
        public String API_NameDebitore                                      {get; set;}
        public String  API_TelefonoDebitore                                 {get; set;}
        public String  API_CodFiscaleDeb                                    {get; set;}
        public String API_CodiceCIG                      {get; set;}
        public String API_DataInizioValiditaCIG                {get; set;}
        public Boolean API_EsenteCIG                    {get; set;}
        public String API_CodiceCUU                      {get; set;}
        public String API_Cup                        {get; set;}
        public String API_Numero_ordine                    {get; set;}
        public String API_Determina_di_Spesa                {get; set;}
        public Boolean API_SplitPubblicaAmministrazione            {get; set;}
        public Boolean API_SoggettoTracciabilita              {get; set;}
        public Boolean API_SocietaPartecipata                 {get; set;}
        public Boolean API_SplitFattureDivisione                            {get; set;}
        public List <wrapperContoCarte> contocarteList                      {get; set;}
        public List <wrapperDivisione> divisioneList                        {get; set;}
        public List <wrapperCarte> carteList                                {get; set;} 
        // public List <wrapperInternazionale> internazionaleWrapperList     {get; set;}
        public Map<String,List<String>> internazionaleWrapperList           {get; set;}
        public List<String>  mappList                                       {get; set;}
        public List<String>  scontoBaseValueList                            {get; set;}
        public List<String>  retiPartnerValueList                           {get; set;}
        public List<String>  canoneValueList                               {get; set;}
        public List<String>  bonusValueList                                 {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> bonusMap      {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> SitoMap        {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> canoneWEB      {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> reteMap        {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> garanziaMap      {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> commissioneMap    {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> pedaggiMap      {get; set;}
        public Map<String, List<API_QuoteLineItemX__c>> partnerMap      {get; set;}
        public List<String>  scontoPacchettoValueList                       {get; set;}
        public List<String>  scontoSiteReteValueList                        {get; set;}
        public List<String>  bonusGaranziaList                              {get; set;}
        public String  pedaggioValoreItalia                              {get; set;}
        public String  pedaggioValoreInteroperabile                        {get; set;}
        public List<String>  commissioneValoreList                          {get; set;}
        public String  API_TipoPINDema                        {get; set;}
        public String  API_Visualizza_PIN                        {get; set;}
        public String  API_Paga_PIN_cartaceo                        {get; set;}
        
        
        
        public Map<Id,Map<String,String>> mapListWrapper                    {get; set;}
        public wrapperObject(){}
        
    }
}