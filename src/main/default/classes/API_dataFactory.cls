public without sharing class API_dataFactory {
	public API_dataFactory() {
		
	}
	public static User createUser(String firstName,String lastName){
		Profile backofficeUser = [select id,Name from Profile where Name='BackOffice' limit 1]; 
		User u = new User();
		u.FirstName=firstName;
		u.LastName=lastName;
		u.Alias='testApi';
		u.Email=firstName+lastName+'@apitest.com';
		u.Username=firstName+lastName+'@api.com';
		u.ProfileId= backofficeUser.Id;
		u.Country='United States';
		u.isActive=true;
		u.TIMEZONESIDKEY='America/Los_Angeles';
		u.LOCALESIDKEY='en_US';
		u.LANGUAGELOCALEKEY='en_US';
		u.EMAILENCODINGKEY='UTF-8';
		return u;
	}
    
    public static User createUser(String firstName,String lastName, String profileName){
		Profile p = [select id, Name from Profile where Name= :profileName limit 1]; 
		User u = new User();
		u.FirstName=firstName;
		u.LastName=lastName;
		u.Alias='testApi';
		u.Email=firstName+lastName+'@apitest.com';
		u.Username=firstName+lastName+'@api.com';
		u.ProfileId= p.Id;
		u.Country='United States';
		u.isActive=true;
		u.TIMEZONESIDKEY='America/Los_Angeles';
		u.LOCALESIDKEY='en_US';
		u.LANGUAGELOCALEKEY='en_US';
		u.EMAILENCODINGKEY='UTF-8';
		return u;
	}

	public static User createUser(String firstName,String lastName, String profileName, String userRoleName){
		UserRole uRole = [select id, Name from UserRole where Name =: userRoleName limit 1];
		Profile p = [select id, Name from Profile where Name= :profileName limit 1]; 
		User u = new User();
		u.FirstName=firstName;
		u.LastName=lastName;
		u.Alias='testApi';
		u.Email=firstName+lastName+'@apitest.com';
		u.Username=firstName+lastName+'@api.com';
		u.ProfileId= p.Id;
		u.UserRoleId = uRole.id;
		u.Country='United States';
		u.isActive=true;
		u.TIMEZONESIDKEY='America/Los_Angeles';
		u.LOCALESIDKEY='en_US';
		u.LANGUAGELOCALEKEY='en_US';
		u.EMAILENCODINGKEY='UTF-8';
		
		insert u;
		return u;
	}

	public static User createUser(String firstName, String lastName, String profileName, String accountName, String ContactName){
         Account portalAccount = new Account(name = accountName);//create a portal account first
         insert portalAccount;
         Contact portalContact = new contact(LastName = ContactName, AccountId = portalAccount.Id); //create a portal contact
         insert portalContact;
		 
         User u = new User( email=firstName+lastName+'@apitest.com',
                            profileid = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                            UserName= firstName+lastName+'@api.com',
                            Alias = 'testApi',
                            TimeZoneSidKey='America/New_York',
                            EmailEncodingKey='ISO-8859-1',
                            LocaleSidKey='en_US', 
                            LanguageLocaleKey='en_US',
                            ContactId = portalContact.Id,
                            PortalRole = 'Manager',
                            FirstName = firstName,
                            LastName = lastName);
         insert u;
         return u; 
	}

	public static User createUser(String firstName, String lastName, String profileName, String accountName, String ContactName, String managerId){
         Account portalAccount = new Account(name = accountName);//create a portal account first
         insert portalAccount;
         Contact portalContact = new contact(LastName = ContactName, AccountId = portalAccount.Id); //create a portal contact
         insert portalContact;
		 
         User u = new User( email=firstName+lastName+'@apitest.com',
                            profileid = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                            UserName= firstName+lastName+'@api.com',
                            Alias = 'testApi',
                            TimeZoneSidKey='America/New_York',
                            EmailEncodingKey='ISO-8859-1',
                            LocaleSidKey='en_US', 
                            LanguageLocaleKey='en_US',
                            ContactId = portalContact.Id,
                            PortalRole = 'Manager',
                            FirstName = firstName,
                            LastName = lastName,
							ManagerId = managerId
							);
         insert u;
         return u; 
	}	

	public static Case createCase(String statoCase){
		Case c = new Case();
		c.Status = statoCase;
		return c; 

	}
	public static Lead createLead(String ivaPartita, String lastNameLead, String emailLead){
        Lead l = new lead();
        String recordType = [select id from RecordType where SobjectType = 'Lead' and name = 'PreVerificaCerved' Limit 1].id;
        l.RecordTypeId = recordType;
        l.LastName =lastNameLead;
        l.API_Iva__c=ivaPartita;
        l.Company = 'qweqwe';
        l.Phone = '09342523';
        l.Email = emailLead+'test@test.it';
        l.API_VerificaCerved__c = 'Rosso';
        l.API_Consumo__c = 'Euro';
        l.API_Valore__c=24332;
        l.API_RagioneSociale__c ='4sdfsf';
        l.API_Richiesta__c = '2werwer';
        
        return l;
    }
    public static Account createAccount(String name, String ivaPassed, String ragioneSociale){
        Account a = new Account();
        a.Name =name;
        a.API_Iva__c = ivaPassed;
        a.API_RagioneSociale__c=ragioneSociale;
		a.API_Consumo__c='Euro';
		a.API_Valore__c=21;

        return a;
    }

    public static Contact createContact(String ContactName, String AccountId, String tipoContratto){
        Contact c = new contact(LastName = ContactName, AccountId = AccountId, API_TipoContatto__c = tipoContratto);
        insert c;
        return c;
    }	
    public static Product2 createProduct(){
    	Product2 p=new Product2();
    	p.Name='Prezzo Misto';
		return p;  
	}
	public static Opportunity createOpportunity(String accID){
    	Opportunity opp = new Opportunity();
        opp.AccountId= accID;
        opp.Name ='OpportDummy';
        opp.StageName='Chiuse/Conseguite';
        opp.CloseDate =date.Today();
		return opp;  
	}
	public static Pricebook2 createPricebook2(){
		Pricebook2 p = new Pricebook2();
        p.Name = 'TEST';
        return p;
	}
	public static Quote createQuote(String oppID, Pricebook2 p){
    	Quote q = new Quote();
    	q.OpportunityId = oppID;
        q.API_Offerta__c='Cliente IP'; 
        q.Name ='Cliente IP';
        q.API_Tipo_fido__c='IFI';
        q.Pricebook2Id=p.Id;
		return q;  
	}


	public static API_QuoteLineItemX__c createQuoteLineItemX(String DeveloperNameMetadata, String NomeAttributo, String NomeProdotto, String Name, String Valore){
    	API_QuoteLineItemX__c q = new API_QuoteLineItemX__c();
    	q.API_DeveloperNameMetadata__c = DeveloperNameMetadata;
		q.API_NomeAttributo__c = NomeAttributo;
		q.API_NomeProdotto__c = NomeProdotto;
		q.Name = Name;
		q.API_Valore__c = Valore;	
		return q;  
	}	

	public static API_512__c create512(){
		API_512__c record= new API_512__c();
		record.API_Codice_cliente__c='123456';
		record.API_CodiceOperazione__c='13';
		record.API_Data_revoca_String__c='03/02/2019';
		record.API_DataDecorrenzaPlafondString__c='03/02/2019';
		record.API_Data_esito_string__c='03/02/2019';
		record.API_ImportoConcessoString__c='100';
		insert record;
		return record;

	}

	public static API_529__c create529(){
		API_529__c record= new API_529__c();
		record.API_Codice_cliente__c='123456';
		record.API_DataRichiestaPlafondString__c='03/02/2019';
		insert record;
		return record;
	}

	public static API_912__c create912(){
		API_912__c record= new API_912__c();
		record.API_Codice_cliente__c='123456';
		record.API_DataModifcaString__c='03/02/2019';
		record.API_ImportoInsolutoString__c='100';
		insert record;
		return record;
	}
	public static API_912__c create912second(){
		API_912__c record= new API_912__c();
		record.API_Codice_cliente__c='232';
		record.API_DataModifcaString__c='03/02/2019';
		record.API_Modifica__c='SBLOCCO';
		record.API_ImportoInsolutoString__c='100';
		insert record;
		return record;
	}
	public static API_Carta__c createCarta(Quote q){
		API_Carta__c carta= new API_Carta__c();
		carta.API_Numero_di_targa__c='JD231SA';
		carta.API_ProdottiAutorizzati__c='BENZINA';
		carta.API_TipoPin__c='1';
		carta.API_TipoVeicolo__c='AUTO';
		carta.API_Rete__c='Internazionale';
		carta.API_Quote__c=q.Id;
		return carta;
	}

	public static API_Divisione__c createDivisione(String accountId){
		API_Divisione__c d = new API_Divisione__c();
		d.API_Account__c = accountId;
		d.Name = 'testNameDivisione';
		d.API_Descrizione__c = 'testDescrizioneDivisione';
		d.Ordine__c = 10;
		return d;
	}

	public static API_ContoCarte__c createContoCarte(String divisioneId, String quoteId){
		API_ContoCarte__c c = new API_ContoCarte__c();
		c.API_RiferimentoDivisione__c = divisioneId;	
		c.API_Quote__c = quoteId;
		c.API_TipoPIN__c = '4-PIN driver';
		return c;
	}
    
    public static Profile getProfileByName(String name){
        return [select id,Name from Profile where Name =:name limit 1];
    }
}