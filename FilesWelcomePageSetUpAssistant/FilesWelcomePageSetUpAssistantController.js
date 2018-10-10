({
   init : function(cmp, event, helper) {
      
    },
    navigatetoGuidedSetup:function(cmp, event, helper) {
        var navService = cmp.find("navService");
        var pageReference =   {    
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "PA_LFM__Guided_Setup"     }
        };
        
        //var pageReference = cmp.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },
    
    navigatetoCreateTag:function(cmp, event, helper) {
    var navService = cmp.find("navService");
    var pageReference = {    
    "type": "standard__objectPage",
    "attributes": {
    "objectApiName": "PA_LFM__Tag__c",
    "actionName": "new"}
 };
 
 event.preventDefault();
navService.navigate(pageReference);
},
       navigatetoCreateFileFilters:function(cmp, event, helper) {
    var navService = cmp.find("navService");
    var pageReference = {    
    "type": "standard__objectPage",
    "attributes": {
    "objectApiName": "PA_LFM__Navigation_Menu_Configuration__c",
    "actionName": "new"}
 };
 
 event.preventDefault();
navService.navigate(pageReference);
},
    handleUrlClick: function(cmp, event, helper) {
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },
  handleSetActiveSectionD: function (cmp) {
              cmp.set('v.showPostSteps', !cmp.get('v.showPostSteps'));
        //cmp.find("accordion").set('v.activeSectionName', 'D');
        cmp.set('v.activeSection','D' );
    },
      handleSetActiveSectionE: function (cmp) {
                  cmp.set('v.showPostSteps', !cmp.get('v.showPostSteps'));
        cmp.set('v.activeSection','E' );

        //cmp.find("accordion").set('v.activeSectionName', 'E');
    },
      handleSetActiveSectionF: function (cmp) {
                  cmp.set('v.showPostSteps', !cmp.get('v.showPostSteps'));
                  cmp.set('v.activeSection','F' );

        //cmp.find("accordion").set('v.activeSectionName', 'F');
    },

	 handleClick : function (cmp) {
        cmp.set('v.showPostSteps', !cmp.get('v.showPostSteps'));
    },
})