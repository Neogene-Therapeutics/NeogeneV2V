/**
 * @description       : 
 * @author            : Rishab Chouhdary
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class UserProfileController {
    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        // Fetch current user's name and profile
        return [
            SELECT Name, UserRole.Name
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }
}