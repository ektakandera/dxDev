@IsTest
public with sharing class DistributePackagesTest {

    @TestSetup
    public static void makeData() {
        TestUtilities.setup();
    }


    @IsTest
    public static void getPackageVersion() {
        System.runAs(TestUtilities.getRunAsUser()) {
            
            // Setup

            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('SF Envirnment')
                .addCredential('Credential 1')
                .createPackage('SF_Package')
                .addPackageVersion('Version 1')
                .addPackageVersion('Version 2');

            // Exercise
            
            List<copado__Artifact_Version__c> versions = DistributePackages.fetchPkgVersionsFor(helper.pkg.Id);

            // Verify
            
            System.assertEquals(2, versions.size());
        }
    }


    @IsTest
    public static void getCredentials() {
        System.runAs(TestUtilities.getRunAsUser()) {
            
            // Setup
            
            DataHelper helper = new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('SF Envirnment')
                .addCredential('Credential 1')
                .addCredential('Credential 2');

            // Exercise
            
            List<copado__Org__c> credentials = DistributePackages.getCredentials(
                new List<String>{ helper.credentials[0].Id }
            );

            // Verify
            
            System.assertEquals(1, credentials.size());
        }
    }


    @IsTest
    public static void getAllCredentials() {
        System.runAs(TestUtilities.getRunAsUser()) {
        
            // Setup
        
            new DataHelper()
                .createRepository('Git Repo')
                .createEnvironment('SF Envirnment')
                .addCredential('Credential 1')
                .addCredential('Credential 2');

            // Exercise
        
            List<copado__Org__c> credentials = DistributePackages.getCredentials(new List<String>{});

            // Verify
            // Note: Its 3 because a credential is automatically created for SFDX platform
            System.assertEquals(3, credentials.size());
        }
    }


    @IsTest
    public static void getProjects() {
        System.runAs(TestUtilities.getRunAsUser()) {

            // Setup
            
            new DataHelper()
                .createRepository('Git Repo')
                .createPipeline('Pipeline')
                .addProject('Project 1')
                .addProject('Project 2');

            // Exercise
            
            List<copado__Project__c> projects = DistributePackages.getProjects();

            // Verify
            
            System.assertEquals(2, projects.size());
        }
    }

    // HELPER

    private class DataHelper {
        private copado__Git_Repository__c repository;
        private copado__Deployment_Flow__c pipeline;
        private copado__Project__c project;
        private copado__Environment__c environment;
        private List<copado__Org__c> credentials = new List<copado__Org__c>();
        private copado__Artifact__c pkg;
        private List<copado__Artifact_Version__c> versions = new List<copado__Artifact_Version__c>();

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
            copado__Org__c credential = TestDataFactory.createCredential(
                name,
                UserInfo.getUserName(),
                environment.Id,
                environment.copado__Type__c
            );
            credential.copado__Validated_Date__c = System.today();
            credential.copado__is_Developer_Hub_Org__c = true;
            insert credential;

            credentials.add(credential);

            return this;
        }

        private DataHelper createPipeline(String name) {
            pipeline = TestDataFactory.createPipeline(name, repository.Id);
            pipeline.copado__Platform__c = 'SFDX';
            insert pipeline;

            return this;
        }

        private DataHelper addProject(String name) {
            project = TestDataFactory.createProject(name, pipeline.Id);
            insert project;

            return this;
        }

        private DataHelper createPackage(String name) {
            pkg = TestDataFactory.createPackage(name, 'Package_Artifact');
            pkg.copado__Artifact_Repository__c = repository.Id;
            pkg.copado__Target_Dev_Hub_Org__c = credentials[0].Id;
            insert pkg;

            return this;
        }

        private DataHelper addPackageVersion(String name) {
            copado__Artifact_Version__c version = TestDataFactory.createPackageVersion(name, pkg.Id);
            insert version;

            versions.add(version);

            return this;
        }
    }
}