public with sharing class API_RichiestaFidoController {
    
    public Wrapper objWRP {get; set;}

    public API_RichiestaFidoController(ApexPages.StandardController controller) {
        ID quoteID = controller.getRecord().Id;
        
        Quote quote =[select Account.API_RagioneSociale__c, Account.API_Iva__c, Account.API_CodiceFiscale__c, Account.API_CodiceCliente__c, Account.BillingCity,
                    Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStreet, Account.API_Tipo_Attivita__c, Account.Phone,
                    Account.API_NominativoAddettoVendite__c, Account.API_NominativoAreaManager__c
                    from Quote where id =: quoteID LIMIT 1];
        
        Wrapper objWRP = new Wrapper();
        objWRP.API_RagioneSociale = quote.Account.API_RagioneSociale__c;
        objWRP.API_Iva = quote.Account.API_Iva__c;
        objWRP.API_CodiceFiscale = quote.Account.API_CodiceFiscale__c;
        objWRP.BillingCity = quote.Account.BillingCity;
        objWRP.BillingState = quote.Account.BillingState;
        objWRP.BillingPostalCode = quote.Account.BillingPostalCode;
        objWRP.BillingCountry = quote.Account.BillingCountry;
        objWRP.BillingStreet = quote.Account.BillingStreet;
        objWRP.API_Tipo_Attivita = quote.Account.API_Tipo_Attivita__c;
        objWRP.Phone = quote.Account.Phone;
        objWRP.API_NominativoAddettoVendite = quote.Account.API_NominativoAddettoVendite__c;
        objWRP.API_NominativoAreaManager = quote.Account.API_NominativoAreaManager__c;

        system.debug('OBJWRP: '+objWRP);
        this.objWRP = objWRP;
    }

    public class Wrapper{

        public String API_RagioneSociale                                   {get; set;}
        public String API_Iva                                              {get; set;}
        public String API_CodiceFiscale                                    {get; set;}
        public String API_CodiceCliente                                    {get; set;}
        public String BillingCity                                          {get; set;}
        public String BillingState                                         {get; set;}
        public String BillingPostalCode                                    {get; set;}
        public String BillingCountry                                       {get; set;}
        public String BillingStreet                                        {get; set;}
        public String API_Tipo_Attivita                                    {get; set;}
        public String Phone                                                {get; set;}
        public String API_NominativoAddettoVendite                         {get; set;}
        public String API_NominativoAreaManager                            {get; set;}
        
        public Wrapper(){}
    }
}