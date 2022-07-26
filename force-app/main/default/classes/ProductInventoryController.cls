public class ProductInventoryController {
    
    @AuraEnabled
    public static List<Product_Inventory__c> getAllProducts(){
        return [SELECT Id, Amount_Available__c, Product__r.Name, Product__r.Product_Code__c, Warehouse__r.Name, Current__c
                FROM Product_Inventory__c];
    }
    
	@AuraEnabled
    public static List<Product_Inventory__c> getProdInvList(String searchKey){
        searchKey = '%' + searchKey + '%';
        return [SELECT Id, Amount_Available__c, Product__r.Name, Product__r.Product_Code__c, Warehouse__r.Name, Current__c
                FROM Product_Inventory__c 
                WHERE (Product__r.Name LIKE :searchKey 
                OR Product__r.Product_Code__c LIKE :searchKey)
               	AND Current__c = true];
    }
    
    @AuraEnabled
    public static List<Product_Inventory__c> filterByWarehouse(String searchKey){
        return [SELECT Id, Amount_Available__c, Product__r.Name, Product__r.Product_Code__c, Warehouse__r.Name, Current__c
                FROM Product_Inventory__c 
                WHERE Warehouse__r.Name = :searchKey];
    }
    
    @AuraEnabled
    public static List<Warehouse__c> getAllWarehouse(){
        return [SELECT Id, Name FROM Warehouse__c];
    }
}