public without sharing class NexusUtility {
    
    @InvocableMethod(label='Fetch User PIN' description='Fetches user PIN')
    public static List<String> fetchPIN(){
        
    
        List<User> userdata = [SELECT Id , E_Sign_PIN__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        if(!userData.isEmpty() ) {
            return new List<String>{userdata[0].E_Sign_PIN__c};
        }
        else {
            return null;
        }
    }
    
    
    public class UserRequest{    
        @InvocableVariable
        public String pin;
    }
}