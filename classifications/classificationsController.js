({
    doInit : function(component, event, helper) {
        ////console.log('doInt of classification compnent');
        var action = component.get("c.fetchTemplate");  
        let mode=component.get('v.mode');
        action.setParams({
            'searchKeyWord':'',
            'mode':mode
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();  
            if (state === "SUCCESS") {
                let result=response.getReturnValue();
                component.set( "v.items",result );  
                
                
            }  
            else{
                
                var errors = response.getError();
                 if (state=='ERROR' && errors) {
                     if (errors[0] && errors[0].message) {
                         if(errors[0].message==$A.get("$Label.c.CurdPermision")){
                             component.find('notifLib').showToast({
                                 "title": "Permission Issue",
                                 "message": $A.get("$Label.c.CurdPermision"),
                                 "variant" : "warning"
                             });
                         }
                         
                     }
                     
                 } 
                 else {
                     component.find('notifLib').showToast({
                        "title": "Opps",
                        "message": 'Something went wrong',
                        "variant" : "error"
                    });
                 }
             }
        });  
        $A.enqueueAction(action);  
    },
    handleSelection: function(component, event, helper) {
        
        let template=component.get('v.SelectedRecordTemplate');
        
        var action = component.get("c.getTemplateRecords");  
        action.setParams({
            'tempId':template.template.Id
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();  
            
            if (state === "SUCCESS") {
                let result=response.getReturnValue();
                
                if(result.tags){
                    var templateEvent = $A.get("e.c:EventUserTemplateSelection");
                    let allTags=[];
                    if(result.records){
                        allTags=result.tags;
                    }
                    let allrecords=[];
                    if(result.records){
                        allrecords=result.records;
                    }     
                    templateEvent.setParams({
                        'treeConfigSelectedU':result.folder,
                        'tressTagSelectedU':allTags,
                        'treesRecordSelecttedU':allrecords,
                        'treeConfigSelectedS':result.folder,
                        'tressTagSelectedS':allTags,
                        'treesRecordSelecttedS':allrecords
                    });
                    templateEvent.fire();
                    component.set('v.tagForm','false');
                }
                
            } 
            else if (state=='ERROR'){
                
                var errors = response.getError();
                var message=errors[0].message;
                
                
                if(message==$A.get("$Label.c.CurdPermision")){
                    component.find('notifLib').showToast({
                        "title": "Permission Issue",
                        "message": $A.get("$Label.c.CurdPermision"),
                        "variant" : "warning"
                    });
                }
                else {
                    
                    component.find('notifLib').showToast({
                        "title": "Opps",
                        "message": 'Something went wrong',
                        "variant" : "error"
                    });
                }  
                
            }
            
        });  
        $A.enqueueAction(action);  
        
    }
})