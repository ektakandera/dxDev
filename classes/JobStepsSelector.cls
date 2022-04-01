public with sharing class JobStepsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public JobStepsSelector() {
        this(true, true);
    }

    public JobStepsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__JobStep__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{ copado__JobStep__c.Name };
    }

    public List<copado__JobStep__c> promotionByIds(Set<Id> ids) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__JobExecution__r.copado__Deployment__r.copado__Promotion__c')
                .setCondition(copado__JobStep__c.Id + ' IN :ids')
                .toSOQL()
        );
    }
}