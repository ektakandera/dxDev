public with sharing class Utilities {
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        List<String> result = new List<String>();

        List<Schema.PicklistEntry> picklistValues = Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .fields.getMap()
            .get(fieldApiName)
            .getDescribe()
            .getPicklistValues();

        for (Schema.PicklistEntry ple : picklistValues) {
            result.add(ple.getValue());
        }

        return result;
    }
}