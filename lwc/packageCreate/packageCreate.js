import { LightningElement, track, wire } from "lwc";
import startCreate from "@salesforce/apex/PackageCreateHandler.startCreate";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Package_Creation_Started from "@salesforce/label/c.Package_Creation_Started";
import PLATFORM_FIELD from "@salesforce/schema/copado__Artifact__c.copado__Pipeline__r.copado__Platform__c";
import PACKAGE_TYPE_FIELD from "@salesforce/schema/copado__Artifact__c.copado__Package_Type__c";

export default class PackageCreate extends NavigationMixin(LightningElement) {
    recordId;
    packageType;
    packageCreationMessage;

    @track alert;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: [PLATFORM_FIELD, PACKAGE_TYPE_FIELD] })
    wiredVersion({ data, error }) {
        if (data) {
            this.platform = getFieldValue(data, PLATFORM_FIELD);
            this.packageCreationMessage = Package_Creation_Started.replace('{0}',getFieldValue(data, PACKAGE_TYPE_FIELD));
        } else if (error) {
            this.alert = {
                message: error?.body || error.body?.message,
                variant: "Error",
                title: "No access"
            };
        }
    }

    async create() {
        try {
            
            await startCreate({ recordId: this.recordId });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Job started successfully!",
                    variant: "success",
                    mode: "pester"
                })
            );
            this.closeModal();
        } catch (ex) {
            this.alert = {
                message: ex.message || ex.body?.message,
                variant: "Error",
                title: "Error"
            };
        }
    }

    closeModal() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                actionName: "view"
            }
        });
    }
}