public with sharing class ContentDocumentLinksSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public ContentDocumentLinksSelector() {
        this(true, true);
    }

    public ContentDocumentLinksSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return ContentDocumentLink.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{ ContentDocumentLink.ContentDocumentId };
    }

    public List<ContentDocumentLink> byLinkedEntityIdAndTitle(Set<Id> linkedEntityIds, String title) {
        return Database.query(newQueryFactory().setCondition('LinkedEntityId IN :linkedEntityIds AND ContentDocument.Title = :title').toSOQL());
    }
}