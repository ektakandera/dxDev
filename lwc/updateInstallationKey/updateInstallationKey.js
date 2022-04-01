import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import MANAGE_PACKAGE_KEYS from "@salesforce/customPermission/Manage_Package_Keys";

import SUBSCRIBER_VERSION_ID_FIELD from "@salesforce/schema/copado__Artifact_Version__c.copado__Subscriber_Version_Id__c";
import fetchInstallationKey from "@salesforce/apex/UpdateInstallationKey.fetchInstallationKey";
import executeJob from "@salesforce/apex/UpdateInstallationKey.executeJob";

export default class UpdateInstallationKey extends LightningElement {
    @api recordId;

    @track alert;

    readonly = true;
    editAccess = MANAGE_PACKAGE_KEYS;
    installationKey = "";
    subscriberVersionId;

    @wire(getRecord, { recordId: "$recordId", fields: [SUBSCRIBER_VERSION_ID_FIELD] })
    wiredVersion({ data, error }) {
        if (this.editAccess) {
            if (data) {
                this.subscriberVersionId = getFieldValue(data, SUBSCRIBER_VERSION_ID_FIELD);
                this._getKeys();
            } else if (error) {
                this.alert = {
                    message: error.body || error.body?.message,
                    variant: "Error",
                    title: "No access"
                };
            }
        } else {
            this.alert = {
                message:
                    "You do not have the necessary permissions to perform the action. Please get in touch with your System Administrator for more information.",
                variant: "Error",
                title: "No access"
            };
        }
    }

    // PUBLIC

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleEdit() {
        if (!this.installationKey) {
            this.installationKey = true;
            this.alert = false;
        }
        /* eslint-disable @lwc/lwc/no-async-operation */
        // Note: Waiting for rendering to finish
        setTimeout(
            function () {
                this.template.querySelector("lightning-input").readOnly = this.readonly = false;
                this.template.querySelector("lightning-input").focus();
            }.bind(this)
        );
    }

    handleSave() {
        const input = this.template.querySelector("lightning-input");

        if (input.value === this.installationKey) {
            input.setCustomValidity("No Change.");
        }

        if (input.reportValidity()) {
            this._updateKey();
        }
    }

    // PRIVATE

    async _updateKey() {
        try {
            await executeJob({
                subscriberVersionId: this.subscriberVersionId,
                installationKey: this.template.querySelector("lightning-input").value
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Job started!",
                    message: "Please {0} the page.",
                    variant: "success",
                    mode: "pester",
                    messageData: [
                        {
                            url: `/${this.recordId}`,
                            label: "refresh"
                        }
                    ]
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (ex) {
            this.alert = {
                message: ex.message || ex.body?.message,
                variant: "Error",
                title: "Error"
            };
        }
    }

    async _getKeys() {
        try {
            this.installationKey = await fetchInstallationKey({ subscriberVersionId: this.subscriberVersionId });
            if (!this.installationKey) {
                this.alert = {
                    message: "This package version does not have an installation key. Click edit to enter.",
                    variant: "Info",
                    title: "Installation key not present."
                };
            }
        } catch (ex) {
            this.alert = {
                message: ex.message || ex.body?.message,
                variant: "Error",
                title: "Error"
            };
        }
    }
}