import PIPELINE_FIELD from "@salesforce/schema/copado__Project__c.copado__Deployment_Flow__c";
import MAIN_BRANCH_FIELD from "@salesforce/schema/copado__Deployment_Flow__c.copado__Main_Branch__c";
import GIT_REPOSITORY_FIELD from "@salesforce/schema/copado__Deployment_Flow__c.copado__Git_Repository__c";
import ENABLE_COPADO_DX_FIELD from "@salesforce/schema/copado__Deployment_Flow__c.copado__Enable_Copado_DX__c";

export const schema = {
    ID_FIELD: "Id",
    NAME_FIELD: "Name",
    PIPELINE_FIELD: PIPELINE_FIELD.fieldApiName,
    MAIN_BRANCH_FIELD: MAIN_BRANCH_FIELD.fieldApiName,
    GIT_REPOSITORY_FIELD: GIT_REPOSITORY_FIELD.fieldApiName,
    ENABLE_COPADO_DX_FIELD: ENABLE_COPADO_DX_FIELD.fieldApiName
};