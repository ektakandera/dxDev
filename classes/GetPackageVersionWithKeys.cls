public with sharing class GetPackageVersionWithKeys {
    private Id subscriberVersionId;
    private Set<Id> dependenciesIds;
    private List<PackageVersion> versions = new List<PackageVersion>();

    // CTOR

    public GetPackageVersionWithKeys(Id subscriberVersionId, Set<Id> dependenciesIds) {
        this.subscriberVersionId = subscriberVersionId;
        this.dependenciesIds = dependenciesIds;
    }

    // PUBLIC

    @InvocableMethod(label='Get Package Version With Key' category='Copado Package Version')
    public static List<Response> execute(List<Request> request) {
        Set<Id> dependenciesIds = getDependenciesIds(request[0].dependenciesIds);

        List<PackageVersion> versions = new GetPackageVersionWithKeys(request[0].subscriberVersionId, dependenciesIds)
            .execute();

        return new List<Response>{ new Response(versions) };
    }

    public List<PackageVersion> execute() {
        try {
            if (!dependenciesIds.isEmpty()) {
                addDependenciesWithKeys();
                addDependenciesWithoutKeys();
            }
            addPackageVersion();

            return versions;
        } catch (Exception ex) {
            throw new ApplicationException().auraHandled(ex);
        }
    }

    // PRIVATE

    private void addDependenciesWithKeys() {
        for (
            PackageVersionInstallationKey__c key : new PackageVersionInstallationKeySelector()
                .byPackageVersionId(dependenciesIds)
        ) {
            versions.add(new PackageVersion(key.PackageVersionId__c, key.InstallationKey__c));
            // Removing the ones added, remaining to be added later
            dependenciesIds.remove(key.PackageVersionId__c);
        }
    }

    private void addDependenciesWithoutKeys() {
        for (Id subscriberId : dependenciesIds) {
            versions.add(new PackageVersion(subscriberId, null));
        }
    }

    private void addPackageVersion() {
        List<PackageVersionInstallationKey__c> versionKey = new PackageVersionInstallationKeySelector()
            .byPackageVersionId(new Set<Id>{ subscriberVersionId });
        String key = versionKey.isEmpty() ? null : versionKey[0].InstallationKey__c;

        versions.add(new PackageVersion(subscriberVersionId, key));
    }

    private static Set<Id> getDependenciesIds(String dependenciesIds) {
        return String.isBlank(dependenciesIds)
            ? new Set<Id>()
            : (Set<Id>) JSON.deserialize(dependenciesIds, Set<Id>.class);
    }

    // INNER

    public class Request {
        @InvocableVariable(label='Subscriber Package Version Id' required=true)
        public String subscriberVersionId;
        @InvocableVariable(label='Subscriber Package Version Id of Dependencies')
        public String dependenciesIds;
    }

    public class Response {
        @InvocableVariable(label='Package Versions with Key')
        public String versions;

        public Response(List<PackageVersion> versions) {
            this.versions = JSON.serialize(versions).escapeEcmaScript();
        }
    }

    public class PackageVersion {
        public String id;
        public String key;

        public PackageVersion(String id, String key) {
            this.id = id;
            this.key = key;
        }
    }
}