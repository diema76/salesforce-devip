global class API_FileIFIController implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        String myContent;
        List<Account> accountList =[select API_RagioneSociale__c, BillingStreet, BillingCity, BillingPostalCode,
                                    BillingState, BillingCountry, API_CodiceFiscale__c, API_Iva__c, API_CodiceCliente__c,
                                    API_Telefono__c, fax, API_Importo_richiesto__c, API_ABI__c,API_Verifica_Cerved__c,
                                    API_CAB__c, API_EmailPec__c, API_Note__c, Banca_del_debitore__c, API_PropostoInValutazione__c
                                    from Account 
                                    where API_CodiceCessione__c = 'SI'AND API_Stato_Factoring__c = 'Da inviare' AND API_CodiceCliente__c != null AND
                                    API_Importo_richiesto__c > 0 AND ((API_Verifica_Cerved__c = 'Verde' AND API_DataScadenzaVerificaCerved__c >= TODAY) 
                                    OR API_Importo_richiesto__c > 50000 OR API_PropostoInValutazione__c=true)];
        
        List<API_CodiciNazioniIFI__c> codiciList = [SELECT name, API_Codice__c from API_CodiciNazioniIFI__c];
        
        String data = String.valueOf(date.today());
        Integer contaRecord = 1;
        
        data = data.remove('-');
        
        for(account q : accountList){
            contaRecord++;
        }
        
        String record = String.valueOf(contaRecord);
        if(contaRecord<=9){
            record = '0000'+contaRecord;
        }else if(contaRecord>=10 && contaRecord<=99){
            record = '000'+contaRecord;
        }else if(contaRecord>=100 && contaRecord<=999) {
            record = '00'+contaRecord;            
        }else if(contaRecord>=1000 && contaRecord<=9999){
            record = '0'+contaRecord;
        }else if(contaRecord >=10000 && contaRecord <= 99999) {
            record = String.valueOf(contaRecord);
        }
        
        myContent = 'ANADEBIC' + data+ '01'+'0101669'+record + 'ITALIANA PETROLI S.P.A.';
        
        for(Account q : accountList){
            myContent += '\nANADEBIDPS';
            
            String ragioneSociale = q.API_RagioneSociale__c;
           	//replace accenti
           	ragioneSociale=ragioneSociale.replace('à', 'a');
            ragioneSociale=ragioneSociale.replace('é', 'e');
            ragioneSociale=ragioneSociale.replace('è', 'e');
            ragioneSociale=ragioneSociale.replace('ì', 'i');
            ragioneSociale=ragioneSociale.replace('ò', 'o');
            ragioneSociale=ragioneSociale.replace('ù', 'u');
            String ragioneSoc;
            if(ragioneSociale != null){
                if(ragioneSociale.length()>35){
                    ragioneSoc = ragioneSociale.substring(0, 35);
                }else if(ragioneSociale.length()<35){
                    integer size = ragioneSociale.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 35; i++){
                        spaziAggiuntivi += ' ';
                    }
                    ragioneSoc = ragioneSociale+spaziAggiuntivi;
                }else if(ragioneSociale.length() == 35){
                    ragioneSoc = ragioneSociale;
                }
            }else {
                ragioneSoc = '                                   ';
            }
            
            myContent += ragioneSoc;
            
            String indirizzo = q.BillingStreet;
            //replace accenti
           	indirizzo=indirizzo.replace('à', 'a');
            indirizzo=indirizzo.replace('é', 'e');
            indirizzo=indirizzo.replace('è', 'e');
            indirizzo=indirizzo.replace('ì', 'i');
            indirizzo=indirizzo.replace('ò', 'o');
            indirizzo=indirizzo.replace('ù', 'u');
            String ind;
            if(indirizzo != null){
                if(indirizzo.length()>30){
                    ind = indirizzo.substring(0, 30);
                }else if(indirizzo.length()<30){
                    integer size = indirizzo.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 30; i++){
                        spaziAggiuntivi += ' ';
                    }
                    ind = indirizzo+spaziAggiuntivi;
                }else if(indirizzo.length() == 30){
                    ind = indirizzo;
                }
            }else {
                ind = '                              ';
            }
            
            myContent += ind;
            
            String citta = q.BillingCity;
            //replace accenti
           	citta=citta.replace('à', 'a');
            citta=citta.replace('è', 'e');
            citta=citta.replace('é', 'e');
            citta=citta.replace('ì', 'i');
            citta=citta.replace('ò', 'o');
            citta=citta.replace('ù', 'u');
            String city;
            if(citta != null){
                if(citta.length()>30){
                    city = citta.substring(0, 30);
                }else if(citta.length()<30){
                    integer size = citta.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 30; i++){
                        spaziAggiuntivi += ' ';
                    }
                    city = citta+spaziAggiuntivi;
                }else if(citta.length() == 30){
                    city = citta;
                }
            }else {
                city = '                              ';
            }
            
            myContent += city;
            
            String codicePostale = q.BillingPostalCode;
            String CP;
            if(codicePostale != null){
                if(codicePostale.length()>5){
                    CP = codicePostale.substring(0, 5);
                }else if(codicePostale.length()<5){
                    integer size = codicePostale.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 5; i++){
                        spaziAggiuntivi += ' ';
                    }
                    CP = codicePostale+spaziAggiuntivi;
                }else if(codicePostale.length() == 5){
                    CP = codicePostale;
                }
            }else {
                CP = '     ';
            }
            
            myContent += CP;
            
            String provincia = q.BillingState;
            String prov;
            if(provincia != null){
                if(provincia.length()>2){
                    prov = provincia.substring(0, 2);
                }else if(provincia.length()<2){
                    integer size = provincia.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 2; i++){
                        spaziAggiuntivi += ' ';
                    }
                    prov = provincia+spaziAggiuntivi;
                }else if(provincia.length() == 2){
                    prov = provincia;
                }
            }else {
                prov = '  ';
            }
            
            myContent += prov;
            
            system.debug('NAZIONE: '+q.BillingCountry);
            String nazione = q.BillingCountry;
            String naz;
            if(nazione != null){
                for(API_CodiciNazioniIFI__c codice : codiciList){
                    system.debug('codici-Nazione: '+codice.name);
                    if(codice.Name.startsWith(nazione)){
                        naz = codice.API_Codice__c;
                    }
                }
            }else{
                naz = '   ';
            }
            
            myContent += naz;
            
            String codiceFiscale = q.API_CodiceFiscale__c;
            String CF;
            if(codiceFiscale != null){
                if(codiceFiscale.length() == 16){
                    CF = codiceFiscale;
                }else if(codiceFiscale.length() == 11){
                    CF = codiceFiscale + '     ';
                }
            }else{
                CF = q.API_Iva__c + '     ';
            }
            
            myContent += CF;
            
            String pIVA = q.API_Iva__c;
            String IVA;
            if(pIVA != null){
                if(pIVA.length()>11){
                    IVA = pIVA.substring(0, 11);
                }else if(pIVA.length()<11){
                    integer size = pIVA.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 11; i++){
                        spaziAggiuntivi += ' ';
                    }
                    IVA = pIVA+spaziAggiuntivi;
                }else if(pIVA.length() == 11){
                    IVA = pIVA;
                }
            }else{
                IVA = '           ';
            }
            
            myContent += IVA;
            
            if(codiceFiscale == null || codiceFiscale.length() == 11)
                myContent += '00';
            else if(codiceFiscale.length() == 16)
                myContent += '03';
            
            String codiceSAP = q.API_CodiceCliente__c;
            String SAP;
            if(codiceSAP.length()>20){
                SAP = codiceSAP.substring(0, 20);
            }else if(codiceSAP.length()<20){
                integer size = codiceSAP.length();
                String spaziAggiuntivi='';
                for(integer i = size; i < 20; i++){
                    spaziAggiuntivi += ' ';
                }
                SAP = codiceSAP+spaziAggiuntivi;
            }else if(codiceSAP.length() == 20){
                SAP = codiceSAP;
            }
            
            myContent += SAP;
            
            myContent += '10100456  '; //questo è la casella postale utente
            
            myContent += '                    ';    //Frazione
            
            String telefono = q.API_Telefono__c;
            String tel;
            if(telefono != null){
                if(telefono.length()>15){
                    tel = telefono.substring(0, 15);
                }else if(telefono.length()<15){
                    integer size = telefono.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 15; i++){
                        spaziAggiuntivi += ' ';
                    }
                    tel = telefono+spaziAggiuntivi;
                }else if(telefono.length() == 15){
                    tel = telefono;
                }
            }else {
                tel ='               ';
            }
            
            myContent += tel;
            
            String fax = q.fax;
            String faxFinale;
            if(fax != null){
                if(fax.length()>15){
                    faxFinale = fax.substring(0, 15);
                }else if(fax.length()<15){
                    integer size = fax.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 15; i++){
                        spaziAggiuntivi += ' ';
                    }
                    faxFinale = fax+spaziAggiuntivi;
                }else if(fax.length() == 15){
                    faxFinale = fax;
                }
            }else {
                faxFinale ='               ';
            }
            
            myContent += faxFinale;
            
            myContent += '0154417';
            
            Decimal importoConc = q.API_Importo_richiesto__c; //IFI lo accetta in millesimi
            String importo;
            if(importoConc != null){
                String importoConcesso = String.valueOf(importoConc * 1000);
                importoConcesso = importoConcesso.substring(0, importoConcesso.length()-3);
                if(importoConcesso.length()>18){
                    importo = importoConcesso.substring(0, 18);
                }else if(importoConcesso.length()<18){
                    integer size = importoConcesso.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 18; i++){
                        spaziAggiuntivi += '0';
                    }
                    importo = spaziAggiuntivi + importoConcesso;
                }else if(importoConcesso.length() == 18){
                    importo = importoConcesso;
                }
            }else {
                importo ='000000000000000000';
            }
            myContent += importo;
            
            myContent += '242'; //divisa
            
            myContent += '60      ';
            
            myContent += 'RID'; //mezzo di incasso
            
            //se Cerved verde con punteggio >=42 e fido richiesto <=50000
            if(q.API_Importo_richiesto__c<=50000 && q.API_Verifica_Cerved__c == 'Verde')          	myContent += 'S'; //car autonomia  
            else if (q.API_PropostoInValutazione__c==true) myContent += 'N'; //car autonomia mod Nov 2020
            else            myContent += 'N'; //car autonomia
            
            myContent += 'N'; //nuovo plafond
            String abi = q.API_ABI__c;
            String abiFinale;
            if(abi != null){
                if(abi.length()>5){
                    abiFinale = abi.substring(0, 5);
                }else if(abi.length()<5){
                    integer size = abi.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 5; i++){
                        spaziAggiuntivi += ' ';
                    }
                    abiFinale = abi+spaziAggiuntivi;
                }else if(abi.length() == 5){
                    abiFinale = abi;
                }
            }else {
                abiFinale ='     ';
            }
            
            myContent += abiFinale;
            
            String cab = q.API_CAB__c;
            String cabFinale;
            if(cab != null){
                if(cab.length()>5){
                    cabFinale = cab.substring(0, 5);
                }else if(cab.length()<5){
                    integer size = cab.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 5; i++){
                        spaziAggiuntivi += ' ';
                    }
                    cabFinale = cab+spaziAggiuntivi;
                }else if(cab.length() == 5){
                    cabFinale = cab;
                }
            }else {
                cabFinale ='     ';
            }
            
            myContent += cabFinale;
            
            myContent += '            '; //CONTO
            
            String bancaDebitore = q.Banca_del_debitore__c;
            String banca;
            if(bancaDebitore != null){
                if(bancaDebitore.length()>50){
                    banca = bancaDebitore.substring(0, 50);
                }else if(bancaDebitore.length()<50){
                    integer size = bancaDebitore.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 50; i++){
                        spaziAggiuntivi += ' ';
                    }
                    banca = bancaDebitore+spaziAggiuntivi;
                }else if(bancaDebitore.length() == 50){
                    banca = bancaDebitore;
                }
            }else {
                banca ='                                                  ';
            }
            
            myContent += banca;
            
            String email = q.API_EmailPec__c;
            String emailFinale='';
            if(email != null){
                if(email.length()>30){
                    //Modifica Sett 2020 se la mail è più lunga la metto vuota
                    emailFinale ='                              ';
                    //emailFinale = email.substring(0, 30);
                }else if(email.length()<30){
                    integer size = email.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 30; i++){
                        spaziAggiuntivi += ' ';
                    }
                    emailFinale = email+spaziAggiuntivi;
                }else if(email.length() == 30){
                    emailFinale = email;
                }
            }else {
                emailFinale ='                              ';
            }
            
            myContent += emailFinale;
            
            myContent += 'M'; //Allineamento
            
            myContent += '100,000'; //Percentuale garanzia
            
            for(integer i = 0; i < 100; i++){
                myContent += ' '; //Garanzie accessorie
            }
            
            String note = q.API_Note__c;
            String noteFinale;
            if(note != null){
                if(note.length()>100){
                    noteFinale = note.substring(0, 100);
                }else if(note.length()<100){
                    integer size = note.length();
                    String spaziAggiuntivi='';
                    for(integer i = size; i < 100; i++){
                        spaziAggiuntivi += ' ';
                    }
                    noteFinale = note+spaziAggiuntivi;
                }else if(note.length() == 100){
                    noteFinale = note;
                }
                myContent += noteFinale;
            }else {
                for(integer i = 0; i < 100; i++){
                    myContent += ' '; //Note
                }
            }
            
            myContent += '      '; //Codice settore e codice ramo
            
        }
        myContent += '\n';
        system.debug('myContent: '+myContent);
        
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        // Create the email attachment    
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        Datetime dataFile = Datetime.now();
        String dFile = dataFile.format('yyyy-MM-dd');
        efa.setFileName('FILE IFI_'+ dFile +'.txt');
        efa.setBody(Blob.valueOf(myContent));
        
        // Set the paramaters to the email object
        email.setSubject('FILE IFI');
        
        // Here I am accessing current user email id to whom we are sending email
        email.setToAddresses( new String[] {'v.marino@italianapetroli.it', 'F.Sensini@gruppoapi.com'} );
        //email.setToAddresses( new String[] { 'assunta.oropallo@nttdata.com'} );
        email.setCcAddresses( new String[] {'gestione.cartamaxima@gruppoapi.com'} );
        email.setBccAddresses( new String[] {'assunta.oropallo@nttdata.com'} );
        email.setPlainTextBody( 'In allegato il file da caricare su IFI' );
        
        // Attach file using setFileAttachments function
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        // Sends the email
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
        
        for(Account acc : accountList){
            acc.API_Stato_Factoring__c = 'Inviato';
            acc.API_Data_invio_IFI__c= System.today();
        }
        
        Database.SaveResult[] srList = Database.update(accountList, false);
        
        List<API_ErroriIFI__c> erroriList = new List<API_ErroriIFI__c>();
        Integer k = 0;
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {          
                for(Database.Error err : sr.getErrors()) {
                    API_ErroriIFI__c errori = new API_ErroriIFI__c ();
                    errori.API_DescrizioneErrore__c = err.getStatusCode() + ': ' + err.getMessage();
                    errori.API_DataOraErrore__c = System.now();
                    errori.API_Account__c = accountList[k].Id;
                    erroriList.add(errori);
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
            k++;
        }
        insert erroriList;
    }
}