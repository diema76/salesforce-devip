public class API_ControllerFlow {

    @AuraEnabled
    public static String picklistValues(){
        Map<String, List<String>> mappaDeiValori= new Map<String, List<String>>();
        //TipoCarta
        List<String> tipoCarta= new List<String>();
        Schema.DescribeFieldResult fieldResult = API_ContoCarte__c.API_TipoCarta__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            Map<String,String> tipoCartaMap= new Map<String,String>();
			tipoCartaMap.put('label',pickListVal.getLabel());
            tipoCartaMap.put('value',pickListVal.getValue());
            tipoCarta.add(JSON.serialize(tipoCartaMap));
		}     
		//Tipo Operazione
        List<String>tipoOperazione= new List<String>();
        Schema.DescribeFieldResult fieldResult2 = API_ContoCarte__c.API_TipoOperat__c.getDescribe();
		List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple2){
            Map<String,String> tipoOperazioneMap= new Map<String,String>();
			tipoOperazioneMap.put('label',pickListVal.getLabel());
            tipoOperazioneMap.put('value',pickListVal.getValue());
            tipoOperazione.add(JSON.serialize(tipoOperazioneMap));
		}  
        //Tipo Veicolo
        List<String> tipoVeicolo= new  List<String>();
        Schema.DescribeFieldResult fieldResult3 = API_ContoCarte__c.API_TipologiaVeicoli__c.getDescribe();
		List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple3){
            Map<String,String> tipoVeicoloMap= new Map<String,String>();
			tipoVeicoloMap.put('label',pickListVal.getLabel());
            tipoVeicoloMap.put('value',pickListVal.getValue());
            tipoVeicolo.add(JSON.serialize(tipoVeicoloMap));
		}  
        //Tipo Prodotti ammessi
         List<String>tipoProdottiAmmessi= new  List<String>();
        Schema.DescribeFieldResult fieldResult4 = API_ContoCarte__c.API_ProdottiAmmessi__c.getDescribe();
		List<Schema.PicklistEntry> ple4 = fieldResult4.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple4){
            Map<String,String> tipoProdottiAmmessiMap= new Map<String,String>();
			tipoProdottiAmmessiMap.put('label',pickListVal.getLabel());
            tipoProdottiAmmessiMap.put('value',pickListVal.getValue());
            tipoProdottiAmmessi.add(JSON.serialize(tipoProdottiAmmessiMap));
		}  
         //Tipo ServiziInStazione
        List<String>tipoServiziInStazione= new   List<String>();
        Schema.DescribeFieldResult fieldResult5 = API_ContoCarte__c.API_ServiziInStazione__c.getDescribe();
		List<Schema.PicklistEntry> ple5 = fieldResult5.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple5){
            Map<String,String> tipoServiziInStazioneMap= new Map<String,String>();
			tipoServiziInStazioneMap.put('label',pickListVal.getLabel());
            tipoServiziInStazioneMap.put('value',pickListVal.getValue());
            tipoServiziInStazione.add(JSON.serialize(tipoServiziInStazioneMap));
		}  
        
        
		mappaDeiValori.put('TipoCarta', tipoCarta);     
        mappaDeiValori.put('TipoOperazione', tipoOperazione);     
        mappaDeiValori.put('TipoVeicolo', tipoVeicolo);     
        mappaDeiValori.put('TipoProdotti', tipoProdottiAmmessi);     
        mappaDeiValori.put('TipoServizi', tipoServiziInStazione); 
        
        return JSON.serialize(mappaDeiValori);
    
    }
    @AuraEnabled
    public static String getParchiMezzi(String quoteId){
        List<Map<String,String>> returnList= new List<Map<String,String>>();
    	List<API_Parco_mezzi__c> parchi= [select id, name, API_Quote__c from API_Parco_mezzi__c where API_Quote__c =:quoteId];
        for(API_Parco_mezzi__c parco: parchi){
            Map<String,String> w= new Map<String,String>();
            w.put('nomeParco',parco.name);
            w.put('idParco',parco.id);
            returnList.add(w);
        }
       	return JSON.serialize(returnList);
        
    }
    
   
    
    @AuraEnabled
    public static API_Parco_mezzi__c salvaParcoMezzi(String quoteId, String descrizione, String codice){
        API_Parco_mezzi__c newParco= new API_Parco_mezzi__c();
        newParco.API_Quote__c=quoteId;
        newParco.name=codice;
        newParco.API_Descrizione__c= descrizione;
        System.debug(newParco);
        insert newParco;
        return newParco;
    }
    
    
}