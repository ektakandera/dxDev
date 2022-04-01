import { LightningElement, api } from "lwc";
import initiateDistributionFor from "@salesforce/apex/DistributePackages.initiateDistributionFor";
import DESTINATION_FIELD from "@salesforce/schema/copado__JobExecution__c.copado__Destination__c";

const columns = [
    {
        label: "Name",
        fieldName: "ExecutionLink",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "ExecutionName" }, target: "_blank" }
    },
    {
        label: "Destination Environment",
        fieldName: "EnvironmentLink",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "EnvironmentName" }, target: "_blank" }
    }
];

const schema = {
    ID_FIELD: "Id",
    NAME_FIELD: "Name",
    DESTINATION_FIELD: DESTINATION_FIELD.fieldApiName
};

export default class DistributeToEnvironments extends LightningElement {
    rows = [];
    selectedRows = [];
    columns = columns;
    isLoading = true;
    error;

    @api pkgVersionId;
    @api
    get credentialIds() {
        return [];
    }
    set credentialIds(selections) {
        this.selectedRows = selections.split(",");
    }

    async connectedCallback() {
        try {
            const result = await initiateDistributionFor({
                pkgVersionId: this.pkgVersionId,
                credentialIds: this.selectedRows
            });
            this.rows = this._createTableRows(result);
        } catch (ex) {
            this.error = {
                message: ex.message || ex.body?.message,
                variant: "Warning",
                title: "Error"
            };
        } finally {
            this.isLoading = false;
        }
    }

    _createTableRows(jobExecutions) {
        return jobExecutions.map((execution) => {
            return {
                ExecutionName: execution[schema.NAME_FIELD],
                ExecutionLink: "/" + execution[schema.ID_FIELD],
                EnvironmentLink: "/" + execution[schema.DESTINATION_FIELD.replace("__c", "__r")][schema.ID_FIELD],
                EnvironmentName: execution[schema.DESTINATION_FIELD.replace("__c", "__r")][schema.NAME_FIELD]
            };
        });
    }
}