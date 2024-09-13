public with sharing class ProtracRequestWrapper {
    public class PatientRegistration {
        public String subjectId { get; set; }
        public String coi { get; set; }
        public Integer DIN { get; set; }
        public String YOB { get; set; }
        public String MFGSiteID { get; set; }
        public String ClinicalSiteID { get; set; }
        public String studyProtocolName { get; set; }
        public String shipmentId { get; set; }
        public Integer orderId { get; set; }
        public Date ExpectedShipmentDate { get; set; }
        public Date ExpectedArrivalDate { get; set; }
    }

    public class StudyWrapper {
        public String StudyProtocolNumber { get; set; }
        public String StudyProtocolNumberDescription { get; set; }
    }

    public class SiteWrapper {
        public String SiteCode { get; set; }
        public String SiteName { get; set; }
        public Integer SiteTypeID { get; set; }
    }

    public class DPBookingWrapper {
        public String ShipmentID { get; set; }
        public String COI { get; set; }
        public Date ExpectedPickupDate { get; set; }
        public Date ExpectedDeliveryDate { get; set; }
    }
    public class DPReceiptWrapper {
        public String ShipmentID { get; set; }
        public Date ReceiptDate { get; set; }
        public String ConditionOfShipment { get; set; }
    }
}