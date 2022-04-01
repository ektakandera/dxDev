@IsTest
private class PackageVersionCreateFlowTest {
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
                'SFDX Package Import'
            );
            insert template;

            copado__JobExecution__c execution = createJobExecution(template, environment);

            copado__Artifact__c pkg = createPackage(createRepository());
            
            copado__Result__c result = createResult(
                createJobStep('Create Package', execution.Id).Id,
                JSON.serialize(createVersion(pkg))
            );

            Map<String, Object> flowParams = getFlowParams(result.Id);

            // Exercise
            Test.startTest();
            new Flow.Interview.CreatePackageVersion(flowParams).start();
            Test.stopTest();

            // Verify
                       
            system.assertEquals(
                getResult(result?.Id).copado__Result_Data__c, 
                JSON.serialize(createVersion(pkg)),
                'Package version details not updated'
            );
            system.assertEquals(
                getInstallationkey()[0].InstallationKey__c,
                'test1234',
                'Insallation key updation failed'
            );
        }
    }

    private static copado__Git_Repository__c createRepository() {
        copado__Git_Repository__c repo = new copado__Git_Repository__c(Name = 'My Repo');
        insert repo;
        return repo;
    }

    private static Map<String, Object> getFlowParams(Id resultId) {
        Map<String, Object> flowParams = new Map<String, Object>{
            'packageVersionJson' => '{"Package2Id":"0Ho5g00000000VzCAI","Branch":null,"Tag":null,"MajorVersion":0,"MinorVersion":1,"PatchVersion":0,"BuildNumber":1,"Id":"05i5g00000000OcAAI","SubscriberPackageVersionId":"04t5g000000xwXMAAY","Name":"ver 0.1","NamespacePrefix":null,"Package2Name":"Testpkg","Description":null,"Version":"0.1.0.1","IsPasswordProtected":false,"IsReleased":false,"CreatedDate":"2021-09-01 11:42","LastModifiedDate":"2021-09-01 11:42","InstallUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000xwXMAAY","CodeCoverage":"","ValidationSkipped":false,"AncestorId":"N/A","AncestorVersion":"N/A","Alias":""}',
            'resultId' => resultId,
            'jsonInformation' => '{\"name\":\"testversion\",\"path\":\"force-app\",\"versionnumber\":\"\",\"branch\":\"master\",\"installationkeybypass\":false,\"installationkey\":\"test1234\",\"versiondescription\":\"\",\"package\":\"a0509000003waC9AAI\"}'
        };
        return flowParams;
    }

    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static copado__Artifact__c createPackage(Copado__Git_Repository__c repo) {
        copado__Artifact__c pkg = new copado__Artifact__c(
            Name = 'Testpkg',
            copado__Package_Type__c = 'Unlocked',
            copado__Artifact_Repository__c = repo.Id,
            copado__Package_Id__c = '0Ho5g00000000VzCAI',
            RecordTypeId = SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName()
                .get('Package_Artifact')
                .getRecordTypeId()
        );
        insert pkg;

        return pkg;
    }

    private static copado__JobExecution__c createJobExecution(
        copado__JobTemplate__c template,
        copado__Environment__c environment
    ) {
        copado__JobExecution__c execution = new copado__JobExecution__c(
            copado__Template__c = template.Id,
            copado__Destination__c = environment.Id
        );
        insert execution;

        return execution;
    }

    private static copado__JobStep__c createJobStep(String name, Id executionId) {
        copado__JobStep__c step = new copado__JobStep__c(
            Name = name,
            copado__JobExecution__c = executionId,
            copado__Type__c = 'Flow'
        );
        insert step;

        return step;
    }

    private static copado__Result__c createResult(Id stepId, String version) {
        copado__Result__c result = new copado__Result__c(
            copado__JobStep__c = stepId,
            copado__Result_Data__c = version,
            copado__Job_Type__c = 'Integration'
        );
        insert result;
        
        return result;
    }
    
    private static copado__Artifact_Version__c createVersion(copado__Artifact__c pkg) {
        String dataJSON = '{\"uninstallscript\":null,\"postinstallscript\":null,\"postinstallurl\":null,\"releasenotesurl\":null,\"skipvalidation\":null,\"codecoverage\":null,\"installationkeybypass\":false,\"tag\":null,\"overrideProjectJsonPath\":null,\"overridePath\":null,\"apiversion\":\"45.0\"}';

        copado__Artifact_Version__c result = new copado__Artifact_Version__c();
        result.copado__Artifact__c = pkg.Id;
        result.copado__Package_Version_Id__c = '05i5g00000000OcAAI';
        result.copado__Subscriber_Version_Id__c = '04t5g000000xwXMAAY';
        result.copado__Is_released__c = false;
        result.copado__Branch__c = null;
        result.copado__Version_Name__c = 'ver 0.1';
        result.copado__Tag__c = null;
        result.copado__Version_Description__c = null;
        result.copado__Version_number__c = '0.1.0.1';
        result.copado__Data_JSON__c = dataJSON;
        result.Name = pkg.Name + ' - ' + '0.1.0.1';
        
        return result;
    }

    private static copado__Result__c getResult(Id resultId) {
        return [SELECT copado__Result_Data__c FROM copado__Result__c WHERE Id = :resultId];
    }

    private static List<PackageVersionInstallationKey__c> getInstallationkey() {
        return [SELECT InstallationKey__c FROM PackageVersionInstallationKey__c];
    }
}