@isTest
public class API_EmailLeadTEST {
	@isTest static void API_EmailLeadTEST(){
        Account a = API_DataFactory.createAccount('name', 'ivaPassed', 'ragioneSociale');
        insert a;
        Set<String> setString = new Set<String>();
        setString.add('test@test.com');
        Id batchJobId = Database.executeBatch(new API_EmailLead(setString), 200);

    }

}