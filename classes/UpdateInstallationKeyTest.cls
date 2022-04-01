@IsTest
private class UpdateInstallationKeyTest {

    @TestSetup
    private static void makeData() {
        User u = TestDataFactory.createUser('Standard User');
        insert u;

        TestDataFactory.assignPermissionSet(u, new Set<String>{ 'Copado_User', 'Copado_Job_Engine', 'CMC_SFDX_Admin' });

        System.runAs(u) {
            TestDataFactory.assignLicense(u.Id, true, true, true, true, true);
        }
    }

    @IsTest
    private static void fetchInstallationKey() {
        System.runAs(getRunAsUser()) {
            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('Env 1')
                .addCredential('Cred 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .createInstallationKey('pwd1');

            // Exercise

            String key = UpdateInstallationKey.fetchInstallationKey(helper.version.copado__Subscriber_Version_Id__c);

            // Verify

            System.assertEquals('pwd1', key, 'Installation Key should be returned correctly.');
        }
    }

    @IsTest
    private static void executeJob() {
        System.runAs(getRunAsUser()) {
            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('Env 1')
                .addCredential('Cred 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .createInstallationKey('pwd1')
                .createJobTemplate('SFDX Package Version Update');

            // Exercise

            UpdateInstallationKey.executeJob(helper.version.copado__Subscriber_Version_Id__c, '12345');

            // Verify

            copado__Artifact_Version__c version = [
                SELECT copado__LastJobExecutionId__c
                FROM copado__Artifact_Version__c
                WHERE Id = :helper.version.Id
            ];

            System.assertNotEquals(null, version.copado__LastJobExecutionId__c, 'Job execution should be started.');
        }
    }

    @IsTest
    private static void executeJobFailure() {
        System.runAs(getRunAsUser()) {
            // Setup

            Exception e = null;

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('Env 1')
                .addCredential('Cred 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .createInstallationKey('pwd1');

            // Exercise

            try {
                UpdateInstallationKey.executeJob(helper.version.copado__Subscriber_Version_Id__c, '12345');
            } catch (Exception ex) {
                e = ex;
            }

            // Verify

            System.assertNotEquals(null, e, 'Exception should be thrown.');
        }
    }

    // HELPER

    private class DataHelper {
        private copado__Git_Repository__c repository;
        private copado__Environment__c environment;
        private copado__Org__c credential;
        private copado__Artifact__c pkg;
        private copado__Artifact_Version__c version;
        private PackageVersionInstallationKey__c installationKey;
        private copado__JobTemplate__c template;

        private DataHelper createRepository(String name) {
            repository = TestDataFactory.createGitRepository(name);
            insert repository;

            return this;
        }

        private DataHelper createEnvironment(String name) {
            environment = TestDataFactory.createEnvironment(name, 'Production/Developer', 'Salesforce');
            insert environment;

            return this;
        }

        private DataHelper addCredential(String name) {
            credential = TestDataFactory.createCredential(
                name,
                UserInfo.getUserName(),
                environment?.Id,
                environment?.copado__Type__c
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

        @SuppressWarnings('PMD.AvoidHardcodingId')
        private DataHelper addPackageVersion(String name) {
            version = TestDataFactory.createPackageVersion(name, pkg.Id);
            version.copado__Subscriber_Version_Id__c = '04t5g000000UgWxAAK';
            insert version;

            return this;
        }

        private DataHelper createInstallationKey(String key) {
            installationKey = new PackageVersionInstallationKey__c(
                PackageVersionId__c = version.copado__Subscriber_Version_Id__c,
                InstallationKey__c = key,
                Name = version.Name
            );
            insert installationKey;

            return this;
        }

        private DataHelper createJobTemplate(String name) {
            template = TestDataFactory.createJobTemplate(name);
            insert template;

            return this;
        }
    }

    private static User getRunAsUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'Standard User' AND UserName LIKE '%testcmcsf@copado.com%'
            LIMIT 1
        ];
    }
}