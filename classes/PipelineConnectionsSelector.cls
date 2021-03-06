public with sharing class PipelineConnectionsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public PipelineConnectionsSelector() {
        this(true, true);
    }

    public PipelineConnectionsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__Deployment_Flow_Step__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{ copado__Deployment_Flow_Step__c.Name };
    }

    public List<copado__Deployment_Flow_Step__c> byPipelineAndSourceEnv(Set<Id> pipelineIds, Set<Id> sourceEnvIds) {
        return Database.query(
            newQueryFactory()
                .selectField('copado__Destination_Environment__r.Name')
                .setCondition(copado__Deployment_Flow_Step__c.copado__Deployment_Flow__c + ' IN :pipelineIds')
                .setCondition(copado__Deployment_Flow_Step__c.copado__Source_Environment__c + ' IN :sourceEnvIds')
                .toSOQL()
        );
    }
}