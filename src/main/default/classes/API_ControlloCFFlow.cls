public without sharing class API_ControlloCFFlow {

@InvocableMethod
	public static List<String> checkCF(List<String> par) {
        List<string> CFList = new List<String>();
        Integer i, s;
        String validi,set1, set2, setpari, setdisp;
        List<String> returnList = new List<String>();

            if(par != null && par.size()>0){
                if(par[0].length()==0) //caso di CF vuoto
                    returnList.add('OK');
                else{
                System.debug('$$$$'+par[0]+'$$$$');
                String cf = par[0].toUpperCase();
                //cf = c.Fiscalcode__C.toUpperCase();
                /*if (cf.length() != 16){
                    return 'La lunghezza del codice fiscale non è corretta: il codice fiscale dovrebbe essere lungo esattamente 16 caratteri.';
                }*/
                validi = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                /*for (i = 0; i < 16; i++) {
                    if (validi.indexOf(cf.substring(i,i+1)) == -1){
                        return 'Il codice fiscale contiene un carattere non valido' + cf.charAt(i) + '.I caratteri validi sono le lettere e le cifre.';
                    }
                }*/
                set1 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                set2 = 'ABCDEFGHIJABCDEFGHIJKLMNOPQRSTUVWXYZ';
                setpari = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                setdisp = 'BAKPLCQDREVOSFTGUHMINJWZYX';
                s = 0;

                for (i = 1; i <= 13; i += 2)
                    s += setpari.indexOf(set2.substring(set1.indexOf(cf.substring(i,i+1)),set1.indexOf(cf.substring(i,i+1))+1));
                for (i = 0; i <= 14; i += 2)
                    s += setdisp.indexOf(set2.substring(set1.indexOf(cf.substring(i,i+1)),set1.indexOf(cf.substring(i,i+1))+1));
                
                system.debug('@@ Controllo codice fiscale completato');

                if (math.mod(s,26) != cf.charAt(15) - 'A'.charAt(0)){
                    system.debug('@@ Il codice fiscale non è corretto');
                    returnList.add('Codice Fiscale non corretto');
                }else {
                    returnList.add('OK');
                }
            }
            }
            return returnList;
    }

}