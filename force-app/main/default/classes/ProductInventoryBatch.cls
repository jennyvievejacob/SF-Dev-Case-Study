public class ProductInventoryBatch implements Database.Batchable<sObject> {
    
    //start
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(
            [SELECT Id, Name, Product__c, Warehouse__c, Inventory_Month__c, Inventory_Year__c, Amount_Available__c, Current__c
             FROM Product_Inventory__c 
             WHERE Current__c = TRUE]
        );
    }
    
    //execute
    public void execute(Database.BatchableContext BC, List<Product_Inventory__c> scope){
        List <Product_Inventory__c> updateProdInvList = new List<Product_Inventory__c>();
        List <Product_Inventory__c> newProdInvList = new List<Product_Inventory__c>();
        
        for(Product_Inventory__c oldRec : (List<Product_Inventory__c>) scope){
            //container for new records
            Product_Inventory__c newRec = new Product_Inventory__c();
            
            //Regex to get the [0] name, [1] month, and [2] year
            String[] regexName = oldRec.Name.split('(?<=\\D)(?=\\d)');
            newRec.Name = regexName[0];
            newRec.Inventory_Month__c = Date.today().month();
            newRec.Inventory_Year__c = Date.today().year();
            newRec.Amount_Available__c = oldRec.Amount_Available__c;
            newRec.Product__c = oldRec.Product__c;
            newRec.Warehouse__c = oldRec.Warehouse__c;
            newRec.Current__c = true;
            //change old recs to false
            oldRec.Current__c = false;
            
            //add to list to bulkify
            newProdInvList.add(newRec);
            updateProdInvList.add(oldRec);
        }
        
        if(newProdInvList.size() > 0){
            Insert newProdInvList;
            Update updateProdInvList;
        }
    }
    
    //finish
    public void finish(Database.BatchableContext BC){
        
    }
}