global class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        List<String> version=System.label.PA_LFM.Version.split('/.');
        if(context.previousVersion() == null) {
            
            //Data to include in first install
            
            //create real libs
            List <ContentWorkspace> listContentWorkSpace= new  List <ContentWorkspace>();
            
            ContentWorkspace RealLib = createRealLib(false,'Sales');
            
            ContentWorkspace RealLibA = createRealLib(false,'Sales_Marketing');
            ContentWorkspace RealLibb = createRealLib(false,'Sales_Funds');
            
            ContentWorkspace RealLibc = createRealLib(false,'Sales_Marketing_Brochures');
           
            listContentWorkSpace.add(RealLib);
            listContentWorkSpace.add(RealLibA);
            listContentWorkSpace.add(RealLibb);
            listContentWorkSpace.add(RealLibc);
            try{
                
                if(Schema.sObjectType.ContentWorkspace.isCreateable() && Schema.sObjectType.ContentWorkspace.fields.Name.isCreateable()    ){
                 
                    insert listContentWorkSpace;    
                }
                	
                
            }catch(exception e){ }   
            createSampleData();
            
        }
        else if(context.previousVersion().compareTo(new Version(Integer.valueOf(version[0]),Integer.valueOf(version[1]))) == 0) {
            //if data is to be added to any  new version
        }
        if(context.isUpgrade()) {
            //if data is to be added in upgrade
        }
        if(context.isPush()) {
            //if data is to be added in push
        }
    }
    @future
    global static void createSampleData() {
        
        ContentWorkspace RealLib = new ContentWorkspace();
        ContentWorkspace RealLibA = new ContentWorkspace();
        ContentWorkspace RealLibb = new ContentWorkspace();
        ContentWorkspace RealLibc = new ContentWorkspace();
           List<ContentWorkspace> listContentWorkSpace= new List <ContentWorkspace>();
        if (Schema.sObjectType.Contact.fields.Email.isAccessible()) {
            listContentWorkSpace= [SELECT Id, Name, DeveloperName FROM ContentWorkspace Limit 100];
        }
        if(listContentWorkSpace.size()>0){
            for(ContentWorkspace objContentW:listContentWorkSpace){
                if(objContentW.Name=='Sales'){
                    RealLib=objContentW;
                }
                
                if(objContentW.Name=='Sales_Marketing'){
                    RealLibA=objContentW;
                }
                if(objContentW.Name=='Sales_Funds'){
                    RealLibb=objContentW;
                }
                if(objContentW.Name=='Sales_Marketing_Brochures'){
                    RealLibc=objContentW;
                }
            }
        }  
        
        Folder_Configuration__c LibA = createFolderWithRealLib(true,null,'Sales',RealLib.id,true);
        
        Folder_Configuration__c childFolderSecondLevel1 = createFolderWithRealLib(true,LibA.id,'Marketing',RealLibA.id,false);
        
        Folder_Configuration__c childFolderSecondLevel2 = createFolderWithRealLib(true,LibA.id,'Funds',RealLibb.id,false);
        
        Folder_Configuration__c childFolderSecondLevel3 = createFolderWithRealLib(true,childFolderSecondLevel1.id,'Brochures',RealLibc.id,false);
        
        //create object configs  
        Object_Configuration__c objectconfigLibA =  createobjectConfig(true,LibA.id,'Opportunity','Name','standard:opportunity',false);
        Object_Configuration__c objectconfigLibB =  createobjectConfig(true,childFolderSecondLevel1.id,'lead','Name','standard:lead',true);
        
        //Tag config
        list<Tag_Configuration__c> tagConfigList = new list<Tag_Configuration__c>();
        
        Tag_Configuration__c tagConfigLibA =createTagConfig(false,LibA.id,'Region','standard:reward', false);
        
        Tag_Configuration__c tagConfigLibA1 =createTagConfig(false,childFolderSecondLevel1.id,'Category','standard:reward', true);
        Tag_Configuration__c tagConfigLibA2 =createTagConfig(false,childFolderSecondLevel1.id,'Sub Category','standard:template', false);
        
        Tag_Configuration__c tagConfigLibA3 =createTagConfig(false,childFolderSecondLevel2.id,'Document Type','standard:reward', false);
        
        Tag_Configuration__c tagConfigLibA4 =createTagConfig(false,childFolderSecondLevel3.id,'Subject','standard:reward', false);
        tagConfigList.add(tagConfigLibA);
        tagConfigList.add(tagConfigLibA1);
        
        tagConfigList.add(tagConfigLibA2);
        
        tagConfigList.add(tagConfigLibA3);
        
        tagConfigList.add(tagConfigLibA4);
        
        try{if (Schema.sObjectType.Tag_Configuration__c.isCreateable() && 
                Schema.sObjectType.Tag_Configuration__c.fields.Tag__c.isCreateable() &&
                Schema.sObjectType.Tag_Configuration__c.fields.Library_and_Folder__c.isCreateable() &&
                Schema.sObjectType.Tag_Configuration__c.fields.Required__c.isCreateable() &&
                Schema.sObjectType.Tag_Configuration__c.fields.Icon_Name__c.isCreateable() 
               ) {
            insert tagConfigList;
        }}catch(exception e){ }  
        
        //insert tags
        list<Tag__c> tags = new list<Tag__c>();
        
        Tag__c childTag1LibA=CreateTagFull('Europe',LibA.id,'Region',null,'');
        Tag__c childTag2LibA=CreateTagFull('Asia Pacific',LibA.id,'Region',null,'');
        Tag__c childTag0LibA=CreateTagFull('Europe',LibA.id,'Region',null,'');
        Tag__c childTag3LibA=CreateTagFull('MiddleEast',LibA.id,'Region',null,'');
        Tag__c childTag4LibA=CreateTagFull('Africa',LibA.id,'Region',null,'');
        tags.add(childTag1LibA);
        tags.add(childTag2LibA);
        tags.add(childTag0LibA);
        tags.add(childTag3LibA);
        tags.add(childTag4LibA);
        Tag__c ParentTag2childFolderSecondLevel1=insertTagFull('Sales Value',childFolderSecondLevel1.id,'Category',null,'');
        Tag__c childTag21childFolderSecondLevel1=CreateTagFull('High',childFolderSecondLevel1.id,'Sub Category',ParentTag2childFolderSecondLevel1.id,'Category');
        Tag__c childTag22childFolderSecondLevel1=CreateTagFull(' low',childFolderSecondLevel1.id,'Sub Category',ParentTag2childFolderSecondLevel1.id,'Category');
        Tag__c childTag23childFolderSecondLevel1=CreateTagFull('medium',childFolderSecondLevel1.id,'Sub Category',ParentTag2childFolderSecondLevel1.id,'Category');
        Tag__c childTag24childFolderSecondLevel1=CreateTagFull('Very High',childFolderSecondLevel1.id,'Sub Category',ParentTag2childFolderSecondLevel1.id,'Category');
        // tags.add(ParentTag2childFolderSecondLevel1);
        tags.add(childTag21childFolderSecondLevel1);
        tags.add(childTag22childFolderSecondLevel1);
        tags.add(childTag23childFolderSecondLevel1);
        tags.add(childTag24childFolderSecondLevel1);
        
        Tag__c childTag1LibAchildFolderSecondLevel2=CreateTagFull('Check',childFolderSecondLevel2.id,'Document Type',null,'');
        Tag__c childTag2LibAchildFolderSecondLevel2=CreateTagFull('Receipt',childFolderSecondLevel2.id,'Document Type',null,'');
        Tag__c childTag5LibAchildFolderSecondLevel2=CreateTagFull('Invoice',childFolderSecondLevel2.id,'Document Type',null,'');
        Tag__c childTag3LibAchildFolderSecondLevel2=CreateTagFull('Bill',childFolderSecondLevel2.id,'Document Type',null,'');
        Tag__c childTag4LibAchildFolderSecondLevel2=CreateTagFull('Payment plan',childFolderSecondLevel2.id,'Document Type',null,'');
        tags.add(childTag1LibAchildFolderSecondLevel2);
        tags.add(childTag2LibAchildFolderSecondLevel2);
        tags.add(childTag3LibAchildFolderSecondLevel2);
        tags.add(childTag4LibAchildFolderSecondLevel2);
        tags.add(childTag5LibAchildFolderSecondLevel2);
        
        
        Tag__c childTag1LibAchildFolderSecondLevel3=CreateTagFull('Flyer for Winter',childFolderSecondLevel3.id,'Subject',null,'');
        Tag__c childTag2LibAchildFolderSecondLevel3=CreateTagFull('Flyer for Summer',childFolderSecondLevel3.id,'Subject',null,'');
        Tag__c childTag5LibAchildFolderSecondLevel3=CreateTagFull('Flyer for Spring',childFolderSecondLevel3.id,'Subject',null,'');
        Tag__c childTag3LibAchildFolderSecondLevel3=CreateTagFull('Flyer for Christmas',childFolderSecondLevel3.id,'Subject',null,'');
        Tag__c childTag4LibAchildFolderSecondLevel3=CreateTagFull('Flyer for All Season',childFolderSecondLevel3.id,'Subject',null,'');
        
        tags.add(childTag1LibAchildFolderSecondLevel3);
        tags.add(childTag2LibAchildFolderSecondLevel3);
        tags.add(childTag3LibAchildFolderSecondLevel3);
        tags.add(childTag4LibAchildFolderSecondLevel3);
        tags.add(childTag5LibAchildFolderSecondLevel3);
        try{if (Schema.sObjectType.Tag__c.isCreateable() &&
                Schema.sObjectType.Tag__c.fields.Active__c.isCreateable() &&
               Schema.sObjectType.Tag__c.fields.Library_and_Folder__c.isCreateable() &&
               Schema.sObjectType.Tag__c.fields.Name.isCreateable() && 
               Schema.sObjectType.Tag__c.fields.Type_of_Tag__c.isCreateable() &&
               Schema.sObjectType.Tag__c.fields.Depends_on_Tag_Type__c.isCreateable() &&
               Schema.sObjectType.Tag__c.fields.Depends_on_Tag__c.isCreateable()) {
            insert tags;
        }}catch(exception e){ }  
        
        //Create File Filters
        Navigation_Menu_Configuration__c NavObjHome = createNavgationMenuConfig(true,null,true,'All files','','');
        
        Navigation_Menu_Configuration__c NavObjOpportunityHome1 = createNavgationMenuConfig(true,null,false,'All Files','','');
        
        //Create Configuration
        LFM_Configuration__c objConfig = new LFM_Configuration__c();
        objConfig.Supported_File_Formate__c='.doc,.docx,.xls,.xlsx,.ppt,.pptx,.pdf,.jpg,.jpeg,.png,.gif,.svg,.zip,.ics';
        objConfig.Enable_Template_Creation__c =true;
        objConfig.Password_Sharing__c = true;
        try{
            if (Schema.sObjectType.LFM_Configuration__c.isCreateable() &&
                Schema.sObjectType.LFM_Configuration__c.fields.Supported_File_Formate__c.isCreateable() &&
               Schema.sObjectType.LFM_Configuration__c.fields.Enable_Template_Creation__c.isCreateable() &&
               Schema.sObjectType.LFM_Configuration__c.fields.Password_Sharing__c.isCreateable() ) {
            insert objConfig;
        }
            }catch(exception e){ }
    }
    
    
    public static Navigation_Menu_Configuration__c createNavgationMenuConfig(Boolean isInsert,id configId, Boolean isFileHomeFilter,String filterName,String soBjectName,String recordtypename){
        
        Navigation_Menu_Configuration__c navMenuConfiObj=new Navigation_Menu_Configuration__c();
        navMenuConfiObj.Name=filterName;
        navMenuConfiObj.Order_of_Display__c=0;
        navMenuConfiObj.Icon_Name__c='custom:custom107';
        // navMenuConfiObj.Record_Type__c=recordtypename;
        navMenuConfiObj.Default_Selected__c=true;
        //navMenuConfiObj.Folder__c=configId;
        //navMenuConfiObj.Filter_on_Tags__c='';
        navMenuConfiObj.Is_Files_Home_Config__c=isFileHomeFilter;
        
        if(isInsert  && Schema.sObjectType.Navigation_Menu_Configuration__c.isCreateable() &&
           Schema.sObjectType.Navigation_Menu_Configuration__c.fields.Name.isCreateable() &&
          Schema.sObjectType.Navigation_Menu_Configuration__c.fields.Order_of_Display__c.isCreateable() &&
          Schema.sObjectType.Navigation_Menu_Configuration__c.fields.Icon_Name__c.isCreateable() &&
          Schema.sObjectType.Navigation_Menu_Configuration__c.fields.Default_Selected__c.isCreateable() &&
          Schema.sObjectType.Navigation_Menu_Configuration__c.fields.Is_Files_Home_Config__c.isCreateable() ){
            insert navMenuConfiObj;
        }
        return navMenuConfiObj;
    }
    
    public static ContentWorkspace createRealLib(Boolean isInsert,String combinedFolderNAme){
        ContentWorkspace objWorkSpace = new ContentWorkspace();
        objWorkSpace.Name = combinedFolderNAme;
        if(isInsert && Schema.sObjectType.ContentWorkspace.isCreateable() &&
                      Schema.sObjectType.ContentWorkspace.fields.Name.isCreateable() 
          ){
            try{insert objWorkSpace;}catch(exception e){ }
        }
        return objWorkSpace;
    }
    public static Folder_Configuration__c createFolderWithRealLib(Boolean isInsert,id parentConfigId,String folderName,id contentfolderid, Boolean defaultbol){
        Folder_Configuration__c childFolder =new Folder_Configuration__c();
        childFolder.Name=folderName;
        childFolder.Active__c=true;
        childFolder.Library_and_Folder__c=folderName;
        childFolder.Content_Folder__c =contentfolderid;
        if(parentConfigId == null){
            childFolder.Icon_Name__c ='doctype:library_folder';
        }else{
            childFolder.Icon_Name__c ='doctype:folder';
        }
        childFolder.Parent_Folder_Configuration__c = parentConfigId;
        childFolder.Default_Folder__c =defaultbol; 
        
        if(isInsert && Schema.sObjectType.Folder_Configuration__c.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Name.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Active__c.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Library_and_Folder__c.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Content_Folder__c.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Icon_Name__c.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Parent_Folder_Configuration__c.isCreateable() &&
           Schema.sObjectType.Folder_Configuration__c.fields.Default_Folder__c.isCreateable() 
          ){
            insert childFolder;
        }
        return childFolder;
    } 
    public static Object_Configuration__c createobjectConfig(Boolean isInsert,id parentfolderConfigId,String objectAPIName,String fieldName,String iconName, Boolean isrequired){
        Object_Configuration__c objConfig =new Object_Configuration__c();
        objConfig.Name=objectAPIName;
        objConfig.Library_and_Folder__c=parentfolderConfigId;
        objConfig.Required__c=isrequired;
        objConfig.Field_to_Display__c =fieldName;
        if(iconName == null){
            objConfig.Icon_Name__c ='standard:account';
        }else{
            objConfig.Icon_Name__c =iconName;
        }
        
        if(isInsert && Schema.sObjectType.Object_Configuration__c.isCreateable() &&
           Schema.sObjectType.Object_Configuration__c.fields.Name.isCreateable() &&
           Schema.sObjectType.Object_Configuration__c.fields.Library_and_Folder__c.isCreateable() &&
           Schema.sObjectType.Object_Configuration__c.fields.Required__c.isCreateable() &&
           Schema.sObjectType.Object_Configuration__c.fields.Field_to_Display__c.isCreateable() &&
           Schema.sObjectType.Object_Configuration__c.fields.Icon_Name__c.isCreateable() 
          ){
            insert objConfig;
        }
        return objConfig;
    }
    public static Tag_Configuration__c createTagConfig(Boolean isInsert,id parentfolderConfigId,String typeoftag,String iconName, Boolean isrequired){
        Tag_Configuration__c objConfig =new Tag_Configuration__c();
        objConfig.Tag__c=typeoftag;
        objConfig.Library_and_Folder__c=parentfolderConfigId;
        objConfig.Required__c=isrequired;
        if(iconName == null){
            objConfig.Icon_Name__c ='standard:account';
        }else{
            objConfig.Icon_Name__c =iconName;
        }
        
        if(isInsert && Schema.sObjectType.Tag_Configuration__c.isCreateable() &&
           Schema.sObjectType.Tag_Configuration__c.fields.Tag__c.isCreateable() &&
           Schema.sObjectType.Tag_Configuration__c.fields.Library_and_Folder__c.isCreateable() &&
           Schema.sObjectType.Tag_Configuration__c.fields.Required__c.isCreateable() &&
           Schema.sObjectType.Tag_Configuration__c.fields.Icon_Name__c.isCreateable() 
		 ){
            
            insert objConfig;
        }
        return objConfig;
    }
    public static Tag__c createTagFull(String tagName,id foldconfigId,String typeofTag,id dependsOnTagID,String dependsOnTagType){
        Tag__c tag=new Tag__c();
        tag.Active__c=true;
        tag.Library_and_Folder__c=foldconfigId;
        tag.Name = tagName;
        tag.Type_of_Tag__c =typeofTag ;
        tag.Depends_on_Tag_Type__c = dependsOnTagType;
        tag.Depends_on_Tag__c = dependsOnTagID;
        return tag;
    }
    
    
    public static Tag__c insertTagFull(String tagName,id foldconfigId,String typeofTag,id dependsOnTagID,String dependsOnTagType){
        Tag__c tag=new Tag__c();
        tag.Active__c=true;
        tag.Library_and_Folder__c=foldconfigId;
        tag.Name = tagName;
        tag.Type_of_Tag__c =typeofTag ;
        tag.Depends_on_Tag_Type__c = dependsOnTagType;
        tag.Depends_on_Tag__c = dependsOnTagID;
        if (Schema.sObjectType.Tag__c.isCreateable() &&
           Schema.sObjectType.Tag__c.fields.Active__c.isCreateable() &&
           Schema.sObjectType.Tag__c.fields.Library_and_Folder__c.isCreateable() &&
           Schema.sObjectType.Tag__c.fields.Name.isCreateable() &&
           Schema.sObjectType.Tag__c.fields.Type_of_Tag__c.isCreateable() &&
           Schema.sObjectType.Tag__c.fields.Depends_on_Tag_Type__c.isCreateable() &&
           Schema.sObjectType.Tag__c.fields.Depends_on_Tag__c.isCreateable() ) {
            insert tag;
        }
        return tag;
        
    }
    
}