public with Sharing class TestDataFactory {
    
    public static User createUser(Boolean isInsert,String profile){
        Profile profileId = [SELECT Id FROM Profile WHERE Name =: profile LIMIT 1]; 
        
        User usr = new User(LastName = 'LIVESTON', 
                            
                            FirstName='JASON', 
                            
                            Alias = 'jliv', 
                            
                            Email = 'jason.liveston@asdf.com', 
                            
                            Username = 'Testjason@asdf.com', 
                            
                            ProfileId = profileId.id, 
                            
                            TimeZoneSidKey = 'GMT', 
                            
                            LanguageLocaleKey = 'en_US', 
                            
                            EmailEncodingKey = 'UTF-8', 
                            
                            LocaleSidKey = 'en_US' 
                            
                           ); 
        if(isInsert){
            INSERT USR;     
        }
        return USR;
        
    }
    public static Account createAccount(Boolean isInsert){
        Account a=new Account();
        a.Name='Alex';
        if(isInsert){
            insert a;
        }
        return a;
    }
    
    public static Tag__c createTag(String configId){
        Tag__c tag=new Tag__c();
        tag.Active__c=true;
        tag.Library_and_Folder__c=configId;
        return tag;
    }
    public static Folder_Configuration__c createFolder(Boolean isInsert){
        Folder_Configuration__c folder =new Folder_Configuration__c();
        folder.Active__c=true;
        folder.Library_and_Folder__c='Legecy';
        if(isInsert){
            insert folder;
        }
        return folder;
    }
    public static Folder_Configuration__c createChildFolder(Boolean isInsert,id parentConfigId,String folderName){
        Folder_Configuration__c childFolder =new Folder_Configuration__c();
        childFolder.Active__c=true;
        childFolder.Library_and_Folder__c=folderName;
        childFolder.Content_Folder__c ='Real Lib Id';
        childFolder.Icon_Name__c ='utility:filterList';
        childFolder.Parent_Folder_Configuration__c = parentConfigId;
        childFolder.Default_Folder__c =true; 
        
        if(isInsert){
            insert childFolder;
        }
        return childFolder;
    }
    
    public static Tag_Configuration__c createTagConfig(Boolean isInsert,id folderId){
        Tag_Configuration__c TC = new Tag_Configuration__c();
        TC.Tag__c = 'Category';
        TC.Required__c = False;
        TC.Icon_Name__c ='standard:scan_card';
        TC.Library_and_Folder__c=folderId;
        if(isInsert){
            insert TC;
        }
        return TC;
    }
    
    public static Object_Configuration__c objectConfig(Boolean isInsert,id folderId){
        Object_Configuration__c OC = new Object_Configuration__c();
        OC.Name  = 'Account';
        OC.Field_to_Display__c = 'Name';
        OC.Library_and_Folder__c=folderId;
        OC.Required__c=false;
        if(isInsert){
            insert OC;
        }
        return OC;
    }
    
    public static Classification_Template__c createTemplate(Boolean isInsert,String configId){
        Classification_Template__c template=new Classification_Template__c();
        template.Active__c=true;
        template.Library_and_Folder__c=configId;
        if(isInsert){
            insert template;
        }
        return template;
    }
    
    public static Navigation_Menu_Configuration__c createNavgationMenuConfig(Boolean isInsert,id configId, Boolean isFileHomeFilter,String filterName,String soBjectName,String recordtypename){
        
        Navigation_Menu_Configuration__c navMenuConfiObj=new Navigation_Menu_Configuration__c();
        navMenuConfiObj.Name=filterName;
        navMenuConfiObj.sObject_Name__c=soBjectName;
        navMenuConfiObj.Icon_Name__c='utility:filterList';
        navMenuConfiObj.Record_Type__c=recordtypename;
        navMenuConfiObj.Default_Selected__c=true;
        navMenuConfiObj.Folder__c=configId;
        navMenuConfiObj.Filter_on_Tags__c='Test Tag,Test tag2';
        navMenuConfiObj.Is_Files_Home_Config__c=isFileHomeFilter;
        
        if(isInsert){
            insert navMenuConfiObj;
        }
        return navMenuConfiObj;
    }
    public static ContentVersion createFile(Boolean isInsert,string filename){
        ContentVersion objContent=new Contentversion();
        objContent.title=filename;
        objContent.PathOnClient ='testing';
        objContent.versiondata=EncodingUtil.base64Decode('Attachment Sample Attachment Body');
        if(isInsert){
            try{ insert objContent; }catch(exception e){ }
        }
        return objContent;
    }
    public static ContentDistribution createContentDistribution(Boolean isInsert,String contentId,Boolean passwordRequired,String title){
        ContentDistribution ObjContentDis = new ContentDistribution();
        ObjContentDis.Name = title;
        ObjContentDis.PreferencesPasswordRequired  = passwordRequired;
        ObjContentDis.ContentVersionId = contentId;
        if(isInsert){
            try{insert ObjContentDis;}catch(exception e){ }
        }
        return ObjContentDis;
    }
    public static Tag__c insertTag(String tagName,id foldconfigId,String typeofTag,id dependsOnTagID,String dependsOnTagType){
        Tag__c tag=new Tag__c();
        tag.Active__c=true;
        tag.Library_and_Folder__c=foldconfigId;
        tag.Name = tagName;
        tag.Type_of_Tag__c =typeofTag ;
        tag.Depends_on_Tag_Type__c = dependsOnTagType;
        tag.Depends_on_Tag__c = dependsOnTagID;
        insert tag;  
        
        return tag;
    }
    
}