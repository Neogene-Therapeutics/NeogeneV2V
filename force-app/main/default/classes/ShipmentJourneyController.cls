public class ShipmentJourneyController {

    public class ShipmentEventWrapper  {
        public ResponseData responseData { get; set; }
        public Integer requestId { get; set; }
        public Datetime requestDate { get; set; }
        public Integer responseId { get; set; }
        public Datetime responseDate { get; set; }
        public Integer returnedDataCount { get; set; }
        public Integer pagenationLimit { get; set; }
        public Integer pagenationOffset { get; set; }
        public Integer pagenationTotalRecords { get; set; }
        public List<String> errorMessage { get; set; }

    }
    public class ResponseData {
        public List<Event> events { get; set; }
    }
    public class Event {
        public String rawEventId { get; set; }
        public Integer eventId { get; set; }
        public Integer orderId { get; set; }
        public String eventTypeCode { get; set; }
        public String eventTypeName { get; set; }
        public EventGPS eventGPS { get; set; }
        public String eventLocation { get; set; }
        public String eventDescription { get; set; }
        public Datetime eventDateTime { get; set; }
        public Pod pod { get; set; }
        public String eventDetails { get; set; }
        public Datetime createdDate { get; set; }
        public Integer eventOrigin { get; set; }
    }

    public class EventGPS {
        public String latitude { get; set; }
        public String longitude { get; set; }
    }

    public class Pod {
        public String nameofSignee { get; set; }
        public Datetime timeOfSignature { get; set; }
        public String goodCondition { get; set; }
        public String note { get; set; }
    }

    @AuraEnabled
    public static String getShipmentStatus(Id recordId){
        try {
            List<Shipment__c> shipmentList = [SELECT Tracking_ID__c, Order_Id__c FROM Shipment__c WHERE Id =: recordId];
            if(!shipmentList.isEmpty()){
                Shipment__c ship = shipmentList.get(0);
                String apiName = 'SHIPMENT_STATUS';
                BioCair_API_Details__mdt apiDetails = BioCair_API_Details__mdt.getInstance(apiName);
                HttpRequest req = new HttpRequest();
                req.setEndpoint(apiDetails.Endpoint__c+'/'+ship.Order_Id__c+'/events');
                req.setMethod(apiDetails.Method__c);
                req.setHeader('Biocair-Subscription-Key',apiDetails.Biocair_Subscription_Key__c);
                req.setHeader('IntegrationKey',apiDetails.IntegrationKey__c);
                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 200) {
                    ShipmentJourneyController.ShipmentEventWrapper wrapper = (ShipmentJourneyController.ShipmentEventWrapper)JSON.deserializeStrict(res.getBody(), ShipmentJourneyController.ShipmentEventWrapper.class);
                    if(wrapper != null){
                        Set<Integer> orderIds = new Set<Integer>();
                        ShipmentJourneyController.ResponseData resData = wrapper.responseData;
                        Map<Double, ShipmentJourneyController.Event> eventMap = new Map<Double,ShipmentJourneyController.Event>();
                        for(Event e : resData.events){
                            if(e.orderId != null){
                                orderIds.add(e.orderId);
                                eventMap.put(e.eventId,e);
                            }
                        }
                        if(!orderIds.isEmpty()){
                            List<Shipment__c> shipments = [SELECT Id, Order_Id__c, Tracking_ID__c, (SELECT Id, Event_Id__c FROM Shipment_Details__r) FROM Shipment__c WHERE Id=: recordId AND Order_Id__c IN: orderIds];
                            if(!shipments.isEmpty()){
                                Shipment__c s = shipments.get(0);
                                Map<Double,Shipment_Details__c> shipDetailsMap = new Map<Double,Shipment_Details__c>();
                                for(Shipment_Details__c sd : s.Shipment_Details__r){
                                    shipDetailsMap.put(sd.Event_Id__c,sd);
                                }
                                List<Shipment_Details__c> shipDetails = new List<Shipment_Details__c>();
                                for(ShipmentJourneyController.Event e : resData.events){
                                    Shipment_Details__c sd = new Shipment_Details__c();
                                    if(shipDetailsMap.containsKey(e.eventId)){
                                        sd = shipDetailsMap.get(e.eventId);
                                    }
                                    sd.Event_Id__c = e.eventId;
                                    sd.Shipment__c = s.Id;
                                    sd.Order_Id__c = e.orderId;
                                    sd.Event_Type_Code__c = e.eventTypeCode;
                                    sd.Event_Type_Name__c = e.eventTypeName;
                                    sd.Event_Date_Time__c = e.eventDateTime;
                                    sd.Event_Description__c = e.eventDescription;
                                    shipDetails.add(sd);
                                }
                                if(!shipDetails.isEmpty()){
                                    upsert shipDetails;
                                }
                            }
                        }
                    }
                    return res.getBody();
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
}