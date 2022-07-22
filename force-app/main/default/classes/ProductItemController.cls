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
    public static List<Warehouse__c> getAllWarehouse(){
        return [SELECT Id, Name FROM Warehouse__c];
    }
    
    @AuraEnabled
    public static void saveProdItem(String prodName, String prodCode){
        Product_Item__c prod = new Product_Item__c();
        prod.Name = prodName;
        prod.Product_Code__c = prodCode;
        insert prod;
        
        //insert to product inventory
    }

}