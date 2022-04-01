@IsTest
private class PackageVersionPublishHandlerTest {
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static final String SUBSCRIBER_ID = '04t09000000G3icAAC';

    @IsTest
    private static void publishPackageVersion() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            copado__Git_Repository__c repo = createRepository();
            copado__Artifact_Version__c version = createPackageVersion(
                repo,
                createPackage(repo, createPipeline(repo.Id).Id)
            );
            copado__JobTemplate__c template = new copado__JobTemplate__c(
                Name = 'SFDX Package Version Publish',
                copado__Version__c = 1
            );
            insert template;

            // Exercise
            PackageVersionPublishHandler.startPublish(version.Id);

            // Verify
            List<copado__JobExecution__c> jobs = [
                SELECT copado__DataJson__c
                FROM copado__JobExecution__c
            ];

            System.assertEquals(1, jobs.size(), 'Package version publish failed.');
        }
    }

    @IsTest
    private static void publishVersionwithNoJobTemplate() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            copado__Git_Repository__c repo = createRepository();
            copado__Artifact_Version__c version = createPackageVersion(
                repo,
                createPackage(repo, createPipeline(repo.Id).Id)
            );
            Exception expectedException = null;

            // Exercise
            try {
                PackageVersionPublishHandler.startPublish(version.Id);
            } catch (Exception ex) {
                expectedException = ex;
            }

            // Verify
            System.assertNotEquals(null, expectedException, 'Should an throw Exception');
        }
    }

    private static copado__Deployment_Flow__c createPipeline(Id repositoryId) {
        copado__Deployment_Flow__c pipeline = new copado__Deployment_Flow__c(
            Name = 'My Pipeline',
            copado__Platform__c = 'SFDX',
            copado__Git_Repository__c = repositoryId
        );
        insert pipeline;
        return pipeline;
    }

    private static copado__Git_Repository__c createRepository() {
        copado__Git_Repository__c repo = new copado__Git_Repository__c(Name = 'My Repo');
        insert repo;
        return repo;
    }

    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static copado__Artifact__c createPackage(
        Copado__Git_Repository__c repo,
        Id pipelineId
    ) {
        copado__Artifact__c pkg = new copado__Artifact__c();
        pkg.Name = 'Testpkg';
        pkg.copado__Package_Type__c = 'Unlocked';
        pkg.copado__Artifact_Repository__c = repo.Id;
        pkg.copado__Package_Id__c = '0Ho5g00000000VzCAI';
        pkg.copado__Pipeline__c = pipelineId;
        pkg.RecordTypeId = SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName()
            .get('Package_Artifact')
            .getRecordTypeId();

        insert pkg;
        return pkg;
    }

    private static copado__Artifact_Version__c createPackageVersion(
        Copado__Git_Repository__c repo,
        copado__Artifact__c pkg
    ) {
        copado__Artifact_Version__c version = new copado__Artifact_Version__c();
        version.copado__Artifact__c = pkg.Id;
        version.Name = 'ver 0.1';
        version.copado__Version_number__c = '0.1.0.1';
        version.copado__Subscriber_Version_Id__c = SUBSCRIBER_ID;

        insert version;
        return version;
    }

    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
    }
}