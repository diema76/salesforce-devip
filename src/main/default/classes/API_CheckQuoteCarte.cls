public class API_CheckQuoteCarte {

     /*metodo che controlla i documenti obbligatori*/
    public static void checkPresenzaCarte(List<Quote> quotes){
        List<Quote> quoteDaControllare= new List<Quote>();
        List<RecordType> rtList=[select id from RecordType where name='Contratto Quadro'];
        String cqId= rtList[0].Id;
        for(Quote q: quotes){
            if(q.Status!='Bozza' && !q.API_CheckControlloCarte__c && q.RecordTypeId!=cqId){
                quoteDaControllare.add(q);
            }
        }
        if(quoteDaControllare.size()>0){
            //per tutte le quote non in bozza che non hanno il flag devo controllare se hanno carte.
            //Se hanno le carte setto il flag
            //Se non hanno le carte do errore
            List<String> quoteId= new List<String>();
            for(Quote q: quoteDaControllare)
                quoteId.add(q.Id);
    		List<API_Carta__c> carte= [Select id, API_Quote__c from API_Carta__c where API_Quote__c in: quoteId];
            //creo la mappa quoteId- ListCarte trovate
            Map<String,List<API_Carta__c>> mapCarte= new Map<String,List<API_Carta__c>>();
            for(API_Carta__c c: carte){
                List<API_Carta__c> carteQuote= mapCarte.get(c.API_Quote__c);
                if(carteQuote==null)	carteQuote= new List<API_Carta__c>();
                carteQuote.add(c);
                mapCarte.put(c.API_Quote__c, carteQuote); 
            }
            for(Quote q: quoteDaControllare){
                List<API_Carta__c> carteTrovate=mapCarte.get(q.Id);
                if(carteTrovate== null || carteTrovate.size()==0){
                    q.addError('Non hai inserito carte per questa Domanda di Adesione');
                }else
                    q.API_CheckControlloCarte__c=true;
            }
            
        }
        
    }
}