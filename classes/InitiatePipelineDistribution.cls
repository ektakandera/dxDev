public with sharing class InitiatePipelineDistribution {
    
    // PUBLIC

    @InvocableMethod(label='Executes Package Distribution Job' category='Package Distribution')
    public static List<Result> startExecution(List<Request> requests) {
        System.debug(requests);
        Result result = new Result();

        copado__Deployment__c deployment = new DeploymentsSelector()
            .byIds(new Set<Id>{ requests[0].deploymentId })
            .get(0);

        Id destinationCredential = deployment.copado__Promotion__r.copado__Destination_Org_Credential__c;

        result.job = new DeployPackages(requests[0].packageVersionId, new List<Id>{ destinationCredential })
            .execute()
            .get(0);

            System.debug(new List<Result>{ result });
        return new List<Result>{ result };
    }

    // INNER

    public class Request {
        @InvocableVariable(label='Package Version Id' required=true)
        public String packageVersionId;

        @InvocableVariable(label='Deployment Id' required=true)
        public String deploymentId;
    }


    public class Result {
        @InvocableVariable(label='Job Execution')
        public copado__JobExecution__c job;
    }
}