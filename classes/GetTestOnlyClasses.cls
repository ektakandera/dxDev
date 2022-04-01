@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GetTestOnlyClasses implements copado.ParameterExpressionCallable {
    // GLOBAL

    // Return a list of test classes filenames
    // ["My Test class one.cls","My Test class two.cls", ...]
    // contextId is the JobStep

    global String execute(Id contextId) {
        Id promotionId = getPromotion(contextId);

        Set<String> result = getTestClassNames(getStoryIds(promotionId));

        return JSON.serialize(result);
    }

    // PRIVATE

    private Id getPromotion(Id contextId) {
        return new JobStepsSelector().promotionByIds(new Set<Id>{ contextId })[0]
            ?.copado__JobExecution__r
            ?.copado__Deployment__r
            ?.copado__Promotion__c;
    }

    private Set<Id> getStoryIds(Id promotionId) {
        Set<Id> result = new Set<Id>();

        for (copado__Promoted_User_Story__c record : new PromotedUserStoriesSelector().byPromotionIds(new Set<Id>{ promotionId })) {
            result.add(record.copado__User_Story__c);
        }

        return result;
    }

    private Set<String> getTestClassNames(Set<Id> storyIds) {
        Set<String> result = new Set<String>();

        for (String attachmentItem : getFromAttachments(storyIds)) {
            result.add(attachmentItem);
        }

        for (String fileItem : getFromFiles(storyIds)) {
            result.add(fileItem);
        }

        return result;
    }

    private Set<String> getFromAttachments(Set<Id> storyIds) {
        List<MetaDataItem> metadataItems = new List<MetaDataItem>();
        for (Attachment attachment : new AttachmentsSelector().byStoryIdsAndTestClasses(storyIds)) {
            metadataItems.addAll((List<MetaDataItem>) JSON.deserialize(attachment.Body.toString(), List<MetaDataItem>.class));
        }

        return processMetadataNames(metadataItems);
    }

    private Set<String> getFromFiles(Set<Id> storyIds) {
        List<MetaDataItem> metadataItems = new List<MetaDataItem>();

        Set<Id> documentIds = new Set<Id>();

        for (ContentDocumentLink documentLink : new ContentDocumentLinksSelector().byLinkedEntityIdAndTitle(storyIds, 'cmcSf_TestClasses')) {
            documentIds.add(documentLink.ContentDocumentId);
        }

        for (ContentVersion content : new ContentVersionsSelector().byContentDocumentIdWithLatest(documentIds)) {
            metadataItems.addAll((List<MetaDataItem>) JSON.deserialize(content.VersionData.toString(), List<MetaDataItem>.class));
        }

        return processMetadataNames(metadataItems);
    }

    private Set<String> processMetadataNames(List<MetaDataItem> metadataItems) {
        Set<String> result = new Set<String>();

        for (MetaDataItem item : metadataItems) {
            result.add(item.n + '.cls');
        }

        return result;
    }
}