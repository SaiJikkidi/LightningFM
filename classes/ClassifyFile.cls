/**********************************************************************
 * @Aim:Classify content version according to selected tags and link to respective object records
 * @UsedAt:tagTree,UploadFileAndClassify
 * @Company:PopcornApps 
 * ********************************************************************
 * Date           Auther              Description
 * 07-07-2018     Syed Furqan Ahmed   created class with methods to classify file,fetch tag,create template methods
 * 08-07-2018     Syed Furqan Ahmed   ristricted tag visiblity according to user access perm on folder
 */
public class ClassifyFile { 
    @AuraEnabled 
    public static Boolean classifyContentversion(id docid,String configString,String tagsString,String recordsObject,String saveTemp){
        
        Savepoint sp = Database.setSavepoint();
        try{
            Utils.log(saveTemp);
            String contentDocumentQuery='select LatestPublishedVersionId,Id from ContentDocument where Id = :docid';
            Map<String,Object> template=(Map<String,Object>)JSON.deserializeUntyped(saveTemp);
            Map<String,Object> config=(Map<String,Object>)JSON.deserializeUntyped(configString);
            
            Boolean saveTemplate=Boolean.valueOf(template.get('Status'));
            String linkedTags='';
            String linkedRecords='';
            if(Utils.checkCurd(contentDocumentQuery, Utils.CURDOpration.READ)){
                //geting file
                List<ContentDocument> cD= Database.query(contentDocumentQuery);
                if(cD.size()>0){
                    String versionId =cD.get(0).LatestPublishedVersionId;
                    //all tags that are to be added
                    List<Object> tags=(List<Object>) JSON.deserializeUntyped(tagsString);
                    if(tags.size()>0){
                        String ContentVersionQuery='SELECT Id,TagCsv,All_Tags__c,ContentDocumentId  FROM ContentVersion WHERE id=:versionId LIMIT 1';
                        if(Utils.checkCurd(ContentVersionQuery, Utils.CURDOpration.READ)){
                            
                            ContentVersion previousCV=Database.query(ContentVersionQuery);
                            docid= previousCV.ContentDocumentId; 
                            ContentVersion objcontVer = new ContentVersion();
                            objcontVer.id=versionId;
                            objcontVer.All_Tags__c='';
                            if(previousCV.TagCsv!=null){
                                objcontVer.TagCsv=previousCV.TagCsv;
                            }
                            else{
                                objcontVer.TagCsv='';
                            }
                            //adding tags to file
                            for(Object currentElememt:tags){
                                Map<String,Object> tag=(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(currentElememt));
                                String tagName=(String)tag.get('Name');
                                linkedTags=linkedTags+(String)tag.get('Id')+',';
                                if(objcontVer.All_Tags__c.length()<255){
                                    objcontVer.All_Tags__c=objcontVer.All_Tags__c+tagName.trim()+',';
                                }
                                if(objcontVer.TagCsv.length()<255){
                                    objcontVer.TagCsv= objcontVer.TagCsv+tagName.trim()+',';
                                }
                                
                                
                            }
                            linkedTags=linkedTags.removeEnd(',');
                            objcontVer.All_Tags__c=objcontVer.All_Tags__c.removeEnd(',');
                            objcontVer.TagCsv=objcontVer.TagCsv.removeEnd(',');
                            
                            if(Utils.checkCurd('SELECT All_Tags__c,TagCsv FROM ContentVersion', Utils.CURDOpration.MODIFY)){
                                update objcontVer;
                            }
                            else{
                                throw new curdPermisionException();
                            } 
                        }
                        else{
                            throw new curdPermisionException();
                        }
                        
                    }
                    //geting all records
                    List<Object> records=(List<Object>) JSON.deserializeUntyped(recordsObject);
                    if(records.size()>0){
                        
                        list<ContentDocumentLink> contDocLinkList = new list<ContentDocumentLink>();
                        for(Object currentElememt:records){
                            //linking file with record
                            ContentDocumentLink objdoclink =new  ContentDocumentLink();
                            objdoclink.ContentDocumentId  = docid;
                            Map<String,Object> obj=(Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(currentElememt));
                            objdoclink.LinkedEntityId = (String)obj.get('Id');
                            objdoclink.ShareType = System.Label.ContentDocumentLink_ShareType;
                            contDocLinkList.add(objdoclink);
                            linkedRecords=linkedRecords+(String)obj.get('Id')+'_'+(String)obj.get('Name')+',';
                        }
                        linkedRecords=linkedRecords.removeEnd(',');
                        if(Utils.checkCurd('ContentDocumentLink', Utils.CURDOpration.CREATE)){
                            insert contDocLinkList;
                        }
                        else{
                            throw new curdPermisionException();
                        }
                    }
                    if(saveTemplate){
                        PA_LFM__Classification_Template__c templat=new PA_LFM__Classification_Template__c();
                        templat.Name=((String)template.get('Name')).trim();
                        templat.PA_LFM__Active__c=saveTemplate;
                        templat.PA_LFM__Library_and_Folder__c=(String)config.get('Id');
                        templat.PA_LFM__Linked_Records__c=linkedRecords.trim();
                        templat.PA_LFM__Linked_Tags__c=linkedTags.trim();
                        if(Utils.checkCurd('PA_LFM__Classification_Template__c', Utils.CURDOpration.CREATE)){
                            insert templat;
                        }
                        else{
                            throw new curdPermisionException();
                        }
                    }
                }  
                
                
            }
            else{
                throw new curdPermisionException();
            }
            return true;
        }
        catch(Exception e){
            Database.rollback( sp );
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<classifyContentversion of ClassifyAndUploadFile>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(System.Label.ContentVersion_CannotClassify);      
            }
        }
        
        
    }
    
    
    @AuraEnabled//return tag tree
    public static List <items> getTagHierarchyData(String searchKey) {
        Utils.log('getTagHierarchyData of tagTreeController');
        try{
            List<items> trL3 = new List<items>();
            List<items> trL2 = new List<items>(); 
            map<id,list<items>> ml2l3childs = new map<id,list<items>>();
            List<items> finalWrp = new List<items>();  
            map<string,list<items>> mLibnameL1Item = new map<string,list<items>>();
            String tQuery='';
            if(String.isEmpty(searchKey)){
                tQuery='SELECT Library_and_Folder__r.Content_Folder__c,Library_and_Folder__c,Library_and_Folder__r.Combined_Folder_Name__c,Type_of_Tag__c,Name,Depends_on_Tag_Type__c,Id,Depends_on_Tag__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c FROM Tag__c where Library_and_Folder__c != null  ORDER BY Depends_on_Tag__c DESC NULLS LAST';
            }
            else{
                Utils.log(searchKey);
                searchKey=String.escapeSingleQuotes(searchKey)+'%';
                tQuery='SELECT Library_and_Folder__r.Content_Folder__c,Library_and_Folder__c,Library_and_Folder__r.Combined_Folder_Name__c,Type_of_Tag__c,Name,Depends_on_Tag_Type__c,Id,Depends_on_Tag__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c FROM Tag__c where Library_and_Folder__c != null AND (Depends_on_Tag__r.Name LIKE: searchKey or Name LIKE: searchKey) ORDER BY Depends_on_Tag__c DESC NULLS LAST';
            }
            Utils.log(tQuery);
            if(Utils.checkCurd(tQuery, Utils.CURDOpration.READ)){
                List<Tag__c> t=Database.query(tQuery);
                
                //added on 8-8-2018
                /*
                List<String> contentFolderIds=new List<String>();
                for(Tag__c tagObj:t){
                    if(tagObj.Library_and_Folder__r.Content_Folder__c!=null){
                        contentFolderIds.add(tagObj.Library_and_Folder__r.Content_Folder__c);
                    }
                }
                Map<String,String> hasAccessFolders=LookupController.checkContentDocumentAccess(contentFolderIds);
                List<Tag__c> hassAccessTag=new List<Tag__c>();
                for(Tag__c tagObj:t){
                    if(tagObj.Library_and_Folder__r.Content_Folder__c!=null){
                        if(hasAccessFolders.containsKey(tagObj.Library_and_Folder__r.Content_Folder__c)){
                            hassAccessTag.add(tagObj);
                        }
                    }
                }
                t=hassAccessTag;*/
                //End
                
                
                
                //querying all tags
                for (Tag__c objtag :t)
                {
                    
                    if(objtag.Depends_on_Tag__c != null){
                        if(!ml2l3childs.containsKey(objtag.Depends_on_Tag__c))
                        {
                            
                            List<items> templistchilds =new List<items> ();
                            //templistchilds.add(new items(objtag.Id,objtag.Type_of_Tag__c +' : '+ objtag.Name,(objtag.Depends_on_Tag__c!=null)?true:false, null));
                            templistchilds.add(new items(objtag.Id,objtag.Type_of_Tag__c +': '+ objtag.Name, false, null));
                            
                            
                            ml2l3childs.put(objtag.Depends_on_Tag__c,templistchilds);
                        }
                        else{
                            
                            List<items> templistchildsold = ml2l3childs.get(objtag.Depends_on_Tag__c);
                            //templistchildsold.add(new items(objtag.Id,objtag.Type_of_Tag__c +' : '+ objtag.Name,(objtag.Depends_on_Tag__c!=null)?true:false, null));
                            templistchildsold.add(new items(objtag.Id,objtag.Type_of_Tag__c +': '+ objtag.Name, false, null));
                            
                            
                            ml2l3childs.put(objtag.Depends_on_Tag__c,templistchildsold); 
                        }
                    }
                    
                    
                    
                    if(objtag.Depends_on_Tag_Type__c == null){
                        if(! mLibnameL1Item.containsKey(objtag.Library_and_Folder__r.Combined_Folder_Name__c))
                        {   
                            List<items> templistnew =new List<items>();
                            if(!ml2l3childs.containsKey(objtag.id)){  
                                
                                templistnew.add(new items(objtag.Id,objtag.Type_of_Tag__c +': '+ objtag.name, false,null) );
                            }
                            else{
                                
                                templistnew.add(new items(objtag.Id, objtag.Type_of_Tag__c +': '+objtag.name, false,ml2l3childs.get(objtag.id)) );
                            }
                            
                            mLibnameL1Item.put(objtag.Library_and_Folder__r.Combined_Folder_Name__c,templistnew );
                        }
                        else{
                            
                            List<items> templistold = mLibnameL1Item.get(objtag.Library_and_Folder__r.Combined_Folder_Name__c);
                            if(! ml2l3childs.containsKey(objtag.id)){  
                                
                                templistold.add(new items(objtag.Id, objtag.Type_of_Tag__c +': '+objtag.name, false,null) );
                            }
                            else{
                                
                                templistold.add(new items(objtag.Id,objtag.Type_of_Tag__c +': '+objtag.name, false,ml2l3childs.get(objtag.id)) );
                            }
                            
                            mLibnameL1Item.put(objtag.Library_and_Folder__r.Combined_Folder_Name__c,templistold );
                        }
                    }
                }
            }
            else{
                throw new curdPermisionException(System.Label.CurdPermision);
            }
            
            
            
            for( string libname :mLibnameL1Item.keyset())
            {
                finalWrp.add(new items(libname, libname, false,mLibnameL1Item.get(libname)));
            }
            
            
            return finalWrp ;  
        }
        catch(Exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(System.Label.Exception_message);      
            }
        }  
    }   
    
    @AuraEnabled//return tag ang configuration
    public static LookupController.templateContiner fetchRecordWithId(String recordId) {
        try{
            String tagQuery =  'select id,Depends_on_Tag__c,Depends_on_Tag_Description__c,Depends_on_Tag_Type__c,Depends_on_Tag__r.Name,Depends_on_Tag__r.Type_of_Tag__c,Library_and_Folder__c,Library_and_Folder__r.Library_and_Folder__c,Tag_Description__c,Name,Type_of_Tag__c,(SELECT Id,Type_of_Tag__c FROM Tags__r) from Tag__c where Id =: recordId ';        
            if(!Utils.checkCurd(tagQuery, Utils.CURDOpration.READ)){  throw new curdPermisionException(System.Label.CurdPermision);}
            List<Tag__c> tag=Database.query(tagQuery);
            if(tag.size()>0){
                String configId=tag.get(0).Library_and_Folder__c;
                String configQuery =  'SELECT Id,Combined_Folder_Name__c,Name,Content_Folder__c,Icon_Name__c,Default_Folder__c,Library_and_Folder__c,Order_of_Display__c,(SELECT Id,Icon_Name__c,Required__c,Tag__c,Library_And_Folder__r.Library_and_Folder__c FROM PA_LFM__Available_Tags__r),(SELECT Id,Field_to_Display__c,Icon_Name__c,Name,Required__c,Library_And_Folder__r.Library_and_Folder__c FROM PA_LFM__Available_Objects__r)  FROM Folder_Configuration__c WHERE Id=:configId AND Active__c=true';        
                List<Folder_Configuration__c> config=Database.query(configQuery);
                if(config.size()>0){
                    
                    return new LookupController.templateContiner(tag,config.get(0));
                }
            }
            return null;
        }
        catch(Exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(System.Label.Exception_message);      
            }
        }  
        
        
        
        
        
        //   return [SELECT Id, Name, PA_LFM__Library_and_Folder__c,Library_and_Folder__r.Library_and_Folder__c,Type_of_Tag__c, Depends_on_Tag_Type__c,Depends_on_Tag__r.name,Depends_on_Tag__r.Type_of_Tag__c, Depends_on_Tag__c FROM Tag__c where Id =: recordId limit 1] ;
    }      
    
    @auraEnabled//used in LFM_classificationResults to make template fav
    public static Boolean saveAsFav(String recordId,Boolean opration){
        Utils.log(recordId);
        try{
            if(Utils.checkCurd('Select id,PA_LFM__Template_Favorite__c FROM User WHERE id=:UserInfo.getUserId',Utils.CURDOpration.READ)){
                User u=[Select id,PA_LFM__Template_Favorite__c FROM User WHERE id=:UserInfo.getUserId()];
                Utils.log(u);
                if(opration != null && recordId != null){
                    if(opration){
                        if(u.PA_LFM__Template_Favorite__c!=null){
                            u.PA_LFM__Template_Favorite__c=u.PA_LFM__Template_Favorite__c+','+recordId;    
                        }
                        else{
                            u.PA_LFM__Template_Favorite__c=recordId;  
                        }
                    }
                    else{
                        u.PA_LFM__Template_Favorite__c= u.PA_LFM__Template_Favorite__c.remove(','+recordId);    
                        u.PA_LFM__Template_Favorite__c= u.PA_LFM__Template_Favorite__c.remove(recordId);    
                    }
                    
                    if(Utils.checkCurd('User',Utils.CURDOpration.MODIFY)){
                        update u;
                        Utils.log(u);
                        return true;
                    }
                    else{
                        throw new curdPermisionException();   
                    }
                }else{
                    return null;
                }
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
                Utils.log(e.getMessage()+'<classifyContentversion of ClassifyAndUploadFile>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException((e.getMessage()));      
            }
        } 
        
    }
    
}