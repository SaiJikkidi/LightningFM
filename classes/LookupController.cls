/**********************************************************************
 * @Aim:Class Provides search results for all lookup related components
 * @UsedAt:LookupContainer,getObjectLookup,getTagLookup,getConfiguration
 * @Company:PopcornApps 
 * ********************************************************************
 * Date           Auther              Description
 * 07-07-2018     Syed Furqan Ahmed   added search result methods for Tag,Folder Configration,classification template and template object
 * 20-07-2018     Syed Furqaa Ahmed   added configuration support for display order and check for creating template
 */
public with Sharing class LookupController {
    
    //wrapper to genralise fileds of diffrent objects
    public class lookupContainer{
        @auraEnabled public String Name;
        @auraEnabled public String Id; 
        @auraEnabled public String objname;
        @auraEnabled public String fieldName;
       public lookupContainer(String name,String id,String objname,String fieldName){
            this.Name=Name;
            this.Id=id;
            this.objname=objname;
            this.fieldName=fieldName;
        }
        
    }
    //wrapper to hold template
    public class templateContiner{
        @auraEnabled public Classification_Template__c template;
        @auraEnabled public Folder_Configuration__c folder;
        @auraEnabled public List<Tag__c> tags;
        @auraEnabled public List<lookupContainer> records;
        public templateContiner(Classification_Template__c template,Folder_Configuration__c folder){
            this.template=template;
            this.folder=folder;
        }
        public templateContiner(List<Tag__c> tags,List<lookupContainer> records){
            this.tags=tags;
            this.records=records;
        }
        public templateContiner(List<Tag__c> tags,Folder_Configuration__c folder){
            this.tags=tags;
            this.folder=folder;
        }
    }
    /* @Aim:returns records of any object
     * @Param:
     * searchKeyWord:search value based on filed name passed
     * ObjectName:object name in which it has to check
     * fieldName:filed name that is to be quried and searched on
     * @Return
     * customCurdException
     * List records
    */
    @AuraEnabled
    public static List < lookupContainer > getObjectRecords(String searchKeyWord, String ObjectName,String fieldName) {
        Utils.log('LookupController>getObjectRecords called searchKeyWord>>'+searchKeyWord+'  ObjectName>>'+ObjectName+' fieldName>>'+fieldName);
        try{
            searchKeyWord = String.escapeSingleQuotes(searchKeyWord.trim()) + '%';
            fieldName=String.escapeSingleQuotes(fieldName);
            
            List < lookupContainer > returnList = new List < lookupContainer > ();
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10
            String sQuery='SELECT id,'+fieldName+' FROM ' +String.escapeSingleQuotes(ObjectName) + ' WHERE '+fieldName+' LIKE: searchKeyWord order by createdDate DESC limit 10';       
            
            if(Utils.checkCurd(sQuery, Utils.CURDOpration.READ)){
                List < sObject > lstOfRecords = Database.query(sQuery);
                for (sObject obj: lstOfRecords) {
                    returnList.add(new lookupContainer(String.valueOf(obj.get(fieldName)),obj.Id,ObjectName,fieldName));
                }
                return returnList;
            }
            else{
                throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
            }
        }
        catch(exception e){
             if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'getObjectRecords of getObjectLookupController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(e.getMessage());      
            }
        }
    }
    /* @Aim:returns records of Tag
     * @Param:
     * searchKeyWord:search value based on tag Name
     * typeOfTags:specify tag type
     * folder:restirct result to only respective folder
     * dependedTag:Id of parent tag if resutlt is to be restructed
     * @Return
     * customCurdException
     * List records
    */
    @AuraEnabled
    public static List<sObject> fetchTags(String searchKeyWord,String typeOfTags,String folder,String dependedTag){
        Utils.log('getObjectLookupController fetchTags called searchKeyWord>>'+searchKeyWord+'  typeOfTags>>'+typeOfTags+'  folder>>'+folder+' dependedTag>>'+dependedTag);
        try{
            
            
            String searchKey = '%'+String.escapeSingleQuotes(searchKeyWord) + '%';
            List < sObject > returnList = new List < sObject > ();
            // Create a Dynamic SOQL Query For Fetch Record List with inner query that return related records
            String sQuery='';
            sQuery =  'select id, Depends_on_Tag__c,Depends_on_Tag_Description__c,Depends_on_Tag_Type__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c,Library_and_Folder__r.Library_and_Folder__c,Tag_Description__c,Name,Type_of_Tag__c,(SELECT Id,Type_of_Tag__c FROM Tags__r) from Tag__c where Name LIKE:searchKey  AND Type_of_Tag__c =:typeOfTags AND  Library_and_Folder__r.Library_and_Folder__c=:folder order by createdDate DESC limit 10';        
            if(!String.isEmpty(dependedTag)){
                sQuery =  'select id, Depends_on_Tag__c,Depends_on_Tag_Description__c,Depends_on_Tag_Type__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c,Library_and_Folder__r.Library_and_Folder__c,Tag_Description__c,Name,Type_of_Tag__c,(SELECT Id,Type_of_Tag__c FROM Tags__r) from Tag__c where Name LIKE:searchKey  AND Depends_on_Tag__c=:dependedTag order by createdDate DESC limit 10';
            }
            if(Utils.checkCurd(sQuery, Utils.CURDOpration.READ)){
                List < sObject > lstOfRecords = Database.query(sQuery);
                for (sObject obj: lstOfRecords) {
                           returnList.add(obj);    
                }
                return returnList;
            }
            else{
                    throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
                }
        }
        catch(exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'fetchTags of getObjectLookupController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(e.getMessage());      
            }
        }
    }
    /* @Aim:returns records of Folder Config
     * @Param:
     * searchKeyWord:search value based on folderName Name
     * getDefault:If True returns default config
     * @Return
     * customCurdException
     * List records
     */
    @AuraEnabled
    public static List<sObject> fetchConfigs(String searchKeyWord,Boolean getDefault){
        Utils.log('getObjectLookupController fetchConfigs called searchKeyWord>>'+searchKeyWord);
        
        
        try{
            searchKeyWord = '%' + String.escapeSingleQuotes(searchKeyWord) + '%';
            List < sObject > returnList = new List < sObject > ();
            // Create a Dynamic SOQL Query For Fetch Record List with 2 inner querys that return related tag and object record
            String sQuery='';
            if(getDefault){
                sQuery =  'SELECT Id,Name,Content_Folder__c,Icon_Name__c,Default_Folder__c,Library_and_Folder__c,Parent_Folder_Configuration__c,Combined_Folder_Name__c,Order_of_Display__c,(SELECT Id,Icon_Name__c,Required__c,Tag__c,Library_And_Folder__r.Library_and_Folder__c,Order_of_Display__c FROM PA_LFM__Available_Tags__r order by Order_of_Display__c ASC NULLS LAST),(SELECT Id,Field_to_Display__c,Icon_Name__c,Name,Required__c,Library_And_Folder__r.Library_and_Folder__c,Order_of_Display__c FROM PA_LFM__Available_Objects__r order by Order_of_Display__c ASC NULLS LAST)  FROM Folder_Configuration__c WHERE PA_LFM__Default_Folder__c=true AND Active__c=true order by Order_of_Display__c ASC NULLS LAST limit 20';
            }
            else{
                sQuery =  'SELECT Id,Name,Content_Folder__c,Icon_Name__c,Default_Folder__c,Library_and_Folder__c,Parent_Folder_Configuration__c,Combined_Folder_Name__c,Order_of_Display__c,(SELECT Id,Icon_Name__c,Required__c,Tag__c,Library_And_Folder__r.Library_and_Folder__c,Order_of_Display__c FROM PA_LFM__Available_Tags__r order by Order_of_Display__c ASC NULLS LAST),(SELECT Id,Field_to_Display__c,Icon_Name__c,Name,Required__c,Library_And_Folder__r.Library_and_Folder__c,Order_of_Display__c FROM PA_LFM__Available_Objects__r order by Order_of_Display__c ASC NULLS LAST)  FROM Folder_Configuration__c WHERE Combined_Folder_Name__c LIKE: searchKeyWord AND Active__c=true order by Order_of_Display__c ASC NULLS LAST limit 20'; 
            }
            
            if(Utils.checkCurd(sQuery, Utils.CURDOpration.READ)){
                List < sObject > lstOfRecords = Database.query(sQuery);
                List<String> contentDocId=new List<String>();
                for (PA_LFM__Folder_Configuration__c obj:(LIST<PA_LFM__Folder_Configuration__c>) lstOfRecords) {
                    //returnList.add(obj);
                    
                    //addedd  5-08-2018
                    if(obj.Content_Folder__c!=null){
                        contentDocId.add(obj.Content_Folder__c);
                    }
                    
                } 
                Map<String,String> accessList=checkContentDocumentAccess(contentDocId);
                for (sObject obj:lstOfRecords) {
                   String contentId =(String) obj.get('PA_LFM__Content_Folder__c');
                    if(accessList.containsKey(contentId)){
                        returnList.add(obj); 
                    }
                }
                return returnList;
            }
            else{
                throw new curdPermisionException();
            }
        }
        catch(exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'fetchConfigs of getObjectLookupController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(e.getMessage());      
            }
            
        }
    }
    /* @Aim Check user access on contentdocument
     * @param list of contentversionid;s
     * @return map with contentverstion id and user id
	 */
    public static Map<String,String> checkContentDocumentAccess(List<String> id){
        if(!Utils.checkCurd('SELECT id,Name,(SELECT id,MemberId FROM ContentWorkspaceMembers) FROM ContentWorkspace', Utils.CURDOpration.READ)){
            return new Map<String,String>();
        }
        List<ContentWorkspace> contDoc=[SELECT id,Name,(SELECT id,MemberId FROM ContentWorkspaceMembers) FROM ContentWorkspace WHERE id IN:id];
        Map<String,String> accessList=new Map<String,String>();
        for(ContentWorkspace cd:contDoc){
            if(cd.ContentWorkspaceMembers!=null){
                for(ContentWorkspaceMember cm:cd.ContentWorkspaceMembers){
                    if(cm.MemberId == UserInfo.getUserId()){
                        accessList.put(cd.id,cm.MemberId);
                        break;
                    }
                }
            }
        }
        return accessList;
    }
    /* @Aim Check user access on template creation
     * @return bollean value based on data fetched from lfm configuration custom setting
	 */
    @AuraEnabled
    public static List<String> checkTemplateCreationPermission(){
        try{
            List<String> returnValue=new List<String>();
            Utils.log('checkContentDocumentAccess ');
            Boolean access=false;
            String fileFormats='';
            PA_LFM__LFM_Configuration__c configs=PA_LFM__LFM_Configuration__c.getOrgDefaults();
            if(configs!=null){
            	access=configs.Enable_Template_Creation__c;    
                if(configs.PA_LFM__Supported_File_Formate__c!=null || String.isEmpty(configs.PA_LFM__Supported_File_Formate__c) ){
                    fileFormats=configs.PA_LFM__Supported_File_Formate__c;
                }
            } 
            
            
            
            
            PA_LFM__LFM_Configuration__c UserProf=PA_LFM__LFM_Configuration__c.getInstance(Userinfo.getProfileId());
            if(UserProf!=null){
                access=UserProf.Enable_Template_Creation__c;
                if(UserProf.PA_LFM__Supported_File_Formate__c!=null || String.isEmpty(configs.PA_LFM__Supported_File_Formate__c) ){
                    fileFormats=UserProf.PA_LFM__Supported_File_Formate__c;
                }
            }
            
                
            
            
            PA_LFM__LFM_Configuration__c UserPerm=PA_LFM__LFM_Configuration__c.getInstance(Userinfo.getUserId());
            if(UserPerm!=null){
                access=UserPerm.Enable_Template_Creation__c;
                if(UserPerm.PA_LFM__Supported_File_Formate__c!=null || String.isEmpty(configs.PA_LFM__Supported_File_Formate__c) ){
                    fileFormats=UserPerm.PA_LFM__Supported_File_Formate__c;
                }
            }
            
            returnValue.add('access_'+access);
            if(!String.isEmpty(fileFormats)){
                returnValue.add('fileFormat_'+fileFormats);
            }
            return returnValue;
        }
        catch(Exception e){
            Utils.log('checkContentDocumentAccess exception '+e.getMessage());
            return new List<String>();   
        }
    }
    
    
    /* @Aim:returns records of classification  templates
     * @Param:
     * searchKeyWord:search value based on template name Name
     * @Return
     * customCurdException
     * List records
     * @usedAt
     * LFM_classification 
     */
    @AuraEnabled
    public static List<templateContiner> fetchTemplate(String searchKeyWord,String mode){
         Utils.log(mode+' fetchTemplate fetchConfigs called searchKeyWord>>'+searchKeyWord);
        try{ 
            User u;
            if(Utils.checkCurd('Select id,PA_LFM__Template_Favorite__c FROM User WHERE id=:UserInfo.getUserId',Utils.CURDOpration.READ)){
                u=[Select id,PA_LFM__Template_Favorite__c FROM User WHERE id=:UserInfo.getUserId()];
            }
            searchKeyWord = String.escapeSingleQuotes(searchKeyWord) + '%';
            List < templateContiner > returnList = new List < templateContiner > ();
            List < PA_LFM__Classification_Template__c > lstOfRecords=new List < PA_LFM__Classification_Template__c >();
            // Createing a Dynamic SOQL Query For Fetch Record List with 2 inner querys that return related tag and object record
            String sQuery =  'SELECT Id,Name,PA_LFM__Is_favorite__c ,PA_LFM__Icon_Name__c,PA_LFM__Library_and_Folder__r.Name,PA_LFM__Library_and_Folder__r.Combined_Folder_Name__c,PA_LFM__Library_and_Folder__c,PA_LFM__Linked_Records__c,PA_LFM__Linked_Tags__c,PA_LFM__Library_and_Folder__r.PA_LFM__Content_Folder__c  FROM Classification_Template__c WHERE Name LIKE:searchKeyWord AND Active__c=true order by createdDate DESC ';        
            if(mode=='Fav'){
                if(u!=null){
                    List<String> favTemp=new List<String>(); 
                    if(u.PA_LFM__Template_Favorite__c!=null){
                        favTemp=u.PA_LFM__Template_Favorite__c.split(',');
                        sQuery =  'SELECT Id,Name,PA_LFM__Is_favorite__c ,PA_LFM__Icon_Name__c,PA_LFM__Library_and_Folder__r.Name,PA_LFM__Library_and_Folder__r.Combined_Folder_Name__c,PA_LFM__Library_and_Folder__c,PA_LFM__Linked_Records__c,PA_LFM__Linked_Tags__c,PA_LFM__Library_and_Folder__r.PA_LFM__Content_Folder__c  FROM Classification_Template__c WHERE Name LIKE:searchKeyWord AND Id IN:favTemp AND Active__c=true order by createdDate DESC '; 
                    }else{
                        sQuery =  'SELECT Id,Name,PA_LFM__Is_favorite__c ,PA_LFM__Icon_Name__c,PA_LFM__Library_and_Folder__r.Name,PA_LFM__Library_and_Folder__r.Combined_Folder_Name__c,PA_LFM__Library_and_Folder__c,PA_LFM__Linked_Records__c,PA_LFM__Linked_Tags__c,PA_LFM__Library_and_Folder__r.PA_LFM__Content_Folder__c  FROM Classification_Template__c WHERE Name LIKE:searchKeyWord AND Id IN:favTemp AND Active__c=true order by createdDate DESC '; 
                    }
                }
                
            }
            
            List<String> folderId=new List<String>();
            List<String> tagIds=new List<String>();
            List<String> contentDocId=new List<String>();
            if(Utils.checkCurd(sQuery, Utils.CURDOpration.READ)){
                lstOfRecords = Database.query(sQuery);
                for (PA_LFM__Classification_Template__c obj: lstOfRecords) {
                    //adding content doc id
                    if(obj.PA_LFM__Library_and_Folder__r.PA_LFM__Content_Folder__c!=null)
                        contentDocId.add(obj.PA_LFM__Library_and_Folder__r.PA_LFM__Content_Folder__c);
                    //adding folderconfig id to list 
                    folderId.add(obj.PA_LFM__Library_and_Folder__c);
                    //adding all tag Ids
                    List<String> tempTag=obj.PA_LFM__Linked_Tags__c.split(',');
                    for(String t:tempTag){
                        tagIds.add(t.trim());
                    }
                    
                    
                }
            }
            else{
                throw new curdPermisionException();
            }
          Utils.log(tagIds);//PA_LFM__Library_and_Folder__r.PA_LFM__Content_Folder__c
            List < Tag__c > lstOfTags;
            String tagQuery =  'select id, Depends_on_Tag__c,Depends_on_Tag_Description__c,Depends_on_Tag_Type__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c,Library_and_Folder__r.Library_and_Folder__c,Tag_Description__c,Name,Type_of_Tag__c,(SELECT Id,Type_of_Tag__c FROM Tags__r) from Tag__c where ID IN:tagIds';        
            Utils.log(tagQuery);
            if(Utils.checkCurd(tagQuery, Utils.CURDOpration.READ)){
                lstOfTags = Database.query(tagQuery);
                Utils.log(lstOfTags);
            }
            else{
                throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
            }
           
            //checking perm for folder access
            Map<String,String> contentWorkspacePerm=checkContentDocumentAccess(contentDocId);
           
            Utils.log('contentWorkspacePerm '+contentWorkspacePerm);
            //getting all folder configs
            List < Folder_Configuration__c > lstOfConfgRecords=new List < Folder_Configuration__c >();
            String folderQuery=sQuery ='SELECT Id,Name,Content_Folder__c,Icon_Name__c,Default_Folder__c,Library_and_Folder__c,Combined_Folder_Name__c,Order_of_Display__c,(SELECT Id,Icon_Name__c,Required__c,Tag__c,Library_And_Folder__r.Library_and_Folder__c FROM PA_LFM__Available_Tags__r),(SELECT Id,Field_to_Display__c,Icon_Name__c,Name,Required__c,Library_And_Folder__r.Library_and_Folder__c FROM PA_LFM__Available_Objects__r)  FROM Folder_Configuration__c WHERE ID IN:folderId AND Active__c=true '; 
            if(Utils.checkCurd(folderQuery, Utils.CURDOpration.READ)){
                List < Folder_Configuration__c > configRecords = Database.query(sQuery);
                for(Folder_Configuration__c fc:configRecords){
                    if(contentWorkspacePerm.containsKey(fc.Content_Folder__c)){
                        lstOfConfgRecords.add(fc);
                    }
                }
            }
            else{
                throw new curdPermisionException();
            }
            
            Utils.log('lstOfConfgRecords '+lstOfConfgRecords);
            
            Map<String,Folder_Configuration__c> mapOfConfig=new Map<String,Folder_Configuration__c>(lstOfConfgRecords);
            Map<String,Tag__c> mapOfTagss=new Map<String,Tag__c>(lstOfTags);
                
            //mapping template with its respective folder configs
            for (PA_LFM__Classification_Template__c obj: lstOfRecords) {
                 if(contentWorkspacePerm.containsKey(obj.PA_LFM__Library_and_Folder__r.Content_Folder__c)){
                     if(u!=null){
                         if(u.PA_LFM__Template_Favorite__c!=null){
                             List<String> fav= u.PA_LFM__Template_Favorite__c.split(',');
                             for(Integer i=0,j=fav.size();i<j;i++){
                                 if(fav[i].equals(obj.Id)){
                                     obj.PA_LFM__Is_favorite__c=true;
                                     i=j;
                                 }
                             }
                         }
                     }
                     
                     
                     templateContiner templateC=new templateContiner(obj,mapOfConfig.get(obj.PA_LFM__Library_and_Folder__c));
                     List<Tag__c> tags=new  List<Tag__c>();
                     if(obj.PA_LFM__Linked_Tags__c!=null){
                         List<String> temp=obj.PA_LFM__Linked_Tags__c.split(',');
                         
                         for(String t:temp){
                             
                             if(mapOfTagss.containsKey(t))
                                 tags.add(mapOfTagss.get(t));
                         }
                     }
                     
                     templateC.tags=tags;
                     List<lookupContainer> recordsTemp=new List<lookupContainer>();
                     if(obj.PA_LFM__Linked_Records__c!=null){
                         Utils.log(obj.PA_LFM__Linked_Records__c);
                         List<String> tempRec=obj.PA_LFM__Linked_Records__c.split(',');
                         Utils.log(tempRec);
                         for(String t:tempRec){
                             List<String> t2=t.split('_');
                             Utils.log(t2);
                             recordsTemp.add(new lookupContainer(t2[1],t2[0],Utils.getObjectNameById(t2[0]) ,'Name' ));
                         }
                     }
                     templateC.records=recordsTemp;
                     returnList.add(templateC);
                 }
            }
            
            return returnList;
            
           
        }
        catch(Exception e){
            
          if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'fetchTemplate of getObjectLookupController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(e.getMessage());  
            } 
        }
    }

    @AuraEnabled//return config/tag/object records for single template
    public static templateContiner getTemplateRecords(String tempId){
        
        String templateQuery =  'SELECT Id,Name,PA_LFM__Library_and_Folder__c,PA_LFM__Linked_Records__c,PA_LFM__Linked_Tags__c  FROM Classification_Template__c WHERE Id =:tempId AND Active__c=true order by createdDate DESC LIMIT 1';        
         PA_LFM__Classification_Template__c template;
        if(Utils.checkCurd(templateQuery, Utils.CURDOpration.READ)){
            template=Database.query(templateQuery);
        }
        else{
            throw new curdPermisionException();
        }
        
        String configId=template.PA_LFM__Library_and_Folder__c;
        String configString =  'SELECT Id,Name,Combined_Folder_Name__c,Content_Folder__c,Icon_Name__c,Default_Folder__c,Library_and_Folder__c,Order_of_Display__c,(SELECT Id,Icon_Name__c,Required__c,Tag__c,Library_And_Folder__r.Library_and_Folder__c FROM PA_LFM__Available_Tags__r),(SELECT Id,Field_to_Display__c,Icon_Name__c,Name,Required__c,Library_And_Folder__r.Library_and_Folder__c FROM PA_LFM__Available_Objects__r)  FROM Folder_Configuration__c WHERE Id=:configId LIMIT 1';         
        Folder_Configuration__c config;
        if(Utils.checkCurd(configString, Utils.CURDOpration.READ)){
            config=Database.query(configString);
        }
        else{
            throw new curdPermisionException();
        }
        
     
       
        List < Tag__c > lstOfTags=new  List < Tag__c >();
        List<lookupContainer> lstOfRecords=new List<lookupContainer>();
        try{
            if(template.PA_LFM__Linked_Tags__c!=null){
                String tagid=template.PA_LFM__Linked_Tags__c;
                List<String> tagIds=tagid.split(',');
                String sQuery =  'select id, Depends_on_Tag__c,Depends_on_Tag_Description__c,Depends_on_Tag_Type__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c,Library_and_Folder__r.Library_and_Folder__c,Tag_Description__c,Name,Type_of_Tag__c,(SELECT Id,Type_of_Tag__c FROM Tags__r) from Tag__c where id IN:tagIds   order by createdDate DESC limit 10';        
                if(Utils.checkCurd(sQuery, Utils.CURDOpration.READ)){
                    lstOfTags = Database.query(sQuery);
                }
                else{
                    throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
                }  
            }
            
            if(template.PA_LFM__Linked_Records__c!=null){
                String oIds=template.PA_LFM__Linked_Records__c;
                List<String> objIds=oIds.split(',');
                for(String rIdaName:objIds){
                    String rId=rIdaName.split('_')[0];
                    String objName=Utils.getObjectNameById(rId);
                    List<PA_LFM__Object_Configuration__c> avilObj=config.PA_LFM__Available_Objects__r;
                    String fieldName='Name';
                    for(PA_LFM__Object_Configuration__c oConfig:avilObj){
                        if(oConfig.Name==objName){
                            fieldName=oConfig.PA_LFM__Field_to_Display__c;
                            break;
                        } 
                    }
                    sObject oRecord=getRecord(rId,fieldName,objName);
                    if(oRecord!=null){
                        lstOfRecords.add(new lookupContainer((String)oRecord.get(fieldName),oRecord.Id,objName,fieldName));
                    }
                }
            }
            templateContiner ret=new templateContiner(lstOfTags,lstOfRecords);
            ret.folder=config;
            return ret;
            
        }
        catch(exception e){
            
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'getTagsById of getObjectLookupController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(e.getMessage());      
            }
        }
        
    }
    @AuraEnabled
    public static lookupContainer getRecordforId(String sid,String fieldName,String objName){
        try{
            
        
        sObject oRecord=getRecord(sid,fieldName,objName);
        return  new lookupContainer((String)oRecord.get(fieldName),oRecord.Id,objName,fieldName);
        }
          catch(exception e){
            
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'getTagsById of getObjectLookupController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(e.getMessage());      
            }
        }
        
    }
    private static sObject getRecord(String sid,String filedName,String objName){
      
        String query='SELECT id,'+filedName+' FROM '+objName+' WHERE id=:sid';
        if(Utils.checkCurd(query, Utils.CURDOpration.READ)){
            List < sObject > lstOfRecords = Database.query(query);
            for (sObject obj: lstOfRecords) {
                return obj;
            }
            return null;
        }
        else{
            throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
        }
        
    }
    
    @AuraEnabled
    public static Boolean callClassifyContentversion(id docid,String configString,String tagsString,String recordsObject,String saveTemp){
        try{
            return ClassifyFile.classifyContentversion(docid,configString,tagsString,recordsObject,saveTemp);    
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());    
        }
        
        
    } 
}