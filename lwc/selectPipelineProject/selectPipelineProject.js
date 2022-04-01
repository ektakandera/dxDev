import { LightningElement, api } from "lwc";
import getProjects from "@salesforce/apex/DistributePackages.getProjects";
import { schema } from "./constants";

const columns = [
    {
        label: "Pipeline",
        fieldName: "PipelineLink",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "PipelineName" }, target: "_blank" }
    },
    {
        label: "Project",
        fieldName: "ProjectLink",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "ProjectName" }, target: "_blank" }
    },
    {
        label: "Git Repository",
        fieldName: "GitRepositoryLink",
        type: "url",
        sortable: true,
        typeAttributes: { label: { fieldName: "GitRepositoryName" }, target: "_blank" }
    },
    { label: "Main Branch", fieldName: "MainBranch", sortable: true },
    { label: "Enable Copado DX", fieldName: "EnableCopadoDX", sortable: true }
];

export default class SelectPipelineProject extends LightningElement {
    rows = [];
    selectedRows = [];
    columns = columns;
    isLoading = true;
    error;

    @api
    get selectedProject() {
        const datatable = this.template.querySelector("c-generic-datatable");
        return datatable ? datatable.selectedRows.toString() : "";
    }
    set selectedProject(selections) {
        this.selectedRows = selections.split(",");
    }

    async connectedCallback() {
        try {
            const result = await getProjects({});
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

    _createTableRows(projects) {
        return projects.map((project) => {
            return {
                Id: project[schema.ID_FIELD],
                ProjectName: project[schema.NAME_FIELD],
                ProjectLink: "/" + project[schema.ID_FIELD],
                PipelineLink: "/" + project[schema.PIPELINE_FIELD.replace("__c", "__r")][schema.ID_FIELD],
                PipelineName: project[schema.PIPELINE_FIELD.replace("__c", "__r")][schema.NAME_FIELD],
                GitRepositoryLink:
                    "/" +
                    project[schema.PIPELINE_FIELD.replace("__c", "__r")][
                        schema.GIT_REPOSITORY_FIELD.replace("__c", "__r")
                    ][schema.ID_FIELD],
                GitRepositoryName:
                    project[schema.PIPELINE_FIELD.replace("__c", "__r")][
                        schema.GIT_REPOSITORY_FIELD.replace("__c", "__r")
                    ][schema.NAME_FIELD],
                MainBranch: project[schema.PIPELINE_FIELD.replace("__c", "__r")][schema.MAIN_BRANCH_FIELD],
                EnableCopadoDX: project[schema.PIPELINE_FIELD.replace("__c", "__r")][schema.ENABLE_COPADO_DX_FIELD]
            };
        });
    }
}