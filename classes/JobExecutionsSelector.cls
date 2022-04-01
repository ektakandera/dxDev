public with sharing class JobExecutionsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public JobExecutionsSelector() {
        this(true, true);
    }

    public JobExecutionsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__JobExecution__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            copado__JobExecution__c.Name
        };
    }

    public List<copado__JobExecution__c> byIds(Set<Id> ids) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__Destination__r.Name')
                .setCondition(copado__JobExecution__c.Id + ' IN :ids')
                .toSOQL()
        );
    }
}