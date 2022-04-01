@IsTest
private with sharing class UserStoryCommitTableActionsCtrlTest {
    @TestSetup
    private static void setup() {
        copado__Environment__c env = new copado__Environment__c();
        env.Name = 'Dev env';
        env.copado__Index_Back_Promotion_metadata__c = true;
        env.copado__Type__c = 'Production/Developer';
        insert env;

        copado__Org__c org = new copado__Org__c();
        org.Name = 'Uat2';
        org.copado__Org_Type__c = 'Production/Developer';
        org.copado__Oauth_Signature__c = 'signature';
        org.copado__Username__c = 'testusername@test.com';
        org.copado__Environment__c = env.Id;

        insert org;
    }

    @IsTest
    private static void isSourceMemberAvailable() {
        // Setup
        copado__Org__c org = [SELECT Id FROM copado__Org__c LIMIT 1];

        insert new Attachment(Name = 'MetaData', Body = Blob.valueOf('[{"n": "ExampleTest", "t": "ApexClass"}]'), ParentId = org.Id);

        // Exercise
        Test.startTest();
        Boolean isSourceMemberAvailable = UserStoryCommitTableActionsCtrl.isSourceMemberAvailable(org.Id);
        Test.stopTest();

        // Verify
        System.assert(isSourceMemberAvailable, 'Source member should be available');
    }

    @IsTest
    private static void retrieveRecentChanges() {
        // Setup
        copado__Org__c org = [SELECT Id FROM copado__Org__c LIMIT 1];

        // Exercise
        Test.startTest();
        List<copado.SourceMemberResult> recentChanges = UserStoryCommitTableActionsCtrl.retrieveRecentChanges(
            org.Id,
            DateTime.newInstance(2021, 2, 6)
        );
        Test.stopTest();

        // Verify
        System.assertEquals(1, recentChanges.size(), 'Recent changes result should match');
    }

    @IsTest
    private static void listAllSobjectsInOrg() {
        // Setup
        copado__Org__c org = [SELECT Id FROM copado__Org__c LIMIT 1];

        // Exercise
        Test.startTest();
        List<SobjectItem> allSobjects = UserStoryCommitTableActionsCtrl.listAllSobjectsInOrg(org.Id);
        Test.stopTest();

        // Verify
        System.assertEquals(MetadataTypes.supportedMetadataTypes().size(), allSobjects.size(), 'All sObjects result should match');
    }

    @IsTest
    private static void searchMetadata() {
        // Setup
        copado__Org__c org = [SELECT Id FROM copado__Org__c LIMIT 1];

        // Exercise
        Test.startTest();
        List<MetadataSearchResult> searchMetadata = UserStoryCommitTableActionsCtrl.searchMetadata(org.Id, 'ApexClass', 'test');
        Test.stopTest();

        // Verify
        System.assertEquals('DummyClassForTest', searchMetadata[0].name, 'Metadata Name is not as expected');
        System.assertEquals('ApexClass', searchMetadata[0].type, 'Metadata Type is not as expected');
    }

    @IsTest
    private static void searchMetadataException() {
        // Setup & Exercise
        String exceptionMessage;
        Test.startTest();
        try {
            UserStoryCommitTableActionsCtrl.searchMetadata('', 'ApexComponent', 'test');
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        // Verify
        System.assert(String.isNotBlank(exceptionMessage), 'Exception should have been thrown');
    }
}