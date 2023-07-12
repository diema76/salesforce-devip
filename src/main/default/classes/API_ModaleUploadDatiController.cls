public class API_ModaleUploadDatiController {
    
    @AuraEnabled
    public static String caricaCarte(List<API_Carta__c> cartaList, String recordId){

        List<API_Parco_mezzi__c> parkList = [select id, Name from API_Parco_mezzi__c where API_Quote__c =: recordId]; 
        List<API_ContoCarte__c> ccList = [select id, Name from API_ContoCarte__c where API_Quote__c =: recordId]; 
        system.debug('PARCO MEZZI: '+parkList);
        system.debug('CARTA LIST: '+cartaList);
        integer count =0;
        for(API_Carta__c carta : cartaList){
            System.debug('CARTA: '+carta);
            system.debug('CARTA: '+carta);
            carta.Name = carta.API_Numero_di_targa__c;
            for(API_Parco_mezzi__c parco : parkList){
                system.debug('Sto ciclando i parchi');
                System.debug('Nome parco: ' +parco.Name );
                System.debug('Nome carta: ' +string.valueOf(carta.API_NomeParco__c));
                if(String.valueOf(carta.API_NomeParco__c) == parco.Name && parco.Name != ''){
                    carta.API_Parco_mezzi__c = parco.id;
                    carta.API_Parco_mezzi__c = String.valueOf(carta.API_Parco_mezzi__c );
                }
            }
            for(API_ContoCarte__c contoCarta : ccList){
                if(String.valueOf(carta.API_NomeContoCarta__c) == contoCarta.Name && contoCarta.Name != ''){
                    carta.API_ContoCarte__c = contoCarta.id;
                }
                carta.API_NomeContoCarta__c = String.valueOf(carta.API_NomeContoCarta__c );
            }
            carta.API_Quote__c = recordId;
            if(carta.API_TipoVeicolo__c == null || carta.API_Numero_di_targa__c == null || carta.API_ServiziStazione__c == null || carta.API_ProdottiAutorizzati__c == null){
                //Caso in cui mancano i campi obbligatori per l'inserimento
                return '-1';
            }
        }
        
        String message;
        System.debug('LA LISTA DELLE CARTE RICEVUTE: '+cartaList);
        try {
            insert cartaList;
            message = '0';
        } catch (Exception e) {
            system.debug(e.getMessage());
            message = e.getMessage();
        }
        return message;
    }
}