import PACKAGE_ID_FIELD from "@salesforce/schema/copado__Artifact__c.copado__Package_Id__c";
import SOURCE_API_VERSION_FIELD from "@salesforce/schema/copado__Artifact__c.copado__Source_Api_Version__c";
import TARGET_DEV_HUB_ORG_FIELD from "@salesforce/schema/copado__Artifact__c.copado__Target_Dev_Hub_Org__c";
import NO_NAMESPACE_FIELD from "@salesforce/schema/copado__Artifact__c.copado__No_Namespace__c";
import PACKAGE_NAMESPACE_FIELD from "@salesforce/schema/copado__Artifact__c.copado__Package_Namespace__c";
import IS_ORG_DEPENDENT_FIELD from "@salesforce/schema/copado__Artifact__c.IsOrgDependent__c";
import DATA_JSON_FIELD from "@salesforce/schema/copado__Artifact__c.copado__DataJSON__c";

export const layout = [
    {
        header: true,
        name: "Package Parameters",
        size: 12
    },
    {
        output: true,
        name: PACKAGE_ID_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: SOURCE_API_VERSION_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: TARGET_DEV_HUB_ORG_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: NO_NAMESPACE_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: PACKAGE_NAMESPACE_FIELD.fieldApiName,
        size: 6
    },
    {
        output: true,
        name: IS_ORG_DEPENDENT_FIELD.fieldApiName,
        size: 6
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