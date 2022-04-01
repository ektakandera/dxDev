@IsTest
private class DeployPackagesTest {

    @TestSetup
    private static void makeData() {
        TestUtilities.setup();
    }

    @IsTest
    private static void deployPackage() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('SF Envirnment')
                .addCredential('Credential 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .createJobTemplate('SFDX Package Distribution');

            // Exercise

            List<copado__JobExecution__c> result = new DeployPackages(
                    helper.version.Id,
                    new List<Id>{ helper.credential.Id }
                )
                .execute();

            // Verify

            System.assertEquals(1, result.size(), 'Job Executions creation has failed.');
            System.assertEquals(
                helper.environment.Id,
                result[0].copado__Destination__c,
                'Job executed created for incorrect environment.'
            );
        }
    }

    
    @IsTest
    private static void exception() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup

            Exception expectedException = null;

            // Exercise

            try {
                new DeployPackages(null, null).execute();
            } catch (Exception ex) {
                expectedException = ex;
            }

            // Verify

            System.assert(expectedException != null, 'Exception should be thrown.');
        }
    }

    // HELPER

    private class DataHelper {
        private copado__Git_Repository__c repository;
        private copado__Environment__c environment;
        private copado__Org__c credential;
        private copado__Artifact__c pkg;
        private copado__Artifact_Version__c version;
        private copado__JobTemplate__c template;

        private DataHelper createRepository(String name) {
            repository = TestDataFactory.createGitRepository(name);
            insert repository;

            return this;
        }

        private DataHelper createEnvironment(String name) {
            environment = TestDataFactory.createEnvironment(name, 'Production/Developer', 'SFDX');
            insert environment;

            return this;
        }

        private DataHelper addCredential(String name) {
            credential = TestDataFactory.createCredential(
                name,
                UserInfo.getUserName(),
                environment.Id,
                environment.copado__Type__c
            );
            credential.copado__is_Developer_Hub_Org__c = true;
            insert credential;

            return this;
        }

        private DataHelper createPackage(String name) {
            pkg = TestDataFactory.createPackage(name, 'Package_Artifact');
            pkg.copado__Artifact_Repository__c = repository.Id;
            pkg.copado__Target_Dev_Hub_Org__c = credential.Id;
            insert pkg;

            return this;
        }

        private DataHelper addPackageVersion(String name) {
            version = TestDataFactory.createPackageVersion(name, pkg.Id);
            insert version;

            return this;
        }

        private DataHelper createJobTemplate(String name) {
            template = TestDataFactory.createJobTemplate(name);
            insert template;

            return this;
        }
    }
}