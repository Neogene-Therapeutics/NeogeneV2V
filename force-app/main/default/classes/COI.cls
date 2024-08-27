public class COI {
    
    // Public method to generate a unique 3-digit number
    @InvocableMethod(label='Generate COI' description='Return Unique COI Number')
    public static List<String> generateUniqueThreeDigitNumber() {
        Set<String> existingNumbers = new Set<String>();

        // Query existing records to ensure uniqueness of the last 3 digits
        for (Chain_of_Identity__c coi : [SELECT COINumber__c FROM Chain_of_Identity__c WHERE COINumber__c != null]) {
            String lastThreeDigits = coi.COINumber__c.length() >= 3 
                                    ? coi.COINumber__c.substring(coi.COINumber__c.length() - 3) 
                                    : null;
            if (lastThreeDigits != null) {
                existingNumbers.add(lastThreeDigits);
            }
        }

        
        String newNumber;
        Boolean unique = false;
        
        while (!unique) {
            newNumber = generateRandomThreeDigitNumber(); // Generate a random 3-digit number
            if (!existingNumbers.contains(newNumber)) {
                unique = true;
            }
        }

        return new List<String>{newNumber};
    }
    // Private method to generate a random 3-digit number
    private static String generateRandomThreeDigitNumber() {
        Integer randomNumber = Math.round(Math.random() * 899) + 100; // Generates a number between 100 and 999
        return String.valueOf(randomNumber);
    }
}