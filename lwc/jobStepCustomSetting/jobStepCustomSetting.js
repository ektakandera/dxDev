import { LightningElement, api } from 'lwc';
import { label, columns } from './constants';

export default class JobStepCustomSetting extends LightningElement {
    @api configJson;
    @api isReadOnly;

    label = label;
    columns = columns;

    get isCreateMode() {
        return !this.configJson && !this.isReadOnly;
    }

    get isEditMode() {
        return this.configJson && !this.isReadOnly;
    }

    get isViewMode() {
        return this.configJson && this.isReadOnly;
    }

    @api
    getConfig() {
        const customSettingElement = this.template.querySelector("[data-id='customSettingJobStep']");
        return customSettingElement ? customSettingElement.getConfig() : {};
    }

    @api
    getAutoFormValidation() {
        const customSettingElement = this.template.querySelector("[data-id='customSettingJobStep']");
        return customSettingElement ? customSettingElement.getAutoFormValidation() : true;
    }
}