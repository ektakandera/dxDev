public with sharing class UserStoryCommitTableActionsCtrl {
    @AuraEnabled(cacheable=true)
    public static Boolean isSourceMemberAvailable(String credentialId) {
        try {
            if (!Test.isRunningTest()) {
                DateTime dateTimeToRetrieveChanges = DateTime.now().addMinutes(-1);
                new copado.GlobalAPI().getRecentChanges(credentialId, dateTimeToRetrieveChanges);
            }
            return true;
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains('sObject type \'SourceMember\' is not supported')) {
                return false;
            } else {
                throw new ApplicationException().auraHandled(e);
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SobjectItem> listAllSobjectsInOrg(String credentialId) {
        try {
            List<SobjectItem> options = new List<SobjectItem>();
            for (String type : MetadataTypes.supportedMetadataTypes()) {
                SobjectItem option = new SobjectItem();
                option.Label = type;
                option.Name = type;
                options.add(option);
            }
            return options;
        } catch (Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
    }

    @AuraEnabled
    public static List<copado.SourceMemberResult> retrieveRecentChanges(String orgId, DateTime dateTimeToRetrieveChanges) {
        try {
            List<copado.SourceMemberResult> results = new List<copado.SourceMemberResult>();
            if (!Test.isRunningTest()) {
                results = new copado.GlobalAPI().getRecentChanges(orgId, dateTimeToRetrieveChanges);
            } else {
                results = new List<copado.SourceMemberResult>{ getSmrDataForTestClass() };
            }
            return results;
        } catch (Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
    }

    @AuraEnabled
    public static List<MetadataSearchResult> searchMetadata(String orgId, String type, String searchTerm) {
        try {
            return new SearchMetadata(orgId, type, searchTerm).execute();
        } catch (Exception e) {
            throw new ApplicationException().auraHandled(e);
        }
    }

    // PRIVATE

    private static copado.SourceMemberResult getSmrDataForTestClass() {
        copado.SourceMemberResult smr = new copado.SourceMemberResult();
        smr.CreatedDate = String.valueOf(System.now());
        smr.CreatedBy = new copado.SourceMemberResult.LookupUserField();
        smr.CreatedBy.Name = 'Test name';
        smr.LastModifiedDate = String.valueOf(System.now());
        smr.LastModifiedBy = new copado.SourceMemberResult.LookupUserField();
        smr.LastModifiedBy.Name = 'Test name';
        smr.IsNameObsolete = false;
        smr.MemberName = 'test';
        smr.MemberType = 'ApexClass';
        return smr;
    }
}