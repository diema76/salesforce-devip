public class API_CallSAP {
    
    public static String callSAP(String quoteID){
      
       system.debug('QuoteID: ' +quoteID);
       Quote quote = [select API_NumeroVersione__c, API_Periodo_di_spendibilita_picklist__c, API_NomeSottoscrittore__c, API_DataSottoscrizioneContratto__c, QuoteNumber,
                       opportunity.Account.API_RagioneSociale__c, opportunity.Account.BillingStreet, opportunity.Account.BillingState, 
                       opportunity.Account.BillingCountry, opportunity.Account.API_Telefono__c, opportunity.Account.API_TelefonoInterno__c,
                       opportunity.Account.API_Cellulare__c, opportunity.Account.Fax, opportunity.Account.API_Email__c, opportunity.Account.SEPA_Direct_Debit_SDD__c,
                       opportunity.Account.API_EmailPec__c, opportunity.Account.ShippingCity, opportunity.Account.ShippingCountry, 
                       opportunity.Account.ShippingStreet, opportunity.Account.ShippingState, opportunity.Account.ShippingPostalCode, 
                       opportunity.Account.API_PartitaIVACEE__c, opportunity.Account.API_PersonaFisica__c, opportunity.Account.API_EsenteCIG__c,
                       opportunity.Account.API_CodiceCIG__c, opportunity.Account.API_DataInizioValiditaCIG__c, opportunity.Account.API_CodiceCUU__c,
                       opportunity.Account.API_AutorizzProfilazione__c, opportunity.Account.API_FormaGiuridica__c, API_Offerta__c, API_Listino__c,
                       API_DeltaPlatts__c, opportunity.Account.API_Note__c, API_Pacchetto__c, opportunity.Account.API_Importo_richiesto__c,opportunity.Account.API_Codice_SDI__c,
                       opportunity.Account.API_Iban__c, API_CodiceFiscaleFirmatarioSepa__c, API_Tipo_fido__c, opportunity.Account.API_Tipo_Affidamento__c, 
                       opportunity.Account.API_Tipo_SEPA__c, opportunity.Account.API_TipoSeda__c, opportunity.Account.API_ClienteTop__c,
                       opportunity.Account.API_ClienteSensibile__c, opportunity.Account.API_FatturazionePDF__c, opportunity.Account.API_EmailCMOnline__c,
                       opportunity.Account.API_Tipo_contrattoPicklist__c, opportunity.Account.API_ClienteAcquisitoDa__c, opportunity.Account.Description,
                       API_Fatturazione__c, API_SplitFattureDivisioneVERO__c, opportunity.AccountId, opportunity.Account.BillingPostalCode,
                       opportunity.Account.BillingCity, Opportunity.Account.API_SplitPubblicaAmministrazione__c, API_Previsione_consumo_annuale__c,
                       API_CondizioniPagamento__c, API_CondizioniDiPagamentoFormula__c, Opportunity.Account.API_Tipo_Attivita__c, Opportunity.Account.API_Privacy__c,
                       opportunity.Account.API_SoggettoTracciabilita__c, opportunity.Account.API_GruppoClientiCartesia__c, opportunity.Account.API_Iva__c,
                       opportunity.Account.API_CodiceFiscale__c, opportunity.Account.API_Codice_area_manager__c, opportunity.Account.API_CodiceAddettoVendite__c, API_Tipo_Carta__c,
                       opportunity.Account.API_Email_Portale_Sicurezza__c, opportunity.Account.API_Determina_di_Spesa__c, opportunity.Account.API_Numero_ordine__c,
                       opportunity.Account.API_TipoPINDema__c, opportunity.Account.API_Visualizza_PIN__c,API_Paga_PIN_cartaceo__c, opportunity.Account.API_Cup__c 
                       from quote where id =: quoteID LIMIT 1];
        
        List<API_QuoteLineItemX__c> qlixList = [select API_NomeAttributo__c, API_NomeProdotto__c, API_QuoteLineItem__c, API_Valore__c, API_DeveloperNameMetadata__c,
                                                API_QuoteLineItem__r.Product2.Name from API_QuoteLineItemX__c where API_QuoteLineItem__r.QuoteId =: quoteID];
        
        List<API_Divisione__c> divisioneList = [select Id, API_Account__c, API_Descrizione__c from API_Divisione__c where API_Account__c =: quote.opportunity.AccountId];
        
        List<API_Parco_mezzi__c> parchiList = [select id, name, API_Descrizione__c, API_Quote__c from API_Parco_mezzi__c where API_Quote__c =: quoteID];
        
        List<Contact> contact = [select Name from contact where AccountId =: quote.opportunity.AccountId and API_TipoContatto__c ='Principale']; 
        
        List<API_ContoCarte__c> contoCarteList = [select id, API_DescrizioneGruppoCarte__c, API_RiferimentoDivisione__c, API_TipoPIN__c, API_NumeroPinAutista__c, 
                                                  API_TipologiaVeicoli__c, API_TipoOperat__c, API_Quote__c, API_ProdottiAmmessi__c, API_ServiziInStazione__c
                                                  from API_ContoCarte__c where API_Quote__c =: quoteID];
        
        List<API_Carta__c> cartaList = [select id, API_Numero_di_targa__c, API_TipoVeicolo__c, API_Tipo_Operazione__c, API_Check_KM__c, API_ContoCarte__c,
                                        API_ProdottiAutorizzati__c, API_ServiziStazione__c, API_InformazioniAggiuntive__c, API_Parco_mezzi__c from API_Carta__c where API_Quote__c =: quoteID];
        
        //Mappa che contiente tutte le carte con il proprio identificativo
        Map<String, String> carteMap = new Map<String,String>();
        //Mappa che contiente tutti i conti carta con il proprio identificativo
        Map<String, String> contoCarteMap = new Map<String,String>();   
        //Mappa che contiente tutte le divisioni con il proprio identificativo
        Map<String, String> divisioneMap = new Map<String,String>();   
        //Mappa che contiente tutti gli sconti con chiave il corrispettivo quotelineitem
        Map<String, String> parchiMap = new Map<String,String>();         
        //Mappa che contiene tutti i bonus con chiave il corrispettivo quotelineitem
        Map<String, List<API_QuoteLineItemX__c>> qlixMapBonus = new Map<String,List<API_QuoteLineItemX__c>>();
        //Mappa che contiente tutti gli sconti con chiave il corrispettivo quotelineitem
        Map<String, List<API_QuoteLineItemX__c>> qlixMapSconti = new Map<String,List<API_QuoteLineItemX__c>>();
        
        for(API_QuoteLineItemX__c qlix :qlixList){
            system.debug('QLIX: ' +qlix);
            if(qlix.API_QuoteLineItem__r.Product2.Name == 'Sconto base' || qlix.API_QuoteLineItem__r.Product2.Name == 'Sconto Site/Rete' ||
               qlix.API_QuoteLineItem__r.Product2.Name == 'Reti partner prezzo pompa' || qlix.API_QuoteLineItem__r.Product2.Name == 'Commissione IP Matic' || 
               qlix.API_QuoteLineItem__r.Product2.Name == 'Sconto Pacchetto' || qlix.API_QuoteLineItem__r.Product2.Name == 'Pedaggi'){
                   if(qlixMapSconti.get(qlix.API_QuoteLineItem__c) == null){
                       List<API_QuoteLineItemX__c> qlixNEW = new List<API_QuoteLineItemX__c>();
                       qlixNEW.add(qlix);
                       qlixMapSconti.put(qlix.API_QuoteLineItem__c, qlixNEW);
                   }else{
                       List<API_QuoteLineItemX__c> qlixNEW = new List<API_QuoteLineItemX__c>();
                       qlixNEW = qlixMapSconti.get(qlix.API_QuoteLineItem__c);
                       qlixNEW.add(qlix);
                       qlixMapSconti.put(qlix.API_QuoteLineItem__c, qlixNEW);
                   }
               }else if(qlix.API_QuoteLineItem__r.Product2.Name == 'Bonus' || qlix.API_QuoteLineItem__r.Product2.Name == 'Bonus Garanzia'){
                   if(qlixMapBonus.get(qlix.API_QuoteLineItem__c) == null){
                       List<API_QuoteLineItemX__c> qlixNEW = new List<API_QuoteLineItemX__c>();
                       qlixNEW.add(qlix);
                       qlixMapBonus.put(qlix.API_QuoteLineItem__c, qlixNEW);
                   }else{
                       List<API_QuoteLineItemX__c> qlixNEW = new List<API_QuoteLineItemX__c>();
                       qlixNEW = qlixMapBonus.get(qlix.API_QuoteLineItem__c);
                       qlixNEW.add(qlix);
                       qlixMapBonus.put(qlix.API_QuoteLineItem__c, qlixNEW);
                   }
               }else{
                   system.debug('QLIX ELSE: ' +qlix);
               }
        }
        
        //Popolo la mappa mettendo la coppia divisione/identificativo numerico
        Integer i = 1;
        for(API_Divisione__c div : divisioneList){
            divisioneMap.put(div.id, String.valueOf(i));
            i++;
        }
        
        //Popolo la mappa mettendo la coppia parchi codice
        
        for(API_Parco_mezzi__c parchi : parchiList){
            if((parchi.Name).length()>3) parchi.Name=parchi.Name.substring(0, 3);
            parchiMap.put(parchi.id, parchi.Name);
        }
        
        //Popolo la mappa mettendo la coppia conto carte/identificativo numerico
        Integer h = 1;
        for(API_ContoCarte__c  cc : contoCarteList){
            contoCarteMap.put(cc.id, String.valueOf(h));
            h++;
        }
        
        //Popolo la mappa mettendo la coppia carte/identificativo numerico
        Integer l = 1;
        for(API_Carta__c  carta : cartaList){
            carteMap.put(carta.id, String.valueOf(l));
            l++;
        }
        
        System.debug('qlixList: ' +qlixList);
        System.debug('qlixList SIZE : ' +qlixList.size());
        System.debug('qlixMapBonus: ' +qlixMapBonus);
        System.debug('qlixMapSconti: ' +qlixMapSconti);
        System.debug('parchiMap: ' +parchiMap);
        System.debug('contoCarteMap: ' +contoCarteMap);
        System.debug('carteMap: ' +carteMap);
        
        //qui ci va il numero di richiesta, la data, il sottoscrittore, la versione
        gruppoapiComCrmClientein.DatiRichiestaAdesione element= new gruppoapiComCrmClientein.DatiRichiestaAdesione();
        if(quote.API_NumeroVersione__c <= 9)                element.ZNUM_PROGRESS = String.valueOf(quote.QuoteNumber) + '0' + String.valueOf(quote.API_NumeroVersione__c);
        if(quote.API_NumeroVersione__c >= 10 && quote.API_NumeroVersione__c<= 99)       element.ZNUM_PROGRESS = String.valueOf(quote.QuoteNumber) + String.valueOf(quote.API_NumeroVersione__c);
        element.ZNAME_SOTTO_SCR = quote.API_NomeSottoscrittore__c;
        if(quote.API_DataSottoscrizioneContratto__c != null){
            String dataSottoscrizione = String.valueOf(quote.API_DataSottoscrizioneContratto__c);
            String data = dataSottoscrizione.substring(0,10);
            data = data.remove('-');
            element.ZDT_RICH_ADES = data.trim();
            String ora = dataSottoscrizione.substring(11);
            ora = ora.remove(':');
            element.ZORA_RICH_ADES = ora;
        }
        element.STCD2 = quote.opportunity.Account.API_Iva__c;
        element.STCD1 = quote.opportunity.Account.API_CodiceFiscale__c;
        element.STCEG = quote.opportunity.Account.API_PartitaIVACEE__c;
        element.VKBUR = quote.opportunity.Account.API_Codice_area_manager__c;
        element.VKGRP = quote.opportunity.Account.API_CodiceAddettoVendite__c;
        
        if(quote.opportunity.Account.API_Codice_SDI__c!=null) element.STCD4 = quote.opportunity.Account.API_Codice_SDI__c;
        else element.STCD4='';
        
        //sezione indirizzi
        gruppoapiComCrmClientein.DatiIndirizzo billingAddress= new gruppoapiComCrmClientein.DatiIndirizzo();
        gruppoapiComCrmClientein.DatiIndirizzo shippingAddressFAT= new gruppoapiComCrmClientein.DatiIndirizzo();
        gruppoapiComCrmClientein.DatiIndirizzo shippingAddressPIN= new gruppoapiComCrmClientein.DatiIndirizzo();
        billingAddress.TIPO_IND='FAT';
        billingAddress.NAME1 = quote.opportunity.Account.API_RagioneSociale__c;
        if(!contact.isEmpty())                                          billingAddress.NAME2 = contact[0].Name;
        billingAddress.STRAS = quote.opportunity.Account.BillingStreet;
        billingAddress.PSTLZ = quote.opportunity.Account.BillingPostalCode;
        billingAddress.ORT01 = quote.opportunity.Account.BillingCity;
        billingAddress.PROV = quote.opportunity.Account.BillingState;
        String countryBilling = quote.opportunity.Account.BillingCountry;
        countryBilling = countryBilling.substring(0,3);
        system.debug('countryBilling: '+countryBilling);
        billingAddress.NAZIONE = countryBilling;
        billingAddress.TELINT = quote.opportunity.Account.API_Telefono__c;
        billingAddress.TELEF = quote.opportunity.Account.API_TelefonoInterno__c;
        billingAddress.TCELL = quote.opportunity.Account.API_Cellulare__c;
        billingAddress.TLFAX = quote.opportunity.Account.Fax;
        billingAddress.EMAIL = quote.opportunity.Account.API_Email__c;
        billingAddress.EMAIL_PEC = quote.opportunity.Account.API_EmailPec__c;
        
        List<gruppoapiComCrmClientein.DatiIndirizzo> indirizzi= new List<gruppoapiComCrmClientein.DatiIndirizzo>();
        
        //se lo shipping address è popolato, creo un altro oggetto e lo inserisco alla lista
        if(quote.opportunity.Account.ShippingCity != null && quote.opportunity.Account.ShippingCountry != null && quote.opportunity.Account.ShippingStreet != null && 
           quote.opportunity.Account.ShippingState != null && quote.opportunity.Account.ShippingPostalCode != null){
               
               shippingAddressFAT.TIPO_IND='CAR';
               shippingAddressFAT.NAME1 = quote.opportunity.Account.API_RagioneSociale__c;
               if(!contact.isEmpty())                                          billingAddress.NAME2 = contact[0].Name;
               shippingAddressFAT.STRAS = quote.opportunity.Account.ShippingStreet;
               shippingAddressFAT.PSTLZ = quote.opportunity.Account.ShippingPostalCode;
               shippingAddressFAT.ORT01 = quote.opportunity.Account.ShippingCity;
               shippingAddressFAT.PROV = quote.opportunity.Account.ShippingState;
               String countryShipping = quote.opportunity.Account.ShippingCountry;
               countryShipping = countryShipping.substring(0,3);
               System.debug('countryShipping' +countryShipping);
               shippingAddressFAT.NAZIONE = countryShipping;
               shippingAddressFAT.TELINT = quote.opportunity.Account.API_Telefono__c;
               shippingAddressFAT.TELEF = quote.opportunity.Account.API_TelefonoInterno__c;
               shippingAddressFAT.TCELL = quote.opportunity.Account.API_Cellulare__c;
               shippingAddressFAT.TLFAX = quote.opportunity.Account.Fax;
               shippingAddressFAT.EMAIL = quote.opportunity.Account.API_Email__c;
               shippingAddressFAT.EMAIL_PEC = quote.opportunity.Account.API_EmailPec__c;
               
               indirizzi.add(shippingAddressFAT);
               
               shippingAddressPIN.TIPO_IND='PIN';
               shippingAddressPIN.NAME1 = quote.opportunity.Account.API_RagioneSociale__c;
               if(!contact.isEmpty())                                          billingAddress.NAME2 = contact[0].Name;
               shippingAddressPIN.STRAS = quote.opportunity.Account.ShippingStreet;
               shippingAddressPIN.PSTLZ = quote.opportunity.Account.ShippingPostalCode;
               shippingAddressPIN.ORT01 = quote.opportunity.Account.ShippingCity;
               shippingAddressPIN.PROV = quote.opportunity.Account.ShippingState;
               shippingAddressPIN.NAZIONE = countryShipping;
               shippingAddressPIN.TELINT = quote.opportunity.Account.API_Telefono__c;
               shippingAddressPIN.TELEF = quote.opportunity.Account.API_TelefonoInterno__c;
               shippingAddressPIN.TCELL = quote.opportunity.Account.API_Cellulare__c;
               shippingAddressPIN.TLFAX = quote.opportunity.Account.Fax;
               shippingAddressPIN.EMAIL = quote.opportunity.Account.API_Email__c;
               shippingAddressPIN.EMAIL_PEC = quote.opportunity.Account.API_EmailPec__c;
               
               indirizzi.add(shippingAddressPIN);
           }
        
        indirizzi.add(billingAddress);
        
        //dati amministrativi
        gruppoapiComCrmClientein.DatiAmministrativi datiAmministrativi= new gruppoapiComCrmClientein.DatiAmministrativi();
        datiAmministrativi.KTOKD = 'AITA';
        if(quote.opportunity.Account.API_Cup__c!=null) datiAmministrativi.COD_CUP=quote.opportunity.Account.API_Cup__c;
        
        if(quote.opportunity.Account.API_GruppoClientiCartesia__c==null) return 'Gruppo clienti Cartesia vuoto';
        datiAmministrativi.IG_CODE = quote.opportunity.Account.API_GruppoClientiCartesia__c.substring(0,6);
        system.debug('IG CODE: '+ datiAmministrativi.IG_CODE);
        datiAmministrativi.STCEG = quote.opportunity.Account.API_PartitaIVACEE__c;
        if(quote.opportunity.Account.API_PersonaFisica__c == true)          datiAmministrativi.STKZN = 'X';
        else                                                                datiAmministrativi.STKZN = '';
        if(quote.opportunity.Account.API_EsenteCIG__c == true)              datiAmministrativi.ALTRA_FOR = 'X';
        else                                                                datiAmministrativi.ALTRA_FOR = '';
        if(quote.opportunity.Account.API_CodiceCIG__c!=null){datiAmministrativi.COD_CIG = quote.opportunity.Account.API_CodiceCIG__c; datiAmministrativi.PUBBL_AMM='X';}
        if(quote.opportunity.Account.API_DataInizioValiditaCIG__c != null){
            String dataCIG = String.valueOf(quote.opportunity.Account.API_DataInizioValiditaCIG__c);
            String dataC = dataCIG.substring(0,10);
            dataC = dataC.remove('-');
            datiAmministrativi.BEGDACIG = dataC;
        }
        
        if(quote.opportunity.Account.API_CodiceCUU__c!= null) {datiAmministrativi.COD_PA = quote.opportunity.Account.API_CodiceCUU__c; datiAmministrativi.F_ELETTR='X';}
        datiAmministrativi.AUT_PROFIL = quote.opportunity.Account.API_Privacy__c.substring(1,2);
        system.debug('AUT_PROFIL: ' +datiAmministrativi.AUT_PROFIL);
        String formaGiuridica = quote.opportunity.Account.API_FormaGiuridica__c;
        if(formaGiuridica.length() >= 10)                           formaGiuridica = formaGiuridica.substring(0,10);
        System.debug('Forma giuridica: ' +formaGiuridica);
        //datiAmministrativi.F_GIUR = formaGiuridica;
        if(quote.API_Offerta__c == 'Miglior Prezzo')             datiAmministrativi.OFF_COMM = 'Best';
        else if(quote.API_Offerta__c == 'Prezzo Listino')        datiAmministrativi.OFF_COMM = 'Listino';
        else if(quote.API_Offerta__c == 'Prezzo Pompa')          datiAmministrativi.OFF_COMM = 'Pompa';
        if(Quote.API_Listino__c == 'L1 LISTINO CARTE')           datiAmministrativi.COD_LISTINO = 'L1';
        else if(Quote.API_Listino__c == 'L2 PLATTS')                     datiAmministrativi.COD_LISTINO = 'L2';
        else if(Quote.API_Listino__c == 'L3 LISTINO SPECIALE')        datiAmministrativi.COD_LISTINO = 'L3';
        else if(Quote.API_Listino__c == 'L4 STAFFETTA')              datiAmministrativi.COD_LISTINO = 'L4';
        double deltaPlatts = quote.API_DeltaPlatts__c;
        if(deltaPlatts != null){
            double iva = (deltaPlatts * 22)/100;
            deltaPlatts = deltaPlatts + iva;
            datiAmministrativi.DPLATTS = String.valueOf(deltaPlatts);
        }
        datiAmministrativi.NOTE = quote.opportunity.Account.API_Note__c;
        datiAmministrativi.WEB_PACK = quote.API_Pacchetto__c;
        if(quote.Opportunity.Account.API_SplitPubblicaAmministrazione__c == false){
            datiAmministrativi.TAXKDW = '1';
        }else{
            datiAmministrativi.TAXKDW = 'S'; datiAmministrativi.F_PUBL_AMM='X';
        }
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Conto terzi > 1000 m3/anno')          datiAmministrativi.TP_CLUSTER = '1';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Conto terzi tra 500 m3 e 1000 m3/anno')          datiAmministrativi.TP_CLUSTER = '2';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Conto terzi < 500 m3/anno')          datiAmministrativi.TP_CLUSTER = '3';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Conto proprio oltre 300 m3/anno')          datiAmministrativi.TP_CLUSTER = '4';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Conto proprio sino a 300 m3/anno')          datiAmministrativi.TP_CLUSTER = '5';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Trasporto furgoni conto proprio')          datiAmministrativi.TP_CLUSTER = '6';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Grandi flotte auto > 300 m3/anno')          datiAmministrativi.TP_CLUSTER = '7';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Piccole flotte < 50 m3/anno')          datiAmministrativi.TP_CLUSTER = '8';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'PMI e artigiano < 4 carte')          datiAmministrativi.TP_CLUSTER = '9';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Trasporto furgoni conto terzi')          datiAmministrativi.TP_CLUSTER = '10';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Trasporto persone BUS')          datiAmministrativi.TP_CLUSTER = '11';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Noleggiatori NTL e breve termine')          datiAmministrativi.TP_CLUSTER = '12';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Amministrazione pubblica')          datiAmministrativi.TP_CLUSTER = '13';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Trasporto furgoni artigianato')          datiAmministrativi.TP_CLUSTER = '14';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Altro o non conosciuto')          datiAmministrativi.TP_CLUSTER = '15';
        if(quote.Opportunity.Account.API_Tipo_Attivita__c == 'Flotte Medie tra 50m3 e 300 m3/anno')          datiAmministrativi.TP_CLUSTER = '16';
        System.debug('LISTINO: ' +datiAmministrativi.COD_LISTINO);
        
        //dati bancari
        gruppoapiComCrmClientein.DatiBancari datiBancari = new gruppoapiComCrmClientein.DatiBancari();
        Integer fidoI = Integer.valueOf(quote.opportunity.Account.API_Importo_richiesto__c);
        String fidoC = String.valueOf(fidoI);
        if(quote.opportunity.Account.API_Importo_richiesto__c <= 9)  datiBancari.LIM_FIDO = '00000000' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c >= 10 && quote.opportunity.Account.API_Importo_richiesto__c <= 99)     datiBancari.LIM_FIDO = '0000000' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 99 && quote.opportunity.Account.API_Importo_richiesto__c <= 999)   datiBancari.LIM_FIDO = '000000' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 999 && quote.opportunity.Account.API_Importo_richiesto__c <= 9999)   datiBancari.LIM_FIDO = '00000' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 9999 && quote.opportunity.Account.API_Importo_richiesto__c <= 99999)     datiBancari.LIM_FIDO = '0000' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 99999 && quote.opportunity.Account.API_Importo_richiesto__c <= 999999)     datiBancari.LIM_FIDO = '000' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 999999 && quote.opportunity.Account.API_Importo_richiesto__c <= 9999999)   datiBancari.LIM_FIDO = '00' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 9999999 && quote.opportunity.Account.API_Importo_richiesto__c <= 99999999)    datiBancari.LIM_FIDO = '0' + fidoC;
        if(quote.opportunity.Account.API_Importo_richiesto__c > 99999999 && quote.opportunity.Account.API_Importo_richiesto__c <= 999999999)     datiBancari.LIM_FIDO = fidoC;
        System.debug('LIM_FIDO: ' +datiBancari.LIM_FIDO);
        
        datiBancari.IBAN = quote.opportunity.Account.API_Iban__c;
        datiBancari.STCD3 = quote.API_CodiceFiscaleFirmatarioSepa__c;
        ///Trascodifica condizioni di pagamento in base al tipo fido scelto
        if(quote.API_Tipo_fido__c == 'IFI'){
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-20 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF01';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-25 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF02';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-30 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF03';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-40 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF04';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-45 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF05';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-60 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF06';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-90 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF07';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-10 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF08';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-15 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF09';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-35 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'TF10';
            datiBancari.ZWELS = 'T';
        }else{
            if(quote.API_CondizioniPagamento__c.contains('RID-Banca'))                                     datiBancari.ZWELS = 'E';
            else                                                                                           datiBancari.ZWELS = 'B';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-20 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX03';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-25 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX18';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-30 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX04';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-40 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX19';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-45 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX05';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-60 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX06';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-90 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX07';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-10 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX01';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-15 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX02';
            if(quote.API_CondizioniPagamento__c == 'RID-Banca-00 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'SX20';
            
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-10 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF21';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-15 gg Data Fattura Fuelcard')                datiBancari.ZTERM = 'BF02';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-20 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF03';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-25 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF12';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-30 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF04';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-40 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF05';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-45 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF06';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-60 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF08';
            if(quote.API_CondizioniPagamento__c == 'Bonifico bancario-90 gg Data Fattura FuelCard')                datiBancari.ZTERM = 'BF09';
        }
        String fido = quote.API_Tipo_fido__c;
        if(fido == 'IFI'){
            datiBancari.CESSION_KZ = 'SI';
            datiBancari.HBKID = 'IFI'; 
        }else{
            datiBancari.CESSION_KZ = 'NO';
            if(quote.opportunity.Account.API_SoggettoTracciabilita__c == true)                  datiBancari.HBKID = 'BEMP1'; 
            else                                                                                datiBancari.HBKID = 'BSARD';
        }
        String sepa = quote.opportunity.Account.SEPA_Direct_Debit_SDD__c;
        if(sepa == 'Business to Business')   datiBancari.BUBKZ = '3';    else datiBancari.BUBKZ = '8';
        
        //dati CRM
        gruppoapiComCrmClientein.DatiCrm datiCrm=new gruppoapiComCrmClientein.DatiCrm();
        String consumoAnnuo = '';
        if(quote.API_Previsione_consumo_annuale__c != null)
            consumoAnnuo = String.valueOf(quote.API_Previsione_consumo_annuale__c);
        for(integer j = consumoAnnuo.length(); j < 9; j++){
            String zero = '0';
            consumoAnnuo = zero + consumoAnnuo;
        }
        datiCrm.CONSNAZ = consumoAnnuo;
        System.debug('datiCrm.CONSNAZ: ' +datiCrm.CONSNAZ);
        datiCrm.ID_SALESFORCE = quote.opportunity.AccountId;
        datiCrm.TIPOSEDA = quote.opportunity.Account.API_TipoSeda__c;
        String data = String.valueOf(quote.API_DataSottoscrizioneContratto__c);
        data = data.substring(0, 11);
        data = data.remove('-');
        datiCrm.DATASOTT = data.trim();
        if(quote.opportunity.Account.API_ClienteTop__c)         datiCrm.FLAGTOP = 'X';
        else                                                    datiCrm.FLAGTOP = '';
        if(quote.opportunity.Account.API_ClienteSensibile__c)   datiCrm.FLAGSENS = 'X';
        else                                                    datiCrm.FLAGSENS = '';
        if(quote.opportunity.Account.API_FatturazionePDF__c)    datiCrm.FLAGPDF = 'X';
        else                                                    datiCrm.FLAGPDF = '';
        datiCrm.EMAIL_CMO = quote.opportunity.Account.API_EmailCMOnline__c;
        datiCrm.TIPOCONTR = quote.opportunity.Account.API_Tipo_contrattoPicklist__c;
        datiCrm.ACQUISITODA = quote.opportunity.Account.API_ClienteAcquisitoDa__c;
        datiCrm.DESCR = quote.opportunity.Account.Description;
        if(quote.API_Tipo_Carta__c!=null)     datiCrm.TIPOCARTA=quote.API_Tipo_Carta__c;
       //CR Gennaio 2022
        if(quote.opportunity.Account.API_CodiceAddettoVendite__c!=null)datiCrm.PROPRIETARIO=quote.opportunity.Account.API_CodiceAddettoVendite__c;
        if(quote.opportunity.Account.API_Email_Portale_Sicurezza__c!=null) datiCrm.MAIL_PORT_SICUR= quote.opportunity.Account.API_Email_Portale_Sicurezza__c;
        if(quote.opportunity.Account.API_Determina_di_Spesa__c!=null) datiCrm.DETERMSPESA= quote.opportunity.Account.API_Determina_di_Spesa__c;
        if(quote.opportunity.Account.API_Numero_ordine__c !=null) datiCrm.NRORDINE= quote.opportunity.Account.API_Numero_ordine__c;
        if(quote.opportunity.Account.API_TipoPINDema__c!= null) datiCrm.TIPOPIN= quote.opportunity.Account.API_TipoPINDema__c; else datiCrm.TIPOPIN= 'D';
        //if(quote.opportunity.Account.API_Visualizza_PIN__c!= null) datiCrm.VISPIN= quote.opportunity.Account.API_Visualizza_PIN__c; else datiCrm.VISPIN= 'NO'; 
        datiCrm.VISPIN='';
        if(quote.API_Paga_PIN_cartaceo__c!= null) datiCrm.PAGAPINCAR = quote.API_Paga_PIN_cartaceo__c; else datiCrm.PAGAPINCAR='NO';
        
        
        //dati fatturazione
        gruppoapiComCrmClientein.DatiFatturazione datiFatturazione=new gruppoapiComCrmClientein.DatiFatturazione();
        if(quote.API_Fatturazione__c == '30')
            datiFatturazione.XAUSZ = 'M';
        else if(quote.API_Fatturazione__c == '15')            datiFatturazione.XAUSZ = 'T';
        else if(quote.API_Fatturazione__c == '7') datiFatturazione.XAUSZ = 'W';
        else datiFatturazione.XAUSZ = 'C'; //(10gg)
       
        if(quote.API_SplitFattureDivisioneVERO__c)      datiFatturazione.FLAG_FATT_DIV = 'X';
        else                                            datiFatturazione.FLAG_FATT_DIV = '';
        if(divisioneList.isEmpty()){            datiFatturazione.FLAG_CLI_DIV = '';   }
        else{                                   datiFatturazione.FLAG_CLI_DIV = 'X';  }
        
        if(quote.API_Periodo_di_spendibilita_picklist__c=='15'){            datiFatturazione.FLPLAFOND15 = 'X';   }
        else{                                   datiFatturazione.FLPLAFOND15 = '';  }
        
        //Lista sconti 
        List<gruppoapiComCrmClientein.DatiSconti> datiSconti= new List<gruppoapiComCrmClientein.DatiSconti>();
        
        //sezione sconti
        for (String idQLI : qlixMapSconti.keySet()){
            system.debug('Sono entrato negli sconti');
            List<API_QuoteLineItemX__c> qlixListNEW = new List<API_QuoteLineItemX__c>();
            qlixListNEW = qlixMapSconti.get(idQLI);
            string tipo;
            string codice;
            String nomeProdotto;
            fasceObject fo = new fasceObject();
            
            for(API_QuoteLineItemX__c qlix :qlixListNEW){
                if(qlix.API_NomeProdotto__c == 'Pedaggi'){
                    nomeProdotto = 'PEDAGGI';
                    if(qlix.API_DeveloperNameMetadata__c == 'API_PedaggioCommissionePercentuale'){  
                        System.debug('VALORE COMMISSIONE');
                        String [] valore = qlix.API_Valore__c.split('\\.');
                        System.debug('VALORE: ' +valore);
                        if(!valore.isEmpty()){
                            String interi = valore[0];
                            if(valore.size() == 2){
                                String decimali = valore[1]; 
                                
                                if(interi.length() == 1)            interi = '00' + interi;
                                else if (interi.length() == 2)      interi = '0' + interi;
                                
                                if(decimali.length() == 0)          decimali = '000';
                                else if (decimali.length() == 1)    decimali = decimali + '00';
                                else if (decimali.length() == 2)    decimali = decimali + '0';
                                else if(decimali.length() > 3)      decimali = decimali.substring(3);    
                                fo.Valore = interi + decimali;
                            }else{
                                if(qlix.API_Valore__c.length() == 1)    fo.Valore = '00' +  qlix.API_Valore__c + '000';
                                else if(qlix.API_Valore__c.length() == 2)    fo.Valore = '0' +  qlix.API_Valore__c + '000'; 
                                else  fo.Valore = qlix.API_Valore__c + '000';
                            }
                        }
                    }
                }else if(qlix.API_NomeProdotto__c == 'Commissione IP Matic'){
                    nomeProdotto = 'COMMISSIONE IP MATIC';
                    if(qlix.API_DeveloperNameMetadata__c == 'API_CommissioneProdotti'){
                        fo.Prodotti = qlix.API_Valore__c;
                        System.debug('PRODOTTI COMMISSIONE');
                        System.debug('********** '+ qlix.API_Valore__c);
                    }
                    if(qlix.API_DeveloperNameMetadata__c == 'API_CommissioneValore'){
                        System.debug('VALORE COMMISSIONE');
                        String [] valore = qlix.API_Valore__c.split('\\.');
                        System.debug('VALORE: ' +valore);
                        if(!valore.isEmpty()){
                            String interi = valore[0];
                            if(valore.size() == 2){
                                String decimali = valore[1]; 
                                
                                if(interi.length() == 1)            interi = '00' + interi;
                                else if (interi.length() == 2)      interi = '0' + interi;
                                
                                if(decimali.length() == 0)          decimali = '000';
                                else if (decimali.length() == 1)    decimali = decimali + '00';
                                else if (decimali.length() == 2)    decimali = decimali + '0';
                                else if(decimali.length() > 3)      decimali = decimali.substring(3);    
                                fo.Valore = interi + decimali;
                            }else{
                                system.debug('DECIMALI NULL');
                                if(qlix.API_Valore__c.length() == 1)    fo.Valore = '00' +  qlix.API_Valore__c + '000';
                                else if(qlix.API_Valore__c.length() == 2)    fo.Valore = '0' +  qlix.API_Valore__c + '000'; 
                                else  fo.Valore = qlix.API_Valore__c + '000';
                            }
                        }
                    }
                    if(qlix.API_DeveloperNameMetadata__c == 'API_CommissioneDataInizio') 
                        fo.DataInizio = qlix.API_Valore__c.remove('-');
                    if(qlix.API_DeveloperNameMetadata__c == 'API_CommissioneDataFine') 
                        fo.DataFine = qlix.API_Valore__c.remove('-');
                }else if(qlix.API_NomeProdotto__c == 'Reti partner prezzo pompa'){
                    nomeProdotto = 'RETI PARTNER';
                    if(qlix.API_DeveloperNameMetadata__c == 'API_RetiPartnerProdotti')
                        fo.Prodotti = qlix.API_Valore__c;
                    if(qlix.API_DeveloperNameMetadata__c == 'API_RetiPartnerReti') 
                        fo.Volume = qlix.API_Valore__c;
                }else if(qlix.API_NomeProdotto__c == 'Sconto base'){
                    nomeProdotto = 'SCONTO BASE';
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_Prodotti')
                        fo.Prodotti = qlix.API_Valore__c;
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_ValoreSconto'){
                        System.debug('VALORE COMMISSIONE');
                        String [] valore = qlix.API_Valore__c.split('\\.');
                        System.debug('VALORE: ' +valore);
                        if(!valore.isEmpty()){
                            String interi;
                            if(valore[0].length() > 1) {
                                integer index = valore[0].length();
                                interi = valore[0].substring(index,1);
                            }else 
                                interi = valore[0];
                            
                            if(valore.size() == 2){
                                String decimali = valore[1]; 
                                
                                if(decimali.length() == 0)          decimali = '00000';
                                else if (decimali.length() == 1)    decimali = decimali + '0000';
                                else if (decimali.length() == 2)    decimali = decimali + '000';
                                else if (decimali.length() == 3)    decimali = decimali + '00';
                                else if (decimali.length() == 4)    decimali = decimali + '0';
                                else if(decimali.length() > 5)      decimali = decimali.substring(5);    
                                fo.Valore = interi + decimali;
                            }else{
                                system.debug('DECIMALI NULL');
                                fo.Valore = qlix.API_Valore__c + '00000';
                            }
                        }
                    }
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_DataInizio') 
                        fo.DataInizio = qlix.API_Valore__c.remove('-');
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_base_DataFine') 
                        fo.DataFine = qlix.API_Valore__c.remove('-');
                }else if(qlix.API_NomeProdotto__c == 'Sconto Site/Rete'){
                    nomeProdotto = 'SCONTO SITE';
                    if(qlix.API_DeveloperNameMetadata__c == 'API_Sconto_sito_rete_Prodotti')
                        fo.Prodotti = qlix.API_Valore__c;
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteValoreSconto'){
                        System.debug('VALORE COMMISSIONE');
                        String [] valore = qlix.API_Valore__c.split('\\.');
                        System.debug('VALORE: ' +valore);
                        if(!valore.isEmpty()){
                            String interi = valore[0];
                            if(valore.size() == 2){
                                String decimali = valore[1]; 
                                
                                if(decimali.length() == 0)          decimali = '00000';
                                else if (decimali.length() == 1)    decimali = decimali + '0000';
                                else if (decimali.length() == 2)    decimali = decimali + '000';
                                else if (decimali.length() == 3)    decimali = decimali + '00';
                                else if (decimali.length() == 4)    decimali = decimali + '0';
                                else if(decimali.length() > 5)      decimali = decimali.substring(5);    
                                fo.Valore = interi + decimali;
                            }else{
                                system.debug('DECIMALI NULL');
                                fo.Valore = qlix.API_Valore__c + '00000';
                            }
                        }
                    }
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteCodice') 
                        codice = qlix.API_Valore__c;
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoSiteReteTipo') 
                        tipo = qlix.API_Valore__c;
                    if(tipo == 'Site' && codice != null){            //QUI VA FATTA LA MODIFICA PER IL CLUSTER 
                        fo.Rinnovabile = codice;fo.Volume='';
                    }else if(codice != null)
                        fo.Volume = codice;
                }else if(qlix.API_NomeProdotto__c == 'Sconto Pacchetto'){
                    nomeProdotto = 'SCONTO PACCHETTO';
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoPacchettoValoreSconto'){
                        System.debug('VALORE COMMISSIONE');
                        String [] valore = qlix.API_Valore__c.split('\\.');
                        System.debug('VALORE: ' +valore);
                        if(!valore.isEmpty()){
                            String interi = valore[0];
                            if(valore.size() == 2){
                                String decimali = valore[1]; 
                                
                                if(interi.length() == 1)            interi = '00' + interi;
                                else if (interi.length() == 2)      interi = '0' + interi;
                                
                                if(decimali.length() == 0)          decimali = '000';
                                else if (decimali.length() == 1)    decimali = decimali + '00';
                                else if (decimali.length() == 2)    decimali = decimali + '0';
                                else if(decimali.length() > 3)      decimali = decimali.substring(3);    
                                fo.Valore = interi + decimali;
                            }else{
                                system.debug('DECIMALI NULL');
                                if(qlix.API_Valore__c.length() == 1)    fo.Valore = '00' +  qlix.API_Valore__c + '000';
                                else if(qlix.API_Valore__c.length() == 2)    fo.Valore = '0' +  qlix.API_Valore__c + '000'; 
                                else  fo.Valore = qlix.API_Valore__c + '000';
                            }
                        }
                    }
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoPack_dataInizio') 
                        fo.DataInizio = qlix.API_Valore__c.remove('-');
                    if(qlix.API_DeveloperNameMetadata__c == 'API_ScontoPack_dataFine') 
                        fo.DataFine = qlix.API_Valore__c.remove('-');
                }
            }
            
            if(nomeProdotto == 'COMMISSIONE IP MATIC'){
                List<String> prodottiList = fo.Prodotti.split(';');
                for(String prodotti : prodottiList){
                    System.debug('***** '+prodotti);
                    prodotti = prodotti.trim();
                    gruppoapiComCrmClientein.DatiSconti sconto1 = new gruppoapiComCrmClientein.DatiSconti();
                    sconto1.TIPO_COND = 'ZC2F';
                    sconto1.DATA_INVAL = fo.DataInizio;
                    sconto1.DATA_FNVAL = fo.DataFine;
                    sconto1.CLUSTER = '50';
                    sconto1.FAM_PRODOTTI = prodotti.substring(0,2);
                    sconto1.SCONTOUNIT = fo.Valore;
                    datiSconti.add(sconto1);
                }
            }else if(nomeProdotto == 'PEDAGGI'){
                gruppoapiComCrmClientein.DatiSconti sconto1 = new gruppoapiComCrmClientein.DatiSconti();
                sconto1.TIPO_COND = 'ZCOP';
                sconto1.SCONTOUNIT = fo.Valore;
                datiSconti.add(sconto1);
            }else if(nomeProdotto == 'RETI PARTNER'){
                List<String> prodottiList = fo.Prodotti.split(',');
                for(String prodotti : prodottiList){
                    prodotti = prodotti.trim();
                    gruppoapiComCrmClientein.DatiSconti sconto1 = new gruppoapiComCrmClientein.DatiSconti();
                    sconto1.TIPO_COND = 'ZC2V';
                    sconto1.FAM_PRODOTTI = prodotti.substring(0,2);
                    If(fo.Volume == 'IP MATIC')                        sconto1.CLUSTER = '50';
                    else If(fo.Volume == 'RETI PARTNER')               sconto1.CLUSTER = 'RE';
                    System.debug('CLUSTER RETI: ' +sconto1.CLUSTER);
                    datiSconti.add(sconto1);
                }
            }else if(nomeProdotto == 'SCONTO BASE'){
                List<String> prodottiList = fo.Prodotti.split(',');
                for(String prodotti : prodottiList){
                    prodotti = prodotti.trim();
                    gruppoapiComCrmClientein.DatiSconti sconto1 = new gruppoapiComCrmClientein.DatiSconti();
                    sconto1.TIPO_COND = 'ZCO5';
                    sconto1.FAM_PRODOTTI = prodotti.substring(0,2);
                    sconto1.SCONTOUNIT = fo.Valore;
                    sconto1.DATA_INVAL = fo.DataInizio;
                    sconto1.DATA_FNVAL = fo.DataFine;
                    datiSconti.add(sconto1);
                }
            }else if(nomeProdotto == 'SCONTO SITE'){
                fo.Prodotti=fo.Prodotti.replace(';', ',');
                List<String> prodottiList = fo.Prodotti.split(',');
                
                for(String prodotti : prodottiList){
                    system.debug('****Prodotto '+prodotti);
                    prodotti = prodotti.trim();
                    gruppoapiComCrmClientein.DatiSconti sconto1 = new gruppoapiComCrmClientein.DatiSconti();
                    sconto1.TIPO_COND = 'ZCO3';
                    sconto1.FAM_PRODOTTI = prodotti.substring(0,2);
                    sconto1.SCONTOUNIT = fo.Valore;
                    sconto1.PV = fo.Rinnovabile;
                    sconto1.CLUSTER = fo.Volume;
                    datiSconti.add(sconto1);
                }
            }else if(nomeProdotto == 'SCONTO PACCHETTO'){
                //List<String> prodottiList = fo.Prodotti.split(',');
                //for(String prodotti : prodottiList){
                //prodotti = prodotti.trim();
                gruppoapiComCrmClientein.DatiSconti sconto1 = new gruppoapiComCrmClientein.DatiSconti();
                sconto1.TIPO_COND = 'ZCO4';
                sconto1.SCONTOUNIT = fo.Valore;
                sconto1.DATA_INVAL = fo.DataInizio;
                sconto1.DATA_FNVAL = fo.DataFine;
                datiSconti.add(sconto1);
                //}
            }
        }
        
        System.debug('datiSconti: ' +datiSconti);
        
        //sezione divisioni
        List<gruppoapiComCrmClientein.DatiDivisioni> datiDivisioni= new List<gruppoapiComCrmClientein.DatiDivisioni>();
        for(API_Divisione__c div : divisioneList){
            gruppoapiComCrmClientein.DatiDivisioni divisione1= new gruppoapiComCrmClientein.DatiDivisioni();
            divisione1.DESC_DIV = div.API_Descrizione__c;
            divisione1.TIPO_DIV = '';
            divisione1.ID_DIV = divisioneMap.get(div.id);
            datiDivisioni.add(divisione1);
        }
        
        for(API_Parco_mezzi__c parchi : parchiList){
            gruppoapiComCrmClientein.DatiDivisioni divisione1= new gruppoapiComCrmClientein.DatiDivisioni();
            divisione1.DESC_DIV = parchi.API_Descrizione__c;
            divisione1.TIPO_DIV = 'P';
            divisione1.ID_DIV = parchiMap.get(parchi.Id);
            datiDivisioni.add(divisione1);
        }
        
        //sezione Bonus
        
        //Creo una mappa con chiave frequenza-volume-prodotti e un l'oggetto custom
        Map<String,fasceObject> fasceMap = new Map<String,fasceObject>(); 
        
        List<gruppoapiComCrmClientein.DatiBonus> datiBonus= new List<gruppoapiComCrmClientein.DatiBonus>();
        for (String idQLI : qlixMapBonus.keySet()){
            List<API_QuoteLineItemX__c> qlixListNEW = new List<API_QuoteLineItemX__c>();
            qlixListNEW = qlixMapBonus.get(idQLI);
            string tipo;
            string codice;
            //istanzio l'oggetto custom
            fasceObject fasceObj = new fasceObject();
            System.debug('qlixListNEW' +qlixListNEW);
            System.debug('qlixListNEW SIZE: ' +qlixListNEW.size());
            for(API_QuoteLineItemX__c qlix :qlixListNEW){
                system.debug('QLIX: ' +qlix);
                if(qlix.API_NomeProdotto__c == 'Bonus')                                                     fasceObj.TipoBonus = 'Bonus';
                else                                                                                        fasceObj.TipoBonus = 'Bonus Garanzia';
                if(qlix.API_DeveloperNameMetadata__c == 'API_BonusPeriodicita')                             fasceObj.Periodicita = qlix.API_Valore__c;
                if(qlix.API_DeveloperNameMetadata__c == 'API_BonusProdotti')                                fasceObj.Prodotti = qlix.API_Valore__c;
                if(qlix.API_DeveloperNameMetadata__c == 'API_BonusVolume')                                  fasceObj.Volume = qlix.API_Valore__c;
                if(qlix.API_DeveloperNameMetadata__c == 'API_BonusValore')                                  fasceObj.Valore = qlix.API_Valore__c;
                if(qlix.API_DeveloperNameMetadata__c == 'Api_BonusTipo')                                    fasceObj.Tipo = qlix.API_Valore__c;
                //if(qlix.API_DeveloperNameMetadata__c == 'API_BonusDataInizioValidita')                      fasceObj.DataInizio = qlix.API_Valore__c;
//if(qlix.API_DeveloperNameMetadata__c == 'API_BonusDataFineValidita')                        fasceObj.DataFine = qlix.API_Valore__c;
                if(qlix.API_DeveloperNameMetadata__c == 'API_BonusSitoRete')                                fasceObj.Sito = qlix.API_Valore__c;
                if(qlix.API_DeveloperNameMetadata__c == 'API_BonusRinnovabile')                             fasceObj.Rinnovabile = qlix.API_Valore__c;
            }
            if(fasceObj.TipoBonus == 'Bonus'){
                List<String> prodottiList = fasceObj.Prodotti.split(',');
                
                for(String prod : prodottiList){
                    String key = fasceObj.Periodicita + fasceObj.Tipo + prod;
                    
                    if(fasceMap.get(key) == null){
                        system.debug('Sono if');
                        fasceObject fo = new fasceObject();
                        fo.TipoBonus = fasceObj.TipoBonus;
                        fo.Periodicita = fasceObj.Periodicita;
                        fo.Prodotti = prod;
                        fo.volume = fasceObj.Volume;
                        fo.Valore = fasceObj.Valore;
                        fo.Tipo = fasceObj.Tipo;
                        fo.Sito = fasceObj.Sito;
                        fo.Rinnovabile = fasceObj.Rinnovabile;
                        fo.volumeImportoMap = new Map<Decimal,String>();
                        fo.volumeImportoMap.put(Decimal.valueOf(fasceObj.volume),fasceObj.Valore);
                        fasceMap.put(key,fo);
                    }else{
                        system.debug('Sono else');
                        fasceObject fo = fasceMap.get(key);
                        system.debug('volumeImportoMap: ' +fo.volumeImportoMap);
                        fo.volumeImportoMap.put(Decimal.valueOf(fasceObj.volume),fasceObj.Valore);
                        fasceMap.put(key, fo);
                    }
                }
                system.debug('FASCE MAP: ' +fasceMap);
            }else{
                gruppoapiComCrmClientein.DatiBonus bonus1= new gruppoapiComCrmClientein.DatiBonus();
                bonus1.TIPOLOGIA = '1';
                bonus1.TIPO_BONUS = '02';
                bonus1.FREQUENZA = '12';
                bonus1.FAM_PRODOTTI = '99';
                bonus1.VALIDO_IP_SERV = 'X';
                bonus1.VALIDO_IPMATIC = 'X';
                bonus1.VALIDO_RETI_PARTNER = 'X';
                gruppoapiComCrmClientein.Fasce fasce= new gruppoapiComCrmClientein.Fasce();
                fasce.ID = '01';
                fasce.LITRI = '1';
                fasce.IMPORTO = fasceObj.Valore;
                
                gruppoapiComCrmClientein.Fasce fasce2= new gruppoapiComCrmClientein.Fasce();
                fasce2.ID = '02';
                fasce2.LITRI = '999999999';
                fasce2.IMPORTO = fasceObj.Valore;
                List<gruppoapiComCrmClientein.Fasce> fasceList= new List<gruppoapiComCrmClientein.Fasce>();
                fasceList.add(fasce);
                fasceList.add(fasce2);
                bonus1.FASCE = fasceList;
                datiBonus.add(bonus1);
                system.debug('FASCE LIST BONUS GARANZIA: ' +fasceList);
                system.debug('BONUS GARANZIA: ' +datiBonus);
            }
        }
        
        for(String keyMap : fasceMap.keySet()){
            fasceObject fo = fasceMap.get(keyMap);
            
            if(fo.TipoBonus == 'Bonus'){
                gruppoapiComCrmClientein.DatiBonus bonus1= new gruppoapiComCrmClientein.DatiBonus();
                boolean check = true;
                bonus1.TIPOLOGIA = '0';
                bonus1.TIPO_BONUS = '02';
                if(fo.Periodicita == 'mensile')                                              bonus1.FREQUENZA = '01';
                else if(fo.Periodicita== 'trimestrale')                                      bonus1.FREQUENZA = '03';
                else if(fo.Periodicita == 'semestrale')                                      bonus1.FREQUENZA = '06';
                else if(fo.Periodicita == 'annuale')                                         bonus1.FREQUENZA = '12';
                system.debug('PRODOTTI:  ' +fo.Prodotti);
                if(fo.prodotti.contains('00'))                                  bonus1.FAM_PRODOTTI = '00';
                if(fo.prodotti.contains('02'))                                  bonus1.FAM_PRODOTTI = '02';
                if(fo.prodotti.contains('03'))                                  bonus1.FAM_PRODOTTI = '03';
                if(fo.prodotti.contains('04'))                                  bonus1.FAM_PRODOTTI = '04';
                if(fo.prodotti.contains('06'))                                  bonus1.FAM_PRODOTTI = '06';
                if(fo.prodotti.contains('09'))                                  bonus1.FAM_PRODOTTI = '09';
                if(fo.prodotti.contains('97'))                                  bonus1.FAM_PRODOTTI = '97';
                if(fo.prodotti.contains('98'))                                  bonus1.FAM_PRODOTTI = '98';
                if(fo.prodotti.contains('99'))                                  bonus1.FAM_PRODOTTI = '99';
                if(fo.prodotti.contains('AA'))                                  bonus1.FAM_PRODOTTI = 'AA';
                
                bonus1.VALIDO_IP_SERV = 'X';
                bonus1.VALIDO_IPMATIC = '';
                bonus1.VALIDO_RETI_PARTNER = 'X';
                if(fo.Rinnovabile != null)                                                   bonus1.RINNOVO = fo.Rinnovabile;
                else                                                                         bonus1.RINNOVO = 'NO';
                System.debug('BONUS1 PRODOTTI: ' +bonus1.FAM_PRODOTTI);
                List<Decimal> decimalList = new List<Decimal>();
                decimalList.addAll(fo.volumeImportoMap.keyset());
                decimalList.sort();
                system.debug('Ordine decimalList: ' +decimalList);
                integer o = 1;
                String ultimoImporto;
                
                List<gruppoapiComCrmClientein.Fasce> fasceList= new List<gruppoapiComCrmClientein.Fasce>();
                for(Decimal keyDecimal : decimalList){
                    gruppoapiComCrmClientein.Fasce fasce= new gruppoapiComCrmClientein.Fasce();
                    string id;
                    if(o <= 9)                          id = '0'+ String.valueOf(o);
                    if(o >= 10 && o <= 99)              id = String.valueOf(o);
                    
                    fasce.ID = id;
                    
                    fasce.IMPORTO = fo.volumeImportoMap.get(keyDecimal);
                    
                    fasce.LITRI = String.valueOf(keyDecimal);
                    o++;
                    ultimoImporto = fo.volumeImportoMap.get(keyDecimal);
                    fasceList.add(fasce);
                }
                gruppoapiComCrmClientein.Fasce fasce= new gruppoapiComCrmClientein.Fasce();
                string idUltimaFascia;
                if(o <= 9)                                                  idUltimaFascia = '0'+ String.valueOf(o);
                if(o >= 10 && o <= 99)                                      idUltimaFascia =  String.valueOf(o);
                fasce.ID = idUltimaFascia;
                fasce.LITRI = '999999999';
                fasce.IMPORTO = ultimoImporto;
                fasceList.add(fasce);
                bonus1.FASCE = fasceList;
                System.debug('FASCE LIST: ' +fasceList);
                
                datiBonus.add(bonus1);
                
            }
            System.debug('datiBonus ' +datiBonus);
        }
        
        //dati conti carte con dentro le carte
        List<gruppoapiComCrmClientein.DatiGruppiCarte> datiGruppiCarte= new List<gruppoapiComCrmClientein.DatiGruppiCarte>();
        for(API_ContoCarte__c cc : contoCarteList){
            gruppoapiComCrmClientein.DatiGruppiCarte gruppoCarte1= new gruppoapiComCrmClientein.DatiGruppiCarte();
            gruppoCarte1.ID_CON = contoCarteMap.get(cc.Id);
            gruppoCarte1.DESC_CA = cc.API_DescrizioneGruppoCarte__c;
            system.debug('DIVISIONE MAP: ' +divisioneMap);
            if(divisioneMap.get(cc.API_RiferimentoDivisione__c) != null){
                gruppoCarte1.ID_DIV = divisioneMap.get(cc.API_RiferimentoDivisione__c);
                system.debug('ID_DIV: ' +gruppoCarte1.ID_DIV);
            }
            gruppoCarte1.RIN_AUTOM = 'X';
            gruppoCarte1.TIPOPIN = cc.API_TipoPIN__c.substring(0,1);
            System.debug('TIPO PIN GC: ' +gruppoCarte1.TIPOPIN); 
            if(cc.API_TipoPIN__c.contains('driver')){
                if(cc.API_NumeroPinAutista__c < 10)                                                     gruppoCarte1.NUMEROPINAUT = '00000' + String.valueOf(cc.API_NumeroPinAutista__c);
                else if(cc.API_NumeroPinAutista__c >= 10 && cc.API_NumeroPinAutista__c < 100)           gruppoCarte1.NUMEROPINAUT = '0000' + String.valueOf(cc.API_NumeroPinAutista__c);
                else if(cc.API_NumeroPinAutista__c >= 100 && cc.API_NumeroPinAutista__c < 1000)         gruppoCarte1.NUMEROPINAUT = '000' + String.valueOf(cc.API_NumeroPinAutista__c);
                else if(cc.API_NumeroPinAutista__c >= 1000 && cc.API_NumeroPinAutista__c < 10000)       gruppoCarte1.NUMEROPINAUT = '00' + String.valueOf(cc.API_NumeroPinAutista__c);
            }else if (cc.API_TipoPIN__c.contains('standard'))                                           gruppoCarte1.NUMEROPINAUT = '000000';
            System.debug('NUMERO PIN AUTISTA: ' +gruppoCarte1.NUMEROPINAUT);
            gruppoCarte1.NUMEROPINAUT = String.valueOf(cc.API_NumeroPinAutista__c);
            gruppoCarte1.PLASTIC_TP = '00';
            if(cc.API_TipologiaVeicoli__c == '1' || cc.API_TipologiaVeicoli__c == 'Auto (200€)')                                gruppoCarte1.TIPOVEICOLO = '1';
            else if(cc.API_TipologiaVeicoli__c == '2' || cc.API_TipologiaVeicoli__c == 'Furgone (650€)')                        gruppoCarte1.TIPOVEICOLO = '2'; 
            else if(cc.API_TipologiaVeicoli__c == '3' || cc.API_TipologiaVeicoli__c == 'Doppio serbatoio (1.800 €)')            gruppoCarte1.TIPOVEICOLO = '3';
            else if(cc.API_TipologiaVeicoli__c == '4' || cc.API_TipologiaVeicoli__c == 'Camion/Bus (1.300 €)')                  gruppoCarte1.TIPOVEICOLO = '4';
            else if(cc.API_TipologiaVeicoli__c == '9' || cc.API_TipologiaVeicoli__c == 'Tutti i veicoli (200 €)')               gruppoCarte1.TIPOVEICOLO = '9';
            else if(cc.API_TipologiaVeicoli__c == '5' || cc.API_TipologiaVeicoli__c == 'Motocicli (50 €)')                      gruppoCarte1.TIPOVEICOLO = '5';
            
            gruppoCarte1.TIPOVEICOLO = cc.API_TipologiaVeicoli__c;
            if(cc.API_TipoOperat__c != null)                      gruppoCarte1.TIPODIALOGO = cc.API_TipoOperat__c.substring(0,1);
            if(cc.API_TipologiaVeicoli__c == '1' || cc.API_TipologiaVeicoli__c == 'Auto (200€)'){                
                gruppoCarte1.LIMSPESA_GG = '200';
            }else if(cc.API_TipologiaVeicoli__c == '2' || cc.API_TipologiaVeicoli__c == 'Furgone (650€)'){          
                gruppoCarte1.LIMSPESA_GG = '650';
            }else if(cc.API_TipologiaVeicoli__c == '3' || cc.API_TipologiaVeicoli__c == 'Doppio serbatoio (1.800 €)'){          
                gruppoCarte1.LIMSPESA_GG = '1800';
            }else if(cc.API_TipologiaVeicoli__c == '4' || cc.API_TipologiaVeicoli__c == 'Camion/Bus (1.300 €)'){         
                gruppoCarte1.LIMSPESA_GG = '1300';
            }else if(cc.API_TipologiaVeicoli__c == '9' || cc.API_TipologiaVeicoli__c == 'Tutti i veicoli (200 €)'){          
                gruppoCarte1.LIMSPESA_GG = '200';
            }else if(cc.API_TipologiaVeicoli__c == '5' || cc.API_TipologiaVeicoli__c == 'Motocicli (50 €)'){         
                gruppoCarte1.LIMSPESA_GG = '50';
            }
            gruppoCarte1.LIMSPESA_MM = '0';
            gruppoCarte1.CHECK_KM = '';
            
            //prodotti e servizi
            if(cc.API_ProdottiAmmessi__c == 'Benzina servito e self' && cc.API_ServiziInStazione__c.contains('Nessuno'))                             gruppoCarte1.PRODOTTI ='A';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina self' && cc.API_ServiziInStazione__c.contains('Nessuno'))                                  gruppoCarte1.PRODOTTI ='B';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina' && cc.API_ServiziInStazione__c.contains('Nessuno'))                                       gruppoCarte1.PRODOTTI ='A';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio servito e self' && cc.API_ServiziInStazione__c.contains('Nessuno'))                        gruppoCarte1.PRODOTTI ='C';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio self' && cc.API_ServiziInStazione__c.contains('Nessuno'))                                  gruppoCarte1.PRODOTTI ='D';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio' && cc.API_ServiziInStazione__c.contains('Nessuno'))                                       gruppoCarte1.PRODOTTI ='C';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale servito e self' && cc.API_ServiziInStazione__c.contains('Nessuno'))               gruppoCarte1.PRODOTTI ='E';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale self' && cc.API_ServiziInStazione__c.contains('Nessuno'))                         gruppoCarte1.PRODOTTI ='F';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale' && cc.API_ServiziInStazione__c.contains('Nessuno'))                              gruppoCarte1.PRODOTTI ='E';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio + Gasolio Speciale servito e self' && cc.API_ServiziInStazione__c.contains('Nessuno'))     gruppoCarte1.PRODOTTI ='G';
            else if(cc.API_ProdottiAmmessi__c == 'GPL' && cc.API_ServiziInStazione__c.contains('Nessuno'))                                           gruppoCarte1.PRODOTTI ='H';
            else if(cc.API_ProdottiAmmessi__c == 'Metano' && cc.API_ServiziInStazione__c.contains('Nessuno'))                                        gruppoCarte1.PRODOTTI ='I';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina servito e self  + Gpl + Metano' && cc.API_ServiziInStazione__c.contains('Nessuno'))        gruppoCarte1.PRODOTTI ='J';
            else if(cc.API_ProdottiAmmessi__c.contains('Tutti i carburanti') && cc.API_ServiziInStazione__c.contains('Nessuno'))                     gruppoCarte1.PRODOTTI ='K';
            
            else if(cc.API_ProdottiAmmessi__c == 'Benzina servito e self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                       gruppoCarte1.PRODOTTI ='L';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina servito e self')                                                                              gruppoCarte1.PRODOTTI ='W';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                                      gruppoCarte1.PRODOTTI ='L';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina')                                                                                             gruppoCarte1.PRODOTTI ='W';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                                 gruppoCarte1.PRODOTTI ='M';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina self')                                                                                        gruppoCarte1.PRODOTTI ='X';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio servito e self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                       gruppoCarte1.PRODOTTI ='N';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio servito e self')                                                                              gruppoCarte1.PRODOTTI ='Y';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                                      gruppoCarte1.PRODOTTI ='N';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio')                                                                                             gruppoCarte1.PRODOTTI ='Y';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                                 gruppoCarte1.PRODOTTI ='O';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio self')                                                                                        gruppoCarte1.PRODOTTI ='Z';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale servito e self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')              gruppoCarte1.PRODOTTI ='P';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale servito e self')                                                                     gruppoCarte1.PRODOTTI ='0';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                             gruppoCarte1.PRODOTTI ='P';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale')                                                                                    gruppoCarte1.PRODOTTI ='0';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                        gruppoCarte1.PRODOTTI ='Q';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio Speciale self')                                                                               gruppoCarte1.PRODOTTI ='1';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio + Gasolio Speciale servito e self' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')    gruppoCarte1.PRODOTTI ='R';
            else if(cc.API_ProdottiAmmessi__c == 'Gasolio + Gasolio Speciale servito e self')                                                           gruppoCarte1.PRODOTTI ='2';
            else if(cc.API_ProdottiAmmessi__c == 'GPL' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                                          gruppoCarte1.PRODOTTI ='S';
            else if(cc.API_ProdottiAmmessi__c == 'GPL')                                                                                                 gruppoCarte1.PRODOTTI ='3';
            else if(cc.API_ProdottiAmmessi__c == 'Metano' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                                       gruppoCarte1.PRODOTTI ='T';
            else if(cc.API_ProdottiAmmessi__c == 'Metano')                                                                                              gruppoCarte1.PRODOTTI ='4';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina servito e self  + Gpl + Metano' && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')       gruppoCarte1.PRODOTTI ='U';
            else if(cc.API_ProdottiAmmessi__c == 'Benzina servito e self  + Gpl + Metano')                                                              gruppoCarte1.PRODOTTI ='5'; 
            else if(cc.API_ProdottiAmmessi__c.contains('Tutti i carburanti') && cc.API_ServiziInStazione__c == 'AdBlu da erogatore')                    gruppoCarte1.PRODOTTI ='V';
            else if(cc.API_ProdottiAmmessi__c.contains('Tutti i carburanti'))                                                                           gruppoCarte1.PRODOTTI ='6';
            
            datiGruppiCarte.add(gruppoCarte1);
        }
        
        system.debug('datiGruppiCarte: ' +datiGruppiCarte);
        
        //CARTE 
        List<gruppoapiComCrmClientein.DatiCarte_element> datiCarte= new List<gruppoapiComCrmClientein.DatiCarte_element>();
        for(API_Carta__c carta : cartaList){
            gruppoapiComCrmClientein.DatiCarte_element datiCarte1= new gruppoapiComCrmClientein.DatiCarte_element();
            datiCarte1.ID_CAR = carteMap.get(carta.Id);
            if(contoCarteMap.get(carta.API_ContoCarte__c) != null)      datiCarte1.ID_CON = contoCarteMap.get(carta.API_ContoCarte__c);
            datiCarte1.TARGA_NOME = carta.API_Numero_di_targa__c;
            datiCarte1.PLASTIC_TP = '00';
            if(carta.API_TipoVeicolo__c == '1' || carta.API_TipoVeicolo__c == 'Auto (200€)')                            datiCarte1.TIPOVEICOLO = '1';
            else if(carta.API_TipoVeicolo__c == '2' || carta.API_TipoVeicolo__c == 'Furgone (650€)')                    datiCarte1.TIPOVEICOLO = '2'; 
            else if(carta.API_TipoVeicolo__c == '3' || carta.API_TipoVeicolo__c == 'Doppio serbatoio (1.800 €)')        datiCarte1.TIPOVEICOLO = '3';
            else if(carta.API_TipoVeicolo__c == '4' || carta.API_TipoVeicolo__c == 'Camion/Bus (1.300 €)')              datiCarte1.TIPOVEICOLO = '4';
            else if(carta.API_TipoVeicolo__c == '9' || carta.API_TipoVeicolo__c == 'Tutti i veicoli (200 €)')           datiCarte1.TIPOVEICOLO = '9';
            else if(carta.API_TipoVeicolo__c == '5' || carta.API_TipoVeicolo__c == 'Motocicli (50 €)')                  datiCarte1.TIPOVEICOLO = '5';
            
            System.debug('TIPO VEICOLO: ' +datiCarte1.TIPOVEICOLO);
            if(carta.API_Tipo_Operazione__c!=null)            datiCarte1.TIPODIALOGO = carta.API_Tipo_Operazione__c.substring(0,1);
            else return 'Errore di invio: manca il tipo di informazione da inserire in stazione per una delle carte.';
            if(carta.API_TipoVeicolo__c == '1' || carta.API_TipoVeicolo__c == 'Auto (200€)'){                           
                datiCarte1.LIMSPESA_GG = '200';
            }else if(carta.API_TipoVeicolo__c == '2' || carta.API_TipoVeicolo__c == 'Furgone (650€)'){  
                datiCarte1.LIMSPESA_GG = '650';
            }else if(carta.API_TipoVeicolo__c == '3' || carta.API_TipoVeicolo__c == 'Doppio serbatoio (1.800 €)'){
                datiCarte1.LIMSPESA_GG = '1800';
            }else if(carta.API_TipoVeicolo__c == '4' || carta.API_TipoVeicolo__c == 'Camion/Bus (1.300 €)'){
                datiCarte1.LIMSPESA_GG = '1300';
            }else if(carta.API_TipoVeicolo__c == '9' || carta.API_TipoVeicolo__c == 'Tutti i veicoli (200 €)'){                    
                datiCarte1.LIMSPESA_GG = '200';
            }else if(carta.API_TipoVeicolo__c == '5' || carta.API_TipoVeicolo__c == 'Motocicli (50 €)'){    
                datiCarte1.LIMSPESA_GG = '50';
            }
            if(carta.API_Check_KM__c == true)        datiCarte1.CHECK_KM = 'X';
            else                                    datiCarte1.CHECK_KM = '';
            
            if(carta.API_InformazioniAggiuntive__c == null)        datiCarte1.CARD_FREE_SPACE = '';
            else                                    datiCarte1.CARD_FREE_SPACE = carta.API_InformazioniAggiuntive__c;
            
            if(carta.API_Parco_mezzi__c!=null) datiCarte1.DIV_PARCO =parchiMap.get(carta.API_Parco_mezzi__c);
           
            //prodotti e servizi
            if(carta.API_ProdottiAutorizzati__c == 'Benzina servito e self' && carta.API_ServiziStazione__c.contains('Nessuno'))                             datiCarte1.PRODOTTI ='A';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina self' && carta.API_ServiziStazione__c.contains('Nessuno'))                                  datiCarte1.PRODOTTI ='B';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina' && carta.API_ServiziStazione__c.contains('Nessuno'))                                       datiCarte1.PRODOTTI ='A';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio servito e self' && carta.API_ServiziStazione__c.contains('Nessuno'))                        datiCarte1.PRODOTTI ='C';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio self' && carta.API_ServiziStazione__c.contains('Nessuno'))                                  datiCarte1.PRODOTTI ='D';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio' && carta.API_ServiziStazione__c.contains('Nessuno'))                                       datiCarte1.PRODOTTI ='C';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale servito e self' && carta.API_ServiziStazione__c.contains('Nessuno'))               datiCarte1.PRODOTTI ='E';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale self' && carta.API_ServiziStazione__c.contains('Nessuno'))                         datiCarte1.PRODOTTI ='F';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale' && carta.API_ServiziStazione__c.contains('Nessuno'))                              datiCarte1.PRODOTTI ='E';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio + Gasolio Speciale servito e self' && carta.API_ServiziStazione__c.contains('Nessuno'))     datiCarte1.PRODOTTI ='G';
            else if(carta.API_ProdottiAutorizzati__c == 'GPL' && carta.API_ServiziStazione__c.contains('Nessuno'))                                           datiCarte1.PRODOTTI ='H';
            else if(carta.API_ProdottiAutorizzati__c == 'Metano' && carta.API_ServiziStazione__c.contains('Nessuno'))                                        datiCarte1.PRODOTTI ='I';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina servito e self  + Gpl + Metano' && carta.API_ServiziStazione__c.contains('Nessuno'))        datiCarte1.PRODOTTI ='J';
            else if(carta.API_ProdottiAutorizzati__c.contains('Tutti i carburanti') && carta.API_ServiziStazione__c.contains('Nessuno'))                     datiCarte1.PRODOTTI ='K';
            
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina servito e self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                        datiCarte1.PRODOTTI ='L';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina servito e self')                                                                                datiCarte1.PRODOTTI ='W';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                                       datiCarte1.PRODOTTI ='L';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina')                                                                                               datiCarte1.PRODOTTI ='W';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                                  datiCarte1.PRODOTTI ='M';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina self')                                                                                          datiCarte1.PRODOTTI ='X';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio servito e self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                        datiCarte1.PRODOTTI ='N';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio servito e self')                                                                                datiCarte1.PRODOTTI ='Y';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                                       datiCarte1.PRODOTTI ='N';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio')                                                                                               datiCarte1.PRODOTTI ='Y';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                                  datiCarte1.PRODOTTI ='O';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio self')                                                                                          datiCarte1.PRODOTTI ='Z';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale servito e self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')               datiCarte1.PRODOTTI ='P';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale servito e self')                                                                       datiCarte1.PRODOTTI ='0';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                              datiCarte1.PRODOTTI ='P';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale')                                                                                      datiCarte1.PRODOTTI ='0';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                         datiCarte1.PRODOTTI ='Q';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio Speciale self')                                                                                 datiCarte1.PRODOTTI ='1';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio + Gasolio Speciale servito e self' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')     datiCarte1.PRODOTTI ='R';
            else if(carta.API_ProdottiAutorizzati__c == 'Gasolio + Gasolio Speciale servito e self')                                                             datiCarte1.PRODOTTI ='2';
            else if(carta.API_ProdottiAutorizzati__c == 'GPL' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                                           datiCarte1.PRODOTTI ='S';
            else if(carta.API_ProdottiAutorizzati__c == 'GPL')                                                                                                   datiCarte1.PRODOTTI ='3';
            else if(carta.API_ProdottiAutorizzati__c == 'Metano' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                                        datiCarte1.PRODOTTI ='T';
            else if(carta.API_ProdottiAutorizzati__c == 'Metano')                                                                                                datiCarte1.PRODOTTI ='4';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina servito e self  + Gpl + Metano' && carta.API_ServiziStazione__c == 'AdBlu da erogatore')        datiCarte1.PRODOTTI ='U';
            else if(carta.API_ProdottiAutorizzati__c == 'Benzina servito e self  + Gpl + Metano')                                                                datiCarte1.PRODOTTI ='5';
            else if(carta.API_ProdottiAutorizzati__c.contains('Tutti i carburanti') && carta.API_ServiziStazione__c == 'AdBlu da erogatore')                     datiCarte1.PRODOTTI ='V';
            else if(carta.API_ProdottiAutorizzati__c.contains('Tutti i carburanti'))                                                                             datiCarte1.PRODOTTI ='6';
            
            
            datiCarte.add(datiCarte1);
        }
        
        for(gruppoapiComCrmClientein.DatiGruppiCarte cc : datiGruppiCarte){
            List <gruppoapiComCrmClientein.DatiCarte_element>  carteList = new  List <gruppoapiComCrmClientein.DatiCarte_element> ();
            for(gruppoapiComCrmClientein.DatiCarte_element c : datiCarte){
                if(c.ID_CON == cc.ID_CON){
                    carteList.add(c);
                }
            }
            cc.DatiCarte = carteList;
        }
        
        system.debug('datiCarte: ' +datiCarte);
        system.debug('datiGruppiCarta DEF: ' +datiGruppiCarte);
        
        /*sapComSprxEpCustZ.binding proxy= new sapComSprxEpCustZ.binding();
        proxy.inputHttpHeaders_x= new Map<String,String>();
        proxy.inputHttpHeaders_x.put('Content-type', 'text/xml');
        
        //AUTENTICAZIONE
        Blob headerValue = Blob.valueOf(Label.API_UsernameSAP + ':' + Label.API_PasswordSAP);
        System.debug(Label.API_UsernameSAP);
        System.debug(Label.API_PasswordSAP);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        proxy.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        
        String returnCode;
        
        returnCode = proxy.ClienteIn(element,indirizzi,datiAmministrativi, datiBancari, datiCrm, datiFatturazione, datiSconti, datiDivisioni, datiBonus,datiGruppiCarte);
        System.debug('returnCode: ' +returnCode);
        return returnCode;*/
        gruppoapiComCrmClientein.HTTPS_Port proxy= new gruppoapiComCrmClientein.HTTPS_Port();
        proxy.inputHttpHeaders_x= new Map<String,String>();
        proxy.inputHttpHeaders_x.put('Content-type', 'text/xml');
        
        //AUTENTICAZIONE
        Blob headerValue = Blob.valueOf(Label.API_UsernameSAP + ':' + Label.API_PasswordSAP);
        System.debug(Label.API_UsernameSAP);
        System.debug(Label.API_PasswordSAP);
        String authorizationHeader = Label.BASIC+' ' +EncodingUtil.base64Encode(headerValue);
        proxy.inputHttpHeaders_x.put('Authorization',authorizationHeader);
        
        String returnCode;
        
        returnCode = proxy.SI_ClienteInResponse(element,indirizzi,datiAmministrativi, datiBancari, datiCrm, datiFatturazione, datiSconti, datiDivisioni, datiBonus,datiGruppiCarte);
        System.debug('returnCode: ' +returnCode);
        return returnCode;
       
        
        
    }

    
    public class fasceObject{
        public String Valore                                   {get; set;}
        public String Tipo                                     {get; set;}
        public String DataInizio                               {get; set;}
        public String DataFine                                 {get; set;}
        public String Volume                                   {get; set;}
        public String Periodicita                              {get; set;}
        public String Sito                                     {get; set;}
        public String TipoBonus                                {get; set;}
        public String Prodotti                                 {get; set;}
        public String Rinnovabile                              {get; set;}
        public Map<Decimal,String> volumeImportoMap             {get; set;}
    }
}