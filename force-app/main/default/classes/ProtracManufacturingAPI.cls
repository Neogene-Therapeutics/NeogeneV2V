@RestResource(urlMapping='/api/updateManufacturingStatus')
global class ProtracManufacturingAPI{
    @HttpPost
    global static void updateManufacturingStatus() {
        Map<String, String> responseMap = new Map<String, String>();
        Boolean isUpdateSuccess = false;
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;

        try {
            String requestString = body.toString();  
            RequestWrapper rw = (RequestWrapper)JSON.deserialize(requestString,RequestWrapper.class);    

            if (rw.coi == null || rw.coi.trim() == '') {
                throw new MissingFieldException('Missing required field: coi');
            }
            if (rw.status == null || rw.status.trim() == '') {
                throw new MissingFieldException('Missing required field: status');
            }
            if (rw.updatedDate == null || rw.updatedDate.trim() == '') {
                throw new MissingFieldException('Missing required field: updatedDate');
            }

            List<Patient_Milestone_Task_Form_Question__c> patientMileTaskFormQues = [SELECT Id FROM Patient_Milestone_Task_Form_Question__c WHERE Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__r.COI__c =: rw.coi AND Is_Manufacturing__c = true];

            for(Patient_Milestone_Task_Form_Question__c pmtq : patientMileTaskFormQues){
                pmtq.Value__c = rw.status;
            } 
            
            if(!patientMileTaskFormQues.isEmpty()){
                update patientMileTaskFormQues;
                isUpdateSuccess = true;
            }

            ResponseWrapper res = new ResponseWrapper();
            if(isUpdateSuccess) {
                res.status = 200;
                res.message = 'Shipment Details Updated';
                RestContext.response.statusCode = 200;
            } else {
                res.status = 400;
                res.message = 'COI is invalid';
                RestContext.response.statusCode = 400;
            }
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
        }
        catch(MissingFieldException mfe) {
            ResponseWrapper res = new ResponseWrapper();
            res.status = 400;
            res.message = mfe.getMessage();
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
        }
        catch(Exception e) {
            ResponseWrapper res = new ResponseWrapper();
            res.status = 400;
            res.message = e.getMessage();
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
        }    
    }

    public class RequestWrapper {
        public String coi { get; set; }
        public String status { get; set; }
        public String updatedDate { get; set; }
    
        public OptionalWrapper optional { get; set; }
    
    }
    
    public class OptionalWrapper {
        public Integer numberOfBags { get; set; }
        public List<String> bag_IDs { get; set; }
    }

    public class ResponseWrapper{
        public Integer status{get;set;}
        public String message{get;set;}
    }

    public class MissingFieldException extends Exception {}
}