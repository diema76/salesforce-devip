@isTest
private class API_LeadTriggerHelperTEST {
    @isTest static void testClass(){
        try{
            Account accTest = API_dataFactory.createAccount('Gigino','127777777','DittaLautaro');
            Account accTest2 = API_dataFactory.createAccount('Matteo','12222222','DittaMaurito');
            insert accTest;
            insert accTest2;
            Lead leadTest=API_dataFactory.createLead('12555555','Russo','russo');
            Lead leadTest2=API_dataFactory.createLead('12333333','Gianni','gianni');
            Account accTest4 = API_dataFactory.createAccount('Matteo','12333333','DittaMaurito');
            insert accTest4;   
            insert leadTest2;
            insert leadTest;
            List<Lead> leList = new List<Lead>();
            leList.add(leadTest);
            API_PlatformEventLeadDuplicato__e pe=API_LeadTriggerHelper.createPlatformevent('12555555555555','prova@prova.com', accTest.Id, 'Oggetto');
            API_PlatformEventLeadDuplicato__e pe2=API_LeadTriggerHelper.createPlatformevent('1299999','provamail@prova.com', accTest2.Id, 'Oggetto2');
            List<API_PlatformEventLeadDuplicato__e> listPE = new List  <API_PlatformEventLeadDuplicato__e>();
            listPE.add(pe);
            listPE.add(pe2);
            update leList;
            API_LeadTriggerHelper.throwPlatformEvents(listPE);
            API_LeadTriggerHelper.webToLeadCompany(leList);
        }
        catch(Exception e){
            
        } 
    }
}