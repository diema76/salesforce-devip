@isTest
public class API_ControlloCFFlowBisTEST {
    @isTest static void testCF(){  
        List<String> CF= new List<String>();
        CF.add('pubblica amministrazione;12345678901');
        API_ControlloCFFlowBis.checkCF(CF);
    }
    @isTest static void testCF2(){  
        List<String> CF= new List<String>();
        CF.add('ditta individuale;ssnntn91r21f839o');
        API_ControlloCFFlowBis.checkCF(CF);
    }
    @isTest static void testCF3(){  
        List<String> CF= new List<String>();
        CF.add('srl;');
        API_ControlloCFFlowBis.checkCF(CF);
    }
    @isTest static void testCF4(){  
        List<String> CF= new List<String>();
        CF.add('srl;12345678901');
        API_ControlloCFFlowBis.checkCF(CF);
    }
    @isTest static void testCF5(){  
        List<String> CF= new List<String>();
        CF.add('assoc.;12345678901');
        API_ControlloCFFlowBis.checkCF(CF);
    }
}