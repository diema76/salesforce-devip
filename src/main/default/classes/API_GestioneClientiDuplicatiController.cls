public without sharing class API_GestioneClientiDuplicatiController {

    @AuraEnabled
     public static List<String> clienteDuplicato(String partitaIVA){
         Id userId = UserInfo.getUserId();
         String errorMessage='';
         String showButtonVisualizzaCliente='false';
         System.debug('userId '+userId);
          System.debug('partitaIVA '+partitaIVA);
         User u= [Select id, Profile.Name, UserType, Name, UserRole.Name, Manager.Name, Manager.UserRole.Name, ManagerId  from User where Id=: userId limit 1];
         //Caso 1 Agente
         if(u.Profile.Name=='AgentiPartnerCommunity'){
             //devo inviare una notifica all'areaManager responabile  ecomunicare all'agente che non può proseguire
             errorMessage=Label.API_erroreAgenteClienteDuplicato;
             //crea notifica per l'area manager
             creaTask(u, partitaIVA);
         }
         //Caso 2 AreaManager
         else if(u.Profile.Name=='Profilo Area Manager' && u.UserRole.Name.containsIgnoreCase('Area Manager')){
             //devo inviare una notifica al capo canale corrispondente
             errorMessage=Label.API_clienteDuplicatoAreaManager;
             creaTask(u, partitaIVA);
             showButtonVisualizzaCliente='true';
         }
         //Caso 3 CapoCanale o CardManager
         else if(u.Profile.Name=='Profilo Area Manager' && !u.UserRole.Name.containsIgnoreCase('Area Manager')){
             errorMessage=Label.API_clienteDuplicatoAreaManager;
             showButtonVisualizzaCliente='true';
         }
         //Caso 4 operatore Telesales
		 else if(u.Profile.Name=='Profilo Telesales' && u.UserRole.Name!=('Telesales')){
             //devo inviare una notifica al capo Telesales e comunicare all'operatore che non può proseguire
             errorMessage=Label.API_erroreAgenteClienteDuplicato;
             //crea notifica per l'area manager
             creaTask(u, partitaIVA);
             showButtonVisualizzaCliente='true';
         }
         //caso 5 Valter (capo Telesales)
         else{
             errorMessage=Label.API_clienteDuplicatoAreaManager;
             showButtonVisualizzaCliente='true';
         }
         //il metodo ritorna una lista di 3 stringhe: l'errore da visualizzare , true/false se visualizzare o meno il bottone per vedere il cliente, l'id del cliente
		 Account a= [Select id from Account where API_Iva__c =: partitaIVA limit 1];
         List<String> returnValues= new List<String>();
         returnValues.add(errorMessage);
         returnValues.add(showButtonVisualizzaCliente);
         if(a!= null)
            returnValues.add(a.Id); 
         return returnValues;
     }
    
    public static void creaTask(User u, String partitaIVA){
        System.debug('@@@@@@');
        System.debug(u);
        String body ='';
        Task t = new Task();
		t.OwnerId = u.ManagerId;
        t.Subject = Label.API_notificaAreaMangerTitle+' '+ partitaIVA;
        body=Label.API_notificaAreaManagerBody;
        body=body.replace('####', u.Name);
        body= body + ' '+ partitaIVA;
        t.Description= body;
		t.ActivityDate = System.today(); 
		t.Status = 'Open';
		t.Priority = 'Normal';
		t.IsReminderSet=true;
		t.ReminderDateTime=System.now();
		insert t;
    }
}