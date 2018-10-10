({
    doInit : function(component, event, helper) {
        var passwordRequired = component.get("v.passwordRequired");
        var action = component.get("c.getCheckPassword");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result =response.getReturnValue();
            helper.checkPasswordPerm(component).then(
                $A.getCallback(function(result) {
                	   component.set('v.allowGenratePassword',result);
                })
            );
            if (state === "SUCCESS") {
                component.set("v.result",result);
                //console.log('result length' + result.length);
                //console.log('result value' + JSON.stringify(result));
                if(result.length  >0 && result[0].PreferencesPasswordRequired != undefined){
                    component.set("v.setBoolean",result[0].PreferencesPasswordRequired);
                    component.set("v.ContentDistributions",result);

                    
                }
                else{
                    component.set("v.setBoolean",passwordRequired);
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
        $A.enqueueAction(action);
    },
    generatePassword: function (component, event) {
        var passwordRequired = event.getSource().get("v.value");
        var ifError = component.get("v.ifError");
        var action = component.get('c.getContentVersion');
        action.setParams({
            'recordId' :component.get("v.recordId"),
            'passwordRequired' : passwordRequired
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                if(result.length  >0 && result[0].PreferencesPasswordRequired != undefined){
                    component.set("v.setBoolean",result[0].PreferencesPasswordRequired);
                    component.set("v.ContentDistributions",result);
                    
                }else{
                    
                    component.set("v.setBoolean",ifError);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "message": "Insufficient permissions.Please contact system Administrator."
                    });
                    toastEvent.fire();
                    
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
        $A.enqueueAction(action);
    },
    copy : function(component, event, helper) {
        var holdtxt = component.find("holdtext1").getElement();
        holdtxt.select();
        document.queryCommandSupported('copy');
        document.execCommand('copy');
        
        var source = event.getSource();
        source.set('v.label','COPIED!');
        
        setTimeout(function(){
        source.set('v.label','Copy');
        }, 1500);
    }
})