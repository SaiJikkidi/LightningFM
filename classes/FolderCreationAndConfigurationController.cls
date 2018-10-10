public class FolderCreationAndConfigurationController {
    
    @AuraEnabled
    public static string getInsertFinalRecords(List<string> folderTagsConfigurations,List<String> objectConfigurations){
        System.debug('folderTagsConfigurations size '+folderTagsConfigurations.size());
        System.debug('objectConfigurations size '+objectConfigurations.size());
        try{
            String folderId='';
            String Success = 'SUCCESS';
            List<PA_LFM__Tag_Configuration__c> folderTags = new List<PA_LFM__Tag_Configuration__c>() ;
            List<PA_LFM__Object_Configuration__c> selectedObjects = new List<PA_LFM__Object_Configuration__c>();
            List<Id>  objectIds=new List<Id>();
            List<Id>  tagIds=new List<Id>();
            if(folderTagsConfigurations.Size()>0){
                Integer tagOrder=1;
                for(String FT : folderTagsConfigurations){
                    PA_LFM__Tag_Configuration__c allTags = (PA_LFM__Tag_Configuration__c)JSON.deserialize(FT,PA_LFM__Tag_Configuration__c.class);
                   
                    if(allTags.Id!=null){
                    	tagIds.add(allTags.Id);
                    }
                    if(String.isBlank(folderId)){
                        folderId=allTags.PA_LFM__Library_and_Folder__c;
                    }
                    allTags.PA_LFM__Order_of_Display__c=tagOrder;
                    tagOrder++;
                    
                    folderTags.add(allTags);
                }
            }
            System.debug('tagIds '+tagIds);
            if(objectConfigurations.Size()>0){
                System.debug('objectConfigurations '+objectConfigurations);
                Integer objectOrder=1;
                for(String OC : objectConfigurations){
                    PA_LFM__Object_Configuration__c allObjects = (PA_LFM__Object_Configuration__c)JSON.deserialize(OC,PA_LFM__Object_Configuration__c.class);
                    
                    if(allObjects.Id!=null){
                    	objectIds.add(allObjects.Id);
                    }
                    if(String.isBlank(folderId)){
                        folderId=allObjects.PA_LFM__Library_and_Folder__c;
                    }
                    allObjects.PA_LFM__Order_of_Display__c=objectOrder;
                    objectOrder++;
                    
                    selectedObjects.add(allObjects);
                }
            }
            if(Utils.checkCurd('SELECT id FROM PA_LFM__Tag_Configuration__c', Utils.CURDOpration.READ) && Utils.checkCurd('SELECT id FROM PA_LFM__Object_Configuration__c', Utils.CURDOpration.READ) &&
                Utils.checkCurd('PA_LFM__Tag_Configuration__c', Utils.CURDOpration.CREATE) && Utils.checkCurd('PA_LFM__Object_Configuration__c', Utils.CURDOpration.CREATE) &&
               Utils.checkCurd('PA_LFM__Tag_Configuration__c', Utils.CURDOpration.REMOVE) && Utils.checkCurd('PA_LFM__Object_Configuration__c', Utils.CURDOpration.REMOVE) &&
               Utils.checkCurd('PA_LFM__Tag_Configuration__c', Utils.CURDOpration.MODIFY) && Utils.checkCurd('PA_LFM__Object_Configuration__c', Utils.CURDOpration.MODIFY)){
                   if(folderTags.size()>0 || selectedObjects.size()>0){
                       if(folderTags.size()>0){
                           try{
                               
                               if(tagIds.size()>0){
                                   Map<id,PA_LFM__Tag_Configuration__c>  exsistingTag=new Map<id,PA_LFM__Tag_Configuration__c>([SELECT id FROM PA_LFM__Tag_Configuration__c WHERE PA_LFM__Library_and_Folder__c =:folderId]);    
                                   for(String tId:tagIds){
                                       exsistingTag.remove(tId);
									}
                                   if(exsistingTag.size()>0){
                                       delete [SELECT id FROM PA_LFM__Tag_Configuration__c WHERE id IN:exsistingTag.values()];
                                   }
                               }
                               
                           	   upsert folderTags;
                           }
                           catch(Exception e){
                               if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);}else{Utils.log(e.getMessage()+'<getInsertFinalRecords of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message); }
                           }
                       }
                       if(selectedObjects.size()>0){  
                           try{
                               if(objectIds.size()>0){
                                   Map<id,PA_LFM__Object_Configuration__c>  exsistingObj=new Map<id,PA_LFM__Object_Configuration__c>([SELECT id FROM PA_LFM__Object_Configuration__c WHERE PA_LFM__Library_and_Folder__c =:folderId]);    
                                   
                                   for(String oId:objectIds){
                                       exsistingObj.remove(oId);
                                   }
                                   if(exsistingObj.size()>0){
                                       delete [SELECT id FROM PA_LFM__Object_Configuration__c WHERE id IN:exsistingObj.values()];
                                   }
                               }
                               
                               upsert selectedObjects;
                           }
                           catch(Exception e){
                               if(e instanceof curdPermisionException){
                                   throw  new AuraHandledException(System.Label.CurdPermision);
                               }
                               else{
                                   Utils.log(e.getMessage()+'<getInsertFinalRecords of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message); 
                               }
                                             }
                       }
                       return Success;
                   }
                   else{
                       return null; 
                   }
               }else{
                   throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
               }
        }
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);}else{Utils.log(e.getMessage()+'<getInsertFinalRecords of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message); }
                          }    
    }
    
    @AuraEnabled
    public static list<PA_LFM__Object_Configuration__c> getobjectConfigurations(string folderId) {
        List<PA_LFM__Object_Configuration__c> objectConfigDetails = new list<PA_LFM__Object_Configuration__c>();
        
        try{
            String soql = 'SELECT id,Name,PA_LFM__Field_to_Display__c,PA_LFM__Library_and_Folder__c,PA_LFM__Required__c from PA_LFM__Object_Configuration__c where PA_LFM__Object_Configuration__c.Name !=null';
            if (!folderId.equals('')){
                soql += ' and PA_LFM__Library_and_Folder__c = :folderId';
            }
            soql += ' ORDER BY PA_LFM__Order_of_Display__c asc NULLS LAST';
            if(!Utils.checkCurd(soql, Utils.CURDOpration.READ)){
                throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
            }
            for(PA_LFM__Object_Configuration__c  objConfig :Database.query(soql)){
                objectConfigDetails.add(objConfig);
            }
            return objectConfigDetails;
        }  
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }    
    }
    
    
    @AuraEnabled
    public static list<PA_LFM__Tag_Configuration__c >  getFileTagsConfiguration(string folderId){
        List<PA_LFM__Tag_Configuration__c> fileTagsConfiguration = new list<PA_LFM__Tag_Configuration__c>();
        try{
            String soql = 'SELECT id,Name,PA_LFM__Tag__c,PA_LFM__Required__c,PA_LFM__Icon_Name__c,PA_LFM__Library_and_Folder__c from PA_LFM__Tag_Configuration__c where PA_LFM__Tag_Configuration__c.Name !=null';
            if (!folderId.equals('')){
                soql += ' and PA_LFM__Library_and_Folder__c = :folderId';
            }
            soql += ' ORDER BY PA_LFM__Order_of_Display__c asc NULLS LAST';
            if(!Utils.checkCurd(soql, Utils.CURDOpration.READ)){
                throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
            }
            for(PA_LFM__Tag_Configuration__c  FTC :Database.query(soql)){
                fileTagsConfiguration.add(FTC);
            }
            return fileTagsConfiguration;
            
        }
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }      
        
    }
    
    @AuraEnabled
    public static string getDuplicates(string folderPath) {
        string CWid = '';
        try{
            if(!Utils.checkCurd('select id, Library_and_Folder__c from Folder_Configuration__c where Name != null LIMIT 1000 ', Utils.CURDOpration.READ)){
                throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
            }
            for(Folder_Configuration__c  FC :[select id, Library_and_Folder__c from Folder_Configuration__c where Name != null LIMIT 1000 ]){                
                if(FC.Library_and_Folder__c == folderPath){
                    return null;
                }
            }
            
            ContentWorkspace objWorkSpace = new ContentWorkspace();
            objWorkSpace.Name = folderPath;
            if(!Utils.checkCurd('ContentWorkspace', Utils.CURDOpration.CREATE)){
                throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
            }
            Database.SaveResult srList = Database.insert(objWorkSpace, false);
            
            if (srList.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                Utils.log('Successfully inserted Library. ContentWorkspace ID: ' + srList.getId());
                CWid = srList.getId();
                return CWid;
                
            }else{
                for(Database.Error err : srList.getErrors()) {
                    Utils.log('The following error has occurred.');                    
                    Utils.log(err.getStatusCode() + ': ' + err.getMessage());
                    Utils.log('ContentWorkspace fields that affected this error: ' + err.getFields());
                }
                return null;
            }
        }
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }   
    }
    
    @AuraEnabled
    public static string getInsertFolders(string folderName,string CWid,string folderParentId,string Icon) {
        string successMessage = 'Record Created';
        try{
            string folderId = '';
            
            if(CWid != '' && CWid != null){
                PA_LFM__Folder_Configuration__c   folderConfiguration = new PA_LFM__Folder_Configuration__c ();
                folderConfiguration.Name = folderName;
                folderConfiguration.PA_LFM__Library_and_Folder__c = folderName.trim();
                folderConfiguration.PA_LFM__Content_Folder__c  = CWid;
                if(folderParentId !=''){
                    folderConfiguration.PA_LFM__Parent_Folder_Configuration__c = folderParentId;}
                folderConfiguration.PA_LFM__Icon_Name__c = Icon;
                if(!Utils.checkCurd('PA_LFM__Folder_Configuration__c', Utils.CURDOpration.CREATE)){
                    throw new curdPermisionException(System.Label.PA_LFM.CurdPermision);
                }
                Database.SaveResult insertFolderTags = Database.insert(folderConfiguration, false);
                
                if (insertFolderTags.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    Utils.log('Successfully inserted Library. ContentWorkspace ID: ' + insertFolderTags.getId());
                    folderId = insertFolderTags.getId();
                }else{
                    for(Database.Error err : insertFolderTags.getErrors()) {
                        Utils.log('The following error has occurred.');                    
                        Utils.log(err.getStatusCode() + ': ' + err.getMessage());
                        Utils.log('ContentWorkspace fields that affected this error: ' + err.getFields());
                    }
                }
            }
            return successMessage;
            
        }   
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }   
    }
    
    
    @AuraEnabled
    public static List <items> getFolderStructureItems() {
        
        /**************************************************************************
@Method name: getFolderStructureItems
@param :null
@return : List <items>
@Description : returns folder structure for guided setup.
***************************************************************************/
        
        List<items> finalWrp = new List<items>(); 
        List<items> SectionWrap = new List<items>(); 
        
        try{
            String folderQuery='SELECT Id,Library_and_Folder__c,Content_Folder__c,Icon_Name__c,Parent_Folder_Configuration__c,Parent_Folder_Configuration__r.Library_and_Folder__c,Parent_Folder_Configuration__r.Parent_Folder_Configuration__c,Parent_Folder_Configuration__r.Parent_Folder_Configuration__r.Library_and_Folder__c,Default_Folder__c FROM Folder_Configuration__c WHERE Active__c=true ORDER BY Combined_Folder_Name__c DESC NULLS LAST';             
            list<Folder_Configuration__c> folderConfigList = new  list<Folder_Configuration__c> (); 
            if(Utils.checkCurd(folderQuery, Utils.CURDOpration.READ)){
                folderConfigList = Database.query(folderQuery);
            }else{
                throw new curdPermisionException(System.Label.CurdPermision);
            }
            if(folderConfigList.size()>0){
                SectionWrap.addall(getNavigationmenuData.getFolderHierarchyItems(folderConfigList));
            }
            return SectionWrap; 
        }
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getFolderStructureItems of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }  
    }
    
    @AuraEnabled
    public static folderTagsWrapper getAllFolderTags(){
        try{
            List<dualPickListWrapper> dualPickListwrpr = new list<dualPickListWrapper> ();
            folderTagsWrapper actionWrapper = new folderTagsWrapper();
            
            String objectType ='PA_LFM__Tag_Configuration__c';
            String selectedField = 'PA_LFM__Tag__c';
            Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
            Schema.DescribeSObjectResult res = convertToObj.getDescribe();
            Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                dualPickListWrapper dualpiklstwrpr = new dualPickListWrapper();
                dualpiklstwrpr.label = pickListVal.getLabel();
                dualpiklstwrpr.value = pickListVal.getValue();
                dualPickListwrpr.add(dualpiklstwrpr);
            }     
            actionWrapper.dualPicklistvalues = dualPickListwrpr;
            return actionWrapper;
        }
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }  
    }
    
    @AuraEnabled
    public static guidedSetupWraper getobjects() {
        try{
            List<dualPickListWrapper> dualPickListwrpr = new list<dualPickListWrapper> ();
            guidedSetupWraper actionWrapper = new guidedSetupWraper();
            
            List<String> objNames = new List<String>();
            List<String> customObjList = new list<string>();
            List<String> standardObjList = new list<string>();
            map<string,schema.sobjecttype> describe = schema.getglobaldescribe();
            for(string objectname:describe.keyset()) {
                objNames.add(describe.get(objectname).getdescribe().getname());
                dualPickListWrapper dualpiklstwrpr = new dualPickListWrapper();
                if(describe.get(objectname).getDescribe().getKeyPrefix() != null && describe.get(objectname).getDescribe().isQueryable() && describe.get(objectname).getDescribe().isAccessible() && describe.get(objectname).getdescribe().getRecordTypeInfos().size()>0){
                    dualpiklstwrpr.label = describe.get(objectname).getdescribe().getLabel();
                    dualpiklstwrpr.value = describe.get(objectname).getdescribe().getname();
                    dualPickListwrpr.add(dualpiklstwrpr);
                }
            }
            actionWrapper.dualPicklistvalues = dualPickListwrpr;
            return actionWrapper;
        }
        catch(Exception e){if(e instanceof curdPermisionException){throw  new AuraHandledException(System.Label.CurdPermision);
                                                                  }
                           else{
                               Utils.log(e.getMessage()+'<getobjectConfigurations of FolderCreationAndConfigurationController>'+e.getStackTraceString());Utils.sendErrorMail(e);throw  new AuraHandledException(System.Label.Exception_message);      
                           }
                          }  
    }
    
    public class dualPickListWrapper {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value {get;set;}
    }
    public class guidedSetupWraper{
        @AuraEnabled
        public List<dualPickListWrapper> dualPicklistvalues {get;set;}   
    }
    
    public class folderTagsWrapper{
        @AuraEnabled
        public List<dualPickListWrapper> dualPicklistvalues {get;set;}   
    }
}