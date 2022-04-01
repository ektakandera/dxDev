@IsTest
private class GetTestOnlyClassesTest {
    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            makeData();
        }
    }

    @IsTest
    private static void testGetTestOnlyClasses() {
        // SETUP

        System.runAs(TestUtilities.getRunAsUser()) {
            // EXERCISE
            copado__JobStep__c jobStep = [SELECT Id FROM copado__JobStep__c LIMIT 1];
            String testClasses = new GetTestOnlyClasses().execute(jobStep.Id);

            // VERIFY
            Set<String> assertNames = getAssertNames();
            Set<String> assertTestClassNames = (Set<String>) JSON.deserialize(testClasses, Set<String>.class);

            System.assertEquals(assertNames, assertTestClassNames, 'Class names does not match');
        }
    }

    // HELPER

    private static void makeData() {
        copado__Git_Repository__c repository = TestDataFactory.createGitRepository('MyRepo');
        insert repository;

        copado__Environment__c devEnvironment = TestDataFactory.createEnvironment('Dev1', 'Production/Developer', 'SFDX');
        copado__Environment__c uatEnvironment = TestDataFactory.createEnvironment('Uat', 'Production/Developer', 'SFDX');
        insert new List<copado__Environment__c>{ devEnvironment, uatEnvironment };

        copado__Org__c devCredential = TestDataFactory.createCredential('Dev1', 'name@example.com', devEnvironment.Id, 'Production/Developer');
        copado__Org__c uatCredential = TestDataFactory.createCredential('Uat', 'nameuat@example.com', uatEnvironment.Id, 'Production/Developer');
        insert new List<copado__Org__c>{ devCredential, uatCredential };

        copado__JobTemplate__c jobTemplate = TestDataFactory.createJobTemplate('Promotion');
        insert jobTemplate;

        copado__Deployment_Flow__c pipeline = TestDataFactory.createPipeline('MyPipeline', repository.Id);
        pipeline.copado__Platform__c = 'SFDX';
        pipeline.copado__Promotion_Job_Template__c = jobTemplate.Id;
        insert pipeline;

        copado__Deployment_Flow_Step__c connection = TestDataFactory.createPipelineConnection(pipeline.Id, devEnvironment.Id, uatEnvironment.Id);
        insert connection;

        copado__Project__c project = TestDataFactory.createProject('MyProject', pipeline.Id);
        insert project;

        copado__User_Story__c story1 = new copado__User_Story__c(
            copado__User_Story_Title__c = 'My Story One',
            copado__Project__c = project.Id,
            copado__Org_Credential__c = devCredential.Id
        );
        copado__User_Story__c story2 = new copado__User_Story__c(
            copado__User_Story_Title__c = 'My Story Two',
            copado__Project__c = project.Id,
            copado__Org_Credential__c = devCredential.Id
        );
        insert new List<copado__User_Story__c>{ story1, story2 };

        Attachment attachment1 = new Attachment(ParentId = story1.Id, Name = 'Test Classes', Body = Blob.valueOf(mockTestClasses()));
        Attachment attachment2 = new Attachment(ParentId = story1.Id, Name = 'Test Classes.json', Body = Blob.valueOf(mockTestClasses()));
        Attachment attachment3 = new Attachment(ParentId = story1.Id, Name = 'cmcSf_TestClasses.json', Body = Blob.valueOf(mockTestClasses()));
        insert new List<Attachment>{ attachment1, attachment2, attachment3 };

        ContentVersion content = new ContentVersion(
            Title = 'cmcSf_TestClasses',
            origin = 'C',
            PathOnClient = 'cmcSf_TestClasses.json',
            VersionData = Blob.valueOf(mockTestClasses2())
        );
        insert content;

        ContentVersion contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id LIMIT 1];

        ContentDocumentLink link = new ContentDocumentLink(LinkedEntityId = story2.Id, ContentDocumentId = contentVersion.ContentDocumentId);
        insert link;

        copado__Promotion__c promotion = new copado__Promotion__c(
            copado__Project__c = project.Id,
            copado__Source_Org_Credential__c = devCredential.Id,
            copado__Source_Environment__c = devEnvironment.Id
        );
        insert promotion;

        copado__Promoted_User_Story__c promotedstory1 = new copado__Promoted_User_Story__c(
            copado__Promotion__c = promotion.Id,
            copado__User_Story__c = story1.Id
        );
        copado__Promoted_User_Story__c promotedstory2 = new copado__Promoted_User_Story__c(
            copado__Promotion__c = promotion.Id,
            copado__User_Story__c = story2.Id
        );
        insert new List<copado__Promoted_User_Story__c>{ promotedstory1, promotedstory2 };

        copado__Deployment__c deployment = new copado__Deployment__c(
            Name = promotion.Name,
            copado__Promotion__c = promotion.Id,
            copado__From_Org__c = devCredential.Id
        );
        insert deployment;

        copado__JobExecution__c execution = new copado__JobExecution__c(
            copado__Deployment__c = deployment.Id,
            copado__Promotion__c = promotion.Id,
            copado__Template__c = jobTemplate.Id,
            copado__Source__c = devEnvironment.Id,
            copado__Destination__c = uatEnvironment.Id
        );
        insert execution;

        copado__JobStep__c step = new copado__JobStep__c(copado__JobExecution__c = execution.Id, copado__Type__c = 'Function');
        insert step;
    }

    private static String mockTestClasses() {
        List<MetaDataItem> metadataItems = new List<MetaDataItem>();
        MetaDataItem item1 = new MetaDataItem();
        item1.n = 'My Test class one';
        item1.r = false;
        item1.s = true;

        MetaDataItem item2 = new MetaDataItem();
        item2.n = 'My Test class two';
        item2.r = false;
        item2.s = true;

        metadataItems.add(item1);
        metadataItems.add(item2);

        return JSON.serialize(metadataItems);
    }

    private static String mockTestClasses2() {
        List<MetaDataItem> metadataItems = new List<MetaDataItem>();
        MetaDataItem item1 = new MetaDataItem();
        item1.n = 'My Test class four';
        item1.r = false;
        item1.s = true;

        MetaDataItem item2 = new MetaDataItem();
        item2.n = 'My Test class Five';
        item2.r = false;
        item2.s = true;

        metadataItems.add(item1);
        metadataItems.add(item2);

        return JSON.serialize(metadataItems);
    }

    private static Set<String> getAssertNames() {
        Set<String> result = new Set<String>();

        for (MetaDataItem item : (List<MetaDataItem>) JSON.deserialize(mockTestClasses(), List<MetaDataItem>.class)) {
            result.add(item.n + '.cls');
        }

        for (MetaDataItem item : (List<MetaDataItem>) JSON.deserialize(mockTestClasses2(), List<MetaDataItem>.class)) {
            result.add(item.n + '.cls');
        }

        return result;
    }
}