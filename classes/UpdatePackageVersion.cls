public with sharing class UpdatePackageVersion {
    private static copado__Artifact_Version__c version;
    private static PackageVersionUpdateJob.Version newVersion;

    // PUBLIC

    @InvocableMethod(label='Update Package Version')
    public static void updateRecords(List<Request> requests) {
        newVersion = (PackageVersionUpdateJob.Version) JSON.deserialize(
            requests[0].newVersion,
            PackageVersionUpdateJob.Version.class
        );

        version = new PackageVersionsSelector().bySubscriberIds(new Set<Id>{ newVersion.subscriberVersionId }).get(0);

        updateInstallationKey();
        doUpdate();
    }

    // PRIVATE

    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static void updateInstallationKey() {
        if (String.isNotBlank(newVersion.installationKey)) {
            List<PackageVersionInstallationKey__c> keys = new PackageVersionInstallationKeySelector()
                .byPackageVersionId(new Set<Id>{ version.copado__Subscriber_Version_Id__c });

            PackageVersionInstallationKey__c newKey = new PackageVersionInstallationKey__c(
                Id = keys.isEmpty() ? null : keys[0].Id,
                InstallationKey__c = newVersion.installationKey,
                PackageVersionId__c = version.copado__Subscriber_Version_Id__c,
                Name = version.Name
            );

            //Note: Protected Custom Settings DML
            upsert newKey;
        }
    }

    private static void doUpdate() {
        version.copado__Branch__c = getValue(version.copado__Branch__c, newVersion.branch);
        version.copado__Tag__c = getValue(version.copado__Tag__c, newVersion.tag);
        version.copado__Version_Name__c = getValue(version.copado__Version_Name__c, newVersion.branch);
        version.copado__Version_Description__c = getValue(
            version.copado__Version_Description__c,
            newVersion.description
        );

        update Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{ version }).getRecords();
    }

    private static String getValue(String oldValue, String newValue) {
        return String.isBlank(newValue) ? oldValue : newValue;
    }

    // INNER

    public class Request {
        @InvocableVariable(label='Serialized Package Version Details' required=true)
        public String newVersion;
    }
}