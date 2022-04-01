public with sharing class PackageVersionCreateAction {
    private static final Set<String> FLAGS = new Set<String>{
        'apiversion',
        'overridePath',
        'overrideProjectJsonPath',
        'tag',
        'installationkeybypass',
        'codecoverage',
        'skipvalidation',
        'releasenotesurl',
        'postinstallurl',
        'postinstallscript',
        'uninstallscript'
    };

    @InvocableMethod(label='Create Package Version' category='Package Version Creation')
    public static List<Response> execute(List<Request> requests) {
        try {
            PackageInfo.Versions version = (PackageInfo.Versions) System.JSON.deserialize(
                requests[0].packageVersionJson,
                PackageInfo.Versions.class
            );
            List<copado__Artifact__c> packages = new PackagesSelector()
                .byPackage2Ids(new Set<Id>{ version.Package2Id });

            if (!packages.isEmpty()) {
                copado__Artifact_Version__c result = createVersion(
                    packages[0],
                    version,
                    (Map<String, Object>) JSON.deserializeUntyped(
                        (requests[0].jsonInformation).unescapeEcmaScript()
                    )
                );

                return new List<Response>{ new Response(JSON.serialize(result, true).escapeEcmaScript()) };
            } else {
                throw new ApplicationException('No package found with Id:' + version.Package2Id);
            }
        } catch (Exception ex) {
            throw new ApplicationException(ex.getMessage());
        }
    }

    // PRIVATE

    private static copado__Artifact_Version__c createVersion(
        copado__Artifact__c pkg,
        PackageInfo.Versions version,
        Map<String, Object> parsedJSON
    ) {
        parsedJSON.put('apiversion', pkg?.copado__Source_Api_Version__c);
        String dataJSON = getDataJSON(parsedJSON);

        copado__Artifact_Version__c result = new copado__Artifact_Version__c();
        result.copado__Artifact__c = pkg.Id;
        result.copado__Package_Version_Id__c = version.Id;
        result.copado__Subscriber_Version_Id__c = version.SubscriberPackageVersionId;
        result.copado__Is_released__c = version.IsReleased;
        result.copado__Branch__c = version.Branch;
        result.copado__Version_Name__c = version.Name;
        result.copado__Tag__c = version.Tag;
        result.copado__Version_Description__c = version.Description;
        result.copado__Version_number__c = version.Version;
        result.copado__Data_JSON__c = dataJSON;
        result.Name = pkg.Name + ' - ' + version.Version;

        if (
            !(Boolean) parsedJSON.get('installationkeybypass') &&
            String.isNotBlank((String) parsedJSON.get('installationkey'))
        ) {
            storeInstallationKey(
                result.Name,
                version.SubscriberPackageVersionId,
                (String) parsedJSON.get('installationkey')
            );
        }

        return result;
    }

    private static String getDataJSON(Map<String, Object> parsedJSON) {
        Map<String, Object> attributes = new Map<String, Object>();

        for (String constant : FLAGS) {
            attributes.put(constant, parsedJSON.get(constant));
        }
        return JSON.serialize(attributes, true);
    }

    private static void storeInstallationKey(
        String versionName,
        String subscriberVersionId,
        String key
    ) {
        insert new PackageVersionInstallationKey__c(
            Name = versionName,
            PackageVersionId__c = subscriberVersionId,
            InstallationKey__c = key
        );
    }
    // INNER

    public class Request {
        @InvocableVariable(label='Generated package version JSON info' required=true)
        public String packageVersionJson;

        @InvocableVariable(label='Package version additional JSON info')
        public String jsonInformation;
    }

    public class Response {
        @InvocableVariable
        public String version;

        public Response(String version) {
            this.version = version;
        }
    }
}