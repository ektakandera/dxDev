public with sharing class UpdateInstallationKey {
    
    // PUBLIC

    @AuraEnabled(cacheable=true)
    public static String fetchInstallationKey(Id subscriberVersionId) {
        List<PackageVersionInstallationKey__c> keys = new PackageVersionInstallationKeySelector()
            .byPackageVersionId(new Set<Id>{ subscriberVersionId });

        return keys.isEmpty() ? null : keys.get(0).InstallationKey__c;
    }

    @AuraEnabled
    public static void executeJob(Id subscriberVersionId, String installationKey) {
        try {
            PackageVersionUpdateJob.Version newVersion = new PackageVersionUpdateJob.Version(subscriberVersionId);
            newVersion.installationKey = installationKey;

            new PackageVersionUpdateJob(newVersion).execute();
        } catch (Exception ex) {
            throw new ApplicationException().auraHandled(ex);
        }
    }
}