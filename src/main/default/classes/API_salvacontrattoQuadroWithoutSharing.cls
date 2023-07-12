public without sharing class API_salvacontrattoQuadroWithoutSharing {

    @InvocableMethod
	public static void updateQuoteContrattoQuadro(List<String> par) {
       //il parametro in ingresso deve essere uno e di tipo lista quindi ho dovuto crere una lista con una stringa in cui c è l id della quote separato da - con l id del contratto quadro
        String quoteID= par[0].split('-')[0].trim();
        String contrattoQuadroID=par[0].split('-')[1].trim();
        Quote q= new Quote();
        q.Id= quoteID;
        q.API_Contratto_quadro__c =contrattoQuadroID;
        update q;
    }
}