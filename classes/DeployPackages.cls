public with sharing class DeployPackages {
    private copado__Artifact_Version__c pkgVersion;
    private List<Id> credentialIds;
    private static final String SFDX_PACKAGE_DISTRIBUTION_TEMPLATE = 'SFDX Package Distribution_1';

    // CONSTRUCTOR

    public DeployPackages(Id pkgVersionId, List<Id> credentialIds) {
        this.pkgVersion = new PackageVersionsSelector().byIds(new Set<Id>{ pkgVersionId }).get(0);
        this.credentialIds = credentialIds;
    }

    // PUBLIC

    public List<copado__JobExecution__c> execute() {
        try {
            List<copado.CreateExecution.Request> executionRequests = new List<copado.CreateExecution.Request>();

            for (copado__Org__c credential : new CredentialsSelector().byIds(credentialIds)) {
                executionRequests.add(createExecutionRequest(credential.copado__Environment__c));
            }

            Map<Id, copado__JobExecution__c> executionsById = new Map<Id, copado__JobExecution__c>(
                copado.CreateExecution.execute(executionRequests)
            );

            return new JobExecutionsSelector().byIds(executionsById.keySet());
        } catch (Exception ex) {
            throw new ApplicationException().auraHandled(ex);
        }
    }

    // PRIVATE

    private copado.CreateExecution.Request createExecutionRequest(Id environment) {
        copado.CreateExecution.Request request = new copado.CreateExecution.Request();

        request.templateName = SFDX_PACKAGE_DISTRIBUTION_TEMPLATE;
        request.destinationId = environment;
        request.dataJson = new PackageVersion(pkgVersion.copado__Subscriber_Version_Id__c).stringify();
        request.runAfterInstantiation = true;

        return request;
    }

    // INNER
    
    public class PackageVersion {
        public String subscriberId;
        public String installationKey;

        public PackageVersion(String subscriberId) {
            List<PackageVersionInstallationKey__c> versionKey = new PackageVersionInstallationKeySelector()
                .byPackageVersionId(new Set<Id>{ subscriberId });

            this.subscriberId = subscriberId;
            this.installationKey = versionKey.isEmpty() ? null : versionKey[0].InstallationKey__c;
        }

        public String stringify() {
            return JSON.serialize(this);
        }
    }
}