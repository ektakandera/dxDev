import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getSearchedData, getSortedData } from 'c/datatableService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import { schema } from './constants';
import { getConfig, onRowSelection, getItemDetailsVerbiage, getAutoFormValidation, ERROR } from 'c/jobStepCustomSettingUtils';

const FIELDS_TO_QUERY = [];
const ICON_NAME = 'standard:record_update';

export default class EditJobStepCustomSetting extends LightningElement {
    @api configJson;
    @api label;
    @api columns;

    iconName = ICON_NAME;
    selectedRecords;
    selectedCustomSetting = '';
    selectedRows;
    sortDirection = 'asc';
    sortedBy;
    showSpinner;
    alert;
    _orgName;
    _allRecords;
    _userStoryKeyPrefix;
    _jobStepKeyPrefix;
    _recordId;
    _pageReferenceInfo;

    connectedCallback() {
        this._setRecords();
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this._pageReferenceInfo = currentPageReference;
            this._setDataToGetRecordDetails();
        }
    }

    @wire(getObjectInfos, { objectApiNames: [schema.USER_STORY_OBJECT, schema.JOB_STEP_OBJECT] })
    getObjectDetails({ error, data }) {
        if (data) {
            let errorInfo = '';
            data.results.forEach((obj) => {
                if (obj.statusCode === 200) {
                    if (obj.result.apiName === schema.USER_STORY_OBJECT.objectApiName) {
                        this._userStoryKeyPrefix = obj.result.keyPrefix;
                    } else if (obj.result.apiName === schema.JOB_STEP_OBJECT.objectApiName) {
                        this._jobStepKeyPrefix = obj.result.keyPrefix;
                    }
                } else {
                    errorInfo += obj.result.map((err) => err.message).join(' ');
                }
            });
            if (errorInfo) {
                this.alert = { message: errorInfo, variant: ERROR, title: ERROR };
            } else {
                this._setDataToGetRecordDetails();
            }
        } else if (error) {
            this.alert = { message: error?.body || error.body?.message, variant: ERROR, title: ERROR };
        }
    }

    _setDataToGetRecordDetails() {
        if (this._pageReferenceInfo?.attributes?.recordId && this._userStoryKeyPrefix && this._jobStepKeyPrefix && !this._orgName) {
            FIELDS_TO_QUERY.push(
                this._pageReferenceInfo.attributes.recordId.startsWith(this._userStoryKeyPrefix)
                    ? schema.USER_STORY_ORG_NAME
                    : this._pageReferenceInfo.attributes.recordId.startsWith(this._jobStepKeyPrefix)
                    ? schema.JOB_STEP_ORG_NAME
                    : null
            );
            if (FIELDS_TO_QUERY.length) {
                this._recordId = this._pageReferenceInfo.attributes.recordId;
            }
        }
    }

    @wire(getRecord, { recordId: '$_recordId', fields: FIELDS_TO_QUERY })
    getRecordDetails({ error, data }) {
        if (data) {
            this._orgName = getFieldValue(
                data,
                this._recordId.startsWith(this._userStoryKeyPrefix)
                    ? schema.USER_STORY_ORG_NAME
                    : this._recordId.startsWith(this._jobStepKeyPrefix)
                    ? schema.JOB_STEP_ORG_NAME
                    : null
            );
        } else if (error) {
            this.alert = { message: error.message || error.body?.message, variant: ERROR, title: ERROR };
        }
    }

    @api
    getAutoFormValidation() {
        const result = getAutoFormValidation(this.selectedRows, this.label);
        this.alert = result.data;
        return result.isValid;
    }

    get customSettingRecordsVerbiage() {
        return this._orgName ? this.label.CustomSettingRecordsEnvName.replace('{0}', this._orgName) : this.label.CustomSettingRecords;
    }

    _setRecords() {
        if (this.configJson) {
            this.showSpinner = true;
            try {
                this.selectedRecords = [];
                this.selectedRows = [];
                const config = JSON.parse(this.configJson);
                Object.entries(config).forEach(([objectApiName, data]) => {
                    this.selectedCustomSetting = objectApiName;
                    this.selectedRows = this.selectedRows.concat(data.map((record) => record.Id));
                    this.selectedRecords = this.selectedRecords.concat(data);
                });
                this._allRecords = this.selectedRecords;
            } catch (error) {
                this.alert = { message: error.message || error.body?.message, variant: ERROR, title: ERROR };
            } finally {
                this.showSpinner = false;
            }
        }
    }

    onRowSelection(event) {
        this.selectedRows = [...onRowSelection(event.detail.selectedRows, this.selectedRecords, this.selectedRows)];
    }

    async handleRecordSearch(event) {
        this.showSpinner = true;
        const searchTerm = event.detail.searchTerm;
        const filteredRawData = await getSearchedData(this.columns, this._allRecords, searchTerm);
        this.selectedRecords = this.sortedBy
            ? getSortedData(this.columns, filteredRawData, { name: this.sortedBy, sortDirection: this.sortDirection })
            : filteredRawData;
        this.showSpinner = false;
    }

    handleClearSearch() {
        this.selectedRecords = this.sortedBy
            ? getSortedData(this.columns, this._allRecords, { name: this.sortedBy, sortDirection: this.sortDirection })
            : [...this._allRecords];
        this.selectedRows = [...this.selectedRows];
    }

    handleSort(event) {
        try {
            this.showSpinner = true;
            this.sortedBy = event.detail.fieldName;
            this.sortDirection = event.detail.sortDirection;
            this.selectedRecords = [
                ...getSortedData(this.columns, this.selectedRecords, { name: this.sortedBy, sortDirection: this.sortDirection })
            ];
        } catch (error) {
            this.alert = { message: error.message || error.body?.message, variant: ERROR, title: ERROR };
        } finally {
            this.showSpinner = false;
        }
    }

    get isDataAvailable() {
        return this.selectedRecords?.length;
    }

    get itemDetails() {
        return getItemDetailsVerbiage(this.selectedRows, this.label);
    }

    @api
    getConfig() {
        let configJson;
        if (this._allRecords && this.selectedRows) {
            const selectedRecords = this._allRecords.filter((element) => this.selectedRows.includes(element.Id));
            configJson = getConfig(this.selectedCustomSetting, selectedRecords);
        }
        return configJson;
    }
}