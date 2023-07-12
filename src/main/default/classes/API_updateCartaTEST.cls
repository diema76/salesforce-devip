@isTest
private class API_updateCartaTEST {
	@isTest static void testClass(){
       	API_ContoCarte__c parchiDaAggiornare= new API_ContoCarte__c();
        parchiDaAggiornare.API_TipoPIN__c='1-PIN standard';
        insert parchiDaAggiornare;
        Account a2=API_dataFactory.createAccount('ci4563tgh','544','gfjhfdg');
        a2.API_Codice_Cartesia__c=null;
    	insert  a2;
         Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        a.API_Codice_Cartesia__c='1234';
    	insert  a;
      	Opportunity opp=API_dataFactory.createOpportunity(a.Id);
        insert opp;
        Pricebook2 pric=API_dataFactory.createPricebook2();
       	Quote q=API_dataFactory.createQuote(opp.Id,pric);
        insert q;
        
   		API_Carta__c car = API_dataFactory.createCarta(q);
        car.API_Data_Blocco_Carta_String__c='02.10.2015';
        car.API_Codice_Cartesia__c='1234';
        car.API_Data_Blocco_Carta_String__c='02.10.2015';
        car.API_Data_di_creazione_carta_String__c='02.10.2015';
        car.API_Data_di_sblocco_carta_String__c='02.10.2015';
        car.API_Data_rinnovo_String__c='02.10.2015';
        car.API_Data_ultimo_aggiornamento_String__c='02.10.2015';
        try{ 
            insert car;
        }
        catch(Exception e){}
        API_Carta__c car2 = API_dataFactory.createCarta(q);
      	try{
       		insert car2;
        }catch(Exception e){}
        
        Opportunity opp2=API_dataFactory.createOpportunity(null);
        opp2.AccountId=null;
        insert opp2;
        Pricebook2 pric2=API_dataFactory.createPricebook2();
       	Quote q2=API_dataFactory.createQuote(opp2.Id,pric2);

        insert q2;
        API_Carta__c car3 = API_dataFactory.createCarta(q2);
        car3.API_Codice_Cartesia__c='123434153246';
        car3.API_ContoCarte__c=parchiDaAggiornare.Id;
        car3.API_Stato_carta__c ='Inserita CRM';
        car.API_Nome_autista__c='sadweqdsdsfafdsfdss';
        car.API_Numero_di_targa_string__c=null;
        try{
        	insert car3;
        }catch(Exception e){}
        
        update car;
	}
    
    @isTest static void testClassContiCarta(){
        Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        a.API_Codice_Cartesia__c='1234';
    	insert  a;
      	Opportunity opp=API_dataFactory.createOpportunity(a.Id);
        insert opp;
        Pricebook2 pric=API_dataFactory.createPricebook2();
       	Quote q=API_dataFactory.createQuote(opp.Id,pric);
        insert q;
        
		API_Carta__c carta= new API_Carta__c();
		carta.API_Numero_di_targa__c='JD231SA';
		carta.API_ProdottiAutorizzati__c='BENZINA';
		carta.API_TipoPin__c='4-PIN driver';
		carta.API_TipoVeicolo__c='AUTO';
		carta.API_Rete__c='Nazionale';
		carta.API_Quote__c=q.Id;   
        try{ 
            insert carta;
        }
        catch(Exception e){}
		carta= new API_Carta__c();
		carta.API_Numero_di_targa__c='JD231SA';
		carta.API_ProdottiAutorizzati__c='BENZINA';
		carta.API_TipoPin__c='1-PIN standard';
		carta.API_TipoVeicolo__c='AUTO';
		carta.API_Rete__c='Nazionale';
		carta.API_Quote__c=q.Id;   
        try{ 
            insert carta;
        }
        catch(Exception e){}
    }
    @isTest static void testClass1111(){
       	API_ContoCarte__c parchiDaAggiornare= new API_ContoCarte__c();
        parchiDaAggiornare.API_TipoPIN__c='1-PIN standard';
        insert parchiDaAggiornare;
        API_ContoCarte__c parchiDaAggiornare2= new API_ContoCarte__c();
        parchiDaAggiornare2.API_TipoPIN__c='4-PIN driver';
        insert parchiDaAggiornare2;
        Account a2=API_dataFactory.createAccount('ci4563tgh','544','gfjhfdg');
        a2.API_Codice_Cartesia__c=null;
    	insert  a2;
         Account a=API_dataFactory.createAccount('citgh','125','NapoliSRL');
        a.API_Codice_Cartesia__c='1234';
    	insert  a;
      	Opportunity opp=API_dataFactory.createOpportunity(a.Id);
        insert opp;
        Pricebook2 pric=API_dataFactory.createPricebook2();
       	Quote q=API_dataFactory.createQuote(opp.Id,pric);
        q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contratto Quadro').getRecordTypeId();
        insert q;
        
        Opportunity opp2=API_dataFactory.createOpportunity(null);
        opp2.AccountId=null;
        insert opp2;
        Pricebook2 pric2=API_dataFactory.createPricebook2();
       	Quote q2=API_dataFactory.createQuote(opp2.Id,pric2);
		q2.API_MaxNumberCardContrattoQuadro__c=1;
        q2.API_Contratto_quadro__c=q.Id;
        insert q2;
        API_Carta__c car3 = API_dataFactory.createCarta(q2);
        car3.API_Codice_Cartesia__c='123434153246';
        car3.API_ContoCarte__c=parchiDaAggiornare.Id;
        car3.API_Stato_carta__c ='Inserita CRM';
        car3.API_Nome_autista__c='sadweqdsdsfafdsfdss';
        car3.API_Numero_di_targa_string__c=null;
        car3.API_TipoPIN__c='1-PIN standard';
        car3.API_Quote__c=q2.Id;
        insert car3;
        API_Carta__c car4 = API_dataFactory.createCarta(q2);
        car4.API_Codice_Cartesia__c='123434153246';
        car4.API_ContoCarte__c=parchiDaAggiornare2.Id;
        car4.API_Stato_carta__c ='Inserita CRM';
        car4.API_Nome_autista__c='sadweqdsdsfafdsfdss';
        car4.API_Numero_di_targa_string__c=null;
        car4.API_TipoPIN__c='4-PIN driver';
        car4.API_Quote__c=q2.Id;
        API_Carta__c car5 = API_dataFactory.createCarta(q2);
        car5.API_Codice_Cartesia__c='123434153246';
        car5.API_ContoCarte__c=parchiDaAggiornare2.Id;
        car5.API_Stato_carta__c ='Inserita CRM';
        car5.API_Nome_autista__c='sadweqdsdsfafdsfdss';
        car5.API_Numero_di_targa_string__c=null;
        car5.API_TipoPIN__c='4-PIN driver';
        car5.API_Quote__c=q2.Id;
        	
         try{
            insert car4;
        }catch(Exception e){}
        try{
            insert car5;
        }catch(Exception e){}
        
	}
}