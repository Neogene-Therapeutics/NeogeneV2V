public class SlotBookingController {
   /*  @AuraEnabled(cacheable=false)
   public static List<SlotWrapper> getSlotsByDate(String dateStr, String recordId, String manufacturingId) {
        List<SlotWrapper> wrapperList = new List<SlotWrapper>();
        if(dateStr != null) {
            Date dt = Date.parse(dateStr);
           // Integer d = Integer.valueOf(dateStr.split('-')[2]);
          //  Integer mo = Integer.valueOf(dateStr.split('-')[1]);
           // Integer yr = Integer.valueOf(dateStr.split('-')[0]);
           // DateTime startTime = DateTime.newInstanceGmt(yr, mo, d);
          //  DateTime endTime = DateTime.newInstanceGmt(yr, mo, d, 23, 59, 59);
            List<Manufacturing_Slot__c> slots = [SELECT Id, Booking_Status__c, Courier__c, End_Date__c, Start_Date__c, Name  
                                    FROM Manufacturing_Slot__c 
                                    WHERE Start_Date__c > :dt 
                                    AND  Start_Date__c < :dt
                                    AND Manufacturing_Site__c = :manufacturingId
                                //    AND Study_Definition__c = :siteSlot.Study_Deifinition__c
                                    ORDER BY Start_Date__c];
                                    //   system.assert(false , startTime + '-----' + endTime);
            for(Manufacturing_Slot__c s : slots){
                SlotWrapper wrapper = new SlotWrapper();
                wrapper.Id = s.Id;
                wrapper.name = s.Name;
                wrapper.bookingStatus  = s.Booking_Status__c;
                wrapper.courier  = s.Courier__c;
                wrapper.startTime  = s.Start_Date__c.format();
                wrapper.endTime  = s.End_Date__c.format();
                wrapper.buttonName  = s.Booking_Status__c == 'Available' ? 'Request' : s.Booking_Status__c;
                wrapper.buttonDisabled  = s.Booking_Status__c == 'Available' ? false : true;
                wrapperList.add(wrapper);
            }  
        }      
        return wrapperList;
    } */

    @AuraEnabled(cacheable=false)
    public static List<SlotSummaryWrapper> getAvailableManufacturingSlots(String recordId) {
        //List<String> uniqueDates = new List<String>();
        List<SlotSummaryWrapper> wrapperList = new List<SlotSummaryWrapper>();
       /* Map<String , Integer> slotAvailableMap = new Map<String, Integer>();
        Map<String , Integer> slotTotalMap = new Map<String, Integer>();

        // Fetch the Site_Slot__c record to get siteId and studyProtocolNumber
        List<Patient_Journey__c> siteSlots = [SELECT Manufacturing_Site__c, Study_Protocol_Number__c 
                                                FROM Patient_Journey__c 
                                                WHERE Id = :recordId 
                                                LIMIT 1];

       
        if(!siteSlots.isEmpty())  {
            Patient_Journey__c siteSlot =  siteSlots[0];
             // Query manufacturing slots based on fetched siteId and studyProtocolNumber
            List<Site_Slot__c> manufacturingSlots = [
                SELECT Id , Start_Date__c, Booking_Status__c
                FROM Site_Slot__c
                WHERE Account = :siteSlot.Manufacturing_Site__c
                AND Study_Protocol_Number__c = :siteSlot.Study_Protocol_Number__c
            //    AND Booking_Status__c = 'Available'  // Ensure this is the correct API name for the status field
                ORDER BY Start_Date__c
            ];
            // Extract unique dates from the queried manufacturing slots
            for (Site_Slot__c slot : manufacturingSlots) {
                String dateStr = slot.Start_Date__c.format('yyyy-MM-dd');
                if (slot.Start_Date__c != null && slot.Booking_Status__c == 'Available' ) {   
                    if (slotAvailableMap.containsKey(dateStr)) {
                        Integer availableCount = slotAvailableMap.get(dateStr) + 1;
                        slotAvailableMap.put(dateStr , availableCount);
                    } else {
                        slotAvailableMap.put(dateStr , 1);
                    }
                }
                if (slotTotalMap.containsKey(dateStr)) {
                    Integer totlCount = slotTotalMap.get(dateStr) + 1;
                    slotTotalMap.put(dateStr , totlCount);
                } else {
                    slotTotalMap.put(dateStr , 1);
                }
            }
         //   system.assert(false, slotTotalMap);
            for(String key : slotTotalMap.keySet()) {
                SlotSummaryWrapper wrapper = new SlotSummaryWrapper();
                wrapper.dateStr = key;
                wrapper.totalSlots = slotTotalMap.containsKey(key) ?  slotTotalMap.get(key) + '' : '0' ;
                wrapper.availableSlots = slotAvailableMap.containsKey(key) ?  slotAvailableMap.get(key) + '' : '0' ;
                wrapperList.add(wrapper);
            }      
        } */       
        return wrapperList;                                     
    } 

    @AuraEnabled(cacheable=false)
    public static List<SlotSummaryWrapper> getAvailableSlots(String recordId) {
        //List<String> uniqueDates = new List<String>();
        List<SlotSummaryWrapper> wrapperList = new List<SlotSummaryWrapper>();
        Map<String , Boolean> slotAvailableMap = new Map<String, Boolean>();
        List<Patient_Journey__c> pjList = [SELECT Id, Study_Definition__c  FROM Patient_Journey__c WHERE Id = :recordId];
        
        if(pjList.isEmpty()){
            return null;
        }

        List<Manufacturing_Slot__c> manufacturingSlots = [
                                SELECT Id , Leukapheresis_Date__c, Booking_Status__c
                                FROM Manufacturing_Slot__c
                                WHERE Study_ID__c = :pjList[0].Study_Definition__c
                                AND Booking_Status__c = 'Available' 
                                ORDER BY Leukapheresis_Date__c
        ];

        for (Manufacturing_Slot__c slot : manufacturingSlots) {
            if (slot.Leukapheresis_Date__c != null) {   
                String dateStr = String.valueOf(slot.Leukapheresis_Date__c);
                slotAvailableMap.put(dateStr , true);
            }
        }
        for(String key : slotAvailableMap.keySet()) {
            SlotSummaryWrapper wrapper = new SlotSummaryWrapper();
            wrapper.dateStr = key;
            wrapper.isAvailable = slotAvailableMap.get(key);
            wrapperList.add(wrapper);
        }        
        return wrapperList;                                     
    }

    @AuraEnabled(cacheable=false)
    public static Boolean bookSlot(String recordId, String dateStr) {
        List<Patient_Journey__c> pjList = [SELECT Id, Study_Definition__c, Clinical_Site__c  FROM Patient_Journey__c WHERE Id = :recordId];
        
        if(pjList.isEmpty()){
            return false;
        }
       // try{
            Date dt = Date.valueOf(dateStr);
       
            List<Manufacturing_Slot__c> manufacturingSlots = [
                                SELECT Id , Start_Date__c, Booking_Status__c
                                FROM Manufacturing_Slot__c
                                WHERE Study_ID__c = :pjList[0].Study_Definition__c
                                AND Booking_Status__c = 'Available' 
                                AND Start_Date__c = :dt
                                ORDER BY Start_Date__c LIMIT 1
                            ];
            if(!manufacturingSlots.isEmpty()) {
                Manufacturing_Slot__c slot = manufacturingSlots[0];
                slot.Booking_Status__c = 'Requested';
                slot.Clinical_Site__c = pjList[0].Clinical_Site__c;
                update slot;
               updateQuestion(pjList[0], dt); // slot Booking Task - checkbox
                return true;      
            }      
            return false;
       // } catch(Exception e) {
         //   throw new AuraHandledException(e.getMessage());
       // }
    }
    public static void updateQuestion(Patient_Journey__c pj, Date dt) {
        List<Patient_Milestone_Task_Form_Question__c> patientFormQuestions = [SELECT Id, Value__c, Type__c, Read_Only__c, Patient_Milestone_Task__c FROM Patient_Milestone_Task_Form_Question__c WHERE Patient_Milestone_Task__r.Patient_Milestone__r.Patient_Journey__c =: pj.Id AND Slot_Booking_Task__c = true];
        if(!patientFormQuestions.isEmpty()) {
            for(Patient_Milestone_Task_Form_Question__c q : patientFormQuestions) {
                q.Value__c = String.valueOf(dt);
                q.Type__c = 'Date';
                q.Read_Only__c = true;
            }
            update patientFormQuestions;
        }
    }

  /*  @AuraEnabled(cacheable=false)
    public static List<ManufacturingOptionWrapper> getManufacturingSites(String recordId) {
        List<ManufacturingOptionWrapper> optionList = new List<ManufacturingOptionWrapper>();
        List<Patient_Journey__c> pjList = [SELECT Id 
                                               FROM Patient_Journey__c 
                                                WHERE Id = :recordId 
                                                LIMIT 1];

        if(!pjList.isEmpty())  {
            Patient_Journey__c pj =  pjList[0];
            List<Account> manufacturingSites = [
                SELECT Id , Name 
                FROM Account
             //   WHERE Region__c = :pm.Site__r.Region__c
             //   AND Study__c = :pm.Study_Protocol_Number__c
                WHERE RecordType.Name = 'Manufacturing Site'
            ];
          //  system.assert(false, manufacturingSites);
            for(Account s : manufacturingSites){
                ManufacturingOptionWrapper wrapper = new ManufacturingOptionWrapper();
                wrapper.label = s.Name;
                wrapper.value = s.Id;
                optionList.add(wrapper);
            }
        }

        return optionList;
        
    } */
   
  /*  public class SlotWrapper{
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String bookingStatus{get;set;}
        @AuraEnabled
        public String courier{get;set;}
        @AuraEnabled
        public String startTime{get;set;}
        @AuraEnabled
        public String endTime{get;set;}
        @AuraEnabled
        public String buttonName{get;set;}
        @AuraEnabled
        public Boolean buttonDisabled{get;set;}
    } */

    public class SlotSummaryWrapper{
        @AuraEnabled
        public String dateStr{get;set;}
        @AuraEnabled
        public Boolean isAvailable{get;set;}
    }

}