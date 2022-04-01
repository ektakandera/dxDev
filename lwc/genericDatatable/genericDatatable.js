/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';

export default class GenericDatatable extends LightningElement {
    @api columns;
    @api rows = [];
    @api maxRowSelection;
    @api selectedRows = [];
    @api hideCheckboxColumn = false;
    @api isLoading = false;
    @api keyField = 'Id';
    
    data = [];
    sortDirection;
    sortedBy;
    _loadLimit = 100;

    renderedCallback() {
        const table = this.template.querySelector('lightning-datatable');
        if (table) {
            if(!this.data.length) {
                this.data = this.rows.slice(0, this._loadLimit);
            }
            table.selectedRows = this.selectedRows;
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRows = selectedRows.map((row) => row[this.keyField]);
    }

    onHandleSort(event) {
        this.isLoading = true;
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.rows];

        cloneData.sort(this._sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.rows = cloneData;
        this.data = cloneData.slice(0, this._loadLimit);
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        
        this.isLoading = false;
    }

    handleLoadMore(event) {
        if (this.data.length >= this.rows.length) {
            event.target.enableInfiniteLoading = false;
        } else {
            const newData = this.rows.slice(this.data.length, this.data.length + this._loadLimit);
            this.data = [...this.data.concat(newData)];
        }
    }

    _sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}