import PACKAGE_VERSION_ID_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Package_Version_Id__c";
import SUBSCRIBER_VERSION_ID_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Subscriber_Version_Id__c";
import IS_RELEASED_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Is_released__c";
import SANDBOX_INSTALLATION_URL_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Sandbox_Installation_URL__c";
import PRODUCTION_INSTALLATION_URL_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Production_Installation_URL__c";
import DATA_JSON_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Data_JSON__c";

export const layout = [
    {
        header: true,
        name: "Integration/Build",
        size: 12
    },
    {
        output: true,
        name: PACKAGE_VERSION_ID_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: SUBSCRIBER_VERSION_ID_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: IS_RELEASED_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: SANDBOX_INSTALLATION_URL_FIELD.fieldApiName,
        size: 12
    },
    {
        output: true,
        name: PRODUCTION_INSTALLATION_URL_FIELD.fieldApiName,
        size: 12
    },
    {
        header: true,
        name: "Additional Parameters",
        size: 12
    },
    {
        output: true,
        name: DATA_JSON_FIELD.fieldApiName,
        size: 12
    }
];