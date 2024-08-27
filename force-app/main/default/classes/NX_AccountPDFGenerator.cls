public class NX_AccountPDFGenerator {
    @AuraEnabled //@future(callout=true)
    public static void generateAndAttachPDF(Id accountId) {
        // Query the Account record
        // Account accRecord = [SELECT Id,Name,City__c,Country__c,AccountNumber,Apheresis_Center_Name__c FROM Account WHERE Id = :accountId];
        Account accRecord = [SELECT Id,Name,AccountNumber FROM Account WHERE Id = :accountId];

        // Generate PDF from Visualforce page
        PageReference pdfPage = Page.AccountPDFTemplate; 
        pdfPage.getParameters().put('id', accountId);
        Blob pdfBlob = pdfPage.getContentAsPDF();

        // Create a ContentVersion (File) record
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Account Details ' + accRecord.Name;
        cv.PathOnClient = 'AccountDetails.pdf';
        cv.VersionData = pdfBlob;
        cv.FirstPublishLocationId = accountId; // Attach to the Account record
        insert cv;
    }
}