public with sharing class PackageVersionsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public PackageVersionsSelector() {
        this(true, true);
    }

    public PackageVersionsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__Artifact_Version__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            copado__Artifact_Version__c.Name,
            copado__Artifact_Version__c.copado__Version_number__c,
            copado__Artifact_Version__c.copado__Branch__c,
            copado__Artifact_Version__c.copado__Status__c,
            copado__Artifact_Version__c.copado__Release_Status__c,
            copado__Artifact_Version__c.copado__Is_released__c,
            copado__Artifact_Version__c.copado__Tag__c,
            copado__Artifact_Version__c.copado__Subscriber_Version_Id__c,
            copado__Artifact_Version__c.copado__Artifact__c,
            copado__Artifact_Version__c.copado__Version_Description__c,
            copado__Artifact_Version__c.copado__Version_Name__c
        };
    }

    public List<copado__Artifact_Version__c> byIds(Set<Id> ids) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__Artifact__r.Name')
                .setCondition(copado__Artifact_Version__c.Id + ' IN :ids')
                .toSOQL()
        );
    }

    public List<copado__Artifact_Version__c> byPackageIds(Set<Id> packageIds) {
        return Database.query(
            newQueryFactory().setCondition(copado__Artifact_Version__c.copado__Artifact__c + ' IN :packageIds').toSOQL()
        );
    }

    public List<copado__Artifact_Version__c> bySubscriberIds(Set<Id> ids) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__Artifact__r.copado__Target_Dev_Hub_Org__r.copado__Environment__c')
                .setCondition(copado__Artifact_Version__c.copado__Subscriber_Version_Id__c + ' IN :ids')
                .toSOQL()
        );
    }
}