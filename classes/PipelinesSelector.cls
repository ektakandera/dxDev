public with sharing class PipelinesSelector extends fflib_SObjectSelector {
  // CONSTRUCTOR

  public PipelinesSelector() {
    this(true);
  }

  public PipelinesSelector(Boolean enforceFLS) {
    super(false, true, enforceFLS, false);
  }

  // PUBLIC

  public List<SObjectField> getSObjectFieldList() {
    return new List<SObjectField>{
      copado__Deployment_Flow__c.copado__Git_Repository__c
    };
  }

  public SObjectType getSObjectType() {
    return copado__Deployment_Flow__c.sObjectType;
  }

  public List<copado__Deployment_Flow__c> byId(Set<Id> ids) {
    return Database.query(
      newQueryFactory().setCondition('Id IN :ids').toSOQL()
    );
  }
}