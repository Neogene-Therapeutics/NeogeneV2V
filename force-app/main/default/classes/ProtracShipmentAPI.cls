@RestResource(urlMapping='/api/notifyShipmentReceipt')
global class ProtracShipmentAPI{
    @HttpPost
    global static void updateShipment() {
        Map<String, String> responseMap = new Map<String, String>();
        Boolean isUpdateSuccess = true;
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        try {
            String requestString = body.toString();  
            RequestWrapper rw = (RequestWrapper)JSON.deserialize(requestString,RequestWrapper.class);     
        /*    List<Patient_Journey__c> journeyRecords = [Select Id, QC_Completion__c FROM Patient_Journey__c WHERE COI__c = :rw.coi LIMIT 1];
            for(Patient_Journey__c pm : journeyRecords){
                pm.QC_Completion__c = true;
                update journeyRecords;
                isUpdateSuccess = true;
            }    */  
            if(isUpdateSuccess) {
                ResponseWrapper res = new ResponseWrapper();
                res.status = 200;
                res.message = 'Shipment Details Updated';
                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
            //    return res;
            } else {
                ResponseWrapper res = new ResponseWrapper();
                res.status = 400;
                res.message = 'COI is invalid';
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
             //   return res;
            }
        }
        catch(exception e) {
            ResponseWrapper res = new ResponseWrapper();
            res.status = 400;
            res.message = e.getMessage();
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
           // return res;
        }    
    }

    public class RequestWrapper{
        public String shipmentId{get;set;}
        public String recipientDate{get;set;}
        public String shipmentCondition{get;set;}
    }

    public class ResponseWrapper{
        public Integer status{get;set;}
        public String message{get;set;}
    }
}