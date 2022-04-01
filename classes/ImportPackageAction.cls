public with sharing class ImportPackageAction {
    private static List<String> versionFields = new List<String>{
        'copado__Package_Version_Id__c',
        'copado__Subscriber_Version_Id__c',
        'copado__Is_released__c',
        'copado__Branch__c',
        'copado__Version_Name__c',
        'copado__Tag__c',
        'copado__Version_Description__c',
        'copado__Version_number__c'
    };

    // CONSTANTS

    private static final List<String> PACKAGE_FIELDS = new List<String>{
        'copado__Artifact_Repository__c',
        'Name',
        'copado__Package_Id__c',
        'copado__Description__c',
        'copado__Package_Namespace__c',
        'copado__pipeline__c',
        'RecordTypeId',
        'copado__Target_Dev_Hub_Org__c'
    };

    // PUBLIC

    @InvocableMethod(
        label='Create Package and Package Version'
        category='Package Import'
        description='Package Import only supports one package request at a time.'
    )
    public static void execute(List<Request> requests) {
        try {
            if (requests.size() > 1) {
                throw new ApplicationException(System.Label.BulkPackageImportNotSupported);
            }
            Request request = requests.get(0);

            if (isValid(request)) {
                PackageInfo info = PackageInfo.parse(request.packageJSON);
                copado__Artifact__c pkg = upsertPackage(retrievePackage(request, info));
                upsertVersions(retrieveVersions(pkg, info));
            }
        } catch (Exception ex) {
            throw new ApplicationException(ex.getMessage());
        }
    }

    // PRIVATE

    private static Boolean isValid(Request request) {
        return (String.isNotBlank(request.packageJson) &&
        String.isNotBlank(request.pipelineId) &&
        String.isNotBlank(PackageInfo.parse(request.packageJson)?.pkg?.Id));
    }

    private static copado__Artifact__c retrievePackage(Request input, PackageInfo info) {
        copado__Artifact__c result = getExistingPackage(info.pkg.Id);

        List<copado__Deployment_Flow__c> pipelines = new PipelinesSelector()
            .byId(new Set<Id>{ Id.valueOf(input.pipelineId) });
        if (pipelines.isEmpty()) {
            throw new ApplicationException(System.Label.InvalidPipeline);
        }
        result.copado__Artifact_Repository__c = Id.valueOf(pipelines[0].copado__Git_Repository__c);
        result.Name = info.pkg.Name;
        result.copado__Package_Id__c = info.pkg.Id;
        result.copado__Description__c = info.pkg.Description;
        result.copado__Package_Namespace__c = info.pkg.NamespacePrefix;
        result.copado__pipeline__c = input.pipelineid;
        result.RecordTypeId = Schema.SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName()
            .get('Package_Artifact')
            .getRecordTypeId();
        result.copado__Target_Dev_Hub_Org__c = (String.isNotBlank(input.jsonInformation))
            ? ParseImportPackageJson.parse(input.jsonInformation).devhub
            : null;

        return result;
    }

    private static List<copado__Artifact_Version__c> retrieveVersions(
        copado__Artifact__c pkg,
        PackageInfo info
    ) {
        Map<String, copado__Artifact_Version__c> versionsByNumber = versionsByNumber(pkg);
        List<copado__Artifact_Version__c> versions = new List<copado__Artifact_Version__c>();

        for (PackageInfo.Versions version : info.versions) {
            String key = version.Version;
            copado__Artifact_Version__c record = (versionsByNumber.containsKey(key))
                ? versionsByNumber.get(key)
                : new copado__Artifact_Version__c(copado__Artifact__c = pkg?.Id);

            record.copado__Package_Version_Id__c = version.Id;
            record.copado__Subscriber_Version_Id__c = version.SubscriberPackageVersionId;
            record.copado__Is_released__c = version.IsReleased;
            record.copado__Branch__c = version.Branch;
            record.copado__Version_Name__c = version.Name;
            record.copado__Tag__c = version.Tag;
            record.copado__Version_Description__c = version.Description;
            record.copado__Version_number__c = version.Version;

            versions.add(record);
        }
        return versions;
    }

    private static copado__Artifact__c upsertPackage(copado__Artifact__c pkg) {
        fflib_ISObjectUnitOfWork unitOfWork = unitOfWork();

        if (String.IsNotBlank(pkg?.Id)) {
            fflib_SecurityUtils.checkUpdate(copado__Artifact__c.SObjectType, PACKAGE_FIELDS);
            unitOfWork.registerDirty(pkg);
        } else {
            fflib_SecurityUtils.checkInsert(copado__Artifact__c.SObjectType, PACKAGE_FIELDS);
            unitOfWork.registerNew(pkg);
        }

        unitOfWork.commitWork();
        return pkg;
    }

    private static void upsertVersions(List<copado__Artifact_Version__c> versions) {
        fflib_ISObjectUnitOfWork unitOfWork = unitOfWork();

        List<copado__Artifact_Version__c> updateVersions = new List<copado__Artifact_Version__c>();
        List<copado__Artifact_Version__c> insertVersions = new List<copado__Artifact_Version__c>();

        for (copado__Artifact_Version__c version : versions) {
            if (String.IsNotBlank(version.Id)) {
                updateVersions.add(version);
            } else {
                insertVersions.add(version);
            }
        }

        if (!updateVersions.isEmpty()) {
            fflib_SecurityUtils.checkUpdate(copado__Artifact_Version__c.SObjectType, versionFields);
            unitOfWork.registerDirty(updateVersions);
        }

        if (!insertVersions.isEmpty()) {
            versionFields.add('copado__Artifact__c');
            fflib_SecurityUtils.checkInsert(copado__Artifact_Version__c.SObjectType, versionFields);
            unitOfWork.registerNew(insertVersions);
        }

        unitOfWork.commitWork();
    }

    private static copado__Artifact__c getExistingPackage(String packageId) {
        List<copado__Artifact__c> packages = new PackagesSelector()
            .selectBySubscriberIdWithVersions(
                new Set<Id>{ packageId },
                new Set<String>{ 'Id', 'copado__Version_number__c' }
            );

        return !packages.isEmpty() ? packages.get(0) : new copado__Artifact__c();
    }

    private static Map<String, copado__Artifact_Version__c> versionsByNumber(
        copado__Artifact__c pkg
    ) {
        Map<String, copado__Artifact_Version__c> result = new Map<String, copado__Artifact_Version__c>();

        for (copado__Artifact_Version__c version : pkg.copado__Artifact_Versions__r) {
            result.put(version.copado__Version_number__c, version);
        }

        return result;
    }

    private static fflib_SObjectUnitOfWork unitOfWork() {
        return new fflib_SObjectUnitOfWork(
            new List<SObjectType>{
                copado__Artifact__c.SObjectType,
                copado__Artifact_Version__c.SObjectType
            }
        );
    }

    // INNER

    public class Request {
        @InvocableVariable(required=true)
        public String packageJson;

        @InvocableVariable(required=true label='Pipeline Id')
        public String pipelineId;

        @InvocableVariable(label='Platform related arguments in JSON format')
        public String jsonInformation;
    }
}