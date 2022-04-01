@IsTest
private class SetApexTestLevelTest {
    @TestSetup
    private static void makeData() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            createData();
        }
    }

    @IsTest
    private static void setEmptyValue() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup

            copado__User_Story__c userStory = getUserStory();
            userStory.copado__Promotion_Test_Level__c = null;

            // Exercise

            Test.startTest();
            update userStory;
            Test.stopTest();

            // Verify

            userStory = getUserStory();
            System.assertEquals(userStory.Apex_Test_Level__c, null, 'Apex_Test_Level__c should be updated to null');
        }
    }

    @IsTest
    private static void setNoRunTest() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            
            copado__User_Story__c userStory = getUserStory();
            userStory.copado__Promotion_Test_Level__c = 'NoTestRun';

            // Exercise

            Test.startTest();
            update userStory;
            Test.stopTest();

            // Verify
            
            userStory = getUserStory();
            System.assertEquals(userStory.Apex_Test_Level__c, 'No Test Run', 'Apex_Test_Level__c should be updated to No Test Run');
        }
    }

    @IsTest
    private static void setRunSpecifiedTest() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            
            copado__User_Story__c userStory = getUserStory();
            userStory.copado__Promotion_Test_Level__c = 'RunSpecifiedTests';

            // Exercise

            Test.startTest();
            update userStory;
            Test.stopTest();

            // Verify
            
            userStory = getUserStory();
            System.assertEquals(userStory.Apex_Test_Level__c, 'Run Specified Tests', 'Apex_Test_Level__c should be updated to Run Specified Tests');
        }
    }

    @IsTest
    private static void setRunLocalTest() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            
            copado__User_Story__c userStory = getUserStory();
            userStory.copado__Promotion_Test_Level__c = 'RunLocalTests';

            // Exercise

            Test.startTest();
            update userStory;
            Test.stopTest();

            // Verify
            
            userStory = getUserStory();
            System.assertEquals(userStory.Apex_Test_Level__c, 'Run Local Tests', 'Apex_Test_Level__c should be updated to Run Local Tests');
        }
    }

    @IsTest
    private static void setRunAllTest() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            
            copado__User_Story__c userStory = getUserStory();
            userStory.copado__Promotion_Test_Level__c = 'RunAllTestsInOrg';

            // Exercise

            Test.startTest();
            update userStory;
            Test.stopTest();

            // Verify
            
            userStory = getUserStory();
            System.assertEquals(userStory.Apex_Test_Level__c, 'Run All Tests In Org', 'Apex_Test_Level__c should be updated to Run All Tests In Org');
        }
    }

    private static copado__User_Story__c getUserStory() {
        return [SELECT Id, Apex_Test_Level__c FROM copado__User_Story__c].get(0);
    }

    private static void createData() {
        copado__User_Story__c story = new copado__User_Story__c(copado__User_Story_Title__c = 'US 1', copado__Status__c = 'Draft');
        insert story;
    }
}