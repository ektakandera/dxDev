@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId')
private class UpdatePackageFlowTest {
    
    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
    }

    @IsTest
    private static void updatePackage2Id() {
        System.runAs(TestUtilities.getRunAsUser()) {
            
            // Setup
            Map<String, Object> flowParams = getFlowParams(createPackage(createRepository()).Id);

            // Exercise

            Test.startTest();
            new Flow.Interview.UpdatePackage(flowParams).start();
            Test.stopTest();

            // Verify
            List<copado__Artifact__c> packages = getPackages();

            System.assertEquals(
                packages.get(0).copado__Package_Id__c,
                '0Ho5g00000000VzCAI',
                'Package Id updation failed'
            );
        }
    }

    private static copado__Git_Repository__c createRepository() {
        copado__Git_Repository__c repo = new copado__Git_Repository__c(Name = 'My Repo');
        insert repo;
        return repo;
    }

    private static Map<String, Object> getFlowParams(Id packageId) {
        Map<String, Object> flowParams = new Map<String, Object>{
            'packageId' => packageId,
            'package2Id' => '0Ho5g00000000VzCAI'
        };
        return flowParams;
    }

    private static copado__Artifact__c createPackage(Copado__Git_Repository__c repo) {
        copado__Artifact__c pkg = new copado__Artifact__c();
        pkg.Name = 'Testpkg';
        pkg.copado__Package_Type__c = 'Unlocked';
        pkg.copado__Artifact_Repository__c = repo.Id;
        pkg.RecordTypeId = SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName()
            .get('Package_Artifact')
            .getRecordTypeId();

        insert pkg;
        return pkg;
    }

    private static List<copado__Artifact__c> getPackages() {
        return [SELECT copado__Package_Id__c FROM copado__Artifact__c];
    }
}