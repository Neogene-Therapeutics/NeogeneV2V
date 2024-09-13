/**
 * @description       : 
 * @author            : Rishab
 * @group             : 
 * @last modified on  : 09-13-2024
**/
public without sharing class PatientController {
    @AuraEnabled(cacheable=true)
    public static List<Patient_Registration__c> getPatientsByProtocol(Id protocolId) {
        return [
            SELECT Id, Name, Subject_ID__c,Year_of_Birth__c,Status__c
            FROM Patient_Registration__c
            WHERE Study_Protocol__c = :protocolId
        ];
    }
}