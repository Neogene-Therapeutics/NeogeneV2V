trigger ShipmentTrigger on Shipment__c (before insert, before update, after insert, after update)  {
    new ShipmentTriggerHandler().run();
}