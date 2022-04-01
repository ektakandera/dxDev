import { LightningElement, api } from "lwc";
import fetchPkgVersionsFor from "@salesforce/apex/DistributePackages.fetchPkgVersionsFor";
import { schema } from "./constants";

const columns = [
    {
        label: "Name",
        fieldName: "Link",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
    },
    { label: "Version number", fieldName: "VersionNumber", sortable: true },
    { label: "Branch", fieldName: "Branch", sortable: true },
    { label: "Status", fieldName: "Status", sortable: true },
    { label: "Release status", fieldName: "ReleaseStatus", sortable: true },
    {
        label: "Is released",
        fieldName: "IsReleased",
        type: "boolean",
        sortable: true
    },
    { label: "Tag", fieldName: "Tag", sortable: true }
];

export default class SelectPackageVersion extends LightningElement {
    rows = [];
    selectedRows = [];
    columns = columns;
    isLoading = true;
    error;

    @api recordId;
    @api
    get selectedPkgVersion() {
        const datatable = this.template.querySelector("c-generic-datatable");
        return datatable ? datatable.selectedRows.toString() : "";
    }
    set selectedPkgVersion(selections) {
        this.selectedRows = selections.split(",");
    }

    async connectedCallback() {
        try {
            const result = await fetchPkgVersionsFor({
                packageId: this.recordId
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

    _createTableRows(versions) {
        return versions.map((version) => {
            return {
                Id: version[schema.ID_FIELD],
                Name: version[schema.NAME_FIELD],
                Link: "/" + version[schema.ID_FIELD],
                VersionNumber: version[schema.VERSION_NUMBER_FIELD],
                Branch: version[schema.BRANCH_FIELD],
                Status: version[schema.STATUS_FIELD],
                ReleaseStatus: version[schema.RELEASE_STATUS_FIELD],
                IsReleased: version[schema.IS_RELEASED_FIELD],
                Tag: version[schema.TAG_FIELD]
            };
        });
    }
}