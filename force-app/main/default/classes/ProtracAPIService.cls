public with sharing class ProtracAPIService {
    public static String createShipmentRequest(Id recordId){
        ProtracRequestWrapper.APHShipmentWrapper shipAph = new ProtracRequestWrapper.APHShipmentWrapper();
        List<Shipment__c> shipmentList = [SELECT Id, Patient_Journey__r.COI__c, Tracking_ID__c FROM Shipment__c WHERE ID = :recordId LIMIT 1];
        if(!shipmentList.isEmpty()){
            Shipment__c ship = shipmentList.get(0);
            shipAph.COI = ship.Patient_Journey__r.COI__c;
            shipAph.ShipmentID = ship.Tracking_ID__c;
            shipAph.ExpectedDeliveryDate = System.today().addDays(6);
            shipAph.ExpectedPickupDate = System.today();
            return JSON.serializePretty(shipAph,true);
        }
        return null;
    }

    public static String createPatientRegistrationRequest(Id recordId){
        ProtracRequestWrapper.PatientRegistration wrapper = new ProtracRequestWrapper.PatientRegistration();
        List<Patient_Journey__c> pjList = [SELECT id, COI__c, Clinical_Site__c, Chain_of_Identity__c, Chain_of_Identity__r.CreatedDate,
                                          Clinical_Site__r.Site_ID__c, Study_Definition__c, Patient__c, Chain_of_Identity__r.COINumber__c,
                                          Study_Definition__r.Study_Protocol_Id__c, Patient__r.CreatedDate, Patient__r.Subject_ID__c
                                          FROM Patient_Journey__c
                                          WHERE ID = :recordId 
                                          LIMIT 1];

        if(!pjList.isEmpty()) {
            Patient_Journey__c pj = pjList.get(0);
            wrapper.subjectId = pj.Patient__r.Subject_ID__c;
            wrapper.registrationDate = pj.Patient__r.CreatedDate.format('yyyy-MM-dd');
            wrapper.coi = pj.Chain_of_Identity__r.COINumber__c;
            wrapper.coiGeneratedDate = pj.Chain_of_Identity__r.CreatedDate.format('yyyy-MM-dd');
            wrapper.clinicalSiteID = Integer.valueOf(pj.Clinical_Site__r.Site_ID__c);
            wrapper.studyProtocolID = Integer.valueOf(pj.Study_Definition__r.Study_Protocol_Id__c);
           // wrapper.diseasetypeID = '';
          //  wrapper.DIN = '';
            return JSON.serializePretty(wrapper,true);
        }
        return null;
    }

    public static String createDPBookingRequest(Id recordId){
        ProtracRequestWrapper.DPBookingWrapper dpBook = new ProtracRequestWrapper.DPBookingWrapper();        
        List<Shipment__c> shipmentList = [SELECT Id, Patient_Journey__r.COI__c, Tracking_ID__c FROM Shipment__c WHERE ID = :recordId LIMIT 1];
        if(!shipmentList.isEmpty()){
            Shipment__c ship = shipmentList.get(0);
            dpBook.COI = ship.Patient_Journey__r.COI__c;
            dpBook.ShipmentID = ship.Tracking_ID__c;
            dpBook.ExpectedDeliveryDate = System.today().addDays(6);
            dpBook.ExpectedPickupDate = System.today();
            return JSON.serializePretty(dpBook,true);
        }
        return null;
    }

    public static String createManufacturingStatusRequest(Id recordId){
        return null; 
    }

    public static String createDPReceiptRequest(Id recordId){
        List<Patient_Milestone_Task_Form_Question__c> formQuestions = [SELECT Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__c FROM Patient_Milestone_Task_Form_Question__c WHERE Id =: recordId];
        if(!formQuestions.isEmpty()){
            Patient_Milestone_Task_Form_Question__c ques = formQuestions.get(0);
            List<Shipment__c> shipmentList = [SELECT CreatedDate, Tracking_ID__c FROM Shipment__c WHERE Patient_Journey__c =: ques.Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__c AND Type__c = 'Drug Product'];
            if(!shipmentList.isEmpty()){
                ProtracRequestWrapper.DPReceiptWrapper dpReceipt = new ProtracRequestWrapper.DPReceiptWrapper();
                Shipment__c ship = shipmentList.get(0);
                dpReceipt.shipmentId = ship.Tracking_ID__c;
                dpReceipt.ReceiptDate = System.today();
                dpReceipt.ConditionOfShipment = 'Good';
                return JSON.serializePretty(dpReceipt,true);
            }
        }
        return null;
    }
}