public class IncomingShipmentTriggerHandler {
    
    public static void incomingShipmentInsert(List<Incoming_Shipment__c> shipList) {
        Set<String> prodCodeSet = new Set<String>();
        Set<String> warehouseSet = new Set<String>();
        
        for(Incoming_Shipment__c ship : shipList){
            //add values to containers
            prodCodeSet.add(ship.Product_Code__c);
            warehouseSet.add(ship.Warehouse__c);
        }
		
        //Check product from Product_Item_c
        List<Product_Item__c> prodItemList = [SELECT Id, Product_Code__c, Total_Available_Count__c
                                              FROM Product_Item__c
                                              WHERE Product_Code__c IN: prodCodeSet];
        
        List<Product_Inventory__c> prodInvList = [SELECT Id, Warehouse__c, Amount_available__c, Product__r.Product_code__c
                                                  FROM Product_inventory__c
                                                  WHERE Warehouse__c IN: warehouseSet
                                                  AND Current__c = TRUE
                                                  AND Product__r.Product_code__c IN: prodCodeSet];

        for(Incoming_Shipment__c ship : shipList){
            if(prodItemList.size() == 0){
                //no match found
                ship.addError('No product found');
            }
            else if(prodItemList.size() != 0){
                Boolean flag = false;
                //compare products with same warehouse between product inventory and incoming shipment
                for(Product_Inventory__c inv : prodInvList){
                    if(ship.Product_Code__c == inv.Product__r.Product_code__c){
                        //increment amount available in inventory
                        inv.Amount_available__c = inv.Amount_available__c + ship.Count__c;
                        flag = true;
                    }
                }
                //create product inventory bool if flag is false
            }
        }
        //update inventory
        if(prodInvList != null && prodInvList.size() > 0)
        	update prodInvList;
    }
}