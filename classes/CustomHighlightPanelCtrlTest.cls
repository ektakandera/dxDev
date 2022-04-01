@isTest
private with sharing class CustomHighlightPanelCtrlTest {
    @testSetup private static void testSetup()
    {
        Id recordTypeId = Schema.SObjectType.copado__User_Story__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId();
        copado__User_Story__c userStory = new copado__User_Story__c(copado__User_Story_Title__c='Ctrl', RecordTypeId = recordTypeId );
        insert userStory;
    }

    @isTest private static void getFieldListandRecordTypeTest(){
        
        //Setup
        copado__User_Story__c userStory = [SELECT Id FROM copado__User_Story__C WHERE copado__User_Story_Title__c='Ctrl'];   
        String namespace = 'copado__';
        
        //Exercise
        Test.startTest();
        List<customHighlightPanelController.FieldDefinition> fieldDefinition = CustomHighlightPanelController.getFieldList(userStory.Id, namespace+'Commit_Page');
        Test.stopTest();
        
        // Verify 
        System.assert(fieldDefinition.size()>0);

    }

    @isTest private static void getObjectNameTest(){
        //Setup
        copado__User_Story__c userStory = [SELECT Id FROM copado__User_Story__C WHERE copado__User_Story_Title__c='Ctrl'];  
        
        //Exercise
        Test.startTest();
        String objectName = CustomHighlightPanelController.getObjectPluralName(userStory.Id);
        Test.stopTest();

        // Verify 
        System.assertEquals(objectName, 'User Stories');
    }

    @isTest private static void getRecordTypeNameTest(){
        //Setup
        copado__User_Story__c userStory = [SELECT Id FROM copado__User_Story__C WHERE copado__User_Story_Title__c='Ctrl'];  
        
        //Exercise
        Test.startTest();
        String recordName = CustomHighlightPanelController.getRecordTypeName(userStory.Id);
        Test.stopTest();

        // Verify 
        System.assert(String.isNotBlank(recordName));
    }
}