import { LightningElement } from 'lwc';
import getExternalServices from '@salesforce/apex/mc_MergeExternalServices.getExternalServices';
import mergeExternalServices from '@salesforce/apex/mc_MergeExternalServices.mergeExternalServices';
import getNamedCredentials from '@salesforce/apex/mc_MergeExternalServices.getNamedCredentials';

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
    isError = false;
    errorMessage = '';

    // Selected Rows
    isMoreThanOneRowSelected = false;
    selectedRows = [];
    sizeOfSelectedRows = 0;

    newExternalServiceName = '';

    namedCredentialOptions = [{}];
    selectedNamedCredentialValue = '';
    showMergeButton = false;

    errorSameRowSelected = false;

    connectedCallback() {
        this.isLoading = true;
        this.getNamedCredentials();
    }

    getExternalServices() {
        getExternalServices({ namedCredentialName: this.selectedNamedCredentialValue})
            .then(result => {
                console.log('Results: ' + JSON.stringify(result));
                this.data = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
                this.isLoading = false;
                this.isError = true;
                this.errorMessage = JSON.stringify(error);
            });
            
    }

    getNamedCredentials() {
        getNamedCredentials()
            .then(result => {
                console.log('Results: ' + JSON.stringify(result));
                this.namedCredentialOptions = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
                this.isLoading = false;
                this.isError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }

    handleNewExternalServiceNameChange(event) {
        this.newExternalServiceName = event.detail.value;
        console.log('handleNewExternalServiceNameChange: ' + this.newExternalServiceName);
        this.handleMergeButton();
    }

    handleNamedCredentialChange(event) {
        this.isLoading = true;
        console.log('handleNamedCredentialChange: ' + event.detail.value);
        this.selectedNamedCredentialValue = event.detail.value;
        this.isNamedCredentialSelected = true;
        this.getExternalServices();
    }

    handleRowSelection(event) {
        // Add selected rows to selectedRows array
        this.selectedRows = event.detail.selectedRows;
        this.sizeOfSelectedRows = this.selectedRows.length;
        console.log('handleRowSelection: ' + this.sizeOfSelectedRows);
        console.log('handleRowSelection: ' + JSON.stringify(this.selectedRows));
        this.handleMergeButton();
    }

    // Will hide/show the merge button based on validity of the form
    handleMergeButton() {
        console.log('handleMergeButton');
        if (this.sizeOfSelectedRows > 1 && this.newExternalServiceName != '') {
            this.showMergeButton = true;
        } else {
            this.showMergeButton = false;
        }
    }

    handleMerge() {
        this.isLoading = true;
        console.log('handleMerge');

        mergeExternalServices({ convertFrom: this.convertFromRowSelectedValue, convertTo: this.convertToRowSelectedValue })
            .then(result => {
                console.log('Results: ' + (result));
                this.isLoading = false;
            })
            .catch(error => {
                console.log('Errors: ' + (error));
                this.isLoading = false;
                this.isError = true;
                this.errorMessage = JSON.stringify(error);
            });


    }

}