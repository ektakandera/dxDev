public with sharing class ConfigurePipelineDistributionStep {
    private Request request;
    private Id userStoryId;

    // CTOR

    public ConfigurePipelineDistributionStep(Request request) {
        this.request = request;
    }

    // PUBLIC

    @InvocableMethod(label='Create deployment step for user story' category='Package Distribution')
    public static List<Result> createDeploymentStep(List<Request> requests) {
        Result result = new Result();

        result.userStoryId = new ConfigurePipelineDistributionStep(requests[0]).execute();

        return new List<Result>{ result };
    }


    public Id execute() {
        userStoryId = String.isBlank(request.existingUserStoryId) ? createUserStory() : request.existingUserStoryId;

        createDeploymentStep();

        return userStoryId;
    }

    // PRIVATE

    @SuppressWarnings('PMD.ApexCRUDViolation')
    private Id createUserStory() {
        copado__User_Story__c userStory = (copado__User_Story__c) JSON.deserialize(
            request.newSerializedUserStory,
            copado__User_Story__c.class
        );

        userStory = (copado__User_Story__c) Security.stripInaccessible(
                AccessType.CREATABLE,
                new List<copado__User_Story__c>{ userStory }
            )
            .getRecords()
            .get(0);

        insert userStory;
        return userStory.Id;
    }


    private void createDeploymentStep() {
        copado__JobStep__c step = new copado__JobStep__c(
            Name = getStepName(),
            copado__UserStory__c = userStoryId,
            copado__Type__c = 'Flow',
            copado__CustomType__c = 'Flow',
            copado__ExecutionSequence__c = 'after',
            copado__Order__c = getStepOrder(),
            copado__ConfigJson__c = getConfigJson()
        );

        insert Security.stripInaccessible(AccessType.CREATABLE, new List<SObject>{ step }).getRecords();
    }


    private String getConfigJson() {
        ConfigJson configJson = new ConfigJson(Settings.NAMESPACE_DOT + 'InitiatePipelineDistribution');
        configJson.parameters = new List<Parameter>{
            new Parameter('packageVersionId', request.packageVersionId),
            // Note: This is deployment job execution
            new Parameter('deploymentId', '{$Job.ExecutionParent.Id}')
        };

        return JSON.serialize(configJson);
    }


    private String getStepName() {
        copado__Artifact_Version__c packageVersion = new PackageVersionsSelector()
            .byIds(new Set<Id>{ request.packageVersionId })
            .get(0);

        return 'Start ' +
            packageVersion.copado__Artifact__r.Name +
            ' - ' +
            packageVersion.copado__Version_number__c +
            ' Installation Job';
    }


    private Decimal getStepOrder() {
        Decimal maxOrder = (Decimal) [
                SELECT MAX(copado__Order__c) MaxOrder
                FROM copado__JobStep__c
                WHERE copado__UserStory__c = :userStoryId AND copado__ExecutionSequence__c = 'after'
            ]
            .get(0)
            .get('MaxOrder');

        return (maxOrder == null) ? 1 : (maxOrder + 1);
    }

    // INNER PUBLIC

    public class Request {
        @InvocableVariable(label='Existing User Story Id')
        public String existingUserStoryId;

        @InvocableVariable(label='New Serialized User Story')
        public String newSerializedUserStory;

        @InvocableVariable(label='Package Version Id' required=true)
        public String packageVersionId;
    }


    public class Result {
        @InvocableVariable(label='User Story Id')
        public String userStoryId;
    }

    // INNER PRIVATE

    @TestVisible
    private class ConfigJson {
        @TestVisible
        private String flowName;

        @TestVisible
        private List<Parameter> parameters;

        // CTOR

        private ConfigJson(String flowName) {
            this.flowName = flowName;
        }
    }
    

    @TestVisible
    private class Parameter {
        @TestVisible
        private String name;

        @TestVisible
        private String value;

        // CTOR
        
        @TestVisible
        private Parameter(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }
}