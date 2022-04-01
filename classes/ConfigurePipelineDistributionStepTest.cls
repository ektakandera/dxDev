@IsTest
private class ConfigurePipelineDistributionStepTest {

    @TestSetup
    private static void makeData() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            createData();
        }
    }

    @IsTest
    private static void createDeploymentStepForNewStory() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup

            copado__Artifact_Version__c version = getVersion();

            ConfigurePipelineDistributionStep.Request request = new ConfigurePipelineDistributionStep.Request();
            request.newSerializedUserStory = '{"copado__User_Story_Title__c": "Install PackageTest - 1.0.0.0"}';
            request.packageVersionId = version.Id;

            // Exercise

            ConfigurePipelineDistributionStep.Result result = ConfigurePipelineDistributionStep.createDeploymentStep(
                    new List<ConfigurePipelineDistributionStep.Request>{ request }
                )
                .get(0);

            // Verify

            List<copado__User_Story__c> story = getUserStoryWithSteps();

            System.assertEquals(1, story.size(), 'New user story should be created.');
            System.assertEquals(result.userStoryId, story[0].Id, 'Result should contain new user story.');
            System.assertEquals(1, story[0].copado__JobSteps__r.size(), 'New deployment step should be created for user story.');

            copado__JobStep__c step = story[0].copado__JobSteps__r[0];
            System.assertEquals(1, step.copado__Order__c, 'Order of step should be 1.');
            System.assertEquals('Start Pkg - 1.0.0.0 Installation Job', step.Name, 'Step name should be correct.');

            ConfigurePipelineDistributionStep.ConfigJson configJson = (ConfigurePipelineDistributionStep.ConfigJson) JSON.deserialize(
                step.copado__ConfigJson__c,
                ConfigurePipelineDistributionStep.ConfigJson.class
            );
            System.assertEquals(2, configJson.parameters.size(), 'Step name should be correct.');
            System.assert(configJson.flowName.contains('InitiatePipelineDistribution'), 'Step name should be correct.');
            
            List<ConfigurePipelineDistributionStep.Parameter> params = new List<ConfigurePipelineDistributionStep.Parameter>{
                new ConfigurePipelineDistributionStep.Parameter('packageVersionId', version.Id),
                new ConfigurePipelineDistributionStep.Parameter('deploymentId', '{$Job.ExecutionParent.Id}')
            };
            System.assertEquals(params.toString(), configJson.parameters.toString(), 'Parameters should be correct.');
        }
    }


    @IsTest
    private static void createDeploymentStepForExistingStory() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup

            copado__User_Story__c us = TestDataFactory.createUserStory('US', 'Draft', null, null, null, null);
            insert us;

            insert new copado__JobStep__c(
                Name = 'Step 1',
                copado__UserStory__c = us.Id,
                copado__ExecutionSequence__c = 'after',
                copado__Order__c = 1,
                copado__Type__c = 'Flow'
            );

            ConfigurePipelineDistributionStep.Request request = new ConfigurePipelineDistributionStep.Request();
            request.existingUserStoryId = us.Id;
            request.packageVersionId = getVersion().Id;

            // Exercise

            ConfigurePipelineDistributionStep.Result result = ConfigurePipelineDistributionStep.createDeploymentStep(
                    new List<ConfigurePipelineDistributionStep.Request>{ request }
                )
                .get(0);

            // Verify

            List<copado__User_Story__c> story = getUserStoryWithSteps();

            System.assertEquals(1, story.size(), 'Only existing user story should be present.');
            System.assertEquals(result.userStoryId, story[0].Id, 'Result should contain existing user story.');
            System.assertEquals(2, story[0].copado__JobSteps__r.size(), 'New deployment step should be created for user story.');
            System.assertEquals(2, story[0].copado__JobSteps__r[0].copado__Order__c, 'Order of step should be 2.');
        }
    }

    // HELPER

    private static void createData() {
        copado__Git_Repository__c repository = TestDataFactory.createGitRepository('Repo');
        insert repository;

        copado__Environment__c environment = TestDataFactory.createEnvironment('Env', 'Production/Developer', 'SFDX');
        insert environment;

        copado__Org__c credential = TestDataFactory.createCredential(
            'Cred',
            UserInfo.getUserName(),
            environment.Id,
            'Production/Developer'
        );
        credential.copado__is_Developer_Hub_Org__c = true;
        insert credential;

        copado__Artifact__c pkg = TestDataFactory.createPackage('Pkg', 'Package_Artifact');
        pkg.copado__Artifact_Repository__c = repository.Id;
        pkg.copado__Target_Dev_Hub_Org__c = credential.Id;
        insert pkg;

        copado__Artifact_Version__c version = TestDataFactory.createPackageVersion('Pkg V1', pkg.Id);
        version.copado__Version_number__c = '1.0.0.0';
        insert version;
    }


    private static List<copado__User_Story__c> getUserStoryWithSteps() {
        return [
            SELECT
                Id,
                (
                    SELECT Name, copado__ConfigJson__c, copado__Order__c
                    FROM copado__JobSteps__r
                    ORDER BY copado__Order__c DESC
                )
            FROM copado__User_Story__c
        ];
    }

    private static copado__Artifact_Version__c getVersion() {
        return [SELECT Id FROM copado__Artifact_Version__c LIMIT 1];
    }
}