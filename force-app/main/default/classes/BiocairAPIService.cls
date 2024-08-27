public with sharing class BiocairAPIService {
    public static String generateShipmentJson(String recordId) {
        List<Shipment__c> shipList = [SELECT Id, Patient_Milestone__r.Patient_Journey__r.Study_Definition__c, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Person_to_contact__c, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Person_to_contact__c, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Cell_Therapy_Lab__r.Person_to_contact__c, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Study__c, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Name, Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Cell_Therapy_Lab__r.Name, CreatedDate, Dropoff_Address__CountryCode__s, Dropoff_Address__StateCode__s, Dropoff_Address__PostalCode__s, Dropoff_Address__City__s, Dropoff_Address__Street__s, Pickup_Address__CountryCode__s, Pickup_Address__StateCode__s, Pickup_Address__City__s, Pickup_Address__PostalCode__s, Pickup_Address__Street__s FROM Shipment__c WHERE Id =: recordId];
        if(!shipList.isEmpty()){
            Shipment__c ship = shipList[0];

            Manufacturing_Slot__c manuSite = [SELECT Manufacturing_Site__r.Name, Manufacturing_Site__r.Person_to_contact__c FROM Manufacturing_Slot__c Where Study_ID__c =: ship.Patient_Milestone__r.Patient_Journey__r.Study_Definition__c AND Booking_Status__c = 'Booked' AND Clinical_Site__c =: ship.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Id LIMIT 1];

            List<Shipment_Container_Detail__c> shipmentContainer = [SELECT Id, Commodity_Library_Id__c, Temperature_Id__c, Package_Quantity__c, Package_Type_Id__c, Weight_Unit_Of_Measure_Id__c, Weight__c, Type_Of_Goods__c, Order_Id__c FROM Shipment_Container_Detail__c WHERE Study_Protocol__c =: ship.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Study__c];
            ShipmentRequestWrapper sw = new ShipmentRequestWrapper();
            sw.OrderDate = ship.CreatedDate;
            String fullName = ship.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Person_to_contact__c;
            if (String.isNotBlank(fullName)) {
                List<String> nameParts = fullName.split(' ');
                if (nameParts.size() > 0) {
                    sw.FirstName = nameParts[0];
                    sw.FamilyName = nameParts[nameParts.size() - 1];
                }
            }
            sw.consignor = new ShipmentRequestWrapper.Consignor();
            fullName = ship.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Person_to_contact__c;
            if (String.isNotBlank(fullName)) {
                List<String> nameParts = fullName.split(' ');
                if (nameParts.size() > 0) {
                    sw.consignor.firstName = nameParts[0];
                    sw.consignor.familyName = nameParts[nameParts.size() - 1];
                }
            }
            sw.consignor.address = new ShipmentRequestWrapper.Address();
            sw.consignor.address.name = ship.Patient_Milestone__r.Patient_Journey__r.Clinical_Site__r.Apheresis_center__r.Name;
            sw.consignor.address.address1 = ship.Pickup_Address__Street__s;
            sw.consignor.address.townCity = ship.Pickup_Address__City__s;
            sw.consignor.address.postcode = ship.Pickup_Address__PostalCode__s;
            sw.consignor.address.countryCode = ship.Pickup_Address__CountryCode__s;
            sw.consignor.address.state = ship.Pickup_Address__StateCode__s;
    
            sw.consignee = new ShipmentRequestWrapper.Consignee();
            fullName = manuSite.Manufacturing_Site__r.Person_to_contact__c;
            if (String.isNotBlank(fullName)) {
                List<String> nameParts = fullName.split(' ');
                if (nameParts.size() > 0) {
                    sw.consignee.firstName = nameParts[0];
                    sw.consignee.familyName = nameParts[nameParts.size() - 1];
                }
            }
            sw.consignee.address = new ShipmentRequestWrapper.Address();
            sw.consignee.address.name = manuSite.Manufacturing_Site__r.Name;
            sw.consignee.address.address1 = ship.Dropoff_Address__Street__s;
            sw.consignee.address.townCity = ship.Dropoff_Address__City__s;
            sw.consignee.address.postcode = ship.Dropoff_Address__PostalCode__s;
            sw.consignee.address.countryCode = ship.Dropoff_Address__CountryCode__s;
            sw.consignee.address.state = ship.Dropoff_Address__StateCode__s;
    
            sw.goodItems = new List<ShipmentRequestWrapper.GoodItem>();
            if(shipmentContainer.size() > 0){
                for(Shipment_Container_Detail__c sc : shipmentContainer){
                    ShipmentRequestWrapper.GoodItem good = new ShipmentRequestWrapper.GoodItem();
                    good.commodityLibraryId = (Integer)sc.Commodity_Library_Id__c;
                    good.packageQuantity = (Integer)sc.Package_Quantity__c;
                    good.packageTypeId = (Integer)sc.Package_Type_Id__c;
                    good.temperatureId = (Integer)sc.Temperature_Id__c;
                    good.weight = (Integer)sc.Weight__c;
                    good.weightunitofmeasureId = (Integer)sc.Weight_Unit_Of_Measure_Id__c;
                    good.typeofgoods = sc.Type_Of_Goods__c;
                    sw.goodItems.add(good);
                }
            }
            return JSON.serializePretty(sw, true);
        }
        return null;
    }
}