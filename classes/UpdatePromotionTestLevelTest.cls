@IsTest
private class UpdatePromotionTestLevelTest {
    @IsTest
    private static void onInsert() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');

            // Exercise

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run Local Tests', 'Run Specified Tests', 'No Test Run' }
            );

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run Local Tests', p.Apex_Test_Level__c, 'Test Levels are incorrect.');
        }
    }

    @IsTest
    private static void onDelete() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run Local Tests', 'Run Specified Tests', 'No Test Run' }
            );

            // Exercise

            copado__Promoted_User_Story__c toDelete = byStoryTestLevel('Run Local Tests');
            delete toDelete;

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run Specified Tests', p.Apex_Test_Level__c, 'Test Levels are incorrect.');
        }
    }

    @IsTest
    private static void onUpdate() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run Local Tests', 'Run Specified Tests', 'No Test Run' }
            );

            // Exercise

            copado__Promoted_User_Story__c toUpdate = byStoryTestLevel('Run Local Tests');
            toUpdate.copado__Status__c = 'Outdated';
            update toUpdate;

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run Specified Tests', p.Apex_Test_Level__c, 'Test Levels are incorrect.');
        }
    }

    @IsTest
    private static void onInsertWithRunAllTestEnv() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');
            setRunAllTestAsTrue();

            // Exercise

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run Specified Tests', 'No Test Run' }
            );

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run All Tests In Org', p.Apex_Test_Level__c, 'Test Levels should not change.');
        }
    }

    @IsTest
    private static void onDeleteWithRunAllTestEnv() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');
            setRunAllTestAsTrue();

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run All Tests In Org', 'Run Specified Tests' }
            );

            // Exercise

            copado__Promoted_User_Story__c toDelete = byStoryTestLevel('Run All Tests In Org');
            delete toDelete;

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run All Tests In Org', p.Apex_Test_Level__c, 'Test Levels should not change.');
        }
    }

    @IsTest
    private static void onUpdateWithRunAllTestEnv() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');
            setRunAllTestAsTrue();

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run All Tests In Org', 'No Test Run' }
            );

            // Exercise

            copado__Promoted_User_Story__c toUpdate = byStoryTestLevel('Run All Tests In Org');
            toUpdate.copado__Status__c = 'Outdated';
            update toUpdate;

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run All Tests In Org', p.Apex_Test_Level__c, 'Test Levels should not change.');
        }
    }

    @IsTest
    private static void onAllUpdateToOutdated() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('SFDX');

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run All Tests In Org', 'Run Specified Tests', 'No Test Run' }
            );

            // Exercise

            ps[0].copado__Status__c = 'Outdated';
            ps[1].copado__Status__c = 'Outdated';
            ps[2].copado__Status__c = 'Outdated';
            update ps;

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('Run All Tests In Org', p.Apex_Test_Level__c, 'Test Levels should not change.');
        }
    }

    @IsTest
    private static void forOtherPlatform() {
        System.runAs(getRunAsUser()) {
            // Setup

            createData('Salesforce');

            // Exercise

            List<copado__Promoted_User_Story__c> ps = addStoriesToPromotionWithLevels(
                new Set<String>{ 'Run All Tests In Org', 'Run Specified Tests', 'No Test Run' }
            );

            // Verify

            copado__Promotion__c p = promotion(ps[0].copado__Promotion__c);
            System.assertEquals('No Test Run', p.Apex_Test_Level__c, 'Test Levels should not update.');
        }
    }

    // HELPER

    @TestSetup
    private static void setup() {
        User u = TestDataFactory.createUser('Standard User');
        insert u;

        TestDataFactory.assignPermissionSet(u, new Set<String>{ 'Copado_User', 'Copado_Job_Engine', 'CMC_SFDX_Admin' });

        System.runAs(u) {
            TestDataFactory.assignLicense(u.Id, true, true, true, true, true);
        }
    }

    private static void createData(String platform) {
        copado__Git_Repository__c repo = TestDataFactory.createGitRepository('Repo 1');
        insert repo;

        copado__Environment__c sEnv = TestDataFactory.createEnvironment('Src', 'Production/Developer', platform);
        copado__Environment__c dEnv = TestDataFactory.createEnvironment('Dst', 'Production/Developer', platform);
        insert new List<copado__Environment__c>{ sEnv, dEnv };

        copado__Org__c sCred = TestDataFactory.createCredential('Src', UserInfo.getUserName(), sEnv.Id, null);
        copado__Org__c dCred = TestDataFactory.createCredential('Dst', UserInfo.getUserName(), dEnv.Id, null);
        insert new List<copado__Org__c>{ sCred, dCred };

        copado__JobTemplate__c promotionJob = TestDataFactory.createJobTemplate('Promotion');
        insert promotionJob;

        copado__Deployment_Flow__c pipeline = TestDataFactory.createPipeline('Pipeline1', repo.Id);
        pipeline.copado__Platform__c = platform;
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

        List<copado__User_Story__c> stories = new List<copado__User_Story__c>();

        for (String testLevel : UpdatePromotionTestLevel.TEST_LEVELS_IN_ORDER) {
            stories.add(
                new copado__User_Story__c(
                    copado__Project__c = project.Id,
                    copado__Org_Credential__c = sCred.Id,
                    Apex_Test_Level__c = testLevel
                )
            );
        }

        insert stories;

        insert new copado__Promotion__c(
            copado__Project__c = project.Id,
            copado__Source_Environment__c = sEnv.Id,
            copado__Source_Org_Credential__c = sCred.Id,
            copado__Destination_Environment__c = dEnv.Id,
            copado__Destination_Org_Credential__c = dCred.Id
        );
    }

    private static List<copado__Promoted_User_Story__c> addStoriesToPromotionWithLevels(Set<String> testLevels) {
        List<copado__Promoted_User_Story__c> ps = new List<copado__Promoted_User_Story__c>();

        copado__Promotion__c promotion = [SELECT Id FROM copado__Promotion__c LIMIT 1];

        for (copado__User_Story__c story : [
            SELECT Id
            FROM copado__User_Story__c
            WHERE Apex_Test_Level__c IN :testLevels
        ]) {
            ps.add(
                new copado__Promoted_User_Story__c(
                    copado__Promotion__c = promotion.Id,
                    copado__User_Story__c = story.Id
                )
            );
        }

        insert ps;
        return ps;
    }

    private static copado__Promotion__c promotion(Id pId) {
        return [SELECT Apex_Test_Level__c FROM copado__Promotion__c WHERE Id = :pId LIMIT 1];
    }

    private static copado__Promoted_User_Story__c byStoryTestLevel(String testLevel) {
        return [
            SELECT Id
            FROM copado__Promoted_User_Story__c
            WHERE copado__User_Story__r.Apex_Test_Level__c = :testLevel
            LIMIT 1
        ];
    }

    private static void setRunAllTestAsTrue() {
        copado__Environment__c dEnv = [SELECT Id FROM copado__Environment__c WHERE Name = 'Dst' LIMIT 1];
        dEnv.copado__Run_all_tests__c = true;
        update dEnv;
    }

    private static User getRunAsUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'Standard User' AND UserName LIKE '%testcmcsf@copado.com%'
            LIMIT 1
        ];
    }
}