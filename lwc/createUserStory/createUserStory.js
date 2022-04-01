import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from "lightning/flowSupport";
import PROJECT_FIELD from "@salesforce/schema/copado__User_Story__c.copado__Project__c";
import TITLE_FIELD from "@salesforce/schema/copado__User_Story__c.copado__User_Story_Title__c";
import getFieldsFromFieldSet from "@salesforce/apex/PipelineDistributionCtrl.getFieldsFromFieldSet";

export default class CreateUserStory extends LightningElement {
    @api serializedUserStory;
    @api projectId;
    @api userStoryTitle;
    objectApiName = TITLE_FIELD.objectApiName;
    recordTypeName = "Utility";
    fieldSet = "PipelineBasedPackageDistribution";
    error;

    recordTypeId;
    fields = [];
    isLoading = true;

    @wire(getObjectInfo, { objectApiName: "$objectApiName" })
    objectInfo({ error, data }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find((rti) => rtis[rti].name === this.recordTypeName);
        } else if (error) {
            this.error = {
                message: error.message || error.body?.message,
                variant: "Warning",
                title: "Error"
            };
        }
    }

    async connectedCallback() {
        try {
            this.fields = await getFieldsFromFieldSet({ objectApiName: this.objectApiName, fieldSet: this.fieldSet });
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

    async handleOnLoad() {
        if (this.serializedUserStory) {
            const fields = JSON.parse(this.serializedUserStory);
            const inputFields = this.template.querySelectorAll("lightning-input-field");
            if (inputFields) {
                inputFields.forEach((field) => {
                    field.value = fields[field.fieldName];
                });
            }
        }
        const projectField = this.template.querySelector(`[data-field="${PROJECT_FIELD.fieldApiName}"]`);
        if (projectField) {
            projectField.value = this.projectId;
        }
        const titleField = this.template.querySelector(`[data-field="${TITLE_FIELD.fieldApiName}"]`);
        if (titleField) {
            titleField.value = this.userStoryTitle;
        }
        this.isLoading = false;
    }

    async handleNext() {
        await this._submitForm();
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    async handlePrevious() {
        await this._submitForm();
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.RecordTypeId = this.recordTypeId;
        this.serializedUserStory = JSON.stringify(fields);
    }

    async _submitForm() {
        const btn = this.template.querySelector(".submit");
        if (btn) {
            btn.click();
        }
    }
}