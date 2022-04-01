public with sharing class UserStoryMetadataListCtlr {
    private final static String IS_SUCCESS = 'isSuccess';
    private final static String RECORD_ID = 'recordId';
    private final static String MESSAGE = 'message';
    private final static String NO_ATTACHMENT_FOUND = 'No attachment found';

    @AuraEnabled
    public static Map<String, Object> createFileFromAttachment(Id credentialId, String name) {
        Map<String, Object> result = new Map<String, Object>{ IS_SUCCESS => false, MESSAGE => NO_ATTACHMENT_FOUND };
        List<Attachment> attachments = new AttachmentsSelector().byParentIdsAndNames(new Set<Id>{ credentialId }, new Set<String>{ name });
        if (!attachments.isEmpty()) {
            List<ContentDocumentLink> contentDocumentLinks = new ContentDocumentLinksSelector()
                .byLinkedEntityIdAndTitle(new Set<Id>{ credentialId }, name);
            try {
                if (!contentDocumentLinks.isEmpty()) {
                    List<ContentDocument> contentDocuments = new List<ContentDocument>();
                    contentDocuments.add(new ContentDocument(Id = contentDocumentLinks[0].ContentDocumentId));
                    deleteContentDocument(contentDocuments);
                }
                Id contentVersionId = createFile(credentialId, name, attachments[0].Body);
                result = new Map<String, Object>{ IS_SUCCESS => true, RECORD_ID => contentVersionId };
            } catch (Exception e) {
                result.put(MESSAGE, e.getMessage());
            }
        }
        return result;
    }

    private static Id createFile(Id credentialId, String name, Blob versionData) {
        List<ContentVersion> contentVersions = createContentVersion(credentialId, name, versionData);
        createContentDocumentLink(credentialId, contentVersions[0]);
        return contentVersions[0].Id;
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static void deleteContentDocument(List<ContentDocument> contentDocuments) {
        fflib_SecurityUtils.checkObjectIsDeletable(ContentDocument.SObjectType);
        delete contentDocuments;
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static List<ContentVersion> createContentVersion(Id credentialId, String name, Blob versionData) {
        ContentVersion contentVersion = new ContentVersion(
            ContentLocation = 'S', // S = Document is located within Salesforce
            PathOnClient = name + '.json',
            Title = name,
            VersionData = versionData
        );
        contentVersion = (ContentVersion) Security.stripInaccessible(AccessType.CREATABLE, new List<ContentVersion>{ contentVersion })
            .getRecords()[0];
        insert contentVersion;

        List<ContentVersion> contentVersions = new ContentVersionsSelector()
            .byContentVersionIdForContentDocId(new Set<Id>{ contentVersion.Id });
        return contentVersions;
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static void createContentDocumentLink(Id credentialId, ContentVersion contentVersion) {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentVersion.ContentDocumentId,
            LinkedEntityId = credentialId,
            ShareType = 'I', // I = Inferred permission. The user’s permission (of file record) is determined by the related record.
            Visibility = 'AllUsers' // AllUsers = The file is available to all users who have permission to see the file.
        );
        contentDocumentLink = (ContentDocumentLink) Security.stripInaccessible(
                AccessType.CREATABLE,
                new List<ContentDocumentLink>{ contentDocumentLink }
            )
            .getRecords()[0];
        insert contentDocumentLink;
    }
}