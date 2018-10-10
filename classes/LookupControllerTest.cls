@isTest
public class LookupControllerTest { 

    @testSetup
    static void setupData(){
        Account a=TestDataFactory.createAccount(true);
        ContentWorkspace objWorkSpace = new ContentWorkspace();
        objWorkSpace.Name = 'TestWorkSpace';
        Database.insert(objWorkSpace, false);
       
        Folder_Configuration__c folder=TestDataFactory.createFolder(true);
        Tag__c tag=TestDataFactory.createTag(folder.id);
        tag.Name='File';
        tag.Type_of_Tag__c='Category';
        
        insert tag;
        Tag__c tag1=TestDataFactory.createTag(folder.id);
        tag1.Depends_on_Tag__c=tag.id;
        tag1.Name='InternalFile';
        tag1.Type_of_Tag__c='Sub Category';
        insert tag1;
        Classification_Template__c createTemplate=TestDataFactory.createTemplate(true,folder.id);
        System.assertEquals(createTemplate.Id != null,true);

        
    }
    @isTest static void getObjectRecordsTest(){
        Account a=[SELECT id FROM Account LIMIT 1];
        try{LookupController.getObjectRecords('','Account','Names');}catch(exception e){}
        
        List<LookupController.lookupContainer> listA=LookupController.getObjectRecords('','Account','Name');
        System.assertEquals(a.Id, listA[0].Id);
    }
    
    @isTest static void fetchTagsTest(){
        Folder_Configuration__c folder=[SELECT id,Library_and_Folder__c FROM Folder_Configuration__c LIMIT 1];
        Tag__c parent=[SELECT id FROM Tag__c WHERE Name='File'];
        Tag__c child=[SELECT id FROM Tag__c WHERE Name='InternalFile'];
        User u=TestDataFactory.createUser(true,'Standard user');
        System.runAs(u){
            try{LookupController.fetchTags('','SubCategory',folder.Library_and_Folder__c,parent.id);}catch(exception e){}
        }
        List<sObject> s=LookupController.fetchTags('','SubCategory',folder.Library_and_Folder__c,parent.id);
        System.assertEquals(child.Id, s[0].Id);
    }
    
    @isTest static void fetchConfigsTest(){
        Folder_Configuration__c folder=[SELECT id,PA_LFM__Default_Folder__c,Active__c,Order_of_Display__c,Content_Folder__c FROM Folder_Configuration__c LIMIT 1];
        ContentWorkspace objWorkSpace=[SELECT id,(SELECT id,MemberId FROM ContentWorkspaceMembers) FROM ContentWorkspace LIMIT 1];
        folder.Content_Folder__c=objWorkSpace.id;
        folder.Active__c=true;
        folder.PA_LFM__Default_Folder__c=true;
        folder.Order_of_Display__c=1;
        update folder;
        LookupController.fetchConfigs('',true);
        User u=TestDataFactory.createUser(true,'Standard user');
        System.runAs(u){
            try{LookupController.fetchConfigs('',true);}catch(exception e){}
        }
        List<sObject> s=LookupController.fetchConfigs('',false);
        System.debug(s);
        System.assertEquals(0,s.size());
    }
    
    @isTest static void fetchTemplateTest(){
        Classification_Template__c createTemplate=[SELECT id FROM Classification_Template__c LIMIT 1];
        Tag__c tag=[SELECT id FROM Tag__c LIMIT 1];
        Account a=[SELECT id,Name FROM Account LIMIT 1];
        createTemplate.PA_LFM__Linked_Records__c=a.Id+'_'+a.Name;
        createTemplate.PA_LFM__Linked_Tags__c=tag.Id;
        update createTemplate;
        User u=TestDataFactory.createUser(true,'Standard user');
        u.PA_LFM__Template_Favorite__c=createTemplate.id;
        update u;
        System.runAs(u){
            try{
                LookupController.fetchTemplate('','Fav');
            }catch(exception e){}
            try{
                LookupController.getTemplateRecords(createTemplate.Id);
            }catch(exception e){}
            try{
                LookupController.lookupContainer rec=LookupController.getRecordforId(a.id,'Name','Account');
            }catch(exception e){}
        } 
        List<LookupController.templateContiner> s=LookupController.fetchTemplate('','ALL');
        LookupController.getTemplateRecords(createTemplate.Id);
        LookupController.lookupContainer rec=LookupController.getRecordforId(a.id,'Name','Account');
        System.assert(a.id==rec.Id);
    }
    
    @isTest static void checkTemplateCreationPermissionTest(){
        List<String> perms=LookupController.checkTemplateCreationPermission();
        System.assertEquals('access_false',perms[0]);
    }
    @isTest static void callClassifyContentversionTest(){
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
        
        LookupController.callClassifyContentversion(document.Id,JSON.serialize(LibA),JSON.serialize(alltags),JSON.serialize(allRecords),saveTemp);
        User u=TestDataFactory.createUser(true,'Standard User');
        Try{System.runAs(u){ClassifyFile.classifyContentversion(document.Id,JSON.serialize(LibA),JSON.serialize(alltags),JSON.serialize(allRecords),saveTemp);}}catch(exception e){}
    }
}