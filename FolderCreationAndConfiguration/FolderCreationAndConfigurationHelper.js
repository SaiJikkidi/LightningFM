({
    refreshSidePanel : function(component, event, helper) {
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
                component.set("v.initiallySelected", '');                
                
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
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    insertFolder : function(CWid,folderName,Icon,component, event, helper) {
        var folderParentId = component.get("v.folderParentId");
        var serverCall=component.get('c.getInsertFolders');
        serverCall.setParams({
            "folderName" : folderName,
            "CWid" : CWid,
            "folderParentId" : folderParentId,
            "Icon" : Icon
        });
        serverCall.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
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
            helper.refreshSidePanel(component, event, helper);
        });
        $A.enqueueAction(serverCall);
    },
    
    selectedTagOptions : function(component, event, helper){
        var selectedLibrary = component.get("v.selectedLibrary");
        var initialTagsSelected = component.get("v.initialTagsSelected"); 
        var selectedTags = component.get("v.selectedTags");
        var folderTagsConfigurations = [];
        //For Tags
        
        var initialTagMap = new Map();
        if(initialTagsSelected != null && initialTagsSelected != ''&& initialTagsSelected != undefined){
            initialTagsSelected.forEach(function(element){
                initialTagMap.set(element.PA_LFM__Tag__c,element);
            });
        }
        if(selectedTags != null && selectedTags != '' && selectedTags != undefined){
            selectedTags.forEach(function(element){
                if(initialTagMap.has(element)){
                    folderTagsConfigurations.push(initialTagMap.get(element));
                }else{
                    folderTagsConfigurations.push({"PA_LFM__Tag__c":element,"PA_LFM__Library_and_Folder__c":selectedLibrary,"PA_LFM__Required__c":false})
                }
            });
        }
        
        //End of Tags
        component.set("v.folderTagsConfigurations",folderTagsConfigurations);
        
    },
    checkBoxOptions : function(component, event, helper){
        var selectedLibrary = component.get("v.selectedLibrary");
        var initialObjectsSelected = component.get("v.initialObjectsSelected"); 
        var selectedObjects = component.get("v.selectedObjects");
        var objectConfigurations = [];
        
        //For Objects
        var initialObjectMap = new Map();
        if(initialObjectsSelected != null && initialObjectsSelected != '' && initialObjectsSelected != undefined){
            initialObjectsSelected.forEach(function(element){
                initialObjectMap.set(element.Name,element);
            });
        }
        if(selectedObjects != null && selectedObjects != '' && selectedObjects != undefined){
            
            selectedObjects.forEach(function(element){
                if(initialObjectMap.has(element)){
                    objectConfigurations.push(initialObjectMap.get(element));
                }else{
                    objectConfigurations.push({"Name":element,"PA_LFM__Field_to_Display__c":'',"PA_LFM__Library_and_Folder__c":selectedLibrary,"PA_LFM__Required__c":false});
                }
            });
        }
        
        //End of Objects
        
        component.set("v.objectConfigurations",objectConfigurations); 
        
    }
})