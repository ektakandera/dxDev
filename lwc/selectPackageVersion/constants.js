import VERSION_NUMBER_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Version_number__c";
import BRANCH_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Branch__c";
import STATUS_FIELD_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Status__c";
import RELEASE_STATUS_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Release_Status__c";
import IS_RELEASED_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Is_released__c";
import TAG_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Tag__c";

export const schema = {
    ID_FIELD: "Id",
    NAME_FIELD: "Name",
    VERSION_NUMBER_FIELD: VERSION_NUMBER_FIELD.fieldApiName,
    BRANCH_FIELD: BRANCH_FIELD.fieldApiName,
    STATUS_FIELD: STATUS_FIELD_FIELD.fieldApiName,
    RELEASE_STATUS_FIELD: RELEASE_STATUS_FIELD.fieldApiName,
    IS_RELEASED_FIELD: IS_RELEASED_FIELD.fieldApiName,
    TAG_FIELD: TAG_FIELD.fieldApiName
};