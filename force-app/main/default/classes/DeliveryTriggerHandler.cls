public class DeliveryTriggerHandler {
    
    public static void truckStatusInsertUpdate(List<Delivery__c> deliList){
        //container for bulkify update
        List<Truck__c> updateTruck = new List<Truck__c>();
		
        List<String> truckIdList = new List<String>();
        for(Delivery__c truck : deliList){
            //add truck ids to containers
            truckIdList.add(truck.Truck__c);
        }
        
        List<Truck__c> truckList = [SELECT Id, Status__c
                                    FROM Truck__c
                                    WHERE Id IN :truckIdList];
        
        for(Delivery__c del : deliList){
            for(Truck__c truck : truckList){
                if(del.Status__c == 'Parked' || del.Status__c == 'En-route'){
                    truck.Status__c = 'On Delivery';
                    updateTruck.add(truck);
                }
                else if(del.Status__c == 'Completed'){
                    truck.Status__c = 'Parked';
                    truck.Current_Location__c = del.To_Warehouse__c;
                    updateTruck.add(truck);
                }
            }
                
        }
        //bulkify update
        update truckList; 
    }

}