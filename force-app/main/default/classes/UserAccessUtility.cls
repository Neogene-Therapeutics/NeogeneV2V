/**
* Class Name        : SecurityCheckController
* Developer         : Adil Aleem          
* Created Date      : 
* @description      :  This is reusable class for determining wether the user is having dml
*                      access on objects and create/update permissions on specific fields.
* Last Modified Date: 
*/

public with sharing class UserAccessUtility {

    public enum CrudType {
        CREATE,
        READ,
        EDIT,
        DEL,
        UPS
    }
  

    /**
     * @description
     * @param obj the object type to check
     * @param permission create, read, update, upsert or delete
     * @return Boolean
     **/
    public static Boolean crud(SObject obj, CrudType permission) {
        switch on permission {
            when CREATE {
                return obj.getSObjectType().getDescribe().isCreateable();
            }
            when READ {
                return obj.getSObjectType().getDescribe().isAccessible();
            }
            when EDIT {
                return obj.getSObjectType().getDescribe().isUpdateable();
            }
            when UPS {
                return obj.getSObjectType().getDescribe().isCreateable()
                       && obj.getSObjectType().getDescribe().isUpdateable();
            }
            when DEL {
                return obj.getSObjectType().getDescribe().isDeletable();
            }
        }
        return false;
    }


    /**
     * @description convenience api for determining if the running user can
     * create the specified object
     * @param  objs list of sobjects
     * @return Boolean
     */
    public static Boolean createCheck(List<SObject> objs) {
        return crud(objs?.get(0), CrudType.CREATE);
    }

    /**
     * @description convenience api for determining if the running user can
     * edit the specified object
     * @param  objs list of sobjects
     * @return Boolean
     */
    public static Boolean editCheck(List<SObject> objs) {
        return crud(objs?.get(0), CrudType.EDIT);
    }

    /**
     * @description convenience api for determining if the running user can
     * upsert the specified object
     * @param  objs list of sobjects
     * @return Boolean
     */
    public static Boolean upsertCheck(List<SObject> objs) {
        return crud(objs?.get(0), CrudType.UPS);
    }

    /**
     * @description convenience api for determining if the running user can
     * delete the specified object
     * @param  objs list of sobjects
     * @return Boolean
     */
    public static Boolean deleteCheck(List<SObject> objs) {
        return crud(objs?.get(0), CrudType.DEL);
    }

    
    /**
     * @description convenience api for determining if the running user can
     * read the specified object
     * @param  objs list of sobjects
     * @return Boolean
     */
    public static Boolean readCheck(List<SObject> objs) {
        return crud(objs?.get(0), CrudType.READ);
    }
}