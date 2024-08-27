public with sharing class ShipmentTriggerHandler extends TriggerHandler {
    public ShipmentTriggerHandler() {
        this.setMaxLoopCount(2);
    }
    public override void afterInsert(){
        sendShipmentRequest();
    }

    public override void afterUpdate(){
        sendShipmentRequestProtrac();
    }

    public static void sendShipmentRequestProtrac(){
        Map<Id,Shipment__c> shipMap = (Map<Id,Shipment__c>)Trigger.oldMap;
        for(Shipment__c ship : (List<Shipment__c>)Trigger.new){
            if(ship.Tracking_ID__c != null && ship.Tracking_ID__c != shipMap.get(ship.Id).Tracking_ID__c){
                if(ship.Type__c == 'Apheresis'){
                    System.enqueueJob(new IntegrationHandler('Protrac_APH_Shipment', 'PROTRAC', ship.Id));
                }else if(ship.Type__c == 'Drug Product'){
                    System.enqueueJob(new IntegrationHandler('Protrac_DP_Booking', 'PROTRAC', ship.Id));
                }
            }
        }
    }
    
    public static void sendShipmentRequest(){
        Set<Id> milestoneIds = new Set<Id>();
        for(Shipment__c ship : (List<Shipment__c>)Trigger.new){
            if(ship.recordTypeId != Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Manual').getRecordTypeId()){
                System.enqueueJob(new IntegrationHandler('CREATE_SHIPMENT', 'BIOCAIR', ship.Id));
            }
            if(ship.Patient_Milestone__c != null){
                milestoneIds.add(ship.Patient_Milestone__c);
            }
        }
        if(!milestoneIds.isEmpty()){
            Map<Id,Patient_Milestone__c> patientMilestones = new Map<Id,Patient_Milestone__c>([SELECT Id, Status__c, (SELECT Status__c, Verify__c, Verify_By__c, Apheresis_Shipment__c, Drug_Product_Shipment__c FROM Patient_Milestone_Tasks__r ORDER BY Order__c), (SELECT Id FROM Shipment__r) FROM Patient_Milestone__c WHERE Id IN :milestoneIds]);
            for(Patient_Milestone__c pm : patientMilestones.values()){
                String status = pm.Status__c;
                for(Patient_Milestone_Task__c pmt : pm.Patient_Milestone_Tasks__r){
                    if(pmt.Status__c == 'Completed' && !pmt.Verify__c){
                        status = 'Completed';
                    }else if(pmt.Status__c == 'Completed' && pmt.Verify__c && pmt.Verify_By__c != null){
                        status = 'Completed';
                    }else{
                        status = pm.Status__c;
                    }
                    if(pmt.Apheresis_Shipment__c || pmt.Drug_Product_Shipment__c){
                        if(pm.Shipment__r.size() == 0){
                            status = pm.Status__c;
                        }
                    }
                }
                pm.Status__c = status;
            }
            if(!patientMilestones.isEmpty()){
                update patientMilestones.values();
            }
        }
    }
}