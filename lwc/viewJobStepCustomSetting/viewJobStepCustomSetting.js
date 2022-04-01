import { LightningElement, api } from 'lwc';
import { columns } from './constants';
import { ERROR } from 'c/jobStepCustomSettingUtils';

// INITIAL_RECORS_COUNT holds the number of records
// which will be displayed in the initial load.
// The user can click the 'View All' link to see all the records
const INITIAL_RECORS_COUNT = 3;
const ICON_NAME = 'standard:record_update';

export default class ViewJobStepCustomSetting extends LightningElement {
    @api configJson;
    @api label;

    columns = columns;
    hasFooter = false;
    selectedRecords;
    selectedCustomSetting = '';
    footerLabel;
    alert;
    allRecords;
    iconName = ICON_NAME;

    connectedCallback() {
        this._setRecords();
    }

    _setRecords() {
        if (this.configJson) {
            try {
                this.allRecords = [];
                const config = JSON.parse(this.configJson);
                Object.entries(config).forEach(([objectApiName, data]) => {
                    this.selectedCustomSetting = objectApiName;
                    this.allRecords = this.allRecords.concat(data);
                });
                if (this.allRecords.length > INITIAL_RECORS_COUNT) {
                    this.hasFooter = true;
                    this._setFooterInfo();
                } else {
                    this.selectedRecords = this.allRecords;
                }
            } catch (error) {
                this.alert = { message: error.message || error.body?.message, variant: ERROR, title: ERROR };
            }
        }
    }

    get isDataAvailable() {
        return this.selectedRecords?.length;
    }

    handleClick(event) {
        event.preventDefault();
        this._setFooterInfo(event.currentTarget.dataset.id);
    }

    _setFooterInfo(viewName) {
        if (viewName === this.label.ViewAll) {
            this.footerLabel = this.label.ViewLess;
            this.selectedRecords = this.allRecords;
        } else {
            this.footerLabel = this.label.ViewAll;
            this.selectedRecords = this.allRecords.slice(0, INITIAL_RECORS_COUNT);
        }
    }
}