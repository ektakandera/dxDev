import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { MessageContext, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import COMMIT_PAGE_COMMUNICATION_CHANNEL from '@salesforce/messageChannel/copado__CommitPageCommunication__c';

import createFileFromAttachment from '@salesforce/apex/UserStoryMetadataListCtlr.createFileFromAttachment';

import { label, schema, METADATA, ERROR, CUSTOM_OBJECT } from './constants';

export default class UserStoryMetadataList extends LightningElement {
    @api credentialId;

    isFileCreated = false;
    showSpinner;
    label = label;
    searchText;

    _contentVersionId;
    _metadata = new Map();
    _selectedMetadata;
    _metadataLookupOptions;

    get isSeachTextRequired() {
        return this._selectedMetadata && this._selectedMetadata === CUSTOM_OBJECT;
    }

    @wire(MessageContext)
    _context;

    @wire(getRecord, { recordId: '$_contentVersionId', fields: [schema.VERSION_DATA] })
    wiredContentVersionRecord({ error, data }) {
        this.showSpinner = true;
        if (data) {
            const versionDataBlob = getFieldValue(data, schema.VERSION_DATA);
            // Locker service supports atob (decodes a string of data which has been encoded using Base64 encoding)
            // https://developer.salesforce.com/docs/component-library/tools/locker-service-viewer
            if (versionDataBlob) {
                const versionData = atob(versionDataBlob);
                this._setMetadataList(versionData);
            }
        } else if (error) {
            this._publishError(error);
        }
        this.showSpinner = false;
    }

    async handleMetadataListing() {
        try {
            this.showSpinner = true;
            const result = await createFileFromAttachment({ credentialId: this.credentialId, name: METADATA });
            if (result.isSuccess) {
                this._contentVersionId = result.recordId;
                this.isFileCreated = true;
            } else {
                this._publishError(result);
            }
        } catch (error) {
            this._publishError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    handleSearchMetadataType(event) {
        const searchTerm = event.detail.searchTerm;
        const lookupElement = event.target;
        if (lookupElement) {
            const result = this._metadataLookupOptions.filter(
                (option) => option.title.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1
            );
            lookupElement.setSearchResults(result);
        }
    }

    handleChangeMetadataType(event) {
        this._selectedMetadata = event.detail.length ? event.detail[0] : null;
    }

    handleInputChange(event) {
        this.searchText = event.target.value;
    }

    handleMetadataSearch() {
        try {
            this.showSpinner = true;
            if (this._validateSearchText()) {
                if (this._selectedMetadata) {
                    this._publishMetadataDetails();
                } else {
                    this._publishError({ message: label.SelectMetadataWarning });
                }
            }
        } catch (error) {
            this._publishError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    _publishError(error) {
        const errorMessage = error.message || error.body?.message;
        this._showNotification(ERROR, errorMessage, 'error', 'dismissible');
    }

    _setMetadataList(versionData) {
        try {
            const metadataList = JSON.parse(versionData);
            metadataList.forEach((item) => {
                if (!this._metadata.has(item.t)) {
                    this._metadata.set(item.t, []);
                }
                this._metadata.get(item.t).push(item);
            });
            this._setMetadataLookupOptions();
        } catch (error) {
            this._publishError(error);
        }
    }

    _setMetadataLookupOptions() {
        if (this._metadata) {
            let options = [...this._metadata.keys()];
            options = options.sort();
            this._metadataLookupOptions = options.map((option) => ({ id: option, title: option, icon: 'standard:all' }));
            const lookup = this.template.querySelector('c-lookup');
            if (lookup) {
                lookup.setDefaultResults(this._metadataLookupOptions);
            }
        }
    }

    _publishMetadataDetails() {
        let selectedMetadataItems;
        if (this._selectedMetadata && this._metadata.has(this._selectedMetadata)) {
            selectedMetadataItems = this._metadata.get(this._selectedMetadata);
            if (this.searchText) {
                const textForSearching = this.searchText.toLowerCase();
                selectedMetadataItems = selectedMetadataItems.filter((metadataElement) =>
                    metadataElement.n.toLowerCase().includes(textForSearching)
                );
            }

            const metadataForGrid = selectedMetadataItems.map((metadataElement) => {
                const row = {};
                row.Operation = 'Add';
                row.MemberName = metadataElement.n;
                row.MemberType = metadataElement.t;
                row.Directory = 'force-app/main/default/';
                row.LastModifiedDate = metadataElement.d;
                row.LastModifiedByName = metadataElement.b;
                row.Category = '';
                return row;
            });

            const payload = {
                type: 'retrievedChanges',
                value: metadataForGrid
            };

            publish(this._context, COMMIT_PAGE_COMMUNICATION_CHANNEL, payload);
        }
    }

    _validateSearchText() {
        const searchTextInput = this.template.querySelector("[data-field='searchText']");
        return searchTextInput.reportValidity();
    }

    _showNotification(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(event);
    }
}