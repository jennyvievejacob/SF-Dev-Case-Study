public class ProductItemController {
    
    @AuraEnabled
    public static List<Product_Inventory__c> getWarehouseByProdName(String searchKey){
        searchKey = '%' + searchKey + '%';
        return [SELECT Id, Amount_Available__c, Product__r.Name, Product__r.Product_Code__c, Warehouse__r.Name, Current__c
                FROM Product_Inventory__c 
                WHERE Product__r.Name != :searchKey 
                OR Product__r.Product_Code__c != :searchKey];
    }
    
    @AuraEnabled
    public static List<DataWrapper> getAllWarehouse(){
        List<DataWrapper> dataWrapperList = new List<DataWrapper>();
        
        for(Warehouse__c warehouse : [SELECT Id, Name FROM Warehouse__c]){
            dataWrapperList.add(new DataWrapper(warehouse));
        }
        
        return dataWrapperList;
    }
    
    @AuraEnabled
    public static void saveProdItem(String prodName, String prodCode, String tableData){
        List<Product_Inventory__c> prodInvList = new List<Product_Inventory__c>();

        List<DataWrapper> dataWrapper = (List<DataWrapper>)JSON.deserialize(tableData, List<DataWrapper>.class);

        Product_Item__c prod = new Product_Item__c();
        prod.Name = prodName;
        prod.Product_Code__c = prodCode;
        insert prod;

        //insert to product inventory
        for(DataWrapper wrap : dataWrapper){
            Product_Inventory__c prodInvItems = new Product_Inventory__c();

            prodInvItems.Warehouse__c = wrap.warehouseId;
            prodInvItems.Product__c = prod.Id;
            prodInvItems.Amount_Available__c = Integer.valueOf(wrap.amountAvailable);
            prodInvItems.Current__c = true;
            prodInvItems.Inventory_Month__c = System.Today().month();
            prodInvItems.Inventory_Year__c = System.Today().year();

            prodInvList.add(prodInvItems);
        }

        if(prodInvList.size() > 0)
            insert prodInvList;
    }

    public class DataWrapper{  
        @AuraEnabled
        public Id warehouseId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal amountAvailable;
        
        public DataWrapper(Warehouse__c warehouse){
            this.warehouseId = warehouse.Id;
            this.name = warehouse.Name;
            this.amountAvailable = 0;
        }
    }

}