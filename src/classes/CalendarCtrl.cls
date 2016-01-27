public with sharing class CalendarCtrl {
	@AuraEnabled
    public static sObject insertX(SObject sobj){
        insert sobj;
        return sobj;
    }

    @AuraEnabled
    public static sObject upsertX(SObject sobj){
        upsert sobj;
        return sobj;
    }

    @AuraEnabled
    public static List<sObject> queryX(String query){
        return Database.query(query);
    }

}