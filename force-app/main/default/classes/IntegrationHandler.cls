public with sharing class IntegrationHandler implements Queueable, Database.AllowsCallouts {

    private String apiName;
    private String category;
    private String recordId;

    public IntegrationHandler(String apiName, String category, String recordId) {
        this.apiName = apiName;
        this.category = category;
        this.recordId = recordId;
    }

    public void execute(QueueableContext context) {
        switch on category {
            when 'PROTRAC' {
                Protrac_API_Details__mdt apiDetails = Protrac_API_Details__mdt.getInstance(apiName);
                String requestBody = generateRequestBody(apiName, recordId);  
                makeProtracCallout(apiDetails.Endpoint__c, apiDetails.Method__c, requestBody, apiDetails.Access_Token__c, recordId, apiName);
            }
            when 'QUICKSTAT' {
                QuickStat_API_Details__mdt apiDetails = QuickStat_API_Details__mdt.getInstance(apiName);
                String requestBody = generateRequestBody(apiName, recordId);  
                makeQuickStatCallout(apiDetails.Endpoint__c, apiDetails.Method__c, requestBody, recordId, apiName);
            }       
            when 'BIOCAIR' {
                BioCair_API_Details__mdt apiDetails = BioCair_API_Details__mdt.getInstance(apiName);
                String requestBody = generateRequestBody(apiName, recordId);
                makeBiocareCallout(apiDetails.Endpoint__c, apiDetails.Method__c, requestBody, apiDetails.IntegrationKey__c, apiDetails.Biocair_Subscription_Key__c, recordId, apiName);
            }
        }
    }

    public static String generateRequestBody(String apiName, String recordId){
        String requestBody = '';
        switch on apiName {
            when 'Protrac_APH_Shipment' {          
                requestBody = ProtracAPIService.createShipmentRequest(recordId); 
            }
            when 'Protrac_DP_Booking' {        
                requestBody = ProtracAPIService.createDPBookingRequest(recordId);    
            }    
            when 'Protrac_DP_Receipt' {          
                requestBody = ProtracAPIService.createDPReceiptRequest(recordId);    
            }       
            when 'Protrac_Manufacturing_Status' {          
                requestBody = ProtracAPIService.createManufacturingStatusRequest(recordId);   
            }       
            when 'Protrac_Patient_Registration' {         
                requestBody = ProtracAPIService.createPatientRegistrationRequest(recordId); 
            }       
            when 'CREATE_SHIPMENT' {         
                requestBody = BiocairAPIService.generateShipmentJson(recordId);      
            }       
            when 'QuickStat_Create_Shipment' {          
               // requestBody = ProtracAPIService.createShipmentRequest(apiName); 
            }       
        }     
        
        return requestBody;
    }

    public void makeProtracCallout(String endpoint, String method, String requestBody, String accessToken, String recordId, String apiName) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(40000);
        request.setBody(requestBody);
        request.setHeader('Authorization', 'Bearer '+ accessToken);
        Http http = new Http();
        HttpResponse response = http.send(request);
        handleIntegrationLogs(response, requestBody, recordId, apiName);
    }
    
    public HttpResponse makeQuickStatCallout(String endpoint, String method, String requestBody, String recordId, String apiName){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(40000);
        request.setBody(requestBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        handleIntegrationLogs(response, requestBody, recordId, apiName);
        return response;
    }

    public void makeBiocareCallout(String endpoint, String method, String requestBody, String integrationKey, String subscriptionKey, String recordId, String apiName){
        HttpRequest request = new HttpRequest();
        System.debug(requestBody);
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Biocair-Subscription-Key', subscriptionKey);
        request.setHeader('IntegrationKey', integrationKey);
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(40000);
        request.setBody(requestBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        handleIntegrationLogs(response, requestBody, recordId, apiName);
        if(response.getStatusCode() == 201){
            Map<String, Object> deserializedData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> responseData = (Map<String, Object>) deserializedData.get('responseData');
            List<Object> shipments = (List<Object>) responseData.get('shipments');
            Map<String, Object> shipment = (Map<String, Object>) shipments[0];
            String trackingNumber = (String) shipment.get('trackingNumber');
            Double orderId = (Double) shipment.get('orderId');
            Shipment__c ship = new Shipment__c();
            ship.Id = recordId;
            ship.Tracking_ID__c = trackingNumber;
            ship.Order_Id__c = orderId;
            update ship;
        }
    }

    public void handleIntegrationLogs(HttpResponse response, String requestBody, String recordId, String apiName){
        Integration_Log__c handle = new Integration_Log__c();
        handle.Status_Code__c = response.getStatusCode();
        handle.Response_Body__c = response.getBody();
        handle.Request_Body__c = requestBody;
        handle.Record_Id__c = recordId;
        handle.API_Name__c = apiName;
        insert handle;
    }
}