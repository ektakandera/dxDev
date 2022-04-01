import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCustomSettings from '@salesforce/apex/JobStepCustomSettingHandler.getCustomSettings';
import getRecords from '@salesforce/apex/JobStepCustomSettingHandler.getRecords';
import { getSearchedData, getSortedData } from 'c/datatableService';
import { schema } from './constants';
import { getConfig, onRowSelection, getItemDetailsVerbiage, getAutoFormValidation, ERROR } from 'c/jobStepCustomSettingUtils';

export default class CreateJobStepCustomSetting extends LightningElement {
    recordId;
    credentialId;

    selectedCustomSetting;
    records;
    selectedRows = [];
    message;
    selectedId = [];

    showRetrieveNow = true;
    showPanel;
    showSpinner;
    noCustomSettings;
    sortDirection = 'asc';
    sortedBy;
    alert;

    _lookupOptions;
    _customSettingsByName = {};
    _cloneRecords;

    @api label;
    @api columns;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [schema.CREDENTIAL_ID, schema.ORG_NAME] })
    wiredStep({ error, data }) {
        if (data) {
            this.credentialId = getFieldValue(data, schema.CREDENTIAL_ID);
            this.noCustomSettings = this.label.NoCustomSettings.replace('{0}', getFieldValue(data, schema.ORG_NAME));
        } else if (error) {
            this.alert = {
                message: error?.body || error.body?.message,
                variant: ERROR,
                title: 'No access'
            };
        }
    }

    @api
    getConfig() {
        let configJson;
        if (this._cloneRecords && this.selectedId) {
            const selectedRecords = this._cloneRecords.filter((element) => this.selectedId.includes(element.Id));
            configJson = getConfig(this.selectedCustomSetting, selectedRecords);
        }
        return configJson;
    }

    async getCustomSettings() {
        try {
            this.showSpinner = true;
            this.showPanel = true;
            const settings = await getCustomSettings({ credentialId: this.credentialId });
            this._createLookupOptions(settings);
            this.showRetrieveNow = false;
        } catch (ex) {
            this.alert = {
                message: ex.message || ex.body?.message,
                variant: ERROR,
                title: ERROR
            };
        } finally {
            this.showSpinner = false;
        }
    }

    async getRecords() {
        try {
            this.showSpinner = true;
            this.records = await getRecords({
                objectAPIName: this.selectedCustomSetting,
                credentialId: this.credentialId
            });
            this._setRecords();
        } catch (ex) {
            this.alert = {
                message: ex.message || ex.body?.message,
                variant: ERROR,
                title: ERROR
            };
        } finally {
            this.showSpinner = false;
        }
    }

    async handleRecordSearch(event) {
        this.showSpinner = true;
        const searchTerm = event.detail.searchTerm;
        const filteredRawData = await getSearchedData(this.columns, this._cloneRecords, searchTerm);
        this.records = this.sortedBy
            ? getSortedData(this.columns, filteredRawData, { name: this.sortedBy, sortDirection: this.sortDirection })
            : filteredRawData;
        this.showSpinner = false;
    }

    handleSearchCustomSetting(event) {
        const searchTerm = event.detail.searchTerm;
        const lookupElement = event.target;
        if (lookupElement) {
            const result = this._lookupOptions.filter((option) => option.title.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1);
            lookupElement.setSearchResults(result);
        }
    }

    handleChangeCustomSetting(event) {
        this.selectedCustomSetting = event.detail?.length > 0 ? event.detail[0] : null;
        this._cloneRecords = this.records = this._customSettingsByName
            ? this._customSettingsByName[this.selectedCustomSetting]?.records
            : [];
        this._showMessage();
        this.selectedRows = [];
        this.selectedId = [];
        this.alert = false;
    }

    handleClearSearch() {
        this.showSpinner = false;
        this.records = this.sortedBy
            ? getSortedData(this.columns, this._cloneRecords, { name: this.sortedBy, sortDirection: this.sortDirection })
            : [...this._cloneRecords];
        this.selectedId = [...this.selectedId];
    }

    handleSort(event) {
        try {
            this.showSpinner = true;
            this.sortedBy = event.detail.fieldName;
            this.sortDirection = event.detail.sortDirection;
            this.records = [...getSortedData(this.columns, this.records, { name: this.sortedBy, sortDirection: this.sortDirection })];
        } catch (error) {
            this.alert = { message: error.message || error.body?.message, variant: ERROR, title: ERROR };
        } finally {
            this.showSpinner = false;
        }
    }

    onRowSelection(event) {
        this.selectedId = [...onRowSelection(event.detail.selectedRows, this.records, this.selectedId)];
    }

    _setRecords() {
        this._cloneRecords = this.records.map((record) => {
            record.SetupOwnerName = record.SetupOwner.Name;
            delete record.SetupOwner;
            delete record.attributes;
            return record;
        });
        this._customSettingsByName[this.selectedCustomSetting] = {
            records: this.records,
            fetchedRecords: true
        };
        this._showMessage();
    }

    _createLookupOptions(options) {
        this._lookupOptions = options.map((option) => ({
            id: option.QualifiedApiName,
            title: option.DeveloperName,
            icon: null
        }));

        const lookupElement = this.template.querySelector('c-lookup');
        lookupElement.setDefaultResults(this._lookupOptions);
        lookupElement.hideIcon = true;
    }

    _showMessage() {
        const fetchedRecord = this._customSettingsByName ? this._customSettingsByName[this.selectedCustomSetting]?.fetchedRecords : false;
        this.message = fetchedRecord ? (!this.records?.length > 0 ? this.label.NoCustomSettingRecords : '') : this.label.FetchAllRecords;
    }

    get itemDetails() {
        return getItemDetailsVerbiage(this.selectedId, this.label);
    }

    @api
    getAutoFormValidation() {
        const result = getAutoFormValidation(this.selectedId, this.label);
        this.alert = result.data;
        return result.isValid;
    }
}