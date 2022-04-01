import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { MessageContext, publish } from 'lightning/messageService';

import isSourceMemberAvailable from '@salesforce/apex/UserStoryCommitTableActionsCtrl.isSourceMemberAvailable';
import listAllSobjectsInOrg from '@salesforce/apex/UserStoryCommitTableActionsCtrl.listAllSobjectsInOrg';
import retrieveRecentChanges from '@salesforce/apex/UserStoryCommitTableActionsCtrl.retrieveRecentChanges';
import searchMetadata from '@salesforce/apex/UserStoryCommitTableActionsCtrl.searchMetadata';

import COMMIT_PAGE_COMMUNICATION_CHANNEL from '@salesforce/messageChannel/copado__CommitPageCommunication__c';

import { reduceErrors, showToastError, showToastWarning } from './utils';
import { label, schema, CUSTOM_OBJECT } from './constants';

import metadataListPermissionEnabled from '@salesforce/customPermission/Enable_Metadata_List';

export default class UserStoryCommitTableActions extends LightningElement {
    label = label;
    schema = schema;

    recordId;
    credentialId;

    // loading
    _isWorking = false;
    _sourceMemberAvailableChecked = true;
    _listOfMetadataTypesAvailable = true;

    // pull changes
    _latestCommitDate;
    _sprintStartDate;
    dateTimeToPull;
    maxDate = new Date().toISOString();
    disablePullChanges = true;
    enablePullChangesHelpText = true;

    // retrieve specific
    searchText = '';
    selectedMetadata;
    metadataTypes;
    disableRetrieveMetadata = false;
    metadataLookupOptions;

    get isSeachTextRequired() {
        return this.selectedMetadata && this.selectedMetadata === CUSTOM_OBJECT;
    }

    get showSpinner() {
        return this._isWorking || this._sourceMemberAvailableChecked === false || this._listOfMetadataTypesAvailable === false;
    }

    get isMetadataListPermissionEnabled() {
        return metadataListPermissionEnabled;
    }

    @wire(MessageContext)
    _context;

    @wire(CurrentPageReference)
    getParameters(pageReference) {
        if (pageReference && pageReference.state) {
            this.recordId = pageReference.state.copado__recordId;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [schema.LATEST_COMMIT_DATE, schema.CREDENTIAL, schema.SPRINT_START_DATE] })
    wiredRecord({ error, data }) {
        if (data) {
            this.dateTimeToPull = this._latestCommitDate = getFieldValue(data, schema.LATEST_COMMIT_DATE);
            if (!this.dateTimeToPull) {
                this.dateTimeToPull = this._sprintStartDate = getFieldValue(data, schema.SPRINT_START_DATE);
            }
            this.credentialId = getFieldValue(data, schema.CREDENTIAL);
            if (this.credentialId) {
                this._sourceMemberAvailableChecked = false;
                this._listOfMetadataTypesAvailable = false;
            }
        } else if (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        }
    }

    @wire(isSourceMemberAvailable, { credentialId: '$credentialId' })
    enablePullChanges({ error, data }) {
        if (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        } else {
            this.disablePullChanges = !data;
            this.enablePullChangesHelpText = !data;
            this._sourceMemberAvailableChecked = true;
        }
    }

    @wire(listAllSobjectsInOrg, { credentialId: '$credentialId' })
    allSobjects({ error, data }) {
        if (data) {
            this.metadataTypes = data.map((sobject) => ({ label: sobject.Label === 'Entity' ? sobject.Name : sobject.Label, value: sobject.Name }));
            this.metadataTypes = this.metadataTypes.sort();
            this.metadataLookupOptions = this._createLookupOptions(this.metadataTypes);
            this._initLookupDefaultResults(this.metadataLookupOptions);
            this._listOfMetadataTypesAvailable = true;
        } else if (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        }
    }

    // TEMPLATE

    handleInputChange(event) {
        this[event.target.name] = event.target.value;
    }

    handleSearchMetadataType(event) {
        const searchTerm = event.detail.searchTerm;
        const lookupElement = event.target;
        if (lookupElement) {
            const result = this.metadataLookupOptions.filter((option) => option.title.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1);
            lookupElement.setSearchResults(result);
        }
    }

    handleChangeMetadataType(event) {
        this.selectedMetadata = event.detail.length > 0 ? event.detail[0] : null;
    }

    async pullChanges() {
        try {
            this._isWorking = true;
            this.disablePullChanges = true;
            this.disableRetrieveMetadata = true;

            const dateTimeToPull = this.dateTimeToPull || this._latestCommitDate || this._sprintStartDate;
            if (dateTimeToPull) {
                const result = await retrieveRecentChanges({ orgId: this.credentialId, dateTimeToRetrieveChanges: dateTimeToPull });
                const recentChanges = result.map((change) => {
                    change.LastModifiedByName = change.LastModifiedBy.Name;
                    change.Operation = change.IsNameObsolete ? 'Delete' : 'Add';
                    change.Directory = 'force-app/main/default/';
                    change.Category = '';
                    return change;
                });

                const payload = {
                    type: 'pulledChanges',
                    value: recentChanges
                };
                publish(this._context, COMMIT_PAGE_COMMUNICATION_CHANNEL, payload);
            } else {
                showToastWarning(this, { message: label.PullChangesDateMandatoryWarning });
            }
        } catch (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        } finally {
            this.disableRetrieveMetadata = false;
            this.disablePullChanges = false;
            this._isWorking = false;
        }
    }

    async retrieveChanges() {
        try {
            this._isWorking = true;
            this.disablePullChanges = true;
            this.disableRetrieveMetadata = true;

            if (this._validateSearchText()) {
                if (this.selectedMetadata) {
                    const result = await searchMetadata({ orgId: this.credentialId, type: this.selectedMetadata, searchTerm: this.searchText });

                    const allMetadataFound = result.map((metadataSearchResult) => {
                        const row = {};
                        row.Operation = 'Add';
                        row.MemberName = metadataSearchResult.name;
                        row.MemberType = metadataSearchResult.type;
                        row.Directory = 'force-app/main/default/';
                        row.LastModifiedDate = metadataSearchResult.lastModifiedDate;
                        row.LastModifiedByName = metadataSearchResult.lastModifiedBy;
                        row.Category = '';
                        return row;
                    });

                    const payload = {
                        type: 'retrievedChanges',
                        value: allMetadataFound
                    };
                    publish(this._context, COMMIT_PAGE_COMMUNICATION_CHANNEL, payload);
                } else {
                    showToastWarning(this, { message: label.SelectMetadataWarning, mode: 'sticky' });
                }
            }
        } catch (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        } finally {
            if (this.enablePullChangesHelpText === false) {
                this.disablePullChanges = false;
            }
            this.disableRetrieveMetadata = false;
            this._isWorking = false;
        }
    }

    // PRIVATE

    _validateSearchText() {
        const searchTextInput = this.template.querySelector("[data-field='searchText']");
        return searchTextInput.reportValidity();
    }

    _createLookupOptions(options) {
        return options.map((option) => ({ id: option.value, title: option.label, icon: 'standard:all' }));
    }

    _initLookupDefaultResults(options) {
        const lookup = this.template.querySelector('c-lookup');
        if (lookup) {
            lookup.setDefaultResults(options);
        }
    }
}