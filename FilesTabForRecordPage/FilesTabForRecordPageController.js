({
    recordUpdate : function(component, event, helper) {
        console.log('init');
        console.log('v.record: '+component.get("v.record"));
        var sobjname = component.get("v.sObjectName");
        var recId = component.get("v.recordId");
        console.log("sobjname: " + sobjname);
        var recordTypeName='';
        console.log('Json component.get("v.currentRecObj")'+JSON.stringify(component.get("v.currentRecObj")));
        console.log('+++ '+component.get("v.currentRecObj"));
        if(component.get("v.currentRecObj")){
            console.log('*** '+component.get("v.currentRecObj"));
            if(component.get("v.currentRecObj").RecordType){
            recordTypeName= component.get("v.currentRecObj").RecordType.DeveloperName;
            }
            
        }
        //console.log('sobjname---'+sobjname+'--recId--'+recId+'--recordTypeName--'+recordTypeName);
        
        var action = component.get("c.getNavigationItemDataForObjectHome");
        action.setParams({
            'recordID':recId,
            'recordTypeName':recordTypeName,
            'sObjectName':sobjname
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.items", storeResponse);
                for (var i = 0, len = storeResponse.length; i < len; i++) {
                    
                    if(storeResponse[i].expanded){
                        
                        component.set('v.initiallySelected', storeResponse[i].name);
                        component.set( 'v.NavItemSelected', storeResponse[i].name );
                    }
                }
                //console.log('in tab do init after action '+component.get("v.NavItemSelected"))
                
                var EventSetSearchResults = $A.get("e.c:EventForSearchParams");
                EventSetSearchResults.setParams({
                    "Searchmode" : 'NavigationMenu',
                    "navMenuID" : component.get("v.NavItemSelected")
                });
                
                EventSetSearchResults.fire();
                //console.log('in tab do init after events fired ');       
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
    
    handleSelectfromNavigationbar: function(component, event, helper) {
        //console.log('handleSelectfromNavigationbar ');
        var selected = event.getParam('name');
        component.set('v.NavItemSelected', selected);
        var EventSetSearchResults = $A.get("e.c:EventForSearchParams");
        EventSetSearchResults.setParams({
            "Searchmode" : 'NavigationMenu',
            "navMenuID" : selected
        });

        EventSetSearchResults.fire();
    },
    
})