@isTest
public with sharing class AddApexTestsControllerTest {

    @TestSetup
    private static void setUp() {
        TestUtilities.setup();
        System.runAs(TestUtilities.getRunAsUser()) {
            makeData();
        }
    }

    @IsTest
    public static void retreiveUserStory() {
        // SETUP
        System.runAs(TestUtilities.getRunAsUser()) {
            
            String body = '[{"n":"getApexTestClasses"},{"n":"fflib_QueryFactoryTest"},{"n":"UserStoryMetadataTriggerTest"}]';
            
            copado__User_Story__c story = [
                SELECT Id, copado__Project__c, copado__Org_Credential__c, copado__Release__c
                FROM copado__User_Story__c
                LIMIT 1
            ];

        // EXCERCISE
            AddApexTestsController.getApexTestClassList(story.Id);
            AddApexTestsController.createContentVersion(body, story.Id);
            AddApexTestsController.getPreselections(story.Id);

        // VERIFY
            String expectedJsonStructureForFile = '[{"s":true,"r":false,"ns":"","n":"getApexTestClasses"},{"s":true,"r":false,"ns":"","n":"fflib_QueryFactoryTest"},{"s":true,"r":false,"ns":"","n":"UserStoryMetadataTriggerTest"}]'; 
            String contentDocumentId = [SELECT ContentDocument.FileExtension, ContentDocument.Id from ContentDocumentLink WHERE LinkedEntityId = :story.Id].ContentDocument.Id;
            String contentFile = [SELECT VersionData from ContentVersion WHERE ContentDocumentId = :ContentDocumentId].VersionData.toString();
            String contentAttachment = [SELECT Id,Body FROM Attachment WHERE ParentId= :story.Id].Body.toString();

            System.assertEquals(AddApexTestsController.getApexTestClassList(story.Id).size() != 0, true);
            System.assertEquals([SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: story.Id].size() > 0, true);
            System.assertEquals(expectedJsonStructureForFile, contentFile);
            System.assertEquals(expectedJsonStructureForFile, contentAttachment);
            System.assertEquals(AddApexTestsController.getPreselections(story.Id).size() != 0, true);
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

    public string getResponse(){
        return '{' +
                '"statusCode" : 200,' +
                '"content" : "{' +
                    '\\"searchRecords\\" : [' +
                            '{' +'\\"Name\\": \\"fflib_IDGeneratorTest\\",' + 
                            '\\"NamespacePrefix\\": \\"copado\\"' +
                            '}' +
                        ']' +
                    '}"' +
                '}';
    }

}