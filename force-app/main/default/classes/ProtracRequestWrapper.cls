public with sharing class ProtracRequestWrapper {
    public class PatientRegistration {
        public String subjectId { get; set; }
        public String registrationDate { get; set; }
        public String coi { get; set; }
        public String coiGeneratedDate { get; set; }
        public Integer clinicalSiteID { get; set; }
        public Integer studyProtocolID { get; set; }
        public String diseasetypeID { get; set; }
        public String DIN { get; set; }
    }

    public class APHShipmentWrapper {
        public String ShipmentID { get; set; }
        public String COI { get; set; }
        public Date ExpectedPickupDate { get; set; }
        public Date ExpectedDeliveryDate { get; set; }
    }
    public class DPBookingWrapper {
        public String ShipmentID { get; set; }
        public String COI { get; set; }
        public Date ExpectedPickupDate { get; set; }
        public Date ExpectedDeliveryDate { get; set; }
    }
    public class DPReceiptWrapper {
        public String shipmentId { get; set; }
        public Date ReceiptDate { get; set; }
        public String ConditionOfShipment { get; set; }
    }
}