public without sharing class API_SetAgenteEAreaManager {

@InvocableMethod
	public static void setAgenteEAreaManager(List<String> par) {
        String accountID= par[0];
        Account a=[Select id from account where id=:accountID];
        //per ogni account creato se sono un agente devo popolare i campi relativi ad agente e area manager
        String idUser=UserInfo.getUserId();
        User me= [Select id, name, Profile.name, ManagerId, API_Codice_Agente__c,API_Codice_Area_Manager__c, Manager.Name, manager.API_Codice_Area_Manager__c
                 from user where id=: idUser limit 1];
        if(me.Profile.name=='AgentiPartnerCommunity') {
            a.Agente_CRM_Atlas__c= me.Name;
            a.API_Agente__c= me.Id;
            a.API_NominativoAddettoVendite__c = me.Name;
            a.API_CodiceAddettoVendite__c = me.API_Codice_Agente__c;
            if(me.Manager.Name!= null)
                a.API_NominativoAreaManager__c=me.Manager.Name;
            if(me.manager.API_Codice_Area_Manager__c!=null)
                a.API_Codice_area_manager__c=me.manager.API_Codice_Area_Manager__c;
            if(me.ManagerId!=null)
                a.API_AreaManager__c=me.ManagerId;
        }
        //se invece sono area manager scrivo solo nei campi areaManager
        else if(me.Profile.name=='Profilo Area Manager'){
            a.API_NominativoAreaManager__c=me.Name;
            a.API_Codice_area_manager__c= me.API_Codice_Area_Manager__c;
        }
        //TBD e per il backoffice e il telesales che ci deve scrivere in quei campi?
        update a;
    }

}