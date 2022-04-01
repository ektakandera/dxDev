import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import PACKAGE_VERSION_OBJECT from "@salesforce/schema/copado__Artifact_Version__c";
import { layout } from "./constants";

export default class EditConfigPackageVersion extends NavigationMixin(LightningElement) {
    objectApiName = PACKAGE_VERSION_OBJECT.objectApiName;
    layout = layout;
    recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
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