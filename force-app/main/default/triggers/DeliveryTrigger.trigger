trigger DeliveryTrigger on Delivery__c (after insert, after update, before insert) {
	
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        DeliveryTriggerHandler.truckStatusInsertUpdate(Trigger.new);
    }
    
}