global class API_BatchCreateAllegato implements Database.Batchable<Case>,Database.Stateful{   

   global List<Case> start(Database.BatchableContext BC) {
        return [SELECT Id FROM Case where API_Con_Allegato_API__c=true];
    }
    global void execute(Database.BatchableContext bc, List<Case> cases){
        List<API_Allegato__c> allegati= new List<API_Allegato__c>();
        for(Case c: cases){
            API_Allegato__c allegato= new API_Allegato__c ();
            allegato.Name='StoricoAllegato';
            allegato.API_Tipologia__c='MODULI VARI';
            allegato.API_Case__c=c.Id;
            allegati.add(allegato);
        }
        insert allegati;
        

    }    
    global void finish(Database.BatchableContext bc){
  
       
    }    
}