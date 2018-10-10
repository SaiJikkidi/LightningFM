/**********************************************************************
* @Aim:Perform unit testing for the class: FolderCreationAndConfigurationController 
* @Company:PopcornApps
* *************************************************************************
* Date           Author              Description
* 07-13-2018     Harish Koilkonda   Test class for class : FolderCreationAndConfigurationController 
* 
* **************************************************************************/
    
@isTest
public class FolderCreationAndConfiguration_Test {
    
    @testSetup static void setup(){
        String mockFolderPath = 'dummyFolder1/file1';
        Folder_Configuration__c rec_1 = new Folder_Configuration__c();
        rec_1.Library_and_Folder__c = mockFolderPath;
        insert rec_1;                      
        
      //Lib A
        Folder_Configuration__c LibA = TestDataFactory.createChildFolder(true,null,'LibraryA');
        System.assertEquals(LibA.Id != null,true);
         //Libb       
        Folder_Configuration__c LibB = TestDataFactory.createChildFolder(true,null,'LibraryB');
        System.assertEquals(LibB.Id != null,true);


    }
                
    static testMethod void getInsertFinalRecords_Test(){
        String success = 'SUCCESS';
        Folder_Configuration__c FolderId = [SELECT Id FROM Folder_Configuration__c Limit 1];
        Tag_Configuration__c tagConfig = TestDataFactory.createTagConfig(true,FolderId.Id);     
        String jsonTagConfig = JSON.serialize(tagConfig);
        Object_Configuration__c objConfig = TestDataFactory.objectConfig(true,FolderId.Id);     
        String jsonObjConfig = JSON.serialize(objConfig);
        List<String> folderTagsConfigurations = new List<String>{jsonTagConfig};
        List<String> objectConfigurations = new List<String>{jsonObjConfig};
        Test.startTest();       
        String result = FolderCreationAndConfigurationController.getInsertFinalRecords(folderTagsConfigurations, objectConfigurations); 
        Test.stopTest();
        System.assertEquals(success, result);    

    }
 
    static testMethod void getobjectConfigurations_Test(){
        Test.startTest();
        Folder_Configuration__c folderConfig = TestDataFactory.createFolder(true);     
        String folderId = folderConfig.Id;
        PA_LFM__Object_Configuration__c objectConfigDetail_1 = new PA_LFM__Object_Configuration__c();
        objectConfigDetail_1.Name = 'Account';
        objectConfigDetail_1.PA_LFM__Field_to_Display__c = 'Name';
        objectConfigDetail_1.PA_LFM__Required__c = true;
        objectConfigDetail_1.PA_LFM__Library_and_Folder__c = folderId;
        insert objectConfigDetail_1; 
        List<PA_LFM__Object_Configuration__c> objectConfigDetails = [SELECT id,Name,PA_LFM__Field_to_Display__c,PA_LFM__Library_and_Folder__c,PA_LFM__Required__c from PA_LFM__Object_Configuration__c where PA_LFM__Object_Configuration__c.Name !=null and PA_LFM__Library_and_Folder__c = :folderId];               
        List<PA_LFM__Object_Configuration__c> result = FolderCreationAndConfigurationController.getobjectConfigurations(folderId);
        Test.stopTest();
        System.assertEquals(objectConfigDetails, result);
    }
    
    static testMethod void getFileTagsConfiguration(){
        Test.startTest();
        Folder_Configuration__c folderConfig = TestDataFactory.createFolder(true);     
        String folderId = folderConfig.Id;
        PA_LFM__Tag_Configuration__c tagConfigDetail_1 = new PA_LFM__Tag_Configuration__c();
        tagConfigDetail_1.PA_LFM__Tag__c = 'Subject';
        tagConfigDetail_1.PA_LFM__Required__c = true;
        tagConfigDetail_1.PA_LFM__Library_and_Folder__c = folderId;
        tagConfigDetail_1.PA_LFM__Icon_Name__c = 'utility:chevrondown';
        insert tagConfigDetail_1; 
        List<PA_LFM__Tag_Configuration__c> tagConfigDetails = [SELECT id,Name,PA_LFM__Tag__c,PA_LFM__Required__c,PA_LFM__Icon_Name__c,PA_LFM__Library_and_Folder__c from PA_LFM__Tag_Configuration__c where PA_LFM__Tag_Configuration__c.Name !=null and PA_LFM__Library_and_Folder__c = :folderId];               
        List<PA_LFM__Tag_Configuration__c> result = FolderCreationAndConfigurationController.getFileTagsConfiguration(folderId);
        Test.stopTest();
        System.assertEquals(tagConfigDetails, result);
    }
    
    static testMethod void getDuplicates_1(){               
        Test.startTest();
       string mockFolderPath='dummyFolder1/file1';
        String result = FolderCreationAndConfigurationController.getDuplicates(mockFolderPath);
        ///Folder_Configuration__c rec_1_result = [Select Id, Library_and_Folder__c from Folder_Configuration__c where Id = :rec_1.Id]; 
        Test.stopTest();
        System.assertEquals(null, result);
        
    }
    
      static testMethod void getDuplicates_2(){        
        String mockFolderPath2 = 'test/test2';
        Test.startTest();
        String result = FolderCreationAndConfigurationController.getDuplicates(mockFolderPath2);
         Id objWorkSpaceId = [Select Id from ContentWorkspace where Name = 'test/test2' LIMIT 1].Id;          
        Test.stopTest();
        System.assertEquals(objWorkSpaceId, result);
        
    }
    
    
      static testMethod void getInsertFolders_Test(){                  
        Test.startTest();
        ContentWorkspace cw = new ContentWorkspace();
        cw.Name = 'dummy1/dummy2';
        insert cw;
        Id cwId = cw.Id;          
        String folderName = 'newFolder';
        Id parentFolderId = [Select Id from Folder_Configuration__c where Library_and_Folder__c = 'dummyFolder1/file1' LIMIT 1].Id;
        String icon = 'dummyIcon';
         String result =  FolderCreationAndConfigurationController.getInsertFolders(folderName, cwId, parentFolderId, icon);
          Test.stopTest();
        System.assertEquals('Record Created', result);
        
    }
    
    static testMethod void getAllFolderTags_Test(){
        FolderCreationAndConfigurationController.getAllFolderTags();
        System.assert(FolderCreationAndConfigurationController.getAllFolderTags().dualPicklistvalues.size() > 0);
    }
    
    static testMethod void getobjects_Test(){
        FolderCreationAndConfigurationController.getobjects();
        System.assert(FolderCreationAndConfigurationController.getobjects().dualPicklistvalues.size() > 0);
    }
    
       @isTest
    static void getFolderStructureItemsTest(){
        //generate wrapperObject to return Hierrachy
        List<items> itemsList=FolderCreationAndConfigurationController.getFolderStructureItems();
        system.debug('itemsList'+itemsList);
        
           //Assert and Navigation menu Section Wrappers items
        System.assertEquals(itemsList[0].label, 'LibraryB');
        System.assertEquals(itemsList[1].label, 'LibraryA');
    }
  
    
}