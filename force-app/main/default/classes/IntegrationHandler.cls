public with sharing class IntegrationHandler implements Queueable, Database.AllowsCallouts {

    private static final String CONTENT_TYPE_JSON = 'application/json';
    private static final Integer TIMEOUT = 40000;

    private String apiName;
    private String category;
    private String recordId;

    public IntegrationHandler(String apiName, String category, String recordId) {
        this.apiName = apiName;
        this.category = category;
        this.recordId = recordId;
    }

    public void execute(QueueableContext context) {
        String requestBody = generateRequestBody(apiName, recordId);  
        switch on category {
            when 'PROTRAC' {
                List<Protrac_API_Details__mdt> apiDetails = [SELECT Access_Token__c, Endpoint__c, Method__c, Id, DeveloperName FROM Protrac_API_Details__mdt WHERE DeveloperName =:apiName];
                System.debug(apiDetails[0]);
                makeHttpCallout(apiDetails[0].Endpoint__c, apiDetails[0].Method__c, requestBody, apiDetails[0].Access_Token__c, null,null,recordId, apiName);
            }
            when 'QUICKSTAT' {
                QuickStat_API_Details__mdt apiDetails = QuickStat_API_Details__mdt.getInstance(apiName);
                makeHttpCallout(apiDetails.Endpoint__c, apiDetails.Method__c, requestBody,null,null,null, recordId, apiName);
            }       
            when 'BIOCAIR' {
                BioCair_API_Details__mdt apiDetails = BioCair_API_Details__mdt.getInstance(apiName);
                makeHttpCallout(apiDetails.Endpoint__c, apiDetails.Method__c, requestBody,null, apiDetails.IntegrationKey__c, apiDetails.Biocair_Subscription_Key__c, recordId, apiName);
            }
        }
    }

    public static String generateRequestBody(String apiName, String recordId){
        String requestBody = '';
        switch on apiName {
            when 'Protrac_Site' {          
                requestBody = ProtracAPIService.createSite(recordId); 
            }
            when 'Protrac_Study' {          
                requestBody = ProtracAPIService.createStudy(recordId); 
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

    private void makeHttpCallout(String endpoint, String method, String requestBody, String accessToken, String integrationKey, String subscriptionKey, String recordId, String apiName) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(method);
            request.setHeader('Content-Type', CONTENT_TYPE_JSON);
            request.setTimeout(TIMEOUT);
            request.setBody(requestBody);
            if (accessToken != null) {
                request.setHeader('Authorization', 'Bearer ' + accessToken);
            }
            if (integrationKey != null) {
                request.setHeader('IntegrationKey', integrationKey);
            }
            if (subscriptionKey != null) {
                request.setHeader('Biocair-Subscription-Key', subscriptionKey);
            }
            Http http = new Http();
            HttpResponse response = http.send(request);
            handleIntegrationLogs(response, requestBody, recordId, apiName);
            if (category == 'BIOCAIR' && response.getStatusCode() == 201) {
                processBiocairResponse(response.getBody(), recordId);
            }
        } catch (Exception ex) {
            System.debug('HTTP Callout error: ' + ex.getMessage());
        }
    }

    private void processBiocairResponse(String responseBody, String recordId) {
        try {
            Map<String, Object> deserializedData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> responseData = (Map<String, Object>) deserializedData.get('responseData');
            List<Object> shipments = (List<Object>) responseData.get('shipments');
            if (!shipments.isEmpty()) {
                Map<String, Object> shipment = (Map<String, Object>) shipments[0];
                String trackingNumber = (String) shipment.get('trackingNumber');
                Double orderId = (Double) shipment.get('orderId');

                Shipment__c ship = new Shipment__c(Id = recordId, Current_Status__c = 'Customer Booking Received', Tracking_ID__c = trackingNumber, Order_Id__c = orderId);
                update ship;
            }
        } catch (Exception ex) {
            System.debug('Error processing BioCair response: ' + ex.getMessage());
        }
    }

    // public void makeProtracCallout(String endpoint, String method, String requestBody, String accessToken, String recordId, String apiName) {
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(endpoint);
    //     request.setMethod(method);
    //     request.setHeader('Content-Type', 'application/json'); 
    //     request.setTimeout(40000);
    //     request.setBody(requestBody);
    //     System.debug('accessToken=>'+accessToken);
    //     request.setHeader('Authorization', 'Bearer '+ accessToken);
    //     Http http = new Http();
    //     HttpResponse response = http.send(request);
    //     handleIntegrationLogs(response, requestBody, recordId, apiName);
    // }
    
    // public HttpResponse makeQuickStatCallout(String endpoint, String method, String requestBody, String recordId, String apiName){
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(endpoint);
    //     request.setMethod(method);
    //     request.setHeader('Content-Type', 'application/json'); 
    //     request.setTimeout(40000);
    //     request.setBody(requestBody);
    //     Http http = new Http();
    //     HttpResponse response = http.send(request);
    //     handleIntegrationLogs(response, requestBody, recordId, apiName);
    //     return response;
    // }

    // public void makeBiocareCallout(String endpoint, String method, String requestBody, String integrationKey, String subscriptionKey, String recordId, String apiName){
    //     HttpRequest request = new HttpRequest();
    //     System.debug(requestBody);
    //     request.setEndpoint(endpoint);
    //     request.setMethod(method);
    //     request.setHeader('Biocair-Subscription-Key', subscriptionKey);
    //     request.setHeader('IntegrationKey', integrationKey);
    //     request.setHeader('Content-Type', 'application/json'); 
    //     request.setTimeout(40000);
    //     request.setBody(requestBody);
    //     Http http = new Http();
    //     HttpResponse response = http.send(request);
    //     String responseBody = response.getBody();
    //     handleIntegrationLogs(response, requestBody, recordId, apiName);
    //     if(response.getStatusCode() == 201){
    //         Map<String, Object> deserializedData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    //         Map<String, Object> responseData = (Map<String, Object>) deserializedData.get('responseData');
    //         List<Object> shipments = (List<Object>) responseData.get('shipments');
    //         Map<String, Object> shipment = (Map<String, Object>) shipments[0];
    //         String trackingNumber = (String) shipment.get('trackingNumber');
    //         Double orderId = (Double) shipment.get('orderId');
    //         Shipment__c ship = new Shipment__c();
    //         ship.Id = recordId;
    //         ship.Current_Status__c = 'Customer Booking Received';
    //         ship.Tracking_ID__c = trackingNumber;
    //         ship.Order_Id__c = orderId;
    //         update ship;
    //     }
    // }

    public void handleIntegrationLogs(HttpResponse response, String requestBody, String recordId, String apiName) {
        try {
            Integration_Log__c log = new Integration_Log__c(
                Status_Code__c = response.getStatusCode(),
                Response_Body__c = response.getBody(),
                Request_Body__c = requestBody,
                Record_Id__c = recordId,
                API_Name__c = apiName
            );
            insert log;
        } catch (DmlException dmlEx) {
            throw new AuraHandledException(dmlEx.getMessage());
        }
    }
}