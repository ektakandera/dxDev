public with sharing class PackageVersionUpdateJob {
    private static final String UPDATE_JOB_NAME = 'SFDX Package Version Update_1';
    private copado__Artifact_Version__c version;
    private Version newVersion;

    // CTOR

    public PackageVersionUpdateJob(Version newVersion) {
        this.version = getVersion(newVersion.subscriberVersionId);
        this.newVersion = newVersion;
    }

    // PUBLIC

    public copado__JobExecution__c execute() {
        copado.CreateExecution.Request request = createJobRequest();
        copado__JobExecution__c job = startJob(request);
        stampJobId(job.Id);

        return job;
    }

    // PRIVATE

    private copado.CreateExecution.Request createJobRequest() {
        copado.CreateExecution.Request request = new copado.CreateExecution.Request();

        request.templateName = UPDATE_JOB_NAME;
        request.destinationId = version.copado__Artifact__r.copado__Target_Dev_Hub_Org__r.copado__Environment__c;
        request.dataJson = JSON.serialize(newVersion);
        request.runAfterInstantiation = true;

        return request;
    }

    private copado__JobExecution__c startJob(copado.CreateExecution.Request request) {
        return copado.CreateExecution.execute(new List<copado.CreateExecution.Request>{ request }).get(0);
    }

    private void stampJobId(Id jobId) {
        version.copado__LastJobExecutionId__c = jobId;

        update Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{ version }).getRecords();
    }

    private copado__Artifact_Version__c getVersion(Id subscriberVersionId) {
        List<copado__Artifact_Version__c> version = new PackageVersionsSelector()
            .bySubscriberIds(new Set<Id>{ subscriberVersionId });

        if (version.isEmpty()) {
            throw new ApplicationException('Invalid Subscriber Version Id');
        }

        if (String.isBlank(version[0].copado__Artifact__r.copado__Target_Dev_Hub_Org__r.copado__Environment__c)) {
            throw new ApplicationException('Could not find Devhub environment.');
        }

        return version[0];
    }

    // INNER

    public class Version {
        public Id subscriberVersionId;
        public String versionName;
        public String description;
        public String branch;
        public String tag;
        public String installationKey;

        // CTOR

        public Version(Id subscriberVersionId) {
            this.subscriberVersionId = subscriberVersionId;
        }
    }
}