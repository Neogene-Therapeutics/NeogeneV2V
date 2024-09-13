public class COI {
    @InvocableMethod(label='Generate Unique COI Number' description='Generate a unique COI number following the pattern "number, alpha, num, alpha, num"')
    public static List<String> generateUniqueCOINumber() {
        String newCOINumber;
        Boolean unique = false;
        while (!unique) {
            newCOINumber = generateRandomCOINumber();
            Integer countExisting = [SELECT COUNT() FROM Chain_of_Identity__c WHERE COINumber__c = :newCOINumber];
            
            if (countExisting == 0) {
                unique = true;
            }
        }
        return new List<String>{newCOINumber};
    }

    private static String generateRandomCOINumber() {
        String numPart1 = String.valueOf(Integer.valueOf(Math.floor(Math.random() * 10)));
        String alphaPart1 = getRandomAlpha();
        String numPart2 = String.valueOf(Integer.valueOf(Math.floor(Math.random() * 10))); 
        String alphaPart2 = getRandomAlpha(); 
        String numPart3 = String.valueOf(Integer.valueOf(Math.floor(Math.random() * 10))); 
        return numPart1 + alphaPart1 + numPart2 + alphaPart2 + numPart3 + '';
    }

    private static String getRandomAlpha() {
        String alphabets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer index = (Integer) Math.floor(Math.random() * alphabets.length());
        return alphabets.substring(index, index + 1);
    }
}