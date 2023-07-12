public  class API_EmailMessageTriggerHelper {

    public static void creaRecordDiTracking(List<EmailMessage> emailList){
        
        List<EmailMessage> messageList = [Select RelatedToId from EmailMessage where id in: emailList];
        List<String> accountDaEliminare = new list<String>();
        for(EmailMessage em : messageList){
            accountDaEliminare.add(em.RelatedToId);
        }        
        
        List<Contact> contactDaEliminare = [select id, email from contact where AccountId in: accountDaEliminare];
        //lista dei record di tracking da creare
        system.debug('Email List: ' +emailList);
        Set<String> emailSet = new Set<String>();
        Set<String> emailSetNew = new Set<String>();
        for(EmailMessage email :emailList){
            if(email.BccAddress != null){
                List<String> emaillisttemp = email.BccAddress.split(';');
                emailSet.addAll(emaillisttemp);
            }
            if(email.ToAddress != null){
                List<String> emaillisttemp = email.ToAddress.split(';');
                emailSet.addAll(emaillisttemp);
            }
            if(email.CcAddress != null){
                List<String> emaillisttemp = email.CcAddress.split(';');
                emailSet.addAll(emaillisttemp);
            }
        }
        for(String email :emailSet){
            String temp = email.trim();
            emailSetNew.add(temp);
        }
        
        for(String email :emailSetNew){
           for(Contact ct :contactDaEliminare){
               if(email == ct.Email){
                   system.debug('devo eliminare');
                   emailSetNew.remove(ct.email);
                   system.debug('nuovo set: ' +emailSetNew);
               }
        	} 
        }
        
        system.debug('Email SET: '+emailSetNew);
        List<Contact> contactList = [select AccountId from contact where email in: emailSetNew];
        List<EmailMessage> emailMessageNew = new List<EmailMessage>();
        system.debug('contactList: ' +contactList);
        List<String> accountList = new list<String>();
        for(Contact cont : contactList)
            accountList.add(cont.AccountId);

        for(EmailMessage email : emailList){
            system.debug('Sto nel for');
            for(String acc : accountList){
                system.debug('Email.API_CheckInserimento: ' +email.API_CheckInserimento__c);
                if(email.API_CheckInserimento__c == false){
                    EmailMessage em = new emailMessage();
                    em.RelatedToId = acc;
                    em.HtmlBody = email.HtmlBody;
                    em.Subject = email.Subject;
                    em.FromAddress = email.FromAddress;
                    em.TextBody = email.TextBody;
                    em.BccAddress = email.BccAddress;
                    system.debug('STO NEL  2 FOR');
                    em.CcAddress = email.CcAddress;
                    em.ToAddress = email.ToAddress;
                    em.MessageDate = email.MessageDate;
                    em.API_CheckInserimento__c = true;
                    emailMessageNew.add(em);
                }
            }
        }
        insert emailMessageNew;
    }
}