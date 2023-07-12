global class API_EmailLead implements Database.Batchable<sObject> {
	
	String query;
	    private Set<String> leadSet;

	global API_EmailLead(Set<String> strParam) {
		        leadSet = strParam;

		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
				 query = 'SELECT Id FROM ACCOUNT LIMIT 1';

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		EmailTemplate emailTemp = [Select id from EmailTemplate where name = 'Lead advertising' limit 1];
    	List<Contact> cList = new List<Contact>();
    	for(String addMail : leadSet){

		    	Contact c = new Contact(FirstName='Joe',
		        LastName='Smith',
		        Email = addMail);
		        cList.add(c);
    	}
    	insert cList;

    	for(Contact c : cList){

    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTargetObjectId(c.Id); 
				        mail.setSenderDisplayName('Salesforce Support'); 
				        mail.setUseSignature(true); 
				        mail.setBccSender(false); 
				        mail.setSaveAsActivity(false);
				        mail.setTemplateId(emailTemp.id);
				        				        mail.setToAddresses(new List<Id>{c.Id}); 
				        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

				        //mail.setTargetObjectId(l.id); 



    	}

    	delete cList;

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}