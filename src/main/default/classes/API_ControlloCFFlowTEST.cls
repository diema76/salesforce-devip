@isTest
public class API_ControlloCFFlowTEST {

    @isTest static void testCF(){  
        List<String> CF= new List<String>();
        CF.add('RPLSNT92E45I197L');
        API_ControlloCFFlow.checkCF(CF);
    }
    @isTest static void testCF2(){  
        List<String> CF= new List<String>();
        CF.add('RPLSNT92E45I197Z');
        API_ControlloCFFlow.checkCF(CF);
    }
    @isTest static void testCF3(){  
        List<String> CF= new List<String>();
        CF.add('');
        API_ControlloCFFlow.checkCF(CF);
    }
}