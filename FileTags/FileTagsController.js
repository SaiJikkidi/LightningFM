({
    getContentVersion : function(component, event, helper) {
        var contentDocumentdata= component.get("v.contentDocumentFileds");
        var ContentVersionId = contentDocumentdata.LatestPublishedVersionId;
        if(ContentVersionId != null && ContentVersionId != ''){
            component.set("v.contentVersionId",contentDocumentdata.LatestPublishedVersionId);
            component.set("v.hasCVId",'True');
        }
    },
    getTags : function(component, event, helper) {
        var allfields = component.get("v.contentVersionFields");
        ////console.log('allfields'+JSON.stringify(allfields));
        var tagString = allfields.TagCsv;
        if(tagString != null && tagString != '' ){
            var tagArray = tagString.split(",");
            if(tagArray.length > 0 && tagArray != undefined ){
                component.set("v.allTags",tagArray);}
        }
    }
})