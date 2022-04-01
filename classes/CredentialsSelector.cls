public with sharing class CredentialsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public CredentialsSelector() {
        this(true, true);
    }

    public CredentialsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__Org__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            copado__Org__c.Name,
            copado__Org__c.copado__Environment__c,
            copado__Org__c.copado__Org_Type__c,
            copado__Org__c.copado__Username__c,
            copado__Org__c.copado__Default_Credential__c,
            copado__Org__c.copado__SFDC_Org_ID__c,
            copado__Org__c.copado__is_Developer_Hub_Org__c
        };
    }

    public List<copado__Org__c> byIds(List<Id> ids) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__Environment__r.Name')
                .setCondition(copado__Org__c.Id + ' IN :ids')
                .toSOQL()
        );
    }

    public List<copado__Org__c> byActiveEnvAndPlatform(Set<String> platforms) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__Environment__r.Name')
                .setCondition('copado__Environment__c != null AND copado__Validated_Date__c != null AND copado__Environment__r.copado__Platform__c IN :platforms')
                .toSOQL()
        );
    }
}