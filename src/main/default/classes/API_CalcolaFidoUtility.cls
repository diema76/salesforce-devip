public class API_CalcolaFidoUtility {
   public static void calcolaFido (List<Quote> quoteList){
         Decimal prezzo=1.5;
         List<API_PrezzoGasolioEuroLitro__mdt> prezzoList=[select id, API_Valore__c from API_PrezzoGasolioEuroLitro__mdt ];
         if(prezzoList.size()>0)
             prezzo=prezzoList[0].API_Valore__c;
         List<API_FidoCalcolato__mdt> fattori= [select id,label, API_TipoCliente__c, API_Fatturazione__c, API_CondizioniPagamento__c, API_Plafond__c, API_Fattore__c from API_FidoCalcolato__mdt];
         Map<String, Decimal> mapFattori= new Map<String, Decimal>();
         for(API_FidoCalcolato__mdt f: fattori){
             mapFattori.put(f.label, f.API_Fattore__c);
         }
         for(Quote q: quoteList){
             if(q.API_PrevisioneConsumi__c!=null){
                 Decimal pedaggi=0;
                 if(q.API_PrevisionePedaggi__c!=null)
                     pedaggi= q.API_PrevisionePedaggi__c;
                 Decimal fidoConsumo= (q.API_PrevisioneConsumi__c * prezzo)+pedaggi;
                 String labelFattore='';
                 if(q.API_Tipo_fido__c!=null && q.API_Tipo_fido__c=='IFI')
                     labelFattore+='Ceduto';
                 else if(q.API_Tipo_fido__c!=null && q.API_Tipo_fido__c!='IFI')
                     labelFattore+='NonCeduto';
                 if(q.API_Fatturazione__c!=null)
                 	labelFattore+=q.API_Fatturazione__c;
                 if(q.API_Periodo_di_spendibilita_picklist__c!=null)
                     labelFattore+=q.API_Periodo_di_spendibilita_picklist__c;
                 if(q.API_CondizioniDiPagamentoFormula__c!=null)
                     labelFattore+=q.API_CondizioniDiPagamentoFormula__c;
                 Decimal fattoreMoltiplicativo=mapFattori.get(labelFattore);
                 Decimal fidoCalcolato=0;
                 if(fattoreMoltiplicativo!=null)
                     fidoCalcolato=(fidoConsumo*fattoreMoltiplicativo).round();
                 q.API_FidoCalcolatoNuovaFormula__c=fidoCalcolato;
             }
             
         }
     }
}