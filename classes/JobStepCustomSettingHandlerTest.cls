@IsTest
private class JobStepCustomSettingHandlerTest {
    @TestSetup
    private static void makeData() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            createData();
        }
    }

    @IsTest
    private static void getCustomSettings() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup

            String content = '{"records":[{"QualifiedApiName":"PackageVersionInstallationKey__c","DeveloperName":"PackageVersionInstallationKey"}]}';
            JobStepCustomSettingHandler.mockResponse = mockResponse(200, content);
            
            // Exercise

            Test.startTest();
            List<Object> records = JobStepCustomSettingHandler.getCustomSettings(getCredentialId());
            Test.stopTest();

            // Verify

            Map<String, Object> record = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(records[0]));
            System.assertEquals(
                record.get('QualifiedApiName'),
                'PackageVersionInstallationKey__c',
                'Should return QualifiedApiName of Custom Setting'
            );
            System.assertEquals(record.get('DeveloperName'), 'PackageVersionInstallationKey', 'Should return developer name');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void getRecords() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup

            String content = '{"records":[{"Id":"a1w09000000A8LuAAK","Name":"test","SetupOwnerId":"00D0900000B62zfEAB"}]}';
            JobStepCustomSettingHandler.mockResponse = mockResponse(200, content);
            
            // Exercise

            Test.startTest();
            List<Object> records = JobStepCustomSettingHandler.getRecords('PackageVersionInstallationKey__c', getCredentialId());
            Test.stopTest();

            // Verify

            Map<String, Object> record = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(records[0]));
            System.assertEquals(record.get('Id'), 'a1w09000000A8LuAAK', 'Should return Id of Custom Setting');
            System.assertEquals(record.get('Name'), 'test', 'Should return developer name');
            System.assertEquals(record.get('SetupOwnerId'), '00D0900000B62zfEAB', 'Should return SetupOwnerId');
        }
    }

    @IsTest
    private static void processFailureResponse() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // Setup

            JobStepCustomSettingHandler.mockResponse = mockResponse(201, '');

            // Exercise

            String message;
            try {
                Test.startTest();
                List<Object> records = JobStepCustomSettingHandler.getRecords('PackageVersionInstallationKey__c', getCredentialId());
                System.assertEquals(records, null, 'No records should be returned');
                Test.stopTest();
            } catch (Exception ex) {
                message = ex.getMessage();
            }

            // Verify

            System.assertEquals('Error in listing custom settings.', message, 'should throw an exception');
        }
    }
    
    // HELPER

    private static copado.GlobalAPI.ProxyOrgResponse mockResponse(Integer statusCode, String content) {
        copado.GlobalAPI.ProxyOrgResponse result = new copado.GlobalAPI.ProxyOrgResponse();
        result.statusCode = statusCode;
        result.content = content;
        return result;
    }

    private static void createData() {
        copado__Environment__c environment = TestDataFactory.createEnvironment('Src Env', null, 'SFDX');
        insert environment;

        copado__Org__c credential = TestDataFactory.createCredential('Src Cred', UserInfo.getUserName(), environment.Id, null);
        insert credential;

        copado__User_Story__c story = TestDataFactory.createUserStory('US 1', 'Draft', null, null, null, credential.Id);
        insert story;
    }

    private static Id getCredentialId() {
        return [SELECT copado__Org_Credential__c FROM copado__User_Story__c LIMIT 1].copado__Org_Credential__c;
    }
}