import { LightningElement, wire } from "lwc";
import startCreate from "@salesforce/apex/PackageVersionCreateHandler.startCreate";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { parameters } from "./parameters";

export default class PackageVersionCreate extends NavigationMixin(LightningElement) {
    recordId;
    parameters = parameters;
    coreParameters = ["versionname", "versionnumber", "versiondescription"];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    async create() {
        try {
            await startCreate({ params: this.generateDataJSON() });
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

    generateDataJSON() {
        let versionDetails = {};
        let jsonInformation = {};

        this.template.querySelectorAll("lightning-input").forEach((record) => {
            let value = record.type === "checkbox" ? record.checked : record.value;

            if (this.coreParameters.includes(record.name)) {
                versionDetails[record.name] = value;
            } else {
                jsonInformation[record.name] = value;
            }
        });
        versionDetails.package = this.recordId;
        versionDetails.jsonInformation = jsonInformation;

        return JSON.stringify(versionDetails);
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