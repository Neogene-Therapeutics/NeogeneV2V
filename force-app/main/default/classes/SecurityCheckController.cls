/**
* Class Name        : SecurityCheckController
* Developer         : Adil Aleem          
* Created Date      : 
* @description      : It is used to check permissions for objects and fields.
* Last Modified Date: 
*/
public with sharing class SecurityCheckController {
    /**
    * @description To insert records.
    * @param list of sobject.
    * @return  
    */
    public static List<Database.SaveResult> doInsert(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        if (UserAccessUtility.createCheck(records)) {
            return Database.insert(records,  AccessLevel.USER_MODE);
        } else {
            return new List<Database.SaveResult>();
        }
    }

    /**
    * @description To update records.
    * @param list of sobject.
    * @return  
    */
    public static List<Database.SaveResult> doUpdate(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        if (UserAccessUtility.editCheck(records)) {
            return Database.update(records,  AccessLevel.USER_MODE);
        } else {
            return new List<Database.SaveResult>();
        }
    }

    /**
    * @description To upsert records.
    * @param list of sobject.
    * @return  
    */
    public static List<Database.UpsertResult> doUpsert(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.UpsertResult>();
        }
        if (UserAccessUtility.editCheck(records) && UserAccessUtility.createCheck(records)) {
            return Database.upsert(records,  AccessLevel.USER_MODE);
        } else {
            return new List<Database.UpsertResult>();
        }
    }

    /**
    * @description To delete records.
    * @param list of sobject.
    * @return  
    */
    public static List<Database.DeleteResult> doDelete(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.DeleteResult>();
        }else if (UserAccessUtility.deleteCheck(records)) {
            return Database.delete(records, AccessLevel.USER_MODE);
        } else {
            return new List<Database.DeleteResult>();
        }
    }
}