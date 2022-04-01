public with sharing class UserStoriesSelector extends FflibExtension {
    // CONSTRUCTOR

    public UserStoriesSelector() {
        this(true, true);
    }

    public UserStoriesSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__User_Story__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            copado__User_Story__c.Name,
            copado__User_Story__c.copado__User_Story_Title__c,
            copado__User_Story__c.copado__Org_Credential__c,
            copado__User_Story__c.copado__Project__c,
            copado__User_Story__c.copado__Release__c,
            copado__User_Story__c.copado__Metadata_Types_in_Selection__c,
            copado__User_Story__c.copado__Has_Apex_Code__c
        };
    }

    public Map<String, List<Schema.SObjectField>> getSObjectLookupFieldMap() {
        return new Map<String, List<Schema.SObjectField>>{
            'copado__Org_Credential__r' => new List<Schema.SObjectField>{
                copado__Org__c.Name            }
        };
    }

    public List<copado__User_Story__c> byIds(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition(copado__User_Story__c.Id + ' IN :ids');
        
        setLookupFields(query, 'copado__Org_Credential__r');

        return Database.query(query.toSOQL());
    }

    public List<copado__User_Story__c> byIdsAndPlatforms(Set<Id> ids, Set<String> platforms) {
        return Database.query(
            newQueryFactory()
                .setCondition(copado__User_Story__c.Id + ' IN :ids AND ' + copado__User_Story__c.copado__Platform__c + ' IN :platforms')
                .toSOQL()
        );
    }

}