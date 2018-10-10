({
    doint : function(component, event, helper) {
        var serverCall=component.get('c.getobjects');
        serverCall.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
              
                component.set('v.options',result.dualPicklistvalues);  
            }
        });
        $A.enqueueAction(serverCall);
        
        var getAllFolderTags = component.get('c.getAllFolderTags');
        getAllFolderTags.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
               
                component.set('v.tagsPickList',result.dualPicklistvalues);  
            }
        });
        $A.enqueueAction(getAllFolderTags);
        
        var action = component.get("c.getFolderStructureItems");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                   
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.items", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    navigateFolder : function(cmp, event, helper) {
        
          var navService = cmp.find("navService");
        
      var contentFolderID = event.getSource().get("v.value");
      // var contentFolderID =  event.target.id
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": contentFolderID,
                "objectApiName": "ContentDocument",
                "actionName": "view"
            }
        }
        cmp.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            cmp.set("v.url", '_'+url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            cmp.set("v.url", defaultUrl);
        }));
        
        
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },
    isIconOpen: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isIconOpen", true);
        var getIconId = event.getSource().getLocalId();
        component.set("v.iconid",getIconId);
        var getName = event.getSource().get("v.name");
        var getIconName = event.getSource().get("v.value");
    },
    
    folderSelected : function(component,event,helper){
        component.set("v.isSelected",true);
        component.set("v.isInitiated",false);
        
        var selected = event.getParam('name');
        component.set("v.selectedLibrary",selected);
        
        var getObjectsSelected =component.get('c.getobjectConfigurations');
        getObjectsSelected.setParams({
            "folderId" : selected,
        });
        getObjectsSelected.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var optionsValues = [];
                var result=response.getReturnValue();
                
                component.set("v.objectConfigurations",result);
                component.set("v.initialObjectsSelected",result);                
                var objectData = result;
                if(objectData != null && objectData !=''){
                    objectData.forEach(function(objectData){
                        optionsValues.push(objectData.Name);
                    })
                }
                component.find("dialPickList").set("v.value",optionsValues);
                component.set("v.selectedObjects",optionsValues); 
            }
        });
        $A.enqueueAction(getObjectsSelected);
        
        var getFileTagsConfiguration =component.get('c.getFileTagsConfiguration');
        getFileTagsConfiguration.setParams({
            "folderId" : selected,
        });
        getFileTagsConfiguration.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistValues =[];
                var fileTagsResult = response.getReturnValue();
                component.set("v.folderTagsConfigurations",fileTagsResult);
                component.set("v.initialTagsSelected",fileTagsResult);                
                if(fileTagsResult != null && fileTagsResult !='' && fileTagsResult != undefined){
                    fileTagsResult.forEach(function(fileTagsResult){
                        picklistValues.push(fileTagsResult.PA_LFM__Tag__c);
                    });
                }
                component.find("tagsPickList").set("v.value",picklistValues);
                component.set("v.selectedTags",picklistValues); 
            }
            
        });
        $A.enqueueAction(getFileTagsConfiguration);
    },
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
        var createFolder = event.getSource().get("v.value");
        var folderParentId = event.getSource().get("v.name");
        
        component.set("v.folderPath",createFolder);
        component.set("v.folderParentId",folderParentId);
        
    },
    
    openLibraryModel: function(component, event, helper) {
        component.set("v.folderParentId",'');
        component.set("v.isOpenLibrary", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.isIconOpen", false);
        component.set("v.isOpenLibrary", false);
        
    },
    saveFolder :function(component, event, helper) {
        var folderPath = component.get("v.folderPath");
        var folderName = component.get("v.folderName");
        var finalPath = folderPath+folderName;
        var serverCall=component.get('c.getDuplicates');
        serverCall.setParams({
            "folderPath" : finalPath
        });
        serverCall.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                if(result == null ||result==''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "message": "Folder name already exists, Please give a different name",
                        "type": "error"
                        
                    });
                    toastEvent.fire();
                }
                var CWid = '';
                if(result != null){
                    component.set("v.workSpaceId",result);
                    CWid = result;
                }
                component.set("v.folderName",'');
                if(CWid != null && CWid !=''){
                    component.set("v.isOpen", false);
                    var Icon = 'doctype:folder'
                    
                    helper.insertFolder(CWid,folderName,Icon,component, event, helper);
                }
                
            }
             else{
                
                var errors = response.getError();
                 if (state=='ERROR' && errors) {
                     if (errors[0] && errors[0].message) {
                         if(errors[0].message==$A.get("$Label.c.CurdPermision")){
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                                 "title": "error!",
                                 "message": $A.get("$Label.c.CurdPermision"),
                                 "type": "error"
                                 
                             });
                             toastEvent.fire();
                         }
                         
                     }
                     
                 } 
                 else {
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "title": "error!",
                         "message": errors[0].message,
                         "type": "error"
                         
                     });
                     toastEvent.fire();
                 }
             }
            
        });
        $A.enqueueAction(serverCall);
    },
    saveLibrary :function(component, event, helper) {        
        var libraryName = component.get("v.libraryName");
        var serverCall=component.get('c.getDuplicates');
        serverCall.setParams({
            "folderPath" : libraryName
        });
        serverCall.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                if(result == null){
                    component.set("v.libraryName",'');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "message": "Library name already exists, Please give a different name",
                        "type": "error"
                        
                    });
                    toastEvent.fire();
                }else{
                    var CWid =result ;
                    var folderName = libraryName;
                    var Icon = 'doctype:library_folder';
                    helper.insertFolder(CWid,folderName,Icon,component, event, helper);
                    component.set("v.libraryName",'');
                    component.set("v.isOpenLibrary", false);  
                }
            }
            else{
                
                var errors = response.getError();
                 if (state=='ERROR' && errors) {
                     if (errors[0] && errors[0].message) {
                         if(errors[0].message==$A.get("$Label.c.CurdPermision")){
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                                 "title": "error!",
                                 "message": $A.get("$Label.c.CurdPermision"),
                                 "type": "error"
                                 
                             });
                             toastEvent.fire();
                         }
                         
                     }
                     
                 } 
                 else {
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "title": "error!",
                         "message": errors[0].message,
                         "type": "error"
                         
                     });
                     toastEvent.fire();
                 }
             }
        });
        $A.enqueueAction(serverCall);
    },
    
    handleChange: function (component, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        component.set('v.selectedObjects',selectedOptionValue);  
    },
    
    selectedTags: function (component, event) {
        var selectedTagsOptionValue = event.getParam("value");
        console.log('selectedTagsOptionValue');
        console.log(JSON.parse(JSON.stringify(selectedTagsOptionValue)));
        
        
        
        let tags=component.get('v.selectedTags');
        console.log('selectedTags');
        console.log(JSON.parse(JSON.stringify(tags)));
        component.set('v.selectedTags',selectedTagsOptionValue);       
        
    },
    
    moveNext : function(component,event,helper){
        // control the next button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "1"){
            component.set("v.currentStep", "2");
            helper.checkBoxOptions(component,event,helper);
            
        }
        else if(getCurrentStep == 2){
            component.set("v.currentStep", "3");
            var newObjRec = component.get('v.objectConfigurations');
            var goBack = false;
            newObjRec.forEach(function(element){
                if(element.PA_LFM__Field_to_Display__c =='' ||element.PA_LFM__Field_to_Display__c == undefined || element.PA_LFM__Field_to_Display__c == null ){
                    goBack = true;
                }
            });
            if(goBack == true){
                component.set("v.currentStep", "2");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",
                    "message": "Please fill the required fields",
                    "type": "error"
                    
                });
                toastEvent.fire();
            }else{
                component.set('v.objectConfigurations',newObjRec);
            }
            
        }
            else if(getCurrentStep == 3){
                component.set("v.currentStep", "4");
                helper.selectedTagOptions(component,event,helper);
                
            }
                else if(getCurrentStep == 4){
                    var newTagRec = component.get("v.folderTagsConfigurations");
                    component.set("v.folderTagsConfigurations",newTagRec);
                    
                }
        
    },
    
    moveBack : function(component,event,helper){
        // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
        }
        else if(getCurrentStep == 3){
            component.set("v.currentStep", "2");
        }
            else if(getCurrentStep == 4){
                component.set("v.currentStep", "3");
            }
    },
    
    confirmAndSave : function(component,event,helper){
        // on last step show the alert msg, hide popup modal box and reset the currentStep attribute  
        var folderTagsConfigurations = component.get("v.folderTagsConfigurations");
        var objectConfigurations = component.get("v.objectConfigurations");
		//console.log('folderTagsConfigurations');
        //console.log(JSON.parse(JSON.stringify(folderTagsConfigurations)));
        var folderTagsList = [];
        folderTagsConfigurations.forEach(function(element){
            folderTagsList.push(JSON.stringify(element));
        });
        
        var objectConfigurationList = [];
        objectConfigurations.forEach(function(element){
            objectConfigurationList.push(JSON.stringify(element));
        });
        
        var serverCall=component.get('c.getInsertFinalRecords');
        //console.log(JSON.parse(JSON.stringify(folderTagsList)));
        

        serverCall.setParams({
            "folderTagsConfigurations" : folderTagsList,
            "objectConfigurations" : objectConfigurationList
        });
        serverCall.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                if(result ==="SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Record saved successfully",
                        "type": "success"
                    });
                    toastEvent.fire();
                    component.set("v.isInitiated",true);
                    component.set("v.isSelected",false);
                    component.set("v.initiallySelected", '');                
                    component.set("v.currentStep", "1");
                    
                }
            }
            else{
                
                var errors = response.getError();
                 if (state=='ERROR' && errors) {
                     if (errors[0] && errors[0].message) {
                         if(errors[0].message==$A.get("$Label.c.CurdPermision")){
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                                 "title": "error!",
                                 "message": $A.get("$Label.c.CurdPermision"),
                                 "type": "error"
                                 
                             });
                             toastEvent.fire();
                         }
                         
                     }
                     
                 } 
                 else {
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "title": "error!",
                         "message": errors[0].message,
                         "type": "error"
                         
                     });
                     toastEvent.fire();
                 }
             }
        });
        $A.enqueueAction(serverCall);
    },
    
    // when user click direactly on step 1,step 2 or step 3 indicator then showing appropriate step using set 'currentStep'   
    selectFromHeaderStep1 : function(component,event,helper){
        component.set("v.currentStep", "1");
    },
    
    selectFromHeaderStep2 : function(component,event,helper){
       component.set("v.currentStep", "2");
        helper.checkBoxOptions(component,event,helper);
        
    },
    selectFromHeaderStep3 : function(component,event,helper){
        component.set("v.currentStep", "3");
        var newObjRec = component.get('v.objectConfigurations');
        var goBack = false;
        newObjRec.forEach(function(element){
            if(element.PA_LFM__Field_to_Display__c =='' ||element.PA_LFM__Field_to_Display__c == undefined || element.PA_LFM__Field_to_Display__c == null ){
                goBack = true;
            }
        });
        if(goBack == true){
            component.set("v.currentStep", "2");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error!",
                "message": "Please fill the required fields",
                "type": "error"
                
            });
            toastEvent.fire();
        }
        else{
            component.set('v.objectConfigurations',newObjRec);
        }        
    },
    selectFromHeaderStep4 : function(component,event,helper){
        component.set("v.currentStep", "4");
        helper.selectedTagOptions(component,event,helper);
        
        
    },
})