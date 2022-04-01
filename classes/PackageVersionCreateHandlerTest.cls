@IsTest
private class PackageVersionCreateHandlerTest {
    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
    }

    @IsTest
    private static void createPackageVersion() {
        
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            copado__Environment__c environment = TestDataFactory.createEnvironment(
                'DevHub',
                'Production/Developer',
                'SFDX'
            );
            insert environment;

            copado__Org__c credential = TestDataFactory.createCredential(
                'DevHub',
                'test@test.com',
                environment.Id,
                'Production/Developer'
            );
            insert credential;

            copado__JobTemplate__c template = TestDataFactory.createJobTemplate(
                'SFDX Package Version Create'
            );
            insert template;
            copado__Git_Repository__c repo = createRepository();
            copado__Artifact__c pkg = createPackage(repo, createPipeline(repo.Id).Id);

            // Exercise
            
            Test.startTest();
            PackageVersionCreateHandler.startCreate(createRequest(pkg.Id));
            Test.stopTest();

            // Verify
            
            system.assertEquals(getJobExecution().size(), 1, 'Package version creation failed');
        }
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

    private static copado__Deployment_Flow__c createPipeline(Id repositoryId) {
        copado__Deployment_Flow__c pipeline = new copado__Deployment_Flow__c(
            Name = 'My Pipeline',
            copado__Platform__c = 'SFDX',
            copado__Git_Repository__c = repositoryId
        );
        insert pipeline;
        return pipeline;
    }

    private static String createRequest(Id packageId) {
        Map<String, Object> flowParams = new Map<String, Object>{
            'package' => packageId,
            'versionname' => 'test56version',
            'versionnumber' => '',
            'versiondescription' => 'new package version',
            'jsonInformation' => '{"path":"force-app","versionnumber":"","branch":"master","installationkeybypass":true,"versiondescription":"","package":' +
            packageId +
            '}'
        };
        return JSON.serialize(flowParams);
    }

    private static List<copado__JobExecution__c> getJobExecution() {
        return [SELECT Id FROM copado__JobExecution__c];
    }
}