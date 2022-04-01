@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId')
private class ImportPackageAndVersionFlowTest {
    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
    }

    @IsTest
    private static void insertPackageAndVersion() {
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            DataHelper helper = new DataHelper()
                .createRepository('My Repo')
                .createPipeline('My Pipeline')
                .createEnvironment('DevHub')
                .addCredential('DevHub Admin')
                .getFlowParams();

            // Exercise

            Test.startTest();
            new Flow.Interview.ImportPackageAndVersions(helper.flowParams).start();
            Test.stopTest();

            // Verify

            List<copado__Artifact__c> packages = helper.getPackages();

            System.assertEquals(packages.size(), 1, 'Package upsertion failed');
            System.assertEquals(packages.get(0).copado__Artifact_Versions__r.size(), 2, 'Package version upsertion failed');
        }
    }

    @IsTest
    private static void updatePackageAndVersion() {
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            DataHelper helper = new DataHelper()
                .createRepository('My Repo')
                .createPipeline('My Pipeline')
                .createPackage('Testpkg')
                .createPackageVersion('ver 0.1')
                .getFlowParams();

            // Exercise

            Test.startTest();
            new Flow.Interview.ImportPackageAndVersions(helper.flowParams).start();
            Test.stopTest();

            // Verify

            List<copado__Artifact__c> packages = helper.getPackages();

            System.assertEquals(packages.get(0).copado__Description__c, 'Package Description', 'Package description upsertion failed');
            System.assertEquals(
                packages.get(0).copado__Artifact_Versions__r.get(0).copado__Version_Description__c,
                'Package Version Description',
                'Package version description upsertion failed'
            );
        }
    }

    @IsTest
    private static void importNewVersion() {
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            DataHelper helper = new DataHelper()
                .createRepository('My Repo')
                .createPipeline('My Pipeline')
                .createPackage('Testpkg')
                .createPackageVersion('ver 0.1')
                .getFlowParams();

            // Exercise

            Test.startTest();
            new Flow.Interview.ImportPackageAndVersions(helper.flowParams).start();
            Test.stopTest();

            // Verify

            List<copado__Artifact__c> packages = helper.getPackages();

            System.assertEquals(
                packages.get(0).copado__Artifact_Versions__r.size(),
                2,
                'Importing new version failed'
            );
        }
    }

    @IsTest
    private static void throwInvalidPipelineException() {
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            DataHelper helper = new DataHelper();
            helper.pipelineId = helper.getFakeId(copado__Deployment_Flow__c.SObjectType);
            helper = helper.createRepository('My Repo')
                .createEnvironment('DevHub')
                .createJobTemplate('SFDX Package Import')
                .createJobExecution()
                .createJobStep('Create Package and Version records.')
                .createResult()
                .getFlowParams();

            // Exercise

            Test.startTest();
            new Flow.Interview.ImportPackageAndVersions(helper.flowParams).start();
            Test.stopTest();

            // Verify

            System.assertEquals(
                helper.getResult(helper.result.Id).copado__Progress_Status__c,
                'An Apex error occurred: ' +
                ApplicationException.class.getName() +
                ': ' +
                System.Label.InvalidPipeline,
                'Invalid pipeline Id. Package creation should failed.'
            );
        }
    }

    @IsTest
    private static void throwBulkRequestNotSupportedException() {
        // Setup

        System.runAs(TestUtilities.getRunAsUser()) {
            DataHelper helper = new DataHelper().createRepository('My Repo').createPipeline('My Pipeline').getPackageRequests();

            String exceptionMessage;

            // Exercise

            try {
                Test.startTest();
                ImportPackageAction.execute(helper.requests);
                Test.stopTest();
            } catch (Exception ex) {
                exceptionMessage = ex.getMessage();
            }

            // Verify

            System.assertEquals(exceptionMessage, System.Label.BulkPackageImportNotSupported, 'Should throw an exception for more than one request.');
        }
    }

    // HELPER

    private class DataHelper {
        private Id pipelineId;
        private copado__Git_Repository__c repository;
        private copado__Org__c credential;
        private copado__Artifact__c pkg;
        private copado__Environment__c environment;
        private copado__JobTemplate__c template;
        private copado__JobExecution__c execution;
        private copado__JobStep__c step;
        private copado__Result__c result;
        private List<ImportPackageAction.Request> requests;
        private Map<String, Object> flowParams;

        private DataHelper createPipeline(String name) {
            copado__Deployment_Flow__c pipeline = TestDataFactory.createPipeline(name, repository.Id);
            pipeline.copado__Platform__c = 'SFDX';
            insert pipeline;

            pipelineId = pipeline.Id;

            return this;
        }

        private DataHelper createRepository(String name) {
            repository = TestDataFactory.createGitRepository(name);
            insert repository;

            return this;
        }

        private DataHelper createPackage(String name) {
            pkg = new copado__Artifact__c();
            pkg.Name = name;
            pkg.copado__Package_Type__c = 'Unlocked';
            pkg.copado__Artifact_Repository__c = repository.Id;
            pkg.copado__Package_Id__c = '0Ho5g00000000VzCAI';
            pkg.RecordTypeId = SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName().get('Package_Artifact').getRecordTypeId();
            insert pkg;

            return this;
        }

        private DataHelper createPackageVersion(String name) {
            copado__Artifact_Version__c version = new copado__Artifact_Version__c();
            version.copado__Artifact__c = pkg.Id;
            version.Name = name;
            version.copado__Version_number__c = '0.1.0.1';
            version.copado__Subscriber_Version_Id__c = '04t5g000000xwXMAAY';
            insert version;

            return this;
        }

        private DataHelper createEnvironment(String name) {
            environment = TestDataFactory.createEnvironment(name, 'Production/Developer', 'Salesforce');
            insert environment;

            return this;
        }

        private DataHelper addCredential(String name) {
            copado__Org__c credential = TestDataFactory.createCredential(name, UserInfo.getUserName(), environment.Id, environment.copado__Type__c);
            credential.copado__is_Developer_Hub_Org__c = true;
            insert credential;

            return this;
        }

        private DataHelper createJobTemplate(String name) {
            template = TestDataFactory.createJobTemplate(name);
            insert template;

            return this;
        }

        private DataHelper createJobExecution() {
            execution = new copado__JobExecution__c(copado__Template__c = template.Id, copado__Destination__c = environment.Id);
            insert execution;

            return this;
        }

        private DataHelper createJobStep(String name) {
            step = new copado__JobStep__c(Name = name, copado__JobExecution__c = execution.Id, copado__Type__c = 'Flow');
            insert step;

            return this;
        }

        private DataHelper createResult() {
            result = new copado__Result__c();
            result.copado__JobStep__c = step.Id;
            result.copado__Job_Type__c = 'Integration';
            insert result;

            return this;
        }

        private DataHelper getPackageRequests() {
            requests = new List<ImportPackageAction.Request>();
            ImportPackageAction.Request request = new ImportPackageAction.Request();
            request.pipelineId = pipelineId;
            request.packageJson = '{"pkg":{"Id":"0Ho5g00000000VzCAI","SubscriberPackageId":"0335g000000xW5pAAE","Name":"Testpkg1","Description":null,"NamespacePrefix":null,"ContainerOptions":"Unlocked","Alias":""},"versions":[{"Package2Id":"0Ho5g00000000VzCAI","Branch":null,"Tag":null,"MajorVersion":0,"MinorVersion":1,"PatchVersion":0,"BuildNumber":1,"Id":"05i5g00000000OcAAI","SubscriberPackageVersionId":"04t5g000000xwXMAAY","Name":"ver 0.1","NamespacePrefix":null,"Package2Name":"Testpkg","Description":null,"Version":"0.1.0.1","IsPasswordProtected":false,"IsReleased":false,"CreatedDate":"2021-09-01 11:42","LastModifiedDate":"2021-09-01 11:42","InstallUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000xwXMAAY","CodeCoverage":"","ValidationSkipped":false,"AncestorId":"N/A","AncestorVersion":"N/A","Alias":""}]}';
            requests.add(request);

            request = new ImportPackageAction.Request();
            request.pipelineId = pipelineId;
            request.packageJson = '{"pkg":{"Id":"0Ho5g00000000VzCA0","SubscriberPackageId":"0335g000000xW5pAAK","Name":"Testpkg2","Description":null,"NamespacePrefix":null,"ContainerOptions":"Unlocked","Alias":""},"versions":[{"Package2Id":"0Ho5g00000000VzCA0","Branch":null,"Tag":null,"MajorVersion":0,"MinorVersion":1,"PatchVersion":0,"BuildNumber":1,"Id":"05i5g00000000OcAAK","SubscriberPackageVersionId":"04t5g000000xwXMAAZ","Name":"ver 0.1","NamespacePrefix":null,"Package2Name":"Testpkg","Description":null,"Version":"0.1.0.1","IsPasswordProtected":false,"IsReleased":false,"CreatedDate":"2021-09-01 11:42","LastModifiedDate":"2021-09-01 11:42","InstallUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000xwXMAAZ","CodeCoverage":"","ValidationSkipped":false,"AncestorId":"N/A","AncestorVersion":"N/A","Alias":""}]}';
            requests.add(request);

            return this;
        }

        private DataHelper getFlowParams() {
            Map<String, Object> jsonInformation = String.isNotBlank(credential?.Id)
                ? new Map<String, Object>{ 'devhub' => credential.Id }
                : new Map<String, Object>();

            flowParams = new Map<String, Object>{
                'packageJson' => '{"pkg":{"Id":"0Ho5g00000000VzCAI","SubscriberPackageId":"0335g000000xW5pAAE","Name":"Testpkg","Description":"Package Description","NamespacePrefix":null,"ContainerOptions":"Unlocked","Alias":""},"versions":[{"Package2Id":"0Ho5g00000000VzCAI","Branch":null,"Tag":null,"MajorVersion":0,"MinorVersion":1,"PatchVersion":0,"BuildNumber":1,"Id":"05i5g00000000OcAAI","SubscriberPackageVersionId":"04t5g000000xwXMAAY","Name":"ver 0.1","NamespacePrefix":null,"Package2Name":"Testpkg","Description":"Package Version Description","Version":"0.1.0.1","IsPasswordProtected":false,"IsReleased":false,"CreatedDate":"2021-09-01 11:42","LastModifiedDate":"2021-09-01 11:42","InstallUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000xwXMAAY","CodeCoverage":"","ValidationSkipped":false,"AncestorId":"N/A","AncestorVersion":"N/A","Alias":""},{"Package2Id":"0Ho5g00000000VzCAI","Branch":null,"Tag":null,"MajorVersion":0,"MinorVersion":1,"PatchVersion":0,"BuildNumber":2,"Id":"05i5g00000000OzAAI","SubscriberPackageVersionId":"04t5g000000xrXMAAY","Name":"ver 0.2","NamespacePrefix":null,"Package2Name":"Testpkg","Description":"Package Version Description","Version":"0.1.0.2","IsPasswordProtected":false,"IsReleased":false,"CreatedDate":"2021-09-01 11:42","LastModifiedDate":"2021-09-01 11:42","InstallUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000xrXMAAY","CodeCoverage":"","ValidationSkipped":false,"AncestorId":"N/A","AncestorVersion":"N/A","Alias":""}]}',
                'pipelineId' => pipelineId,
                'jsonInformation' => JSON.serialize(jsonInformation),
                'resultId' => result?.Id
            };

            return this;
        }

        private String getFakeId(Schema.SObjectType sObjectName) {
            Integer num = 1;
            String resultId = String.valueOf(num++);
            return sObjectName.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(12 - resultId.length()) + resultId;
        }

        private List<copado__Artifact__c> getPackages() {
            return [
                SELECT copado__Description__c, (SELECT copado__Version_number__c, copado__Version_Description__c FROM copado__Artifact_Versions__r)
                FROM copado__Artifact__c
            ];
        }

        private copado__Result__c getResult(Id resultId) {
            return [SELECT copado__Progress_Status__c FROM copado__Result__c WHERE Id = :resultId];
        }
    }
}