@IsTest
private class CreatePackageFlowTest {
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static final String SUBSCRIBER_ID = '04t09000000G3icAAC';

    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
    }

    @IsTest
    private static void insertPackageAndVersion() {
        // Setup
        System.runAs(TestUtilities.getRunAsUser()) {
            Map<String, Object> flowParams = getFlowParams(createPipeline(createRepository().Id));

            // Exercise
            Test.startTest();
            new Flow.Interview.Create_Package(flowParams).start();
            Test.stopTest();
            // Verify
            List<copado__Artifact__c> packages = getPackages();

            System.assertEquals(packages.size(), 1, 'Package upsertion failed');
            System.assertEquals(
                packages.get(0).copado__Artifact_Versions__r.size(),
                1,
                'Package version upsertion failed'
            );
        }
    }

    @IsTest
    private static void updatePackageAndVersion() {
        // Setup
        System.runAs(TestUtilities.getRunAsUser()) {
            copado__Git_Repository__c repo = createRepository();

            copado__Artifact__c pkg = createPackage(repo);
            createPackageVersion(repo, pkg);

            Map<String, Object> flowParams = getFlowParams(createPipeline(repo.Id));

            PackageInfo info = PackageInfo.parse(String.valueOf(flowParams.get('packageJson')));
            info.pkg.Description = 'Package Description';
            info.versions.get(0).Description = 'Package Version Description';
            flowParams.put('packageJson', JSON.serialize(info));
            // Exercise
            Test.startTest();
            new Flow.Interview.Create_Package(flowParams).start();
            Test.stopTest();

            // Verify
            List<copado__Artifact__c> packages = getPackages();

            System.assertEquals(
                packages.get(0).copado__Description__c,
                'Package Description',
                'Package upsert description failed'
            );
            System.assertEquals(
                packages.get(0).copado__Artifact_Versions__r.get(0).copado__Version_Description__c,
                'Package Version Description',
                'Package version upsert description failed'
            );
        }
    }

    @IsTest
    private static void throwException() {
        // Setup
        System.runAs(TestUtilities.getRunAsUser()) {
            Map<String, Object> flowParams = getFlowParams(createPipeline(createRepository().Id));

            flowParams.put('jsonInformation', '{"devhub":"invalidId"}');
            // Exercise
            Test.startTest();
            new Flow.Interview.Create_Package(flowParams).start();
            Test.stopTest();

            // Verify
            List<copado__Artifact__c> packages = getPackages();

            System.assertEquals(packages.size(), 0, 'throw exception failed');
        }
    }

    private static copado__Deployment_Flow__c createPipeline(Id repositoryId) {
        copado__Deployment_Flow__c pipeline = new copado__Deployment_Flow__c(
            Name = 'My Pipeline',
            copado__Platform__c = 'Salesforce',
            copado__Git_Repository__c = repositoryId
        );
        insert pipeline;
        return pipeline;
    }
    private static copado__Git_Repository__c createRepository() {
        copado__Git_Repository__c repo = new copado__Git_Repository__c(Name = 'My Repo');
        insert repo;
        return repo;
    }
    private static Map<String, Object> getFlowParams(copado__Deployment_Flow__c pipeline) {
        Map<String, Object> flowParams = new Map<String, Object>{
            'packageJson' => '{"pkg":{"Id":"0Ho5g00000000VzCAI","SubscriberPackageId":"0335g000000xW5pAAE","Name":"Testpkg","Description":null,"NamespacePrefix":null,"ContainerOptions":"Unlocked","Alias":""},"versions":[{"Package2Id":"0Ho5g00000000VzCAI","Branch":null,"Tag":null,"MajorVersion":0,"MinorVersion":1,"PatchVersion":0,"BuildNumber":1,"Id":"05i5g00000000OcAAI","SubscriberPackageVersionId":"04t5g000000xwXMAAY","Name":"ver 0.1","NamespacePrefix":null,"Package2Name":"Testpkg","Description":null,"Version":"0.1.0.1","IsPasswordProtected":false,"IsReleased":false,"CreatedDate":"2021-09-01 11:42","LastModifiedDate":"2021-09-01 11:42","InstallUrl":"https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000xwXMAAY","CodeCoverage":"","ValidationSkipped":false,"AncestorId":"N/A","AncestorVersion":"N/A","Alias":""}]}',
            'pipelineId' => pipeline.Id
        };
        return flowParams;
    }

    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static copado__Artifact__c createPackage(Copado__Git_Repository__c repo) {
        copado__Artifact__c pkg = new copado__Artifact__c();
        pkg.Name = 'Testpkg';
        pkg.copado__Package_Type__c = 'Unlocked';
        pkg.copado__Artifact_Repository__c = repo.Id;
        pkg.copado__Package_Id__c = '0Ho5g00000000VzCAI';
        pkg.RecordTypeId = SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName()
            .get('Package_Artifact')
            .getRecordTypeId();

        insert pkg;
        return pkg;
    }

    private static void createPackageVersion(
        Copado__Git_Repository__c repo,
        copado__Artifact__c pkg
    ) {
        copado__Artifact_Version__c version = new copado__Artifact_Version__c();
        version.copado__Artifact__c = pkg.Id;
        version.Name = 'ver 0.1';
        version.copado__Version_number__c = '0.1.0.1';
        version.copado__Subscriber_Version_Id__c = SUBSCRIBER_ID;

        insert version;
    }

    private static List<copado__Artifact__c> getPackages() {
        return [
            SELECT
                copado__Description__c,
                (
                    SELECT copado__Version_number__c, copado__Version_Description__c
                    FROM copado__Artifact_Versions__r
                )
            FROM copado__Artifact__c
        ];
    }
}