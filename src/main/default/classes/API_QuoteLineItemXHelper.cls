public class API_QuoteLineItemXHelper {

    public static void checkCommissioneScontoIPMATIC(List<API_QuoteLineItemX__c> qlixList){
        //mi prendo gli id delle quote associate ai quoteLineItemX che sto inserendo
        Set<String> quoteIdSet= new Set<String>();
        for(API_QuoteLineItemX__c qlix: qlixList){
            quoteIdSet.add(qlix.API_QuoteID__c);
        }
        System.debug('#### QuoteID '+quoteIdSet);
        //mi prendo tutti i quotelineitem associati alle quote trovate
        List<QuoteLineItem> qlitems= [Select id, API_CodiceCliente_numero__c, Product2.Name, Product2.API_ProdottoLabel__c, Product2Id, QuoteId from QuoteLineItem where QuoteId in:quoteIdSet];
        Map<String, List<QuoteLineItem>> mapQuoteQLItem= new Map<String, List<QuoteLineItem>>();
        List<String> listQlitems= new List<String>();
        for(QuoteLineItem ql: qlitems){
            System.debug('### '+ ql.QuoteId);
            listQlitems.add(ql.Id);
            List<QuoteLineItem> listQl= mapQuoteQLItem.get(ql.QuoteId);
            if(listQl==null){
                listQl= new List<QuoteLineItem>();
            }
            listQl.add(ql);
            System.debug(listQl);
            mapQuoteQLItem.put(ql.QuoteId, listQl);
        }
        System.debug('La quote ha già '+qlitems.size());
        System.debug(qlitems);
        System.debug('MAPPA ');
        System.debug(mapQuoteQLItem);
        
        List<API_QuoteLineItemX__c> qlixRetrived= [select Id,API_NomeAttributo__c, API_NomeProdotto__c, API_QuoteLineItem__c, 
                                                   API_Valore__c, API_DeveloperNameMetadata__c, API_QuoteID__c from API_QuoteLineItemX__c
                                                  where API_QuoteLineItem__c in: listQlitems]; 
        Map<String,List<API_QuoteLineItemX__c>> mapQliXdeiprodottiGiaInseriti= new  Map<String,List<API_QuoteLineItemX__c>>();
        for(API_QuoteLineItemX__c qlixR : qlixRetrived){
           List<API_QuoteLineItemX__c> lqlixretrived= mapQliXdeiprodottiGiaInseriti.get(qlixR.API_QuoteLineItem__c);
            if(lqlixretrived==null)
                lqlixretrived= new List<API_QuoteLineItemX__c>();
            lqlixretrived.add(qlixR);
            mapQliXdeiprodottiGiaInseriti.put(qlixR.API_QuoteLineItem__c, lqlixretrived);
        }
        System.debug('#### MAp qlix già inseriti');
        System.debug(mapQliXdeiprodottiGiaInseriti);
        
        for(API_QuoteLineItemX__c q: qlixList){
            //a questo punto controllo: ho uno sconto rete IP Matic e sto inserendo una commissione? non posso farlo
            if(q.API_DeveloperNameMetadata__c=='API_ScontoSiteReteCodice' && q.API_Valore__c=='50'){
                System.debug('Sono nell if sto inserendo lo sconto IP MATIC');
                //ho uno sconto su rete IP Matic devo controllare se ho già la commissione
                String quotex= q.API_QuoteID__c;
                List<QuoteLineItem> qlitemDellaQuote= mapQuoteQLItem.get(quotex);
                if(qlitemDellaQuote!=null){
                    for(QuoteLineItem qlitem: qlitemDellaQuote){
                        System.debug('qlitem.Product2.Name '+qlitem.Product2.Name);
                        if(qlitem.Product2.Name=='Commissione IP Matic' && !q.API_Ereditato__c)
                            throw new IPMaticException('Non puoi inserire uno sconto su rete IP Matic perchè c è già una commissione IP MATIC'); 
                        else if(qlitem.Product2.Name=='Commissione IP Matic' && q.API_Ereditato__c){
                            //devo elimiare la commissione IPMatic messa di default
                            eliminaCommissioneIPMatic(qlitem);
                        }
                    }
                }
            }
            //viceversa: ho uno sconto su rete IP Matic e voglio inserire una commissione IPMatic
            else if(q.API_NomeProdotto__c=='Commissione IP Matic' && q.API_DeveloperNameMetadata__c=='API_CommissioneValore'){
                System.debug('Sono nell if sto inserendo commissione IP Matic');
                //devo vedere se c'è uno sconto rete su IPMatic
                System.debug('######'+q.API_QuoteLineItem__c);
                String quotex2= q.API_QuoteID__c;
                List<QuoteLineItem> qlitemDellaQuote= mapQuoteQLItem.get(quotex2);
                for(QuoteLineItem qyz: qlitemDellaQuote){
                    List<API_QuoteLineItemX__c> listaQXDaControllare= mapQliXdeiprodottiGiaInseriti.get(qyz.Id);
                    if(listaQXDaControllare!=null){
                        for(API_QuoteLineItemX__c qqqq: listaQXDaControllare){
                            System.debug(qqqq);
                            System.debug('@@@ '+qqqq.API_DeveloperNameMetadata__c);
                            System.debug('@@@ '+qqqq.API_Valore__c);
                             if(qqqq.API_DeveloperNameMetadata__c=='API_ScontoSiteReteCodice' && qqqq.API_Valore__c=='50')
                                 throw new IPMaticException('Non puoi inserire una commissione IP MATIC perchè c è già uno Sconto su rete IPMatic');
                        }
                    }
            }
            }
        }
        
    }
    
    public static void eliminaCommissioneIPMatic(QuoteLineItem q){
        List<API_QuoteLineItemX__c> qlix= [Select id from API_QuoteLineItemX__c where API_QuoteLineItem__c=: q.Id];
        delete qlix;
        delete q;
    }
    public class IPMaticException extends Exception {}

}