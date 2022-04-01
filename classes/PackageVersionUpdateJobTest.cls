@IsTest
private class PackageVersionUpdateJobTest {
    
    @TestSetup
    private static void makeData() {
        User u = TestDataFactory.createUser('Standard User');
        insert u;

        TestDataFactory.assignPermissionSet(u, new Set<String>{ 'Copado_User', 'Copado_Job_Engine' });

        System.runAs(u) {
            TestDataFactory.assignLicense(u.Id, true, true, true, true, true);
        }
    }

    @IsTest
    private static void execute() {
        System.runAs(getRunAsUser()) {
            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createPipeline('Pipeline 1')
                .createEnvironment('Env 1')
                .addCredential('Cred 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .createJobTemplate('SFDX Package Version Update');

            PackageVersionUpdateJob.Version newVersion = new PackageVersionUpdateJob.Version(
                helper.version.copado__Subscriber_Version_Id__c
            );
            newVersion.installationKey = 'installationKey';

            // Exercise

            copado__JobExecution__c job = new PackageVersionUpdateJob(newVersion).execute();

            // Verify

            copado__Artifact_Version__c version = [
                SELECT copado__LastJobExecutionId__c
                FROM copado__Artifact_Version__c
                WHERE Id = :helper.version.Id
            ];
            System.assertEquals(job.Id, version.copado__LastJobExecutionId__c, 'Job execution should be started.');
        }
    }

    @IsTest
    private static void invalidPackageVersion() {
        System.runAs(getRunAsUser()) {
            // Setup

            Exception e = null;
            PackageVersionUpdateJob.Version newVersion = new PackageVersionUpdateJob.Version(null);
            newVersion.installationKey = 'installationKey';

            // Exercise

            try {
                copado__JobExecution__c job = new PackageVersionUpdateJob(newVersion).execute();
            } catch (Exception ex) {
                e = ex;
            }

            // Verify

            System.assertNotEquals(null, e, 'Exception should be thrown.');
            System.assertEquals(
                'Invalid Subscriber Version Id',
                e.getMessage(),
                'Should throw invalid package version exception.'
            );
        }
    }

    @IsTest
    private static void invalidDevhub() {
        System.runAs(getRunAsUser()) {
            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createPipeline('Pipeline 1')
                .addCredential('Cred 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .createJobTemplate('SFDX Package Version Update');

            PackageVersionUpdateJob.Version newVersion = new PackageVersionUpdateJob.Version(
                helper.version.copado__Subscriber_Version_Id__c
            );
            newVersion.installationKey = 'installationKey';

            Exception e = null;

            // Exercise

            try {
                copado__JobExecution__c job = new PackageVersionUpdateJob(newVersion).execute();
            } catch (Exception ex) {
                e = ex;
            }

            // Verify

            System.assertNotEquals(null, e, 'Exception should be thrown.');
            System.assertEquals(
                'Could not find Devhub environment.',
                e.getMessage(),
                'Should throw invalid devhub exception.'
            );
        }
    }

    // HELPER

    private class DataHelper {
        private copado__Git_Repository__c repository;
        private copado__Deployment_Flow__c pipeline;
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

        private DataHelper createPipeline(String name) {
            pipeline = TestDataFactory.createPipeline(name, repository.Id);
            pipeline.copado__Platform__c = 'SFDX';
            insert pipeline;

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