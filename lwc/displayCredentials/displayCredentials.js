import { LightningElement, api } from "lwc";
import getCredentials from "@salesforce/apex/DistributePackages.getCredentials";
import { schema } from "./constants";

const columns = [
    {
        label: "Name",
        fieldName: "Link",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
    },
    { label: "Org Type", fieldName: "OrgType", sortable: true },
    { label: "Username", fieldName: "Username", sortable: true },
    {
        label: "Environment",
        fieldName: "EnvironmentLink",
        type: "url",
        sortable: true,
        typeAttributes: {
            label: { fieldName: "EnvironmentName" },
            target: "_blank"
        }
    },
    {
        label: "Default Credential",
        fieldName: "DefaultCredential",
        type: "boolean",
        sortable: true
    },
    { label: "SFDC Org Id", fieldName: "SFDCOrgId", sortable: true },
    {
        label: "Is Developer Hub Credential",
        fieldName: "IsDeveloperHubOrg",
        type: "boolean",
        sortable: true
    }
];

export default class DisplayCredentials extends LightningElement {
    rows = [];
    selectedRows = [];
    columns = columns;
    hideCheckboxColumn = false;
    isLoading = true;
    error;

    @api usageType;
    @api
    get credentialIds() {
        const datatable = this.template.querySelector("c-generic-datatable");
        return datatable ? datatable.selectedRows.toString() : "";
    }
    set credentialIds(selections) {
        this.selectedRows = selections.split(",");
    }

    async connectedCallback() {
        try {
            const selected = this.usageType === "Selection" ? [] : this.selectedRows;
            this.hideCheckboxColumn = this.usageType === "Confirmation";

            const result = await getCredentials({ credentialIds: selected });
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

    _createTableRows(credentials) {
        return credentials.map((credential) => {
            return {
                Id: credential[schema.ID_FIELD],
                Name: credential[schema.NAME_FIELD],
                Link: "/" + credential[schema.ID_FIELD],
                OrgType: credential[schema.ORG_TYPE_FIELD],
                Username: credential[schema.USERNAME_FIELD],
                EnvironmentName: credential[schema.ENVIRONMENT_FIELD.replace("__c", "__r")][schema.NAME_FIELD],
                EnvironmentLink: "/" + credential[schema.ENVIRONMENT_FIELD.replace("__c", "__r")][schema.ID_FIELD],
                DefaultCredential: credential[schema.DEFAULT_CREDENTIAL_FIELD],
                SFDCOrgId: credential[schema.SFDC_ORG_ID_FIELD],
                IsDeveloperHubOrg: credential[schema.IS_DEVELOPER_HUB_ORG_FIELD]
            };
        });
    }
}