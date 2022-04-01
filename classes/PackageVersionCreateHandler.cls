public with sharing class PackageVersionCreateHandler {
    @AuraEnabled
    public static void startCreate(String params) {
        Map<String, Object> version = (Map<String, Object>) JSON.deserializeUntyped(params);

        Copado.PackageVersionCreateAction.Request request = new Copado.PackageVersionCreateAction.Request(
            (Id) version.get('package'),
            JSON.serialize(version.get('jsonInformation'))
        );

        request.versionName = (String) version.get('versionname');
        request.versionNumber = (String) version.get('versionnumber');
        request.description = (String) version.get('versiondescription');

        List<Copado.PackageVersionCreateAction.Response> response = Copado.PackageVersionCreateAction.create(
            new List<Copado.PackageVersionCreateAction.Request>{ request }
        );

        update Security.stripInaccessible(
                AccessType.UPDATABLE,
                new List<copado__Artifact__c>{
                    new copado__Artifact__c(
                        Id = (Id) version.get('package'),
                        copado__LastJobExecutionId__c = response[0]?.job?.Id
                    )
                }
            )
            .getRecords();
    }
}