@IsTest
private class PackageCreateHandlerTest {
    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
        
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
            credential.copado__is_Developer_Hub_Org__c = true;
            insert credential;

            copado__JobTemplate__c template = TestDataFactory.createJobTemplate(
                'SFDX Package Create'
            );
            insert template;

            copado__Git_Repository__c repo = createRepository();

            createPackage(repo, createPipeline(repo.Id).Id, credential.Id);
        }
    }

    @IsTest
    private static void generatePackage() {
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            // Exercise

            Test.startTest();
            PackageCreateHandler.startCreate(getPackage()[0].Id);
            Test.stopTest();

            // Verify

            System.assertEquals(getJobExecution().size(), 1, 'Package generation failed');
        }
    }

    private static copado__Git_Repository__c createRepository() {
        copado__Git_Repository__c repo = new copado__Git_Repository__c(Name = 'My Repo');
        insert repo;
        return repo;
    }

    private static copado__Artifact__c createPackage(
        Copado__Git_Repository__c repo,
        Id pipelineId,
        Id credentialId
    ) {
        copado__Artifact__c pkg = new copado__Artifact__c();
        pkg.Name = 'Testpkg';
        pkg.copado__Package_Type__c = 'Unlocked';
        pkg.copado__Artifact_Repository__c = repo.Id;
        pkg.copado__Pipeline__c = pipelineId;
        pkg.copado__Target_Dev_Hub_Org__c = credentialId;
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

    private static List<copado__Artifact__c> getPackage() {
        return [SELECT Id FROM copado__Artifact__c];
    }

    private static List<copado__JobExecution__c> getJobExecution() {
        return [SELECT Id FROM copado__JobExecution__c];
    }
}