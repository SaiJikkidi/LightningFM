@isTest
public class UtilsTEST {
    
    
    @isTest
    static void checkCurdTest(){
        user u=TestDataFactory.createUser(true,'System Administrator');
        System.runAs(u){
            String query='select id,Name,Default_Selected__c From Navigation_Menu_Configuration__c Where PA_files__Default_Selected__c=true';
            Utils.checkCurd(query, Utils.CURDOpration.READ);
            Utils.checkCurd(query, Utils.CURDOpration.MODIFY);
            Utils.checkCurd(query, Utils.CURDOpration.CREATE);
            Utils.checkCurd(query, Utils.CURDOpration.REMOVE);
            
            query='select id,Name,(select id From Contacts) From Account id in:(select AccontId From Contact)';
            Utils.checkCurd(query, Utils.CURDOpration.READ);
            Utils.checkCurd(query, Utils.CURDOpration.MODIFY);
            Utils.checkCurd(query, Utils.CURDOpration.CREATE);
            Utils.checkCurd(query, Utils.CURDOpration.REMOVE);
            
            query='select id From Account id in:(select AccountId From Contact)';
            Utils.checkCurd(query, Utils.CURDOpration.MODIFY);
            Utils.checkCurd(query, Utils.CURDOpration.CREATE);
            Utils.checkCurd(query, Utils.CURDOpration.REMOVE);
            Boolean access=Utils.checkCurd(query, Utils.CURDOpration.READ);
            System.assertEquals(true, access);
        }
        
    }
    
    @istest
    private static void testMethodPositive(){
        String objectName = Utils.getObjectNameById('500');
        System.assertEquals(objectName,'Case');
    }
    @isTest
    private static void testMethodNegative(){
        String objectName = Utils.getObjectNameById('500');
        System.assertNotEquals(objectName,'Account');
    }
    @isTest
    private static void testMethodNull(){
        String objectName = Utils.getObjectNameById('101');
        System.assertEquals(objectName,'');
    }
    @isTest
    private static void testMethodException(){
        String objectName = Utils.getObjectNameById('10');
        System.assertEquals(objectName,'');
    }
    
}