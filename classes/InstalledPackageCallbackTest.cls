@IsTest
private class InstalledPackageCallbackTest {
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static final String SUBSCRIBER_ID = '04t09000000G3icAAC';

    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
    }

    @IsTest
    private static void testInstalledPackageFlow() {
        System.runAs(TestUtilities.getRunAsUser()) {
            // SETUP
            copado__Environment__c environment = new copado__Environment__c();
            environment.Name = 'My Environment';
            insert environment;

            copado__Git_Repository__c repository = new copado__Git_Repository__c();
            repository.Name = 'My Repo';
            insert repository;

            copado__Artifact__c pkg = new copado__Artifact__c();
            pkg.copado__Package_Type__c = 'Unlocked';
            pkg.copado__Artifact_Repository__c = repository.Id;
            pkg.RecordTypeId = SObjectType.copado__Artifact__c.getRecordTypeInfosByDeveloperName()
                .get('Package_Artifact')
                .getRecordTypeId();
            insert pkg;

            copado__Artifact_Version__c version = new copado__Artifact_Version__c();
            version.copado__Artifact__c = pkg.Id;
            version.Name = 'Version One';
            version.copado__Subscriber_Version_Id__c = SUBSCRIBER_ID;
            insert version;

            copado__JobTemplate__c template = new copado__JobTemplate__c(
                Name = 'SFDX Package Install',
                copado__Version__c = 1
            );
            insert template;

            copado__JobExecution__c execution = new copado__JobExecution__c(
                copado__Template__c = template.Id,
                copado__Destination__c = environment.Id
            );
            insert execution;

            copado__JobStep__c step = new copado__JobStep__c(
                Name = 'Install Function',
                copado__JobExecution__c = execution.Id,
                copado__Type__c = 'Flow'
            );
            insert step;

            copado__Result__c result = new copado__Result__c();
            result.copado__ParentId__c = step.Id;
            result.copado__Result_Data__c = SUBSCRIBER_ID;
            result.copado__Job_Type__c = 'Integration';
            insert result;

            Map<String, Object> parameters = new Map<String,Object>();
            parameters.put('status', 'Success');
            parameters.put('result', result);

            // EXERCISE
            Flow.Interview.Installed_Package_Callback callback = new Flow.Interview.Installed_Package_Callback(
                parameters
            );
            callback.start();

            // VERIFY
            List<copado__Installed_Artifact_Version__c> assertions = [
                SELECT Id, copado__Environment__c, copado__Package_Version__c
                FROM copado__Installed_Artifact_Version__c
                WHERE copado__Environment__c = :environment.Id AND copado__Package_Version__c = :version.Id
            ];
            System.assertEquals(1, assertions.size(), 'There should be one record');
        }
    }
}