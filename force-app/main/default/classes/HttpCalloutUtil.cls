public class HttpCalloutUtil {
    // Method to send a POST request
    public static HttpResponse sendPostRequest(String url, String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(60000); // Set timeout to 60 seconds
        
        Http http = new Http();
        HttpResponse response = null;
        
        try {
            response = http.send(request);
        } catch (System.CalloutException e) {
            // Handle callout exception
            System.debug('Callout error: ' + e);
        }
        
        return response;
    }
     // Method to send a POST request
    public static HttpResponse sendGetRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(60000); // Set timeout to 60 seconds
        
        Http http = new Http();
        HttpResponse response = null;
        
        try {
            response = http.send(request);
        } catch (System.CalloutException e) {
            // Handle callout exception
            System.debug('Callout error: ' + e);
        }
        
        return response;
    }
}