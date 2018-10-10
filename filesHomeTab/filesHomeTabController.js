({
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   likenClose: function(component, event, helper) {
      // Display alert message on the click on the "Like and Close" button from Model Footer 
      // and set set the "isOpen" attribute to "False for close the model Box.
      alert('thanks for like Us :)');
      component.set("v.isOpen", false);
   },
   
    handleShowModalwithFooter : function (component, event, helper) {
    var modalBody;
    var modalFooter;
    $A.createComponents([
        ["c:uploadFileAndClassify",{}],
        ["c:filesUploadAndClassifyModalFooter",{}]
    ],
    function(components, status){
        if (status === "SUCCESS") {
            modalBody = components[0];
            modalFooter = components[1];
            component.find('overlayLib').showCustomModal({
               header: "Upload Files",
               body: modalBody, 
               footer: modalFooter,
               showCloseButton: true,
               cssClass: "slds-modal slds-fade-in-open,slds-modal slds-fade-in-open",
               closeCallback: function() {
               /* component.find('notifLib').showToast({
                    "title": "File Upload Success!",
                    "message": "File has been uploaded successfully.",
                    "variant" : "success"
                }); */
               }
           })
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
    }
                       );
    },
    CreateComponent : function(component, evt, helper) {
    $A.createComponent("PA_LFM:LFM_uploadFileAndClassify", {},function(newCaseList){
    if (component.isValid()) {
        var body = component.get("v.body");
        body.push(newCaseList);
        component.set("v.body", body);
    }});}
})