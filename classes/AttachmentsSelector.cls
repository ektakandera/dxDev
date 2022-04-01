public with sharing class AttachmentsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public AttachmentsSelector() {
        this(true, true);
    }

    public AttachmentsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return Attachment.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{ Attachment.Body, Attachment.Name };
    }

    public List<Attachment> byStoryIdsAndTestClasses(Set<Id> ids) {
        return Database.query(
            newQueryFactory()
                .setCondition(
                    Attachment.ParentId + ' IN :ids AND Name IN (\'Test Classes\', \'Test Classes.json\', \'cmcSf_TestClasses.json\')'
                )
                .toSOQL()
        );
    }

    public List<Attachment> byParentIdsAndNames(Set<Id> ids, Set<String> names) {
        return Database.query(
            newQueryFactory()
                .setCondition(Attachment.ParentId + ' IN :ids AND ' + Attachment.Name + ' IN :names')
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                .toSOQL()
        );
    }
}