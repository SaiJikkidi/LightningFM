public class searchResultDataTableController {
    
    /**********************************************************************
* @Aim:Class Provides methods returning file search results
* @UsedAt:NavigationMenu
* @Company:PopcornApps
* *************************************************************************
* Date           Auther              Description
* 07-08-2018     Harish Koilkonda   Created class and methods to returm List of content version records 
* 
* **************************************************************************/
    
    @AuraEnabled
    public static lightningTableWraper getFilesResults(String configString,String tagsString,String recordsObject,String searchKeyWord,String fileType,String sortDate,string fieldstoget,Integer limits,Integer offsets,String NavItemSelected,String recordID) {
        
        try{
            List<Object> tags = new List<Object>();
            List<Object> Objects = new List<Object>();
            string contentworksapceID ;
            
            if(configString !='' && configString != null && !String.isBlank(configString) ){
                Map<String,Object> WorkSpaceObj=(Map<String,Object>) JSON.deserializeUntyped(configString);
                contentworksapceID = (String)WorkSpaceObj.get('PA_LFM__Content_Folder__c');}
            
            if(tagsString !=''&& tagsString != null && !String.isBlank(tagsString)){
                tags=(List<Object>) JSON.deserializeUntyped(tagsString);}
            if(recordsObject !='' && recordsObject != null && !String.isBlank(recordsObject)){
                Objects=(List<Object>) JSON.deserializeUntyped(recordsObject);}            
            //Select Fields to Display
            List<OptionsWrapper> optwrpr = new list<OptionsWrapper> ();
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                OptionsWrapper optionswrpr = new OptionsWrapper();
                optionswrpr.label = dfield.getLabel();
                optionswrpr.value =dfield.getName();
                optwrpr.add(optionswrpr);
                
            }
            //End of Select Fields to Display
            
            //Get List view values from login user
            string lst ='';
            List<String> lstfieldstoget = new List<String>();
            if(fieldstoget !='' && !string.isBlank(fieldstoget)){
                lst = fieldstoget;
                try {
                    User usr =  new User(); 
                    usr.Id= UserInfo.getUserId();
                    usr.Listview__c = fieldstoget;
                    update usr;
                } catch(DmlException e) {
                    Utils.log('An unexpected error has occurred: ' + e.getMessage());
                    throw new curdPermisionException(System.Label.CurdPermision);
                }
            }else{
                Utils.log('Inside else');
                for(User u : [SELECT Id,Listview__c  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]){
                    if(u.Listview__c != null && !string.isBlank(u.Listview__c)){
                        lst = u.Listview__c;
                    }else {
                        lst = 'Title,CreatedDate,OwnerId';
                    }
                }
            }
            
            // End of List view for User
            lstfieldstoget = lst.split(',');
            Boolean Titleresult = lstfieldstoget.contains('Title');
            if(Titleresult==False){
                lstfieldstoget.add(0,'Title');
            }
            List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper> ();
            
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('ContentVersion').getDescribe();
            
            
            String soql =  'SELECT Id,Icons__c,ContentDocumentId, IsLatest, ContentUrl, ContentBodyId, VersionNumber, Title, Description, OwnerId,Owner.Name, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, TagCsv, FileType, PublishStatus, ContentLocation, Origin, TextPreview, All_Tags__c from ContentVersion where ContentVersion.Title != null';
            
            String countOfRecords = 'SELECT count(Id) total from ContentVersion where ContentVersion.Title != null';
            
            set<id> DocId = new set<id>();   
            set<id> relatedToRecordDocId = new set<id>();    
            
            set <id> LinkedEntityIds = new set <id>();
            
            
            List<String> allTags = new List <String>();
            string eachtag ='';
            string eachTagKey ='';
            if (!NavItemSelected.equals('')){
                if( NavItemSelected instanceof id ){
                    Id navKey = Id.valueOf(String.escapeSingleQuotes(NavItemSelected));
                    if(navKey.getSobjectType() == Schema.Navigation_Menu_Configuration__c.SObjectType)
                    {   String passQueryParam=Id.valueOf(String.escapeSingleQuotes(NavItemSelected));
                     String objTabNavQuery='SELECT Id,Name,Folder__r.Content_Folder__c, sObject_Name__c, Record_Type__c, Icon_Name__c, Default_Selected__c, Filter_on_Tags__c, Is_Files_Home_Config__c FROM Navigation_Menu_Configuration__c where Id=:passQueryParam';
                     if(Utils.checkCurd(objTabNavQuery, Utils.CURDOpration.READ)){
                         Navigation_Menu_Configuration__c  objTabNav =Database.query(objTabNavQuery);
                         
                         if(!string.isblank(objTabNav.Filter_on_Tags__c))
                         {  
                             for( string tagKey: objTabNav.Filter_on_Tags__c.split(','))
                             {
                                 tagKey = '%'+String.escapeSingleQuotes(TagKey.trim())+'%';
                                 allTags.add(tagKey) ;
                             }
                             
                         }
                         if(!string.isblank(objTabNav.Folder__c))
                         {
                             contentworksapceID=objTabNav.Folder__r.Content_Folder__c;
                         }
                     }else{
                         throw new curdPermisionException(System.Label.CurdPermision);
                     }
                    } 
                    if(navKey.getSobjectType() == Schema.Folder_Configuration__c.SObjectType)
                    {  
                        Folder_Configuration__c  objFoldrConf   =[SELECT Id, Content_Folder__c, Default_Folder__c, Library_and_Folder__c FROM Folder_Configuration__c where Id=: Id.valueOf(String.escapeSingleQuotes(NavItemSelected))];
                        contentworksapceID = objFoldrConf.Content_Folder__c;
                    } 
                }
            }
            
            
            if(!string.isblank(recordID)){
                LinkedEntityIds.add(Id.valueOf(String.escapeSingleQuotes(recordID)));
            }
            if(!string.isblank(contentworksapceID)){
                String objContentWorkspaceDocQuery='SELECT Id, ContentWorkspaceId, ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspaceId ='+':contentworksapceID';
                if(Utils.checkCurd(objContentWorkspaceDocQuery, Utils.CURDOpration.READ))
                {
                    for (ContentWorkspaceDoc obj :Database.query(objContentWorkspaceDocQuery)) 
                    {
                        DocId.add(obj.ContentDocumentId);
                    }
                }
            } 
            
            for(Object currentElememt:tags){
                Map<String,Object> tag=(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(currentElememt));
                eachtag = (String)tag.get('Name');
                eachTagKey = '%'+String.escapeSingleQuotes(eachtag.trim())+'%';
                allTags.add(eachTagKey);
            }
            if (allTags.size() > 0){
                soql += ' and All_Tags__c LIKE :allTags';
                countOfRecords += ' and All_Tags__c LIKE :allTags';
                
            }
            
            for(Object currentObjects:Objects){
                Map<String,Object> tag=(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(currentObjects));
                LinkedEntityIds.add((String)tag.get('Id'));
            }
            
            
            String searchKey ='';
            if (!searchKeyWord.equals('')){
                searchKey = '%'+String.escapeSingleQuotes(searchKeyWord.trim())+'%';
                soql += ' and title LIKE :searchKey';
                countOfRecords += ' and title LIKE :searchKey';}
            
            String FileTypes = '';
            if (!fileType.equals('')){
                FileTypes = '%'+String.escapeSingleQuotes(fileType.trim())+'%';
                soql += ' and FileType LIKE :FileTypes';
                countOfRecords += ' and FileType LIKE :FileTypes';
            }
            
            if(!LinkedEntityIds.isEmpty()){
                String objQuery='SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :LinkedEntityIds';
                if(Utils.checkCurd(objQuery, Utils.CURDOpration.READ)){
                    for (ContentDocumentLink obj :Database.query(objQuery)) 
                    {
                        relatedToRecordDocId.add(obj.ContentDocumentId);
                    }
                }else{throw new curdPermisionException(System.Label.CurdPermision);}
            }
            if(!LinkedEntityIds.isEmpty() || !string.isblank(contentworksapceID)){
                
                if(!LinkedEntityIds.isEmpty() && !string.isblank(contentworksapceID)){
                    if(relatedToRecordDocId.size()>0){
                        if(DocId.retainAll(relatedToRecordDocId)){
                        }
                    }
                }
                if(!LinkedEntityIds.isEmpty() && string.isblank(contentworksapceID)){
                    
                    if(relatedToRecordDocId.size()>0){
                        if(DocId.addAll(relatedToRecordDocId)){
                        }
                    }
                }
                
                soql += ' and ContentDocumentId IN'+':DocId' ;
                countOfRecords += ' and ContentDocumentId IN'+':DocId' ;
            }
            
            String sortDates = '';
            if (!sortDate.equals('')){
                sortDates = String.escapeSingleQuotes(sortDate.trim());
                soql += ' ORDER BY '+ sortDates +' DESC';
            }
            Integer intlimits = integer.valueof(limits);
            Integer intoffsets = integer.valueof(offsets);
            if(intlimits != null && intoffsets !=null){
                soql +=  ' Limit : intlimits Offset : intoffsets';}
            
            AggregateResult results = Database.query(countOfRecords);
            Integer total =(Integer)results.get('total') ; 
            if(Utils.checkCurd(soql, Utils.CURDOpration.READ) && Utils.checkCurd(soql, Utils.CURDOpration.READ)){
                List < sObject > returnList = new List < sObject > ();
                List <ContentVersion> lstOfRecords = Database.query(soql);
                
                for (ContentVersion   obj: lstOfRecords) {
                    returnList.add(obj);
                }
                
                LightningTableWraper ltngTableWrapper = new LightningTableWraper();
                ltngTableWrapper.tableRecord = database.query(soql);
                
                // Option wrapper Code
                List<actionCloumnWrapper> rawrpr = new list<actionCloumnWrapper> ();
                List<string> actions = new List <string>{'File Preview', 'Download File'};
                    for(String act : actions){
                        actionCloumnWrapper actcolwrpr = new actionCloumnWrapper();
                        actcolwrpr.label =act;
                        actcolwrpr.Name =act;
                        rawrpr.add(actcolwrpr);
                    }
                actionWrapper actionwrpr = new actionWrapper();
                actionwrpr.rowActions = rawrpr;
                //End of Options Wrapper code
                
                //Icon Wrapper Code
                IconWrapper icw = new IconWrapper();
                FileIconWrapper fileicw = new FileIconWrapper();
                DescribeFieldResult IconResult = objResult.fields.getMap().get('PA_LFM__Icons__c').getDescribe();
                fileicw.fieldName =IconResult.getName();
                icw.iconName = fileicw;
                //End of Icon Code
                
                //Date time Wrapper
                dateTimeWrapper dtWrpr = new dateTimeWrapper();
                dtWrpr.year ='numeric';
                dtWrpr.month = 'numeric';
                dtWrpr.day = 'numeric';
                dtWrpr.hour = '2-digit';
                dtWrpr.minute = '2-digit';
                //End of date Time
                for(String field : lstfieldstoget){
                    lightningTableColumnWrapper colWrapper = new lightningTableColumnWrapper();
                    DescribeFieldResult fieldResult = objResult.fields.getMap().get(field).getDescribe();
                    string fldType = string.valueOf(fieldResult.getName()); 
                    
                    if (fldType == 'OwnerId'){ // Lookup field!
                        colWrapper.label = 'Owner Name';
                        colWrapper.fieldName = 'OwnerName';
                    }else{
                        colWrapper.label = fieldResult.getLabel();
                        colWrapper.fieldName = fieldResult.getName();}
                    colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                    colWrapper.sortable = true;
                    if(colWrapper.type == 'datetime'){
                        colWrapper.type = 'date';
                        colWrapper.typeAttributes = dtWrpr;
                    }
                    
                    if(fieldResult.getLabel().equals('Title')){
                        colWrapper.cellAttributes = icw;
                    }
                    lstTableColumn.add(colWrapper);
                    
                }
                
                lightningTableColumnWrapper actionWrapper = new lightningTableColumnWrapper();
                actionWrapper.type ='action';
                actionWrapper.typeAttributes = actionwrpr;
                lstTableColumn.add(actionWrapper);
                
                ltngTableWrapper.tableColumn = lstTableColumn;
                ltngTableWrapper.Optionsvalues= optwrpr;
                ltngTableWrapper.listviews = lst;
                ltngTableWrapper.totalNumberOfRecords = total;
                
                return ltngTableWrapper;
            }else{
                throw new curdPermisionException(System.Label.CurdPermision);
            }
        }
        catch(Exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<getFilesResults of searchResultDataTableController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(System.Label.Exception_message);      
            }
        }
    }
    
    public class lightningTableColumnWrapper {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public string type {get;set;}
        @AuraEnabled
        public boolean sortable {get;set;}
        @AuraEnabled
        public Object cellAttributes {get;set;}
        @AuraEnabled
        public Object typeAttributes {get;set;}
        
    }
    
    
    public class OptionsWrapper {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value {get;set;}
    }
    
    public class dateTimeWrapper{
        @AuraEnabled
        public string year {get;set;}
        @AuraEnabled
        public string month {get;set;}
        @AuraEnabled
        public string day {get;set;}
        @AuraEnabled
        public string hour {get;set;}
        @AuraEnabled
        public string minute {get;set;}
    }
    
    Public class actionCloumnWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string Name {get;set;}
    }
    
    public class IconWrapper {
        @AuraEnabled
        public Object iconName {get;set;}  
    }
    
    public class rowActionWrapper {
        @AuraEnabled
        public List<actionCloumnWrapper> rowAct {get;set;}  
    }
    
    public class actionWrapper {
        @AuraEnabled
        public Object rowActions {get;set;}  
    }
    
    public class FileIconWrapper {
        @AuraEnabled
        public String fieldName {get;set;}  
    }
    
    
    public class lightningTableWraper{
        @AuraEnabled
        public List<sObject> tableRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
        
        @AuraEnabled
        public List<OptionsWrapper> Optionsvalues {get;set;}
        @AuraEnabled
        public string listviews{get;set;}
        
        @AuraEnabled
        public integer totalNumberOfRecords{get;set;}
        
    }
    //End of Table code
    
    
    @AuraEnabled
    public static List<ContentDistribution> getCheckPassword(list<string> recordId) {
        try{
            List<ContentDistribution> Distribution = new List<ContentDistribution>();
            if(recordId.Size()>0){
                String contdistQuery='SELECT Id,ContentDocumentId,ContentVersionId,ContentVersion.Title,Password,DistributionPublicUrl FROM ContentDistribution where ContentDocumentId IN :recordId';
                if(Utils.checkCurd(contdistQuery, Utils.CURDOpration.READ)){
                    for(ContentDistribution contdist : Database.query(contdistQuery) ){
                        Utils.log('contdist.ContentDocumentId123'+contdist.ContentDocumentId);
                        if(contdist.Password != '' && contdist.Password != null){
                            Utils.log('Has Password');
                            Distribution.add(contdist);
                        }
                    }
                }
                else{
                    throw new curdPermisionException(System.Label.CurdPermision);
                }
            }
            return Distribution;
        }
        catch(Exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<getCheckPassword of searchResultDataTableController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(System.Label.Exception_message);      
            }
        }
        
    }
    @AuraEnabled
    public static boolean checkPasswordCreationAccess(){
        /**************************************************************************
@Method name: checkPasswordCreationAccess
@return : Boolean
@Description : Checks for user permistion to create password protected link from custom settigns
***************************************************************************/
        try{
            Utils.log('checkPasswordCreationAccess ');
            Boolean access=false;
            String fileFormats='';
            PA_LFM__LFM_Configuration__c configs=PA_LFM__LFM_Configuration__c.getOrgDefaults();
            if(configs!=null){
                access=configs.PA_LFM__Password_Sharing__c;    
            } 
            PA_LFM__LFM_Configuration__c UserProf=PA_LFM__LFM_Configuration__c.getInstance(Userinfo.getProfileId());
            if(UserProf!=null){
                access=UserProf.PA_LFM__Password_Sharing__c;
            }
            PA_LFM__LFM_Configuration__c UserPerm=PA_LFM__LFM_Configuration__c.getInstance(Userinfo.getUserId());
            if(UserPerm!=null){
                access=UserPerm.PA_LFM__Password_Sharing__c;
            }
            return access;
        }
        catch(Exception e){
            Utils.log('checkContentDocumentAccess exception '+e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled
    public static List<ContentDistribution> getContentVersion(list<string> recordId,Boolean passwordRequired) {
        /**************************************************************************
@Method name: getContentVersion
@param :recordid,passwordRequired
@return : List <ContentDistribution>
@Description : helps in password generated urls.
***************************************************************************/
        try {
            List<ContentDistribution> DistributionsToReturn = new List<ContentDistribution>();
            List<ContentDistribution> toBeInserted = new List<ContentDistribution>();
            
            Map<id, ContentDistribution> cdMap = new Map<id, ContentDistribution>();
            List<id> ContentDocIds = new List<Id>();
            if(recordId.Size()>0){
                String contdistQuery='SELECT Id,ContentDocumentId,ContentVersionId,ContentVersion.Title,Password,DistributionPublicUrl FROM ContentDistribution where ContentDocumentId IN :recordId';
                if(Utils.checkCurd(contdistQuery, Utils.CURDOpration.READ)){
                    for(ContentDistribution contdist : Database.query(contdistQuery) ){
                        Utils.log('contdist.ContentDocumentId123'+contdist.ContentDocumentId);
                        if(contdist.Password != '' && contdist.Password != null && passwordRequired == True ){
                            Utils.log('Has Password');
                            DistributionsToReturn.add(contdist);
                            ContentDocIds.add(contdist.ContentDocumentId);
                        }
                    }
                }
                else{
                    throw new curdPermisionException(System.Label.CurdPermision);
                }
            }
            
            String cvQuery='';
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            if(ContentDocIds.Size() >0 && recordId.Size()>0){
                Utils.log('Inside If if has password');
                if(passwordRequired == False){
                    cvQuery='select LatestPublishedVersionId from ContentDocument where Id IN :recordId';
                    if(Utils.checkCurd(cvQuery, Utils.CURDOpration.READ)){
                        for(ContentDocument cv :Database.query(cvQuery)){
                            ContentDistribution contDst = new ContentDistribution();
                            contDst.Name = 'Test';
                            contDst.PreferencesPasswordRequired  = passwordRequired;
                            contDst.ContentVersionId = cv.LatestPublishedVersionId;
                            toBeInserted.add(contDst);
                            Utils.log('URL generated without password which has password previously'+toBeInserted);
                            
                        }
                    }else{throw new curdPermisionException(System.Label.CurdPermision);}
                }else{
                    cvQuery='select LatestPublishedVersionId from ContentDocument where Id IN :recordId and Id NOT IN :ContentDocIds';
                    if(Utils.checkCurd(cvQuery, Utils.CURDOpration.READ)){
                        for(ContentDocument cv :Database.query(cvQuery)){
                            Utils.log('password generated since it doesnt have a password');
                            ContentDistribution contDst = new ContentDistribution();
                            contDst.Name = 'Test';
                            contDst.PreferencesPasswordRequired  = True;
                            contDst.ContentVersionId = cv.LatestPublishedVersionId;
                            PA_LFM__LFM_Configuration__c  CS = PA_LFM__LFM_Configuration__c.getInstance();
                            
                            toBeInserted.add(contDst);
                            Utils.log('password generated'+toBeInserted);
                        }
                    }else{throw new curdPermisionException(System.Label.CurdPermision);}
                }
            }else{
                cvQuery='select LatestPublishedVersionId from ContentDocument where Id IN :recordId';
                if(Utils.checkCurd(cvQuery, Utils.CURDOpration.READ)){
                    for(ContentDocument cv :Database.query(cvQuery)){
                        Utils.log('Inside else no password');
                        ContentDistribution contDst = new ContentDistribution();
                        contDst.Name = 'Test';
                        contDst.PreferencesPasswordRequired  = passwordRequired;
                        contDst.ContentVersionId = cv.LatestPublishedVersionId;
                        toBeInserted.add(contDst);
                        Utils.log('URL generated for the first time'+toBeInserted);
                    }
                }else{throw new curdPermisionException(System.Label.CurdPermision);}
            }
            if(Utils.checkCurd('ContentDistribution', Utils.CURDOpration.CREATE)){
                srList = Database.insert(toBeInserted, false);
            }else{throw new curdPermisionException(System.Label.CurdPermision);}
            
            
            set<id> successIds = new set<id>();
            if(srList.Size() > 0){
                for (Database.SaveResult s : srList) {
                    //insert contversion;
                    if (s.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        successIds.add(s.getId());
                    }
                    else {
                        // Operation failed, so get all errors               
                        for(Database.Error err : s.getErrors()) {
                            Utils.log('The following error has occurred.');                   
                            Utils.log(err.getStatusCode() + ': ' + err.getMessage());
                            Utils.log('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }  
                cvQuery='SELECT Id,ContentVersionId,ContentVersion.Title,Password,DistributionPublicUrl FROM ContentDistribution WHERE Id = :successIds';
                if(Utils.checkCurd(cvQuery, Utils.CURDOpration.READ)){
                    for(ContentDistribution cd : Database.query(cvQuery) ){
                        DistributionsToReturn.add(cd);
                    }
                }else{throw new curdPermisionException(System.Label.CurdPermision);}
            }
            Utils.log('DistributionsToReturn-->'+DistributionsToReturn);
            return DistributionsToReturn;
        }
        catch(Exception e){
            if(e instanceof curdPermisionException){
                throw  new AuraHandledException(System.Label.CurdPermision);
            }
            else{
                Utils.log(e.getMessage()+'<getContentVersion of searchResultDataTableController>'+e.getStackTraceString());
                Utils.sendErrorMail(e);
                throw  new AuraHandledException(System.Label.Exception_message);      
            }
        }
    } 
    
    
    
}