public class ShipmentRequestWrapper {
    public DateTime OrderDate { get; set; }
    public String FirstName { get; set; }
    public String FamilyName { get; set; }
    public String ContactNumber { get; set; }
    public String ContactEmail { get; set; }
    public String ShipmentStatus { get; set; }
    public String purchaseOrderNumber { get; set; }
    public String costCentre { get; set; }
    public String shipmentReference { get; set; }
    public String studyReference { get; set; }
    public Integer gxpShipment { get; set; }
    public Consignor consignor { get; set; }
    public Consignee consignee { get; set; }
    public List<GoodItem> goodItems { get; set; }
    public Notes notes { get; set; }

    public class Address {
        public String name { get; set; }
        public String address1 { get; set; }
        public String address2 { get; set; }
        public String townCity { get; set; }
        public String state { get; set; }
        public String postcode { get; set; }
        public String countryCode { get; set; }
        public String department { get; set; }
        public String building { get; set; }
    }

    public class Consignor {
        public String firstName { get; set; }
        public String familyName { get; set; }
        public Address address { get; set; }
        public DateTime collectionWindowStart { get; set; }
        public DateTime collectionWindowEnd { get; set; }
    }

    public class Consignee {
        public String firstName { get; set; }
        public String familyName { get; set; }
        public Address address { get; set; }
        public DateTime deliveryWindowStart { get; set; }
        public DateTime deliveryWindowEnd { get; set; }
    }

    public class GoodItem {
        public String typeofgoods { get; set; }
        public Decimal weight { get; set; }
        public Integer weightunitofmeasureId { get; set; }
        public Integer packageTypeId { get; set; }
        public Integer packageQuantity { get; set; }
        public Integer temperatureId { get; set; }
        public Integer commodityLibraryId { get; set; }
    }

    public class Notes {
        public String DangerousGoodsNotes { get; set; }
        public String AdditionalNotes { get; set; }
    }
}