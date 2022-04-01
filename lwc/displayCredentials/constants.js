import ORG_TYPE_FIELD from "@salesforce/schema/copado__Org__c.copado__Org_Type__c";
import USERNAME_FIELD from "@salesforce/schema/copado__Org__c.copado__Username__c";
import ENVIRONMENT_FIELD from "@salesforce/schema/copado__Org__c.copado__Environment__c";
import DEFAULT_CREDENTIAL_FIELD from "@salesforce/schema/copado__Org__c.copado__Default_Credential__c";
import SFDC_ORG_ID_FIELD from "@salesforce/schema/copado__Org__c.copado__SFDC_Org_ID__c";
import IS_DEVELOPER_HUB_ORG_FIELD from "@salesforce/schema/copado__Org__c.copado__is_Developer_Hub_Org__c";

export const schema = {
    ID_FIELD: "Id",
    NAME_FIELD: "Name",
    ORG_TYPE_FIELD: ORG_TYPE_FIELD.fieldApiName,
    USERNAME_FIELD: USERNAME_FIELD.fieldApiName,
    ENVIRONMENT_FIELD: ENVIRONMENT_FIELD.fieldApiName,
    DEFAULT_CREDENTIAL_FIELD: DEFAULT_CREDENTIAL_FIELD.fieldApiName,
    SFDC_ORG_ID_FIELD: SFDC_ORG_ID_FIELD.fieldApiName,
    IS_DEVELOPER_HUB_ORG_FIELD: IS_DEVELOPER_HUB_ORG_FIELD.fieldApiName
};