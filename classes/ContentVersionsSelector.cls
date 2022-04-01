public with sharing class ContentVersionsSelector extends fflib_SObjectSelector {
    // CONSTRUCTOR

    public ContentVersionsSelector() {
        this(true, true);
    }

    public ContentVersionsSelector(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS, false);
    }

    // PUBLIC

    public SObjectType getSObjectType() {
        return ContentVersion.sObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{ ContentVersion.VersionData, ContentVersion.ContentDocumentId };
    }

    public List<ContentVersion> byContentDocumentIdWithLatest(Set<Id> contentDocumentIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('ContentDocumentId IN :contentDocumentIds AND isLatest = TRUE');
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }

    public List<ContentVersion> byContentVersionIdForContentDocId(Set<Id> contentVersionIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :contentVersionIds');
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }
}