public without sharing class  API_CheckFileAllegato {
   @InvocableMethod
   public static List<String> getAllegatoIDS(List<String> allegatoID) {
      
      List<API_Allegato__c> allegatoList = [select id from API_Allegato__c where id =:allegatoID];
       System.debug('ALLEGATO LIST: ' +allegatoList);
      List<ContentDocumentLink> CDLList = [select Id, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: allegatoID];
      System.debug('CDLList: ' +CDLList);
      if(CDLList.isEmpty()){
          delete allegatoList;
      }
        return null;
   }
    
    

}