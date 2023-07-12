public class API_FlowUtility {

/*Metodo che restituisce tutte le opzioni di API_Condizioni_di_Pagamento__c in base al profilo dell'utente */
@AuraEnabled
    public static List<String> getOpzioni(){
        List<String> options= new List<String>();
        String userID= UserInfo.getUserId();
        User u=[select id, Profile.Name, UserRole.DeveloperName  from User where Id=:userID limit 1];
        if(u!= null && u.Profile.Name=='AgentiPartnerCommunity'){
            System.debug('Lista agente');
            options= new List<String>{	
                						'RID-Banca-20 gg Data Fattura FuelCard','RID-Banca-25 gg Data Fattura FuelCard',
                                        'RID-Banca-30 gg Data Fattura FuelCard', 'RID-Banca-40 gg Data Fattura FuelCard',
                                        'RID-Banca-45 gg Data Fattura FuelCard', 'RID-Banca-60 gg Data Fattura FuelCard',
                                            'RID-Banca-10 gg Data Fattura FuelCard'};
        }
        else if(u!= null && u.UserRole.DeveloperName.contains('Area_Manager')){
            System.debug('Lista area manager');
            options= new List<String>{	
                						'RID-Banca-20 gg Data Fattura FuelCard','RID-Banca-25 gg Data Fattura FuelCard',
                                        'RID-Banca-30 gg Data Fattura FuelCard', 'RID-Banca-40 gg Data Fattura FuelCard',
                                        'RID-Banca-45 gg Data Fattura FuelCard', 'RID-Banca-60 gg Data Fattura FuelCard',
                                            'RID-Banca-10 gg Data Fattura FuelCard'};
        }
        else if(u!= null && u.UserRole.DeveloperName.contains('CC') || u.UserRole.DeveloperName.contains('Card_Manager')){
            System.debug('Lista CC Card Manager');
            options= new List<String>{	'RID-Banca-10 gg Data Fattura FuelCard',
                						'RID-Banca-20 gg Data Fattura FuelCard','RID-Banca-25 gg Data Fattura FuelCard',
                                        'RID-Banca-30 gg Data Fattura FuelCard', 'RID-Banca-40 gg Data Fattura FuelCard',
                                        'RID-Banca-45 gg Data Fattura FuelCard', 'RID-Banca-60 gg Data Fattura FuelCard',
                                        'RID-Banca-90 gg Data Fattura FuelCard'};
        }
        else {
            System.debug('Lista BO');
            options= new List<String>{'RID-Banca-10 gg Data Fattura FuelCard','RID-Banca-15 gg Data Fattura Fuelcard',
                                        'RID-Banca-20 gg Data Fattura FuelCard','RID-Banca-25 gg Data Fattura FuelCard',
                                        'RID-Banca-30 gg Data Fattura FuelCard','RID-Banca-40 gg Data Fattura FuelCard',
                                        'RID-Banca-45 gg Data Fattura FuelCard','RID-Banca-60 gg Data Fattura FuelCard',
                                        'RID-Banca-90 gg Data Fattura FuelCard','Bonifico bancario-10 gg Data Fattura FuelCard',
                                        'Bonifico bancario-15 gg Data Fattura Fuelcard','Bonifico bancario-20 gg Data Fattura FuelCard',
                                        'Bonifico bancario-25 gg Data Fattura FuelCard','Bonifico bancario-30 gg Data Fattura FuelCard',
                                        'Bonifico bancario-40 gg Data Fattura FuelCard','Bonifico bancario-45 gg Data Fattura FuelCard',
                                        'Bonifico bancario-60 gg Data Fattura FuelCard','Bonifico bancario-90 gg Data Fattura FuelCard'
            };
        }
        return options;
        
    }
@AuraEnabled
    public static List<String> getTipoFido2(){
        List<String> options= new List<String>();
        String userID= UserInfo.getUserId();
        User u=[select id, Profile.Name, UserRole.DeveloperName  from User where Id=:userID limit 1];
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Quote.API_Tipo_Fido__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
        if(u!= null && u.Profile.Name=='AgentiPartnerCommunity'){
            options.add(pickListValuesList[0]);
            options.add(pickListValuesList[1]);
        }
        else {
            options= pickListValuesList;
        }
        return options;
        
    }
    //metodo utilizzato per il resume dei flow
    @AuraEnabled
    public static List<FlowInterview>getPausedFlow(){
        // Get the ID of the running user
      String currentUser = UserInfo.getUserId();
      // Find all of that user's paused interviews for the Survey customers flow
      List<FlowInterview> interviews = new List<FlowInterview>();
      interviews=[ SELECT Id, InterviewLabel, PauseLabel FROM FlowInterview
           WHERE CreatedById = :currentUser AND InterviewLabel LIKE '%DDA%'];
      return interviews;
    }
}