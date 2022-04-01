@IsTest
private class InitiatePipelineDistributionTest {

    @TestSetup
    private static void makeData() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            createData();
        }
    }

    @IsTest
    private static void startExecution() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup

            Id deploymentId = [SELECT Id FROM copado__Deployment__c LIMIT 1].Id;
            Id packageVersionId = [SELECT Id FROM copado__Artifact_Version__c LIMIT 1].Id;

            Map<String, Object> flowParams = new Map<String, Object>{
                'deploymentId' => deploymentId,
                'packageVersionId' => packageVersionId
            };

            // Exercise

            Test.startTest();
            new Flow.Interview.InitiatePipelineDistribution(flowParams).start();
            Test.stopTest();

            // Verify

            List<copado__JobExecution__c> job = [SELECT Id FROM copado__JobExecution__c WHERE copado__Template__r.Name = 'SFDX Package Distribution'];

            System.assertEquals(1, job.size(), 'Job Execution not started.');
        }
    }


    @IsTest
    private static void exception() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup

            Exception expectedException = null;
            InitiatePipelineDistribution.Request request = new InitiatePipelineDistribution.Request();

            // Exercise

            try {
                InitiatePipelineDistribution.startExecution(new List<InitiatePipelineDistribution.Request>{ request });
            } catch (Exception ex) {
                expectedException = ex;
            }

            // Verify

            System.assert(expectedException != null, 'Exception should be thrown.');
        }
    }

    // HELPER

    private static void createData() {
        copado__Git_Repository__c repo = TestDataFactory.createGitRepository('Repo 1');
        insert repo;

        copado__Environment__c sEnv = TestDataFactory.createEnvironment('Src Env', 'Production/Developer', 'SFDX');
        copado__Environment__c dEnv = TestDataFactory.createEnvironment('Dst Env', 'Production/Developer', 'SFDX');
        insert new List<copado__Environment__c>{ sEnv, dEnv };

        copado__Org__c sCred = TestDataFactory.createCredential('Src Cred', UserInfo.getUserName(), sEnv.Id, null);
        copado__Org__c dCred = TestDataFactory.createCredential('Dst Cred', UserInfo.getUserName(), dEnv.Id, null);
        sCred.copado__is_Developer_Hub_Org__c = true;
        insert new List<copado__Org__c>{ sCred, dCred };

        copado__JobTemplate__c promotionJob = TestDataFactory.createJobTemplate('Promotion');
        insert promotionJob;

        copado__Deployment_Flow__c pipeline = TestDataFactory.createPipeline('Pipeline1', repo.Id);
        pipeline.copado__Platform__c = 'SFDX';
        pipeline.copado__Promotion_Job_Template__c = promotionJob.Id;
        insert pipeline;

        copado__Deployment_Flow_Step__c pipelineConnection = TestDataFactory.createPipelineConnection(
            pipeline.Id,
            sEnv.Id,
            dEnv.Id
        );
        insert pipelineConnection;

        copado__Project__c project = TestDataFactory.createProject('Project 1', pipeline.Id);
        insert project;

        copado__User_Story__c stories = new copado__User_Story__c(
            copado__Project__c = project.Id,
            copado__Org_Credential__c = sCred.Id
        );

        insert stories;

        copado__Promotion__c promotion = new copado__Promotion__c(
            copado__Project__c = project.Id,
            copado__Source_Environment__c = sEnv.Id,
            copado__Source_Org_Credential__c = sCred.Id,
            copado__Destination_Environment__c = dEnv.Id,
            copado__Destination_Org_Credential__c = dCred.Id
        );
        insert promotion;

        copado__JobStep__c step = new copado__JobStep__c(
            Name = 'Start Installation Job',
            copado__UserStory__c = stories.Id,
            copado__Type__c = 'Flow',
            copado__CustomType__c = 'Flow',
            copado__ExecutionSequence__c = 'after',
            copado__Order__c = 1
        );
        insert step;

        copado__Deployment__c deployment = new copado__Deployment__c(
            Name = 'Deployment 1',
            copado__Promotion__c = promotion.Id
        );
        insert deployment;

        copado__Artifact__c pkg = TestDataFactory.createPackage('Pkg1', 'Package_Artifact');
        pkg.copado__Artifact_Repository__c = repo.Id;
        pkg.copado__Target_Dev_Hub_Org__c = sCred.Id;
        insert pkg;

        copado__Artifact_Version__c version = TestDataFactory.createPackageVersion('Pkg1_v1', pkg.Id);
        insert version;

        copado__JobTemplate__c template = TestDataFactory.createJobTemplate('SFDX Package Distribution');
        insert template;
    }
}