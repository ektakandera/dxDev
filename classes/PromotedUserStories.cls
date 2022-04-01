public with sharing class PromotedUserStories extends fflib_SObjectDomain {
    // CONSTRUCTOR

    public PromotedUserStories(List<copado__Promoted_User_Story__c> records) {
        super(records);
    }

    // PUBLIC

    public override void onAfterInsert() {
        new UpdatePromotionTestLevel(records).execute();
    }

    public override void onAfterUpdate(Map<Id, SObject> old) {
        new UpdatePromotionTestLevel(withStatusChange(records, (Map<Id, copado__Promoted_User_Story__c>) old))
            .execute();
    }

    public override void onAfterDelete() {
        new UpdatePromotionTestLevel(records).execute();
    }

    // PRIVATE

    private Set<Id> withStatusChange(
        List<copado__Promoted_User_Story__c> promotedUserStories,
        Map<Id, copado__Promoted_User_Story__c> old
    ) {
        Set<Id> result = new Set<Id>();

        for (copado__Promoted_User_Story__c ps : promotedUserStories) {
            if (ps.copado__Status__c != old.get(ps.Id).copado__Status__c) {
                result.add(ps.copado__Promotion__c);
            }
        }

        return result;
    }

    // INNER

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new PromotedUserStories(records);
        }
    }
}