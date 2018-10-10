({
    selectRecord : function(component, event, helper){    
        
        component.set('v.SelectedRecordTemplate',component.get("v.oRecord"));
    },
    tempSave:function(component, event, helper){    
        let record=component.get("v.oRecord");
        // let status=event.target.checked;
        //console.log('record.template.PA_LFM__Is_favorite__c'+ record.template.PA_LFM__Is_favorite__c)
        
        let status= !record.template.PA_LFM__Is_favorite__c;
        record.template.PA_LFM__Is_favorite__c = status;
        
        //console.log('status'+ status)
        component.set('v.oRecord',record)
        var action = component.get('c.saveAsFav');
        
        action.setParams({
            'recordId':record.template.Id,
            'opration':status
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            
            if (state === "SUCCESS") {
                if(status){
                    component.find('notifLib').showToast({
                        "title": "Success",
                        "message": "Template saved as favourite.",
                        "variant" : "success"
                    });  
                }else{
                    component.find('notifLib').showToast({
                        "title": "Success",
                        "message": "Template remove as favourite.",
                        "variant" : "success"
                    });
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