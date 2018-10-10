({
    injectComponent: function (name,mode,title, target,cmp) {
        $A.createComponent(name, {
            "mode": mode,
            "pageTitle" : title,
            "sObjectName":cmp.get('v.sObjectName'),
            "recordId":cmp.get('v.recordId')
            
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });}
})