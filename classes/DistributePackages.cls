public with sharing class DistributePackages {
    
    // PUBLIC

    @AuraEnabled(cacheable=true)
    public static List<copado__Artifact_Version__c> fetchPkgVersionsFor(Id packageId) {
        return new PackageVersionsSelector().byPackageIds(new Set<Id>{ packageId });
    }


    @AuraEnabled(cacheable=true)
    public static List<copado__Org__c> getCredentials(List<String> credentialIds) {
        if (credentialIds.isEmpty()) {
            return new CredentialsSelector().byActiveEnvAndPlatform(new Set<String>{ 'SFDX' });
        } else {
            return new CredentialsSelector().byIds(credentialIds);
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<copado__Project__c> getProjects() {
        return new ProjectsSelector().byActivePipelineRepoAndPlatform();
    }


    @AuraEnabled
    public static List<copado__JobExecution__c> initiateDistributionFor(
        String pkgVersionId,
        List<String> credentialIds
    ) {
        return new DeployPackages(pkgVersionId, credentialIds).execute();
    }
}