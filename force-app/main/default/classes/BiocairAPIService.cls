public with sharing class BiocairAPIService {

    public static String generateShipmentJson(String recordId) {
        try {
            Shipment__c ship = [SELECT Id, Patient_Journey__r.Patient__c, Patient_Journey__r.Study_Definition__c, 
                                       Patient_Journey__r.Clinical_Site__r.Person_to_contact__c, 
                                       Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Person_to_contact__c, 
                                       Patient_Journey__r.Clinical_Site__r.Study__c, 
                                       Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Name, 
                                       CreatedDate, Dropoff_Address__CountryCode__s, Dropoff_Address__StateCode__s, 
                                       Dropoff_Address__PostalCode__s, Dropoff_Address__City__s, Dropoff_Address__Street__s, 
                                       Pickup_Address__CountryCode__s, Pickup_Address__StateCode__s, Pickup_Address__City__s, 
                                       Pickup_Address__PostalCode__s, Pickup_Address__Street__s 
                                FROM Shipment__c 
                                WHERE Id = :recordId 
                                LIMIT 1];
            if (ship != null) {
                Manufacturing_Slot__c manuSite = [SELECT Manufacturing_Site__r.Name, Manufacturing_Site__r.Person_to_contact__c 
                                                  FROM Manufacturing_Slot__c 
                                                  WHERE Study_ID__c = :ship.Patient_Journey__r.Study_Definition__c 
                                                  AND Booking_Status__c = 'Booked' 
                                                  AND Clinical_Site__c = :ship.Patient_Journey__r.Clinical_Site__r.Id 
                                                  AND Patient__c = :ship.Patient_Journey__r.Patient__c 
                                                  LIMIT 1];
                List<Shipment_Container_Detail__c> shipmentContainers = [SELECT Id, Commodity_Library_Id__c, Temperature_Id__c, 
                                                                               Package_Quantity__c, Package_Type_Id__c, 
                                                                               Weight_Unit_Of_Measure_Id__c, Weight__c, 
                                                                               Type_Of_Goods__c 
                                                                        FROM Shipment_Container_Detail__c 
                                                                        WHERE Study_Protocol__c = :ship.Patient_Journey__r.Clinical_Site__r.Study__c];

                ShipmentRequestWrapper sw = new ShipmentRequestWrapper();
                sw.OrderDate = ship.CreatedDate;
                sw.FirstName = getFirstName(ship.Patient_Journey__r.Clinical_Site__r.Person_to_contact__c);
                sw.FamilyName = getLastName(ship.Patient_Journey__r.Clinical_Site__r.Person_to_contact__c);
                sw.consignor = new ShipmentRequestWrapper.Consignor();
                sw.consignor.firstName = getFirstName(ship.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Person_to_contact__c);
                sw.consignor.familyName = getLastName(ship.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Person_to_contact__c);
                sw.consignor.address = setAddress(ship.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Name,
                                                  ship.Pickup_Address__Street__s, ship.Pickup_Address__City__s, 
                                                  ship.Pickup_Address__PostalCode__s, ship.Pickup_Address__CountryCode__s, 
                                                  ship.Pickup_Address__StateCode__s);
                
                sw.consignee = new ShipmentRequestWrapper.Consignee();
                sw.consignee.firstName = getFirstName(manuSite.Manufacturing_Site__r.Person_to_contact__c);
                sw.consignee.familyName = getLastName(manuSite.Manufacturing_Site__r.Person_to_contact__c);
                sw.consignee.address = setAddress(manuSite.Manufacturing_Site__r.Name,
                                                  ship.Dropoff_Address__Street__s, ship.Dropoff_Address__City__s, 
                                                  ship.Dropoff_Address__PostalCode__s, ship.Dropoff_Address__CountryCode__s, 
                                                  ship.Dropoff_Address__StateCode__s);
                
                sw.goodItems = new List<ShipmentRequestWrapper.GoodItem>();
                for (Shipment_Container_Detail__c sc : shipmentContainers) {
                    ShipmentRequestWrapper.GoodItem good = new ShipmentRequestWrapper.GoodItem();
                    good.commodityLibraryId = (Integer) sc.Commodity_Library_Id__c;
                    good.packageQuantity = (Integer) sc.Package_Quantity__c;
                    good.packageTypeId = (Integer) sc.Package_Type_Id__c;
                    good.temperatureId = (Integer) sc.Temperature_Id__c;
                    good.weight = (Integer) sc.Weight__c;
                    good.weightunitofmeasureId = (Integer) sc.Weight_Unit_Of_Measure_Id__c;
                    good.typeofgoods = sc.Type_Of_Goods__c;
                    sw.goodItems.add(good);
                }
                return JSON.serializePretty(sw, true);
            }

            return null;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    private static String getFirstName(String fullName) {
        if (String.isNotBlank(fullName)) {
            List<String> nameParts = fullName.split(' ');
            return nameParts.size() > 0 ? nameParts[0] : null;
        }
        return null;
    }
    private static String getLastName(String fullName) {
        if (String.isNotBlank(fullName)) {
            List<String> nameParts = fullName.split(' ');
            return nameParts.size() > 1 ? nameParts[nameParts.size() - 1] : null;
        }
        return null;
    }
    private static ShipmentRequestWrapper.Address setAddress(String name, String street, String city, 
                                                             String postalCode, String countryCode, String stateCode) {
        ShipmentRequestWrapper.Address address = new ShipmentRequestWrapper.Address();
        address.name = name;
        address.address1 = street;
        address.townCity = city;
        address.postcode = postalCode;
        address.countryCode = countryCode;
        address.state = stateCode;
        return address;
    }
}