public class getNavigationmenuData 
{
    /**********************************************************************
* @Aim:Class Provides methods returning file structure data
* @UsedAt:NavigationMenu
* @Company:PopcornApps
* *************************************************************************
* Date           Auther              Description
* 07-08-2018     Sai Kiran Jikkidi   Created class and methods to returm List<Items> to Navigation Menu components 
* 08-08-2018     Syed Furqan Ahmed   Modified getFolderHierarchyItems to ristrict visiblity of folder that only user has access
* **************************************************************************/
    
    @AuraEnabled
    public static List <items> getNavigationItemDataForHome() {
        
        /**************************************************************************
@Method name: getNavigationItemDataForHome
@param :null
@return : List <items>
@Description : Gives Files Home Tab's Left Navigation Menu Items Data.
***************************************************************************/
        
        List<items> filterWrp = new List<items>();
        List<items> LibFolderWrp = new List<items>(); 
        
        List<items> SectionWrap = new List<items>(); 
        
        try{
            String objNavItemQuery='SELECT Id,sObject_Name__c,  Name,Icon_Name__c,Record_Type__c, Default_Selected__c, Folder__c, Filter_on_Tags__c, Is_Files_Home_Config__c FROM Navigation_Menu_Configuration__c Where Is_Files_Home_Config__c = true ORDER BY Order_of_Display__c,Icon_Name__c ASC  NULLS LAST Limit 200';
            if(Utils.checkCurd(objNavItemQuery, Utils.CURDOpration.READ)){
                for (Navigation_Menu_Configuration__c  objNavItem:Database.query(objNavItemQuery))
                {
                    filterWrp.add(new items(objNavItem.Id, objNavItem.Name,objNavItem.Default_Selected__c,null,objNavItem.Icon_Name__c));
                }
                string sectionLabel = System.Label.Files_Home_Top_Section_Placeholder;
                string sectionIcon = System.Label.Files_Home_Top_Section_Icon_Name ;
                SectionWrap.add(new items(sectionLabel, sectionLabel, false,filterWrp,sectionIcon));
            }
            else{
                throw new curdPermisionException(System.Label.CurdPermision);
            }
            
            String folderQuery='SELECT Id,Library_and_Folder__c,Content_Folder__c,Icon_Name__c,Parent_Folder_Configuration__c,Parent_Folder_Configuration__r.Library_and_Folder__c,Parent_Folder_Configuration__r.Parent_Folder_Configuration__c,Parent_Folder_Configuration__r.Parent_Folder_Configuration__r.Library_and_Folder__c,Default_Folder__c FROM Folder_Configuration__c WHERE Active__c=true ORDER BY Combined_Folder_Name__c  DESC  ';             
            list<Folder_Configuration__c> folderConfigList = new  list<Folder_Configuration__c> (); 
            if(Utils.checkCurd(folderQuery, Utils.CURDOpration.READ)){
                folderConfigList = Database.query(folderQuery);
            }else{
                throw new curdPermisionException(System.Label.CurdPermision);
            }
            if(folderConfigList.size()>0){
                LibFolderWrp.addall(getFolderHierarchyItems(folderConfigList));
            }
            string sectionLabel = System.Label.Files_Home_Folder_Section_Name;
            string sectionIcon = System.Label.Files_Home_Top_Section_Icon_Name ;
            SectionWrap.add(new items(sectionLabel, sectionLabel, false,LibFolderWrp,sectionIcon));
            
            return SectionWrap; 
        }
        catch(exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<classifyContentversion of ClassifyAndUploadFile>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException((e.getMessage()));      
            }
        } 
    }
    
    @AuraEnabled
    public static List <items> getNavigationItemDataForObjectHome(string recordTypeName,string sObjectName) {
        try{
            /**************************************************************************
@Method name: getNavigationItemDataForObjectHome
@param :recordTypeName,sObjectName
@return : List <items>
@Description : Gives Object Record Pag Files Tab's Left Navigation Menu Items Data.
***************************************************************************/
            
            String   sObjectNameKey =   String.escapeSingleQuotes(sObjectName.trim());
            String   recordTypeNameKey = String.escapeSingleQuotes(recordTypeName.trim());
             String   defaultKey ='';
            Utils.log('sObjectNameKey'+sObjectNameKey);
            Utils.log('recordTypeNameKey'+recordTypeNameKey);

            List<items> finalWrp = new List<items>(); 
            List<items> SectionWrap = new List<items>(); 
            String objNavItemQuery='SELECT Id,sObject_Name__c,Name,Icon_Name__c,Record_Type__c,Default_Selected__c,Folder__c,Is_Files_Home_Config__c FROM Navigation_Menu_Configuration__c Where Is_Files_Home_Config__c = false AND ORDER BY Order_of_Display__c,Icon_Name__c ASC  NULLS LAST';
            if(sObjectName !='' && string.isNotBlank(sObjectName)){
                objNavItemQuery='SELECT Id,sObject_Name__c,Name,Icon_Name__c,Record_Type__c,Default_Selected__c,Folder__c,Is_Files_Home_Config__c FROM Navigation_Menu_Configuration__c Where Is_Files_Home_Config__c = false AND (sObject_Name__c =: sObjectNameKey or sObject_Name__c =: defaultKey ) ORDER BY Order_of_Display__c,Icon_Name__c ASC  NULLS LAST';
                if(recordTypeName !='' && string.isNotBlank(recordTypeName)){
                    objNavItemQuery='SELECT Id,sObject_Name__c,Name,Icon_Name__c,Record_Type__c,Default_Selected__c,Folder__c,Is_Files_Home_Config__c FROM Navigation_Menu_Configuration__c Where Is_Files_Home_Config__c = false AND ((sObject_Name__c =: sObjectNameKey AND  Record_Type__c =: recordTypeNameKey ) or (sObject_Name__c =: defaultKey))  ORDER BY Order_of_Display__c,Icon_Name__c ASC  NULLS LAST';
                }
            }
            
                        Utils.log('objNavItemQuery'+objNavItemQuery);

            
            if(Utils.checkCurd(objNavItemQuery, Utils.CURDOpration.READ)){
                for (Navigation_Menu_Configuration__c  objNavItem:Database.query(objNavItemQuery))
                {
                    finalWrp.add(new items(objNavItem.Id, objNavItem.Name,objNavItem.Default_Selected__c,null,objNavItem.Icon_Name__c));
                }
            }
            else{
                throw new curdPermisionException(System.Label.CurdPermision);
            }
            
            return finalWrp; 
        }
        catch(exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<classifyContentversion of ClassifyAndUploadFile>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException((e.getMessage()));      
            }
        } 
    }
    
    
    @AuraEnabled
    public static list<items> getFolderHierarchyItems(list<Folder_Configuration__c> folderConfigList ) 
    {     
        /**************************************************************************
@Method name: getFolderHierarchyItems
@param :list<Folder_Configuration__c> folderConfigList
@return : List <items>
@Description : Returns Hierarchy Items wrapper of Folder_Configuration__c Data.
***************************************************************************/
        //added on 8-8-2018 to restrict access to folder where user dont have perm
       /*
        List<String> contentFolderIds=new List<String>();
        for(Folder_Configuration__c configs:folderConfigList){
            if(configs.Content_Folder__c!=null){
            	contentFolderIds.add(configs.Content_Folder__c);    
            }
        }
        Utils.log('contentFolderIds '+contentFolderIds);
        Map<String,String> folderIds=LookupController.checkContentDocumentAccess(contentFolderIds);
        List<Folder_Configuration__c> hasAccessFolders=new List<Folder_Configuration__c>();
        for(Folder_Configuration__c configs:folderConfigList){
            if(configs.Content_Folder__c!=null){
                if(folderIds.containsKey(configs.Content_Folder__c)){
                    hasAccessFolders.add(configs);
                }
            }
        }
        Utils.log('hasAccessFolders '+hasAccessFolders);
        folderConfigList=hasAccessFolders;
        */
        //end
        
        
        
        List<items> SectionWrap = new List<items>(); 
        map<id,list<items>> mLibId_FolderItems = new map<id,list<items>>();
        map<id,list<items>> mFoldID_SubfolderItems = new map<id,list<items>>();
        try{
            if(folderConfigList.size()>0){
                for (Folder_Configuration__c objFoldConfig: folderConfigList)
                {
                    Utils.log('objFoldConfig'+ objFoldConfig);            
                    
                    if(objFoldConfig != null){
                        if(objFoldConfig.Parent_Folder_Configuration__c != null){
                            if(objFoldConfig.Parent_Folder_Configuration__r.Parent_Folder_Configuration__c != null){
                                id libid =  objFoldConfig.Parent_Folder_Configuration__r.Parent_Folder_Configuration__c;
                                id folderid  = objFoldConfig.Parent_Folder_Configuration__c;
                                id subfolderid = objFoldConfig.id;
                                
                                string libname = objFoldConfig.Parent_Folder_Configuration__r.Parent_Folder_Configuration__r.Library_and_Folder__c;
                                string foldername = objFoldConfig.Parent_Folder_Configuration__r.Library_and_Folder__c;
                                string subfoldername = objFoldConfig.Library_and_Folder__c;
                                string iconname =objFoldConfig.Icon_Name__c;
                                if(! mFoldID_SubfolderItems.containsKey(folderid))
                                {
                                    List<items> templistchilds =new List<items> ();
                                    templistchilds.add(new items(subfolderid,subfoldername, false, null,iconname,objFoldConfig.Content_Folder__c));
                                    mFoldID_SubfolderItems.put(folderid,templistchilds);
                                    
                                }else{
                                    List<items> templistchildsold = mFoldID_SubfolderItems.get(folderid);
                                    templistchildsold.add(new items(subfolderid,subfoldername, false, null,iconname,objFoldConfig.Content_Folder__c));
                                    mFoldID_SubfolderItems.put(folderid,templistchildsold); 
                                }
                            }
                            
                            if(objFoldConfig.Parent_Folder_Configuration__c != null && objFoldConfig.Parent_Folder_Configuration__r.Parent_Folder_Configuration__c == null ){
                                id libid =  objFoldConfig.Parent_Folder_Configuration__c;
                                id folderid = objFoldConfig.id;
                                
                                string libname = objFoldConfig.Parent_Folder_Configuration__r.Library_and_Folder__c;
                                string foldername = objFoldConfig.Library_and_Folder__c;
                                string iconname =objFoldConfig.Icon_Name__c;
                                if(! mLibId_FolderItems.containsKey(libid))
                                {
                                    List<items> templistchilds =new List<items> ();
                                    templistchilds.add(new items(folderid,foldername, false, mFoldID_SubfolderItems.get(folderid),iconname,objFoldConfig.Content_Folder__c));
                                    mLibId_FolderItems.put(libid,templistchilds);
                                }else{
                                    List<items> templistchildsold = mLibId_FolderItems.get(libid);
                                    templistchildsold.add(new items(folderid,foldername, false, mFoldID_SubfolderItems.get(folderid),iconname,objFoldConfig.Content_Folder__c));
                                    mLibId_FolderItems.put(libid,templistchildsold);
                                }
                            }
                        }
                        if(objFoldConfig.Parent_Folder_Configuration__c == null)
                        {
                            id libid = objFoldConfig.id;
                            string iconname =objFoldConfig.Icon_Name__c;
                            string libname = objFoldConfig.Library_and_Folder__c;
                            
                            if(mLibId_FolderItems.containsKey(libid))
                            {
                                SectionWrap.add(new items(libid,libname, false, mLibId_FolderItems.get(libid),iconname,objFoldConfig.Content_Folder__c));
                            }else{
                                SectionWrap.add(new items(libid,libname, false, null,iconname,objFoldConfig.Content_Folder__c));
                            }
                            
                        } 
                    } 
                }
                
            } 
            return SectionWrap; 
        } catch(exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<classifyContentversion of ClassifyAndUploadFile>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException((e.getMessage()));      
            }
        } 
    }
}