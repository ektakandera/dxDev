public with sharing class JobStepCustomSettingHandler {
    @TestVisible
    private static copado.GlobalAPI.ProxyOrgResponse mockResponse;

    // PUBLIC

    @AuraEnabled
    public static List<Object> getCustomSettings(String credentialId) {
        String queryParam = EncodingUtil.urlEncode(
            'SELECT QualifiedApiName, DeveloperName FROM EntityDefinition WHERE IsCustomSetting = true',
            'UTF-8'
        );
        String endpoint = getEndpoint(Settings.TOOLING_API_ENDPOINT, queryParam);

        copado.GlobalAPI.ProxyOrgResponse response = makeCallout(createRequest(endpoint, 'List all custom setting Tooling API Query', credentialId));

        return processResponse(response);
    }

    @AuraEnabled
    public static List<Object> getRecords(String objectAPIName, String credentialId) {
        String queryParam = EncodingUtil.urlEncode('SELECT Id, Name, SetupOwnerId, SetupOwner.Name FROM ' + objectAPIName, 'UTF-8');
        String endpoint = getEndpoint('/services/data/v53.0', queryParam);

        copado.GlobalAPI.ProxyOrgResponse response = makeCallout(createRequest(endpoint, 'List all ' + objectAPIName + ' custom setting Records.', credentialId));
        return processResponse(response);
    }

    //PRIVATE

    private static String getEndpoint(String api, String queryParam) {
        return api + '/query/?q=' + queryParam;
    }

    private static copado.GlobalAPI.ProxyOrgRequest createRequest(String endpoint, String logLabelIdentifier, String credentialId) {
        copado.GlobalAPI.ProxyOrgRequest request = new copado.GlobalAPI.ProxyOrgRequest();
        request.endPointUrlService = endpoint;
        request.orgCredentialId = credentialId;
        request.logLabelIdentifier = logLabelIdentifier;
        request.requestType = HttpMethod.GET.name();

        return request;
    }

    private static copado.GlobalAPI.ProxyOrgResponse makeCallout(copado.GlobalAPI.ProxyOrgRequest request) {
        return Test.isRunningTest() ? mockResponse : new copado.GlobalAPI().proxyOrgRequest(request);
    }

    private static List<Object> processResponse(copado.GlobalAPI.ProxyOrgResponse response) {
        if (response.statusCode == 200) {
            Map<String, Object> content = (Map<String, Object>) JSON.deserializeUntyped(response.content);
            return (List<Object>) content.get('records');
        } else {
            String message = String.isNotBlank(response.errorMessage) ? response.errorMessage : 'Error in listing custom settings.';
            throw new ApplicationException(message);
        }
    }
}