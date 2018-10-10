({
    searchHelper : function(component,event,getInputkeyWord,getDefault) {
        //console.log('searchHelper of getConfig');
        let helper=this;
        // call the apex class method 
        var action = component.get("c.fetchConfigs");
        // set param to method  
        action.setParams({
            'searchKeyWord':getInputkeyWord,
            'getDefault':getDefault
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                if(getDefault && storeResponse[0]){
                    component.set('v.selectedRecordConfig',storeResponse[0]);
                  
                }
                else{
                	// set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);    
                }
                
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    updateUserSelection:function(component,event,operation) {
        //console.log('updateUserSelection of getConfig');
        var oSelectedRecordEvent = $A.get("e.c:EventsaveUserTagsSelection");
        var currentSelectedRecord=component.get("v.selectedRecordConfig");
        if(operation === 'Add'){
            oSelectedRecordEvent.setParams({
                'selectedConfig':currentSelectedRecord,
                'userObjectSelection':null,
                'userTagSelection':null,
                'filterTagSelection':null
            });
            oSelectedRecordEvent.fire();
		} 
        else if(operation === 'Remove'){
            oSelectedRecordEvent.setParams({
			 	'selectedConfig':currentSelectedRecord,
                'userObjectSelection':null,
                'userTagSelection':null,
                'filterTagSelection':null
                });
			oSelectedRecordEvent.fire();
        }
      
        
    }
})