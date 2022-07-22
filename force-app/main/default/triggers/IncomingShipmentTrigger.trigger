trigger IncomingShipmentTrigger on Incoming_Shipment__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        IncomingShipmentTriggerHandler.incomingShipmentInsert(Trigger.new);
    }
    
}