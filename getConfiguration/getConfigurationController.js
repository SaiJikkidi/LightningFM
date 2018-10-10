({	
    doInit:function(component,event,helper){
        //console.log('doInit of getConfig');
        helper.searchHelper(component,event,'',true)
        
    },
    onexRecordSelected:function(component,event,helper){
        //console.log('onexRecordSelected of getConfigration');
        let exSelectedRecord=component.get('v.exSelectedRecordConfig');
        
        if(exSelectedRecord){
            component.set("v.selectedRecordConfig" , exSelectedRecord); 
            var pillShow = component.find("lookup-pill");
            $A.util.addClass(pillShow, 'slds-show'); 
            $A.util.removeClass(pillShow, 'slds-hide');
            
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
        }
        
    },
    onfocus : function(component,event,helper){
        
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord,false);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord,false);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set('v.IconName',component.get('v.IconName'));
        var currentSelectedRecord=component.get("v.selectedRecordConfig");
        currentSelectedRecord.Name='Remove';
        component.set("v.selectedRecordConfig", currentSelectedRecord ); 
        
        
       
        
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
          
       
    },
    //function called when user selects template
    applyTemplate:function(component,event,helper){
       
       
        if(component.get('v.mode')=='Upload'){
     
            var selectedConfig=event.getParam("treeConfigSelectedU");
            if(selectedConfig){
                component.set("v.selectedRecordConfig", selectedConfig );     
                var tagsTemp=event.getParam("tressTagSelectedU");
                var tempRecord=event.getParam("treesRecordSelecttedU");
                var templateEvent = $A.get("e.c:EventUserTemplateSelection");
                templateEvent.setParams({
                    'tressTagSelectedU':tagsTemp,
                    'treesRecordSelecttedU':tempRecord
                });
                templateEvent.fire();
            } 
        }
        else if(component.get('v.mode')=='Search'){
     
            var selectedConfig=event.getParam("treeConfigSelectedS");
            if(selectedConfig){
                component.set("v.selectedRecordConfig", selectedConfig );     
                var tagsTemp=event.getParam("tressTagSelectedS");
                var tempRecord=event.getParam("treesRecordSelecttedS");
                var templateEvent = $A.get("e.c:EventUserTemplateSelection");
                templateEvent.setParams({
                    'tressTagSelectedS':tagsTemp,
                    'treesRecordSelecttedS':tempRecord
                });
                templateEvent.fire();
            } 
        }
       
    },
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        //console.log('handle compoentn event of get configration');
        let selectedRecord= component.get('v.selectedRecordConfig');
        //console.log(selectedRecord);
        if(selectedRecord && selectedRecord.Name=='Remove'){
            helper.updateUserSelection(component,event,'Remove');
            component.set("v.selectedRecordConfig", null ); 
        }
        else if(selectedRecord) {
            component.set('v.IconName',selectedRecord.PA_LFM__Icon_Name__c);
            
            // get the selected Account record from the COMPONETN event 	 
            helper.updateUserSelection(component,event,'Add');
            var pillShow = component.find("lookup-pill");
            $A.util.addClass(pillShow, 'slds-show'); 
            $A.util.removeClass(pillShow, 'slds-hide');
            
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
            
            var searchIcon = component.find("inPutsearchIcon");
            $A.util.addClass(searchIcon, 'slds-hide');
            $A.util.removeClass(searchIcon, 'slds-show'); 
            
        }
        
        
    }
})