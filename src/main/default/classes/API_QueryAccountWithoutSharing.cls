public without sharing class  API_QueryAccountWithoutSharing {
   @InvocableMethod
   public static List<String> getAccountIds(List<String> partitaIVA) {
      List<Id> accountIds = new List<Id>();
      System.debug(partitaIVA);
      List<Account> accounts = [SELECT Id, API_Stato_cliente__c, API_Iva__c, API_CodiceCliente__c, API_Record_Type_Name__c  FROM Account WHERE API_Iva__c  in:partitaIVA and API_Record_Type_Name__c ='PostVerificaCerved'];
      System.debug(accounts.size());
      List<Lead> leads= [Select id, API_Iva__c, Status from Lead where API_Iva__c in:partitaIVA and (Status='Qualified' or Status='Converted' or Status='Convertito')];
      System.debug(leads.size());
      //creo una mappa dei LEAD perchè: se ho trovato un account con quella partita IVA e lo stato è Nuovo (e non ha un codice SAP), 
      //potrebbe essere stato generato dalla conversione di un LEAD quindi dovrei trovare anche un LEAD convertito
      //se trovo il LEAD il cliente non è duplicato
      Map<String, Lead> mapLeads= new Map<String, Lead>();
       for(Lead l: leads)
           mapLeads.put(l.API_Iva__c, l);
       for (Account account : accounts) {
           if(account.API_Stato_cliente__c=='Nuovo' && account.API_CodiceCliente__c==null){
               if(mapLeads.get(account.API_Iva__c)== null)
                  accountIds.add(account.Id); 
           }  
         else
         	accountIds.add(account.Id);
      }
      System.debug('Clienti con partitaIVA '+ partitaIVA +' trovati:'+accountIds.size());
      if(accountIds.size()>0){
        List<String> returnValue= new List<String>();
        returnValue.add(accountIds[0]);
        return returnValue;
      }
      	
      else 
        return null;
   }
    
    

}