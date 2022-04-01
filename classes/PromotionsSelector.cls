public with sharing class PromotionsSelector extends fflib_SObjectSelector {
    private Boolean enforceFLS;
    private Boolean enforceCRUD;

    // CONSTRUCTOR

    public PromotionsSelector() {
        this(true, true);
    }

    public PromotionsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
        this.enforceFLS = enforceFLS;
        this.enforceCRUD = enforceCRUD;
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return copado__Promotion__c.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{ copado__Promotion__c.Apex_Test_Level__c };
    }

    public List<copado__Promotion__c> byIdsAndActivePromotedStories(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('copado__Destination_Environment__r.copado__Run_all_tests__c')
            .setCondition(
                'copado__Platform__c = \'SFDX\' AND Id IN (SELECT copado__Promotion__c from copado__Promoted_User_Story__c WHERE copado__Promotion__c IN :ids AND copado__Status__c = \'Active\')'
            );

        new PromotedUserStoriesSelector(enforceCRUD, enforceFLS)
            .addQueryFactorySubselect(query)
            .selectField('copado__User_Story__r.Apex_Test_Level__c')
            .setCondition(
                'copado__Promotion__r.copado__Destination_Environment__r.copado__Run_all_tests__c = false AND copado__Status__c = \'Active\''
            );

        return Database.query(query.toSOQL());
    }
}