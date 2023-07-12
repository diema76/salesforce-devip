public without sharing class API_ContrattiQuadriWithoutSharing {
   @AuraEnabled
   public static List<Quote> getContrattiQuadri() {
      List<String> contrattiQuadriTrovati= new  List<String>();
       List<Quote> contrattiQuadri= new List<Quote>();
      String userID= UserInfo.getUserId();
      //se l'utente non è BO deve vedere i ContrattiQuadri visibili a tutti
      //se è BO deve vedere tutti i contratti quadri
      User u=[select id, Profile.name from user where Id =:userID limit 1];
      System.debug('User '+ u);
      
      if(u.Profile.name!='BackOffice' && u.Profile.name!='Profilo Telesales') //caso agenti e commerciali
      	contrattiQuadri=[Select id, name, API_Visibilit_contratto_quadro__c, RecordType.DeveloperName from Quote where RecordType.DeveloperName='API_Contratto_Quadro' and API_Visibilit_contratto_quadro__c='Tutti'];
      else if(u.Profile.name!='BackOffice' && u.Profile.name=='Profilo Telesales') //caso Telesales
         contrattiQuadri=[Select id, name, API_Visibilit_contratto_quadro__c, RecordType.DeveloperName from Quote where RecordType.DeveloperName='API_Contratto_Quadro' and API_Visibilit_contratto_quadro__c='Telesales'];
      else //Backoffice
        contrattiQuadri=[Select id, name, API_Visibilit_contratto_quadro__c, RecordType.DeveloperName from Quote where RecordType.DeveloperName='API_Contratto_Quadro'];
      
      return contrattiQuadri;
   }
    
   /* @InvocableMethod
	public static void updateQuoteContrattoQuadro(List<String> par) {
       //il parametro in ingresso deve essere uno e di tipo lista quindi ho dovuto crere una lista con una stringa in cui c è l id della quote separato da - con l id del contratto quadro
        String quoteID= par[0].split('-')[0].trim();
        String contrattoQuadroID=par[0].split('-')[1].trim();
        Quote q= new Quote();
        q.Id= quoteID;
        q.API_Contratto_quadro__c =contrattoQuadroID;
        update q;
    }*/
}