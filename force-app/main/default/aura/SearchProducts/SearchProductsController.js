({
    doInit: function(component, event, helper) {
        helper.getAllProducts(component);
        helper.getAllWarehouse(component);
    },
    searchProducts : function(component, event, helper) {
        var searchString = component.get("v.searchString");
        var action = component.get("c.getProdInvList");
        action.setParams({
            searchKey: searchString
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                console.log(res);
                component.set("v.prodList", res)
                
                if(res.length > 0){
                    component.set('v.showTable', true);
                    component.set('v.showNoResult', false);
                }
                else if(searchString !== null & res.length == 0){
                    component.set('v.showNoResult', true);
                    component.set('v.showTable', false)
                }
            }
            else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error message: " + errors[0].message);
                } else 
                    console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
    handleSelect : function (component, event, helper) {
        var menuItems = component.find("menuItems");
        var menuValue = event.getParam("value");
        var action = component.get("c.filterByWarehouse");
        action.setParams({
            searchKey: menuValue
        })
        menuItems.forEach(function (menuItem) {
            // For each menu item, if it was checked, un-check it. This ensures that only one
            // menu item is checked at a time
            if (menuItem.get("v.checked")) {
                menuItem.set("v.checked", false);
            }
            // Check the selected menu item
            if (menuItem.get("v.value") === menuValue) {
                menuItem.set("v.checked", true);
            }
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                console.log(res);
                component.set("v.prodList", res)
                if(res.length > 0){
                    component.set('v.showTable', true);
                    component.set('v.showNoResult', false);
                } 
                else if(searchString !== null & res.length == 0){
                    component.set('v.showNoResult', true);
                    component.set('v.showTable', false)
                }
            }
            else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error message: " + errors[0].message);
                } 
                else
                    console.log("Unknown error");
            }
        });
        
        $A.enqueueAction(action);
    }
})