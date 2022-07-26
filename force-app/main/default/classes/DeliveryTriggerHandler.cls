public class DeliveryTriggerHandler {
    
    public static void truckStatusInsertUpdate(List<Delivery__c> deliList){
        //container for bulkify update
        List<Truck__c> updateTruck = new List<Truck__c>();
		
        List<String> truckIdList = new List<String>();
        for(Delivery__c truck : deliList){
            //add truck ids to containers
            truckIdList.add(truck.Truck__c);
        }
        
        for(Delivery__c del : deliList){
            Truck__c trk = new Truck__c(); 
            trk.Id = del.Truck__c;
            if(del.Status__c == 'Parked' || del.Status__c == 'En-route'){
                trk.Status__c = 'On Delivery';
                updateTruck.add(trk);
            }
            else if(del.Status__c == 'Completed'){
                trk.Status__c = 'Parked';
                trk.Current_Location__c = del.To_Warehouse__c;
                updateTruck.add(trk);
            }
        }
        //bulkify update
        if(updateTruck != null & updateTruck.size() > 0)
            update updateTruck; 
    }

}