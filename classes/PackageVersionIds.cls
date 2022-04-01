public with sharing class PackageVersionIds {
    public with sharing class Request {
        @InvocableVariable(label='Subscriber ID')
        public String subscriberId;
    }
    public with sharing class Result {
        @InvocableVariable(label='Package Versions')
        public List<copado__Artifact_Version__c> versions = new List<copado__Artifact_Version__c>();
    }

    @InvocableMethod(label='Retrieve Package Version Ids' description='Return Package Version Ids' category='Apex Action')
    public static List<Result> packageVersionsBydId(List<Request> requests) {
        List<Result> results = new List<Result>();
        List<String> ids = requests[0].subscriberId.split(',');

        List<copado__Artifact_Version__c> versionIds = [
            SELECT Id
            FROM copado__Artifact_Version__c
            WHERE copado__Subscriber_Version_Id__c IN :ids
            WITH SECURITY_ENFORCED
        ];

        Result result = new Result();
        result.versions.addAll(versionIds);

        results.add(result);
        return results;
    }

    public class PackageVersionIdsException extends Exception {}
}