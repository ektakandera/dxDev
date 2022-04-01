/* eslint-disable array-callback-return */
/* eslint-disable no-shadow */
import { LightningElement, api, wire } from 'lwc';
import { getSearchedData } from 'c/datatableService';
import { cmcSfNamespace, reduceErrors } from 'c/copadocoreUtils';
import { showToastError, showToastSuccess } from 'c/copadocoreToastNotification';
import { CurrentPageReference } from 'lightning/navigation';
import createContentVersion from '@salesforce/apex/AddApexTestsController.createContentVersion';
import getApexTestClassList from '@salesforce/apex/AddApexTestsController.getApexTestClassList';
import getPreselections from '@salesforce/apex/AddApexTestsController.getPreselections';
import { label } from './constants';

const columns = [
    { label: 'Name', fieldName: 'n', type: 'text', searchable: true },
    { label: 'Namespace', fieldName: 'ns', type: 'text' }
];
export default class AddApexTests extends LightningElement {
    recordId;
    data = [];
    @api columns = columns;
    label = label;
    fieldSetName = `${cmcSfNamespace}Add_Test_Classes`;
    preSelectedRows = [];
    isSearchInProgress = false;
    isLoading = false;

    _cloneData = [];
    _preSelectedRowsSet = new Set();
    _selection = [];
    _searchValue = '';
    _searchSelections = [];

    connectedCallback() {
        this._retreiveTestClasses();
    }

    @wire(CurrentPageReference)
    getParameters(pageReference) {
        if (pageReference && pageReference.state) {
            this.recordId = pageReference.attributes.attributes.recordId;
        }
    }

    get title() {
        return label.APEX_TEST_CLASSES;
    }

    get title_header() {
        return label.ADD_APEX_TESTS;
    }

    async handleApplySearch(event) {
        try {
            this.isSearchInProgress = true;
            const searchObj = event.detail;
            this._searchValue = searchObj.searchTerm;
            this.isSearchInProgress = true;
            const filteredRawData = await getSearchedData(columns, this.data, this._searchValue);
            if (filteredRawData) {
                this.data = [...filteredRawData];
                this.isSearchInProgress = false;
            }
        } catch (error) {
            showToastError(this, { message: reduceErrors(error) });
        }
    }

    handleSelect(event) {
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = this._selection.length === 0 ? new Set(this.preSelectedRows) : new Set(this._selection);
        // List of items currently loaded for the current view.
        let loadedItemsSet = this.data.map(event => event.n);

        if (event.detail.selectedRows) {
            event.detail.selectedRows.map(evt => {
                updatedItemsSet.add(evt.n);
            });

            updatedItemsSet.forEach(n => {
                if (!selectedItemsSet.has(n)) {
                    selectedItemsSet.add(n);
                }
            });
        }
        loadedItemsSet.forEach(element => {
            if (selectedItemsSet.has(element) && !updatedItemsSet.has(element)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(element);
                if (this._preSelectedRowsSet.has(element)) this._preSelectedRowsSet.delete(element);
            }
        });
        this._selection = [...selectedItemsSet];
        this._selection.forEach(element => {
            if (!this._preSelectedRowsSet.has(element)) {
                this._preSelectedRowsSet.add(element);
            }
        });

        this.preSelectedRows = [...this._preSelectedRowsSet];
    }

    handleClearSearch() {
        this._searchValue = '';
        this.isSearchInProgress = false;
        this._preSelectedRowsSet.add(this.data.n);
        this.data = [...this._cloneData];
        this._searchSelections = JSON.parse(JSON.stringify(this.template.querySelector('lightning-datatable').getSelectedRows()));
        this._searchSelections.forEach(element => {
            this._preSelectedRowsSet.add(element.n);
        });
        this.preSelectedRows = [...this._preSelectedRowsSet];
        this.template.querySelector('lightning-datatable').selectedRows = this.preSelectedRows;
    }

    async _retreiveTestClasses() {
        this.isLoading = true;
        try {
            this.data = await getApexTestClassList({ recordId: this.recordId });
            this._cloneData = this.data;
            this.getPreselectedRecords();
            this.isLoading = false;
        } catch (error) {
            this.data = undefined;
            showToastError(this, { message: reduceErrors(error) });
        }
    }

    async attachSelectedRows() {
        const selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
        try {
            await createContentVersion({ body: JSON.stringify(selectedRecords), recordId: this.recordId });
            showToastSuccess(this, {
                message: 'Apex test classes have been added/updated in the user story.'
            });
        } catch (error) {
            showToastError(this, { message: reduceErrors(error) });
        }
    }

    async getPreselectedRecords() {
        const result = await getPreselections({ recordId: this.recordId });
        try {
            result.map(element => {
                this._preSelectedRowsSet.add(element.n);
            });
            this.preSelectedRows = [...this._preSelectedRowsSet];
            console.log(this.preSelectedRows);
        } catch (error) {
            showToastError(this, { message: reduceErrors(error) });
        }
    }
}