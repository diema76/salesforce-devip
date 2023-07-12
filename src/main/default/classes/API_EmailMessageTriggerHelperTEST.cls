@isTest
public class API_EmailMessageTriggerHelperTEST {
    @isTest static void API_EmailMessageTriggerHelper(){
        Account acc;
        
        acc = API_dataFactory.createAccount('testAcc','01234567','testRagioneSociale');
        insert acc;
        
        Contact cont = API_dataFactory.createContact('test', acc.Id, 'Principale');
        cont.Email = 'test@test.com';
        update cont;
        
        List<String> emailSetNew = new List <String>();
        emailSetNew.add('test@test.com');
        EmailMessage em = new emailMessage();
        em.RelatedToId = acc.Id;
        em.Subject = 'Test';
        em.FromAddress = 'test@test.com';
        em.TextBody = 'body';
        em.BccAddress = 'test@test.com';
        em.CcAddress = 'test@test.com';
        em.ToAddress = 'test@test.com';
        em.API_CheckInserimento__c = false;
       
        insert em;
        
        Account acc2;
        
        acc2 = API_dataFactory.createAccount('testAcc','01234567','testRagioneSociale');
        insert acc2;
        
        Contact cont2 = API_dataFactory.createContact('test', acc.Id, 'Principale');
        cont2.Email = 'test2@test.com';
        update cont2;
        
        List<String> emailSetNew2 = new List <String>();
        emailSetNew2.add('test@test.com');
        EmailMessage em2 = new emailMessage();
        em2.RelatedToId = acc2.Id;
        em2.Subject = 'Test';
        em2.FromAddress = 'test@test.com';
        em2.TextBody = 'body';
        em2.BccAddress = 'test@test.com';
        em2.CcAddress = 'test@test.com';
        em2.ToAddress = 'test@test.com';
        em2.API_CheckInserimento__c = false;
        
        insert em2;
    }
}