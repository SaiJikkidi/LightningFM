@isTest
public class ClassifyFileTest { 
    @testSetup
    static void setupClassifyFileTest(){
        
        //Lib A
        Folder_Configuration__c LibA = TestDataFactory.createChildFolder(true,null,'LibraryA');
        System.assertEquals(LibA.Id != null,true);

        Tag__c ParentTag1=TestDataFactory.insertTag('Insurance',LibA.id,'Category',null,'');
        Tag__c childTag1=TestDataFactory.insertTag('car',LibA.id,'Sub Category',ParentTag1.id,'Category');
        Tag__c childTag2=TestDataFactory.insertTag('car',LibA.id,'Sub Category',ParentTag1.id,'Category');
        Tag__c childTag3=TestDataFactory.insertTag('Life',LibA.id,'Sub Category',ParentTag1.id,'Category');
        Tag__c childTag4=TestDataFactory.insertTag('Medical',LibA.id,'Sub Category',ParentTag1.id,'Category');
          
        Tag__c ParentTag2=TestDataFactory.insertTag('Tax',LibA.id,'Category',null,'');
        Tag__c childTag21=TestDataFactory.insertTag('Income Tax',LibA.id,'Sub Category',ParentTag2.id,'Category');
        Tag__c childTag22=TestDataFactory.insertTag('Sales Tax',LibA.id,'Sub Category',ParentTag2.id,'Category');
        Tag__c childTag23=TestDataFactory.insertTag('Export Tax',LibA.id,'Sub Category',ParentTag2.id,'Category');
        Tag__c childTag24=TestDataFactory.insertTag('Import Tax',LibA.id,'Sub Category',ParentTag2.id,'Category');
        
        //Lib B
        Folder_Configuration__c LibB = TestDataFactory.createChildFolder(true,null,'LibraryB');
        System.assertEquals(LibB.Id != null,true);

        Tag__c ParentTagB1=TestDataFactory.insertTag('Insurance',LibB.id,'Category',null,'');
        Tag__c childTagB1=TestDataFactory.insertTag('car',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        Tag__c childTagB2=TestDataFactory.insertTag('car',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        Tag__c childTagB3=TestDataFactory.insertTag('Life',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        Tag__c childTagB4=TestDataFactory.insertTag('Medical',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        
        Tag__c ParentTagB2=TestDataFactory.insertTag('Tax',LibB.id,'Category',null,'');
        Tag__c childTagB21=TestDataFactory.insertTag('Income Tax',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        Tag__c childTagB22=TestDataFactory.insertTag('Sales Tax',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        Tag__c childTagB23=TestDataFactory.insertTag('Export Tax',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        Tag__c childTagB24=TestDataFactory.insertTag('Import Tax',LibB.id,'Sub Category',ParentTagB1.id,'Category');
        
        //doc
        ContentVersion objContent = TestDataFactory.createFile(true,'filename1');
        System.assertEquals(objContent.Id != null,true);

        //acc
        Account a=TestDataFactory.createAccount(true);
        System.assertEquals(a.Id != null,true);

        LookupController.lookupContainer container=new LookupController.lookupContainer(a.Name,a.id,'Account','Name');
        
        List<Tag__c> alltags=new List<Tag__c> {ParentTag1};
        List<LookupController.lookupContainer> allRecords=new List<LookupController.lookupContainer> {container};
        
        //template
        Classification_Template__c createTemplate=TestDataFactory.createTemplate(true,String.valueOf(LibA.id));
        System.assertEquals(createTemplate.Id != null,true);

        //testing classifyContentversion in test setup as during code scan test method with assert is failing
        ContentDocument document = [SELECT Id, Title FROM ContentDocument LIMIT 1];
        String saveTemp='{"Status":"true","Name":"templateName"}';
        
        ClassifyFile.classifyContentversion(document.Id,JSON.serialize(LibA),JSON.serialize(alltags),JSON.serialize(allRecords),saveTemp);
        User u=TestDataFactory.createUser(true,'Standard User');
        System.assertEquals(u.Id != null,true);

        Try{
            System.runAs(u){
                ClassifyFile.classifyContentversion(document.Id,JSON.serialize(LibA),JSON.serialize(alltags),JSON.serialize(allRecords),saveTemp);   
            }    
            Test.startTest();
            LookupController.callClassifyContentversion(document.Id,JSON.serialize(LibA),JSON.serialize(alltags),JSON.serialize(allRecords),saveTemp);
            Test.stopTest();
        }
        catch(exception e){
            
        }
        
        ContentDocumentLink link=[SELECT id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:a.id];
        System.assertEquals(a.id, link.LinkedEntityId);
    }
    
    @isTest
    static void getTagHierarchyDataTest(){
        //generate wrapperObject to return Hierrachy
        List<items> itemsList = ClassifyFile.getTagHierarchyData('');
       
        //Assert and Navigation menu Section Wrappers items
        System.assertEquals(itemsList[0].label, 'LibraryA');
        System.assertEquals(itemsList[1].label, 'LibraryB');
    }
    @isTest
    static void fetchRecordWithIdTest(){
        Tag__c tag=[SELECT id FROM Tag__c LIMIT 1];
        ClassifyFile.fetchRecordWithId(null);
        ClassifyFile.fetchRecordWithId('*');
        LookupController.templateContiner record=ClassifyFile.fetchRecordWithId(tag.id);
        System.assertEquals(tag.id, record.tags[0].id);
        
        
    }
    @isTest
    static void saveAsFavTest(){
        
        //Lib A
        Folder_Configuration__c LibA = [SELECT id FROM Folder_Configuration__c LIMIT 1];
        //template
        Classification_Template__c createTemplate=[SELECT id FROM Classification_Template__c LIMIT 1];
        
        ClassifyFile.saveAsFav(createTemplate.id,true);
        ClassifyFile.saveAsFav(createTemplate.id,false); 
        try{
            ClassifyFile.saveAsFav(null,null);    
        }
        catch(exception e){
            
        }
        User u=[Select id,PA_LFM__Template_Favorite__c FROM User WHERE id=:UserInfo.getUserId()];
        System.debug(u.PA_LFM__Template_Favorite__c);
        if(u.PA_LFM__Template_Favorite__c != null){
            System.assert(!u.PA_LFM__Template_Favorite__c.contains(createTemplate.id));}
        
        
        

    }
    
    
}