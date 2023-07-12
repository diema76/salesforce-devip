public without sharing class API_ControlloCFFlowBis {

@InvocableMethod
	public static List<String> checkCF(List<String> CFFG) {
        System.debug('CF+FG: ' +CFFG);
        List<String> listCFFG = new List<String>();
        listCFFG = CFFG[0].split(';');
        System.debug('listCFFG: ' +listCFFG);
        String formaGiuridica = listCFFG[0].trim();
        String codiceFiscale;
        if(listCFFG.size() == 2)
            codiceFiscale = listCFFG[1].trim();
        Boolean corretto = false;
        List<String> message = new List<String>();
        if(formaGiuridica == 'ditta individuale' || formaGiuridica == 'libero professionista'){
            if(listCFFG.size() == 2){
                String regex = '^[a-zA-Z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$';
                Pattern regexPattern = Pattern.compile(regex);
                Matcher regexMatcher = regexPattern.matcher(codiceFiscale);
                corretto = regexMatcher.matches();
                if(corretto){
                    message.add('0');
                }else {
                    message.add('alfa obbligatorio');
                }
            }else {
                message.add('alfa obbligatorio');
            }
        }else if(formaGiuridica == 'srl' || formaGiuridica == 'srls' || formaGiuridica == 'spa' || formaGiuridica == 'sas' || formaGiuridica == 'snc' || formaGiuridica == 'coop'){
            if(codiceFiscale == null){
                message.add('0');
            }else{
                String regex = '^[0-9]{11}$';
                Pattern regexPattern = Pattern.compile(regex);
                Matcher regexMatcher = regexPattern.matcher(codiceFiscale);
                corretto = regexMatcher.matches();
                if(corretto){
                    message.add('0');
                }else {
                   message.add('numerico facoltativo');
                }
            }
        }else if(formaGiuridica == 'assoc.' || formaGiuridica == 'onlus e CRI'){
            if(listCFFG.size() == 2){
                String regex = '^[0-9]{11}$';
                Pattern regexPattern = Pattern.compile(regex);
                Matcher regexMatcher = regexPattern.matcher(codiceFiscale);
                corretto = regexMatcher.matches();
                if(corretto){
                    message.add('0');
                }else {
                    message.add('numerico obbligatorio');
                }
            }else {
                message.add('numerico obbligatorio');
            }
        }else if(formaGiuridica == 'pubblica amministrazione'){
            if(codiceFiscale == null){
                System.debug('codice fiscale vuoto');
                message.add('0');
            }else{
                String regex = '^[0-9]{11}$';
                Pattern regexPattern = Pattern.compile(regex);
                Matcher regexMatcher = regexPattern.matcher(codiceFiscale);
                corretto = regexMatcher.matches();
                if(corretto){
                    message.add('0');
                }else {
                    message.add('numerico facoltativo');
                }
            }
        }
        system.debug('message: ' +message);
        return message;
    }
}