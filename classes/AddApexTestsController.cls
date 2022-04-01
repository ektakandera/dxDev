public with sharing class AddApexTestsController {

    private final static String USER_SELECTIONS_FILENAME = 'cmcSf_TestClasses';
    private final static String ATTACHMENT_FILENAME = 'Test Classes';
    private final static String SOSL_ENPOINT_PREFIX = '/services/data/v53.0/search/?q=';
    
    // PUBLIC
	@AuraEnabled
    public static List<MetaDataItem> getApexTestClassList(String recordId){

        String query = 'FIND {@isTest OR @IsTest} IN ALL FIELDS RETURNING ApexClass(Name,NamespacePrefix)';

        copado.GlobalAPI.ProxyOrgRequest request = new copado.GlobalAPI.ProxyOrgRequest();
        request.endPointUrlService = getEndpoint(query);
        request.orgCredentialId = getOrgCredentialId(recordId);
        request.logLabelIdentifier = 'Apex Test Class - Retriever';
        request.requestType = HttpMethod.GET.name();

        copado.GlobalAPI.ProxyOrgResponse response;

        if (!Test.isRunningTest()) {
            response = new copado.GlobalAPI().proxyOrgRequest(request);
        }
        else {
            response = mockResponse();
        }
        
        return processResponse(response);
    }

    @AuraEnabled
    public static void createContentVersion(String body, String recordId){
        try{
            List<MetaDataItem> metadataItems = new List<MetaDataItem>();
            for(MetaDataItem selectedRecords: MetaDataItem.parseForFileJSON(body)){
                MetaDataItem record = new MetaDataItem();
                record.n = (!String.isBlank(selectedRecords.n)) ? selectedRecords.n : '';
                record.s = true;
                record.ns = (!String.isBlank(selectedRecords.ns)) ? selectedRecords.ns : '';
                record.r = false;
                metadataItems.add(record);
            }
            Blob content = Blob.valueOf(JSON.serialize(metadataItems,true));
            
            deleteTestSelections(recordId);
        
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = USER_SELECTIONS_FILENAME+'.json';
            contentVersion.Title = USER_SELECTIONS_FILENAME;
            contentVersion.VersionData = content;
            insert contentVersion;
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            List<ContentVersion> contentVersionList = new ContentVersionsSelector().byContentVersionIdForContentDocId(new Set<Id>{contentVersion.Id});
            contentDocumentLink.ContentDocumentId = contentVersionList[0].ContentDocumentId;
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ShareType = 'V'; // Only View Permission
            contentDocumentLink.Visibility = 'AllUsers';
            insert contentDocumentLink;

            addFileAsAttachment(recordId, content);

        }catch(Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
    }

    @AuraEnabled
    public static List<MetaDataItem> getPreselections(String recordId) {
        try{
            List<MetaDataItem> result = new List<MetaDataItem> ();
            List<ContentDocumentLink> content = new ContentDocumentLinksSelector().byLinkedEntityIdAndTitle(new Set<Id>{recordId}, USER_SELECTIONS_FILENAME);

            if(!content.isEmpty()){
                String data = new ContentVersionsSelector().byContentDocumentIdWithLatest(new Set<Id>{content[0].ContentDocumentId})[0].VersionData.toString();
                result = (String.isNotBlank(data)) ? MetaDataItem.parseForFileJSON(data) : result;
            }
            
            return result;

        }catch(Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
        
    }

    // PRIVATE
    private static String getUrlEncoded(String query, String encoding){
        return (EncodingUtil.urlEncode(query, encoding));
    }
    
    private static String getEndpoint(String query){
        return (SOSL_ENPOINT_PREFIX + getUrlEncoded(query,'UTF-8'));
    }
    
    private static String getOrgCredentialId(String recordId){
        return (recordId != null) ? new UserStoriesSelector().byIds(new Set<Id>{recordId})[0].copado__Org_Credential__c: '';
    }
    
    private static List<MetaDataItem> processResponse(copado.GlobalAPI.ProxyOrgResponse response) {
        if (response.statusCode != 200) {
            String message = String.isNotBlank(response.errorMessage) ? response.errorMessage : 'Error searching metadata';
            throw new ApplicationException(message);
        }
        
        return  MetaDataItem.parse(response.content);
    }

    private static void deleteTestSelections(String recordId){
        if(String.isNotBlank(recordId)){
            delete (new ContentDocumentLinksSelector().byLinkedEntityIdAndTitle(new Set<Id>{recordId}, USER_SELECTIONS_FILENAME));
            delete (new AttachmentsSelector().byStoryIdsAndTestClasses(new Set<Id>{recordId}));
        }
    }

    private static void addFileAsAttachment(String recordId, Blob content){
        
            if(String.isNotBlank(recordId) && content != null){
                insert (new Attachment(Name=ATTACHMENT_FILENAME, Body=content, ParentId=recordId));
            }
    }

    private static copado.GlobalAPI.ProxyOrgResponse mockResponse() {
        copado.GlobalAPI.ProxyOrgResponse result = new copado.GlobalAPI.ProxyOrgResponse();
        // Note: can not deserialize directly into copado.GlobalAPI.ProxyOrgResponse as it is in another namespace (@JsonAccess annotation must be defined in core package)
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
            new AddApexTestsControllerTest().getResponse()
        );
        if (responseMap.containsKey('statusCode')) {
            result.statusCode = Integer.valueOf(responseMap.get('statusCode'));
        }
        if (responseMap.containsKey('content')) {
            result.content = String.valueOf(responseMap.get('content'));
        }
        if (responseMap.containsKey('errorMessage')) {
            result.errorMessage = String.valueOf(responseMap.get('errorMessage'));
        }
        return result;
    }
}