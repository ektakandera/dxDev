@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId')
public with sharing class GetPackageVersionWithKeysTest {

    @TestSetup
    public static void makeData() {
        User u = TestDataFactory.createUser('Standard User');
        insert u;

        TestDataFactory.assignPermissionSet(u, new Set<String>{ 'Copado_User', 'Copado_Job_Engine', 'CMC_SFDX_Admin' });

        System.runAs(u) {
            TestDataFactory.assignLicense(u.Id, true, true, true, true, true);
        }
    }

    @IsTest
    public static void execute() {
        System.runAs(getRunAsUser()) {

            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('SF Envirnment')
                .createCredential('Credential 1')
                .createPackage('SF_Package')
                .createPackageVersion('Version 1', 'key1')
                .addPackageDependency('Pre_Install_Pkg1', 'key2');

            // Exercise

            List<GetPackageVersionWithKeys.PackageVersion> result = new GetPackageVersionWithKeys(
                    helper.version.copado__Subscriber_Version_Id__c,
                    new Set<Id>{ helper.dependencies[0].copado__Subscriber_Version_Id__c }
                )
                .execute();

            // Verify

            System.assertEquals(2, result.size(), 'Package Version with Dependencies and keys should be returned.');
            System.assertEquals(
                helper.version.copado__Subscriber_Version_Id__c,
                result[1].id,
                'Package Version should be last element.'
            );
            System.assertEquals('key1', result[1].key, 'Package Version should be returned with key.');
        }
    }

    @IsTest
    public static void executeInvocable() {
        System.runAs(getRunAsUser()) {

            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('SF Envirnment')
                .createCredential('Credential 1')
                .createPackage('SF_Package')
                .createPackageVersion('Version 1', null)
                .addPackageDependency('Pre_Install_Pkg2', null);

            GetPackageVersionWithKeys.Request request = new GetPackageVersionWithKeys.Request();
            request.subscriberVersionId = helper.version.copado__Subscriber_Version_Id__c;
            request.dependenciesIds = JSON.serialize(
                new Set<Id>{ helper.dependencies[0].copado__Subscriber_Version_Id__c }
            );

            // Exercise

            GetPackageVersionWithKeys.Response response = GetPackageVersionWithKeys.execute(
                    new List<GetPackageVersionWithKeys.Request>{ request }
                )
                .get(0);

            List<GetPackageVersionWithKeys.PackageVersion> versions = (List<GetPackageVersionWithKeys.PackageVersion>) JSON.deserialize(
                response.versions.unescapeEcmaScript(),
                List<GetPackageVersionWithKeys.PackageVersion>.class
            );

            // Verify

            System.assertEquals(2, versions.size(), 'Package Version with Dependencies and keys should be returned.');
            System.assertEquals(
                helper.version.copado__Subscriber_Version_Id__c,
                versions[1].id,
                'Package Version should be last element.'
            );
            System.assertEquals(null, versions[1].key, 'Package Version should be returned with key.');
        }
    }

    // HELPER

    private class DataHelper {
        private copado__Git_Repository__c repository;
        private copado__Environment__c environment;
        private copado__Org__c credential;
        private copado__Artifact__c pkg;
        copado__Artifact_Version__c version;
        private List<copado__Artifact_Version__c> dependencies = new List<copado__Artifact_Version__c>();
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

        private DataHelper createCredential(String name) {
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

        private DataHelper createPackageVersion(String name, String key) {
            version = TestDataFactory.createPackageVersion(name, pkg.Id);
            version.copado__Subscriber_Version_Id__c = '04t5g000000UcgUAAS';
            insert version;

            if (String.isNotBlank(key)) {
                PackageVersionInstallationKey__c versionKey = new PackageVersionInstallationKey__c(
                    Name = version.copado__Subscriber_Version_Id__c,
                    PackageVersionId__c = version.copado__Subscriber_Version_Id__c,
                    InstallationKey__c = key
                );
                insert versionKey;
            }

            return this;
        }

        private Datahelper addPackageDependency(String name, String key) {
            copado__Artifact__c dPkg = TestDataFactory.createPackage(name, 'Package_Artifact');
            dPkg.copado__Artifact_Repository__c = repository.Id;
            dPkg.copado__Target_Dev_Hub_Org__c = credential.Id;
            insert dPkg;

            copado__Artifact_Version__c dVersion = TestDataFactory.createPackageVersion(name, dPkg.Id);
            dVersion.copado__Subscriber_Version_Id__c = '04t5g000000UcgTAAS';
            insert dVersion;

            dependencies.add(dVersion);

            if (String.isNotBlank(key)) {
                PackageVersionInstallationKey__c versionKey = new PackageVersionInstallationKey__c(
                    Name = dVersion.copado__Subscriber_Version_Id__c,
                    PackageVersionId__c = dVersion.copado__Subscriber_Version_Id__c,
                    InstallationKey__c = key
                );
                insert versionKey;
            }

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