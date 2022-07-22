@RestResource(urlMapping='/WSIncomingShipment')
global class WSIncomingShipment {
	
    @HttpPost
    global static void insertIncomingShipment(){
        //create vars to hold data from arc
        String prodCode, warehouse, response;
        Integer count;
        
        //retrieve JSON body
        String body = RestContext.request.requestBody.toString();
        
        NewIncShipment ship = (NewIncShipment) JSON.deserialize(body, NewIncShipment.class);
        prodCode = ship.ProductCode;
        count = ship.count;
        warehouse = ship.warehouse;
        system.debug(ship);
        
        //Query warehouse id
        Warehouse__c getWarehouseId = [SELECT Id, Warehouse_Code__c, Name
                                       From Warehouse__c
                                       WHERE Warehouse_Code__c = :warehouse];
        
        //Check if fields are null
        if(prodCode != null && count != null && warehouse != null){
            //Insert new incoming shipment method
            Incoming_Shipment__c newRec = new Incoming_Shipment__c();
            newRec.Product_Code__c = prodCode;
            newRec.Count__c = count;
            newRec.Warehouse__c = getWarehouseId.Id;
            
            insert newRec;
            response = 'Inserted with Id: ' + newRec.Id;
        }
        else{
            response = 'Values should not be null';
        }
        Restcontext.response.responseBody = blob.valueof(response);
    }
    
    //Wrapper to receive JSON data 
    public class NewIncShipment{
        public String ProductCode;
        public Integer count;
        public String warehouse;
    }
    
}