({
    doInit: function(component, event, helper) {
        helper.getWarehouse(component);
    },
    onSave : function(component, event, helper) {
        var action = component.get("c.saveProdItem");
        var name = component.get("v.prodName");
        var code = component.get("v.prodCode");
        var getWarehouseList = component.get("v.warehouseList");

        action.setParams({
            prodName : name,
            prodCode : code,
            tableData: JSON.stringify(getWarehouseList)
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                //Show Toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Product Item has been successfully created!",
                    type: "success"
                });
                toastEvent.fire();
            }
            else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error message: " + errors[0].message);

                    //Show Toast
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Error creating a product item",
                        type: "error"
                    });
                    toastEvent.fire();
                } 
            }
        });
        $A.enqueueAction(action);
    }
})