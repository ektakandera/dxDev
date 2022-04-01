import { LightningElement, wire, track } from "lwc";
import startPublish from "@salesforce/apex/PackageVersionPublishHandler.startPublish";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PackageVersionPublish extends NavigationMixin(LightningElement) {
    recordId;
    @track alert;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    async connectedCallback() {
        try {
            await startPublish({ recordId: this.recordId });
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