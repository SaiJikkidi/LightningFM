@isTest
public class searchResultDataTableControllerTest {
    
    @testSetup
    static void setupSearchResultDataTable(){
        Folder_Configuration__c LibFirstLevel = TestDataFactory.createChildFolder(true,null,'LibraryB');
        System.assertEquals(LibFirstLevel.Id != null,true);
        
        Navigation_Menu_Configuration__c NavObjAccountHome2 = TestDataFactory.createNavgationMenuConfig(true,LibFirstLevel.id,false,'Account filtered','Account','');
        System.assertEquals(NavObjAccountHome2.Id != null,true);
        
        ContentVersion objContent = TestDataFactory.createFile(true,'filename1');
        ContentVersion objContent1 = TestDataFactory.createFile(true,'filename2');
        ContentVersion objContent2 = TestDataFactory.createFile(true,'filename3');
        ContentVersion objContent3 = TestDataFactory.createFile(true,'filename4');
        ContentVersion objContent4 = TestDataFactory.createFile(true,'filename5');
        ContentVersion objContent5 = TestDataFactory.createFile(true,'filename6');
        
        ContentDistribution objcontentDisPwrd1 = TestDataFactory.createContentDistribution(true,objContent.Id,true,'title1');
        ContentDistribution objcontentDisNoPwrd2 = TestDataFactory.createContentDistribution(true,objContent1.Id,true,'title2');
        ContentDistribution objcontentDisPwrd3 = TestDataFactory.createContentDistribution(true,objContent2.Id,false,'title1');
        ContentDistribution objcontentDisPwrd4 = TestDataFactory.createContentDistribution(true,objContent3.Id,false,'title1');
        
        Account a=TestDataFactory.createAccount(true);
        System.assertEquals(a.Id != null,true);
        
    }
    
    
    @isTest
    static void getCheckPasswordTest(){
         Boolean result=searchResultDataTableController.checkPasswordCreationAccess();
        List< ContentVersion> ObjContentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion Limit 20];
        List< ContentDistribution> ObjContentVersionListhaspassword = [SELECT Id, ContentDocumentId FROM ContentDistribution where PreferencesPasswordRequired = true Limit 20];
        
        List<String> recordidshavepassword = new List<String>();
        for(ContentVersion ObjContentDistribution: ObjContentVersionList)
        {
            recordidshavepassword.add(String.valueOf(ObjContentDistribution.ContentDocumentId)); 
        }
        
        List<String> recordids = new List<String>();
        for(ContentVersion ObjContentVersion: ObjContentVersionList)
        {
            recordids.add(String.valueOf(ObjContentVersion.ContentDocumentId)); 
        }
        List<ContentDistribution> Distribution = searchResultDataTableController.getCheckPassword(recordids);
        System.assertEquals(Distribution.size() > 0,true);
        
        List<ContentDistribution> Distribution1 = searchResultDataTableController.getContentVersion(recordids,true);
        System.assertEquals(Distribution1.size() > 0,true);
        
        List<ContentDistribution> Distribution2 = searchResultDataTableController.getContentVersion(recordids,false);
       // System.assertEquals(Distribution2.size() > 0,true);
        
        List<ContentDistribution> Distribution3 = searchResultDataTableController.getContentVersion(recordidshavepassword,true);
        System.assertEquals(Distribution3.size()>0,true);
        
        ContentVersion objContent=new Contentversion();
        objContent.title='testing';
        objContent.PathOnClient ='testing';
        objContent.versiondata=EncodingUtil.base64Decode('Attachment Sample Attachment Body');
        try{ insert objContent;}catch(exception e){ }
        
        List<String> recordidshasPasswrdNopasswordreq = new List<String>();
        recordidshasPasswrdNopasswordreq.add(objContent.Id);
        List<ContentDistribution> Distribution4 = searchResultDataTableController.getContentVersion(recordidshasPasswrdNopasswordreq,false);
        List<ContentDistribution> Distribution5 = searchResultDataTableController.getContentVersion(recordidshasPasswrdNopasswordreq,true);
        
        
        //getFilesResultsTest
        //inject multiple search params 
        Account acc=[SELECT id FROM Account LIMIT 1];
        String accId = JSON.serialize(acc);
        
        ContentWorkspace CW = [SELECT Id FROM ContentWorkspace Limit 1];
        Folder_Configuration__c FoldCon = new Folder_Configuration__c();
        FoldCon.Content_Folder__c = CW.Id ;
        String configString = JSON.serialize(FoldCon);
                
        searchResultDataTableController.getFilesResults(configString,'[{"Name":"color2"}]','','','','','',5,5,'','');
        
        searchResultDataTableController.getFilesResults('','','','','','','Title,OwnerId',5,5,'','');
        
        searchResultDataTableController.getFilesResults('','','','','.png','','',5,5,'','');
        
        
        searchResultDataTableController.getFilesResults('','','','','','','',5,5,'',String.valueOf(acc.Id));
        
        Navigation_Menu_Configuration__c objnav = [SELECT Id FROM Navigation_Menu_Configuration__c Limit 1];
        
        searchResultDataTableController.getFilesResults('','','','','','','',5,5,String.valueOf(objnav.Id),'');
        Folder_Configuration__c folder = [SELECT Id FROM Folder_Configuration__c Limit 1];
        
        searchResultDataTableController.getFilesResults('','','','','','','',5,5,String.valueOf(folder.Id),'');
        System.assertEquals(searchResultDataTableController.getFilesResults('','','','','','','',5,5,String.valueOf(folder.Id),'') != null,true);

        searchResultDataTableController.getFilesResults('','','','filename1','','','',5,5,'','');
        
        System.assertEquals(searchResultDataTableController.getFilesResults('','','','filename1','','','',5,5,'','') != null,true);

        searchResultDataTableController.getFilesResults('','','','','','CreatedDate','',5,5,'','');
        
        System.assertEquals(searchResultDataTableController.getFilesResults('','','','','','CreatedDate','',5,5,'','') != null,true);
        
        
    }
}