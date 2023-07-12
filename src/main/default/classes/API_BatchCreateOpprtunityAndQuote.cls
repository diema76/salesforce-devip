global class API_BatchCreateOpprtunityAndQuote implements Database.Batchable<Account>,Database.Stateful{   
    
    global Pricebook2 pb = new Pricebook2();
    
    global List<Account> start(Database.BatchableContext BC) {
        //mi prendo tutti gli account che non hanno un'opportunity che sono ex IP e che hanno il falg API_QuoteDaCreare__c a true
        pb=[SELECT Id, name from Pricebook2 where name='Price Book API' limit 1];
        return [SELECT Id, Name FROM Account WHERE API_Ex_Cliente__c ='Ex cliente IP' AND API_QuoteDaCreare__c=true ];
    }
    global void execute(Database.BatchableContext bc, List<Account> accounts){
        
        List <Opportunity> listOpp = new List <Opportunity>();
        List<Quote> listQuote = new List<Quote>();
        for(Account acc: accounts){
            Opportunity opp = new Opportunity(name = 'opp-' + acc.Name, StageName= 'Chiuse/Conseguite', CloseDate = Date.today());
            opp.AccountId= acc.Id;
            listOpp.add(opp);   
        }
        insert listOpp;
        Id standardRecordTypeId = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('API_Standard_Finale').getRecordTypeId();
        for(Opportunity opp: listOpp){
            String name = opp.Name.substring(4,opp.Name.length());
            Quote q = new Quote (name=name, API_DataSottoscrizioneContratto__c = System.now(), OpportunityId = opp.Id);
            q.RecordTypeId= standardRecordTypeId;
            q.Status='Inviato a Cartesia';
            q.API_Tipo_fido__c = 'IFI';
            q.Pricebook2Id =pb.Id;
            listQuote.add(q);    
        }
        insert listQuote;
    }    
    global void finish(Database.BatchableContext bc){
        
        
    }    
}