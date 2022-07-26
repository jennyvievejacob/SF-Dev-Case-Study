public with sharing class NewDeliveryController {


    @AuraEnabled(Cacheable=true)
    public static List<Warehouse__c> getWarehouse(){
        return [Select Id, Name
                FROM Warehouse__c];
    }

    @AuraEnabled(cacheable=true)
    public static String getETA(Id fromWarehouseValue, Id toWarehouseValue){
        Route__c eta = [SELECT Id, Name, From_Warehouse__r.Name, To_Warehouse__r.Name, Travel_Time_mins__c 
                        FROM Route__c
                        WHERE From_Warehouse__c = :fromWarehouseValue
                        AND To_Warehouse__c = :toWarehouseValue];

        DateTime now = Datetime.now();
        DateTime adjusted = now.addMinutes((Integer)eta.Travel_time_mins__c);
        String formatTime = adjusted.format('h:mm a');

        return formatTime;
    }

    //get trucks
    @AuraEnabled(Cacheable=true)
    public static List<Truck__c> getTrucks(Id fromWarehouseValue){
        return [Select Id, Name, Status__c 
                FROM Truck__c
                WHERE Status__c = 'Parked'];
    }

    //get data for table
    @AuraEnabled(Cacheable=true)
    public static List<DataWrapper> getDeliveryContents(Id fromWarehouseValue){
        List<DataWrapper> dataWrapperList = new List<DataWrapper>();
        List<Product_Inventory__c> prodList = [Select Id, Product__r.Name, Name, Warehouse__r.Name, Amount_Available__c, Product__c
                                               FROM Product_Inventory__c 
                                               WHERE Current__c = true
                                               AND Warehouse__c = :fromWarehouseValue];

        for(Product_Inventory__c prod : prodList){
            dataWrapperList.add(new DataWrapper(prod));
        }
        return dataWrapperList;
    }

    //save new delivery
    @AuraEnabled
    public static void insertNewDelivery(Id fromWarehouse, Id toWarehouse, Id truck, String status, String deliveryContentsList){
        //for bulkify
        List<Delivery_Content__c> insertDelContentList = new List<Delivery_Content__c>();

        //deserialize wrapper
        List<DataWrapper> deliveryList = (List<DataWrapper>) JSON.deserialize(deliveryContentsList, List<DataWrapper>.class);

        //query routeId
        Route__c route = [Select Id, Name 
                          FROM Route__c WHERE From_Warehouse__c = :fromWarehouse 
                          AND To_Warehouse__c = :toWarehouse];

        //insert delivery
        Delivery__c newDel = new Delivery__c();
        newDel.Name = 'Temp';
        newDel.Truck__c = truck;
        newDel.From_Warehouse__c = fromWarehouse;
        newDel.To_Warehouse__c = toWarehouse;
        newDel.Route__c = route.Id;
        newDel.Status__c = status;
        insert newDel;

        //insert delivery content
        for(DataWrapper d  : deliveryList){
            Delivery_Content__c newRec = new Delivery_Content__c();
            newRec.Item__c = d.prodItemId;
            newRec.Delivery__c = newDel.Id;
            newRec.Amount__c = d.deliveryAmount; 

            insertDelContentList.add(newRec);
        }

        if(insertDelContentList != null && insertDelContentList.size() > 0){
            insert insertDelContentList;
        }
    }

    public class DataWrapper{        
        @AuraEnabled public Id prodItemId;
        @AuraEnabled public String prodName;
        @AuraEnabled public Decimal amountAvailable;
        @AuraEnabled public Decimal deliveryAmount;
        
        public DataWrapper(Product_Inventory__c rec){
            this.prodItemId = rec.Product__c;
            this.prodName = rec.Product__r.Name;
            this.amountAvailable = rec.Amount_Available__c;
            this.deliveryAmount = 0;
        }
    }
}