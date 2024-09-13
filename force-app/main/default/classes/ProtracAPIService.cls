public with sharing class ProtracAPIService {
    public static String createShipmentRequest(Id recordId){
        // List<Shipment__c> shipmentList = [SELECT Id,Name, Patient_Journey__r.COI__c,Courier__c,Dropoff_Address__StateCode__s, Tracking_ID__c FROM Shipment__c WHERE ID = :recordId LIMIT 1];
        // if(!shipmentList.isEmpty()){
        //     ProtracRequestWrapper.APHShipmentWrapper shipAph = new ProtracRequestWrapper.APHShipmentWrapper();
        //     Shipment__c ship = shipmentList.get(0);
        //     shipAph.COI = ship.Patient_Journey__r.COI__c;
        //     shipAph.ShipmentID = ship.Name;
        //     shipAph.TrackingID = ship.Tracking_ID__c;
        //     shipAph.ShipmentVendor = ship.Courier__c;
        //     shipAph.ShippingAddress = ship.Dropoff_Address__StateCode__s;
        //     shipAph.ExpectedArrivalDate = System.today().addDays(10);
        //     return JSON.serializePretty(shipAph,true);
        // }
        return null;
    }

    public static String createStudy(Id recordId){
        List<Study_Protocol__c> protocolList = [SELECT Display_Name__c, Study_Protocol_Description__c FROM Study_Protocol__c WHERE Id =: recordId];
        if(!protocolList.isEmpty()){
            ProtracRequestWrapper.StudyWrapper wrapper = new ProtracRequestWrapper.StudyWrapper();
            wrapper.StudyProtocolNumber = protocolList[0].Display_Name__c;
            wrapper.StudyProtocolNumberDescription = protocolList[0].Study_Protocol_Description__c;
            return JSON.serialize(wrapper);
        }
        return null;
    }
    public static String createSite(Id recordId){
        List<Account> accountList = [SELECT RecordTypeId, Name, Site_ID__c FROM Account WHERE Id =: recordId];
        if(!accountList.isEmpty()){
            ProtracRequestWrapper.SiteWrapper wrapper = new ProtracRequestWrapper.SiteWrapper();
            wrapper.SiteCode = accountList[0].Site_ID__c;
            if(accountList[0].RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Clinical Site').getRecordTypeId()){
                wrapper.SiteTypeID = 1;
            }else if(accountList[0].RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Manufacturing Site').getRecordTypeId()){
                wrapper.SiteTypeID = 2;
            }
            wrapper.SiteName = accountList[0].Name;
            return JSON.serialize(wrapper);
        }
        return null;
    }
    public static String createPatientRegistrationRequest(Id recordId){
        ProtracRequestWrapper.PatientRegistration wrapper = new ProtracRequestWrapper.PatientRegistration();
        List<Shipment__c> shipList = [SELECT Id, Patient_Journey__r.Study_Definition__r.Name ,Patient_Journey__r.Clinical_Site__r.Site_ID__c, Patient_Journey__r.Patient__r.Year_of_Birth__c, Patient_Journey__r.COI__c, Courier__c, Order_Id__c, Patient_Journey__r.Patient__r.Subject_ID__c, Dropoff_Address__StateCode__s, Tracking_ID__c FROM Shipment__c WHERE ID = :recordId LIMIT 1];
        if(!shipList.isEmpty()) {
            Shipment__c ship = shipList.get(0);
            List<Patient_Milestone_Task_Form_Question__c> formSubjectQuestions = [SELECT Value__c, Is_Subject__c FROM Patient_Milestone_Task_Form_Question__c WHERE Is_Subject__c = true AND Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__c =:ship.Patient_Journey__r.Id];

            List<Patient_Milestone_Task_Form_Question__c> formDinQuestions = [SELECT Value__c, Is_DIN__c FROM Patient_Milestone_Task_Form_Question__c WHERE Is_DIN__c = true AND Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__c =:ship.Patient_Journey__r.Id];

            wrapper.subjectId = !formSubjectQuestions.isEmpty()?formSubjectQuestions.get(0).Value__c:null;
            wrapper.coi = ship.Patient_Journey__r.COI__c;
            // wrapper.DIN = Integer.valueOf(!formDinQuestions.isEmpty()?formDinQuestions.get(0).Value__c:null);
            wrapper.YOB = ship.Patient_Journey__r.Patient__r.Year_of_Birth__c;
            wrapper.MFGSiteID = '';
            wrapper.ClinicalSiteID = ship.Patient_Journey__r.Clinical_Site__r.Site_ID__c;
            wrapper.studyProtocolName = ship.Patient_Journey__r.Study_Definition__r.Name;
            wrapper.shipmentId = ship.Tracking_ID__c;
            wrapper.orderId = Integer.valueOf(ship.Order_Id__c);
            wrapper.ExpectedShipmentDate = System.today();
            wrapper.ExpectedArrivalDate = System.today().addDays(8);
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