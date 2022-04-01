@IsTest
private class UserStoryMetadataListCtlrTest {
    @TestSetup
    private static void makeData() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            createData();
        }
    }

    @IsTest
    private static void createFileFromAttachment() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup
            Id credentialId = getCredentialId();

            // Exercise
            Test.startTest();
            Map<String, Object> result1 = UserStoryMetadataListCtlr.createFileFromAttachment(credentialId, 'Metadata');
            Map<String, Object> result2 = UserStoryMetadataListCtlr.createFileFromAttachment(credentialId, 'Metadata');
            Test.stopTest();

            // Verify
            System.assertEquals(true, (Boolean) result1.get('isSuccess'), 'The success parameter should return true');
            System.assert(
                ((String) result1.get('recordId')).startsWith(ContentVersion.SObjectType.getDescribe().getKeyPrefix()),
                'The record id parameter must belong to content version'
            );
            System.assertEquals(true, (Boolean) result2.get('isSuccess'), 'The success parameter should return true');
            System.assert(
                ((String) result2.get('recordId')).startsWith(ContentVersion.SObjectType.getDescribe().getKeyPrefix()),
                'The record id parameter must belong to content version'
            );
            System.assert(
                (String) result1.get('recordId') != (String) result2.get('recordId'),
                'The content version ids should be different' // since the files are recreated everytime
            );
        }
    }

    private static void createData() {
        copado__Environment__c environment = TestDataFactory.createEnvironment('Src Env', null, 'SFDX');
        insert environment;

        copado__Org__c credential = TestDataFactory.createCredential('Src Cred', UserInfo.getUserName(), environment.Id, null);
        insert credential;

        copado__User_Story__c story = TestDataFactory.createUserStory('US 1', 'Draft', null, null, null, credential.Id);
        insert story;

        Attachment attachment = TestDataFactory.createAttachment(credential.Id, 'Metadata');
        insert attachment;
    }

    private static Id getCredentialId() {
        return [SELECT copado__Org_Credential__c FROM copado__User_Story__c LIMIT 1].copado__Org_Credential__c;
    }
}