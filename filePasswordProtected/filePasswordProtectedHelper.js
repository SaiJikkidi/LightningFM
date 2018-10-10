({
	helperMethod : function() {
		
	},
    checkPasswordPerm : function(component) {
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get("c.checkPasswordCreationAccess");
            action.setCallback(this, function(response){
                var state = response.getState();
                var result =response.getReturnValue();
                if (state === "SUCCESS"){
                    resolve(result);
                }
                else{
                    reject(false);
                }
            });
            $A.enqueueAction(action);
        }));
    }
})