import { LightningElement } from 'lwc';
import getExternalServices from '@salesforce/apex/mc_MergeExternalServices.getExternalServices';
import mergeExternalServices from '@salesforce/apex/mc_MergeExternalServices.mergeExternalServices';

const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'MasterLabel', fieldName: 'MasterLabel' },
    { label: 'NamedCredential', fieldName: 'NamedCredential', type: 'string' },
    { label: 'Schema', fieldName: 'Schema', type: 'string' },
    { label: 'SchemaType', fieldName: 'SchemaType', type: 'string' },
    { label: 'Status', fieldName: 'Status', type: 'string' },
];

export default class Mc_MergeExternalServices extends LightningElement {
    data = [];
    columns = columns;
    isLoading = false;

    convertFromRowSelected = false;
    convertToRowSelected = false;
    convertFromRowSelectedValue = '';
    convertToRowSelectedValue = '';
    convertFromRowSelectedId = '';
    convertToRowSelectedId = '';
    bothRowsSelected = false;

    errorSameRowSelected = false;

    connectedCallback() {
        this.isLoading = true;
        this.getExternalServices();
    }

    getExternalServices() {
        getExternalServices()
            .then(result => {
                console.log('Results: ' + JSON.stringify(result));
                this.data = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
                this.isLoading = false;
            });
            
    }

    handleConvertToRowSelection(event) {
        console.log('handleConvertToRowSelection: ' + JSON.stringify(event.detail));

        // Set the selected row
        this.convertToRowSelected = true;
        this.convertToRowSelectedValue = JSON.stringify(event.detail.selectedRows[0]);
        this.convertToRowSelectedId = event.detail.selectedRows[0].Id;

        // Check if the same row is selected in both tables
        if (this.convertFromRowSelectedId === this.convertToRowSelectedId) {
            this.errorSameRowSelected = true;
        } else {
            this.errorSameRowSelected = false;
        }

        // Check if both rows are selected
        if (this.convertFromRowSelected && this.convertToRowSelected) {
            this.bothRowsSelected = true;
        } else {
            this.bothRowsSelected = false;
        }
    }

    handleConvertFromRowSelection(event) {
        console.log('handleConvertFromRowSelection: ' + JSON.stringify(event.detail));

        // Set the selected row
        this.convertFromRowSelected = true;
        this.convertFromRowSelectedValue = JSON.stringify(event.detail.selectedRows[0]);
        this.convertFromRowSelectedId = event.detail.selectedRows[0].Id;

        // Check if the same row is selected in both tables
        if (this.convertFromRowSelectedId === this.convertToRowSelectedId) {
            this.errorSameRowSelected = true;
        } else {
            this.errorSameRowSelected = false;
        }

        // Check if both rows are selected
        if (this.convertFromRowSelected && this.convertToRowSelected) {
            this.bothRowsSelected = true;
        } else {
            this.bothRowsSelected = false;
        }
    }

    handleMerge() {
        console.log('handleMerge');

        console.log('convertFromRowSelectedValue: ' + this.convertFromRowSelectedValue);
        console.log('convertToRowSelectedValue: ' + this.convertToRowSelectedValue);
        console.log('typeof convertFromRowSelectedValue: ' + typeof this.convertFromRowSelectedValue);

        mergeExternalServices({ convertFrom: this.convertFromRowSelectedValue, convertTo: this.convertToRowSelectedValue })

    }

}