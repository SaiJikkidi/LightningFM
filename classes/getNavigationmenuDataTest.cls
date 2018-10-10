@isTest
public class getNavigationmenuDataTest {
    @testSetup
    static void setupNavHierrachyData(){
        //Create Folder Hierrachy
        //LibA
        Folder_Configuration__c folderFirstLevelA = TestDataFactory.createFolder(true);
        
        System.assertEquals(folderFirstLevelA.Id != null,true);
        
        Folder_Configuration__c childFolderSecondLevelA = TestDataFactory.createChildFolder(true,folderFirstLevelA.id,'folderNameLevel2');
        Folder_Configuration__c childFolderSecondLevelAB = TestDataFactory.createChildFolder(true,folderFirstLevelA.id,'folderNameLevel21');
        System.assertEquals(childFolderSecondLevelA.Id != null,true);
        Folder_Configuration__c childFolderSecondThirdLevelA = TestDataFactory.createChildFolder(true,childFolderSecondLevelA.id,'folderNameLevel3');
        Folder_Configuration__c childFolderSecondThirdLevel = TestDataFactory.createChildFolder(true,childFolderSecondThirdLevelA.id,'folderNameLevel3_A');
        
        System.assertEquals(childFolderSecondLevelAB.Id != null,true);
        
        Folder_Configuration__c childFolderSecondThirdLevelb1 = TestDataFactory.createChildFolder(true,childFolderSecondLevelAB.id,'folderNameLevel3_B');
        Folder_Configuration__c childFolderSecondThirdLevelb1c = TestDataFactory.createChildFolder(true,childFolderSecondLevelAB.id,'folderNameLevel3_C');
        
        System.assertEquals(childFolderSecondLevelA.Id != null,true);
        
        //Lib B
        Folder_Configuration__c LibFirstLevelB = TestDataFactory.createChildFolder(true,null,'LibraryB');
        
        System.assertEquals(LibFirstLevelB.Id != null,true);
        
        Folder_Configuration__c childFolderSecondLevelB = TestDataFactory.createChildFolder(true,LibFirstLevelB.id,'folderNameLevel2A');
        Folder_Configuration__c childFolderSecondThirdLevelB = TestDataFactory.createChildFolder(true,childFolderSecondLevelB.id,'folderNameLevel3B');
        //Lib c
        Folder_Configuration__c LibFirstLevelc = TestDataFactory.createChildFolder(true,null,'Libraryc');
        
        System.assertEquals(LibFirstLevelc.Id != null,true);
        
        //Create File Filters
        Navigation_Menu_Configuration__c NavObjHome = TestDataFactory.createNavgationMenuConfig(true,folderFirstLevelA.id,true,'All files','','');
        System.assertEquals(NavObjHome.Id != null,true);
        
        Navigation_Menu_Configuration__c NavObjAccountHome1 = TestDataFactory.createNavgationMenuConfig(true,childFolderSecondLevelA.id,false,'Account Special Files','Account','testrecord');
        System.assertEquals(NavObjAccountHome1.Id != null,true);
        
        Navigation_Menu_Configuration__c NavObjAccountHome2 = TestDataFactory.createNavgationMenuConfig(true,LibFirstLevelB.id,false,'Account filtered','Account','');
        System.assertEquals(NavObjAccountHome2.Id != null,true);
        
    }
    @isTest
    static void getNavigationItemDataForHomeTest(){
        //generate wrapperObject to return Hierrachy
        List<items> itemsList=getNavigationmenuData.getNavigationItemDataForHome();
        system.debug('itemsList'+itemsList);
        
        //Assert and Navigation menu Section Wrappers items
        System.assertEquals(itemsList[0].label, System.Label.Files_Home_Top_Section_Placeholder);
        System.assertEquals(itemsList[0].iconName, System.Label.Files_Home_Top_Section_Icon_Name);
        System.assertEquals(itemsList[1].label, System.Label.Files_Home_Folder_Section_Name);
        System.assertEquals(itemsList[1].iconName, System.Label.Files_Home_Top_Section_Icon_Name);
    }
    
    @isTest
    static void getNavigationItemDataForObjectHomeTest() {
        //generate wrapperObject to return Hierrachy
        List<items> itemsList1 = getNavigationmenuData.getNavigationItemDataForObjectHome('','Account');
        
        //Assert and Navigation menu Section Wrappers items
        System.assertEquals(itemsList1[0].label, 'Account Special Files');
        
        List<items> itemsList2 = getNavigationmenuData.getNavigationItemDataForObjectHome('testrecord','Account');
        System.assertEquals(itemsList2[0].label, 'Account Special Files');
    }
    @isTest
    static void getNavigationItemDataForceExceptionTest() {
        //generate wrapperObject to return Hierrachy
       
        try {
            List<items> itemsList1 = getNavigationmenuData.getNavigationItemDataForObjectHome(null,null);
            System.assertEquals(itemsList1.size(),0 );
       
        
        //Assert and Navigation menu Section Wrappers items
        
        
        List<items> itemsList2 = getNavigationmenuData.getNavigationItemDataForObjectHome(null,null);
        System.assertEquals(itemsList2.size(),0);
             }
        catch(exception e){}
    }
    
}