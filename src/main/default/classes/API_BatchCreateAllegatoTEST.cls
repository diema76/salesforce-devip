@isTest
public class API_BatchCreateAllegatoTEST {
	@isTest static void API_BatchCreateAllegatoTEST(){
        Case c= new Case();
        c.Status='Nuovo';
        c.Subject='TEST';
        c.API_Con_Allegato_API__c=true;
        insert c;
        Id batchJobId = Database.executeBatch(new API_BatchCreateAllegato(), 200);

    }

}