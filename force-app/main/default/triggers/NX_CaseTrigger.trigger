trigger NX_CaseTrigger on Case (after update) {
  /*  for (Case caseRecord : Trigger.new) {
        // Check if the Case fields of interest have changed
        if (caseRecord.Subject != Trigger.oldMap.get(caseRecord.Id).Subject ||
            caseRecord.Description != Trigger.oldMap.get(caseRecord.Id).Description) {
            // Call the method to generate and attach the PDF
            NX_AccountPDFGenerator.generateAndAttachPDF(caseRecord.Id); 
        }
    }  */
}