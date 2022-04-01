import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import getFunctionByApiName from '@salesforce/apex/JobStepApexCtrl.getFunctionByApiName';

import { reduceErrors, showToastError } from './utils';
import { label, resource, schema, SFDX_EXECUTE_APEX_FUNCTION_API_NAME } from './constants';

export default class JobStepApex extends LightningElement {
    label = label;
    resource = resource;

    @api recordId;
    @api configJson;
    @api isReadOnly;

    showSpinner = false;

    _functionParameters = [];

    _editor;

    get script() {
        return this._script;
    }

    set script(value) {
        this._script = value;
        if (this.script) {
            this.editorValue = this.script;
        }
    }
    _script = '\n'.repeat(4);

    get editorValue() {
        return this._editor ? this._editor.getValue() : '';
    }

    set editorValue(value) {
        if (this._editor) {
            this._editor.getDoc().setValue(value);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => this._editor.refresh(), 1);
        }
    }

    // PUBLIC

    @api
    getAutoFormValidation() {
        return !!this.editorValue;
    }

    @api
    getConfig() {
        const defaultFunctionPameters = this._functionParameters
            .filter((parameter) => !!parameter.defaultValue)
            .map((parameter) => {
                return { name: parameter.name, value: parameter.defaultValue };
            });
        return {
            type: 'Function',
            configJson: {
                functionName: SFDX_EXECUTE_APEX_FUNCTION_API_NAME,
                parameters: [{ name: 'script', value: this.editorValue }, ...defaultFunctionPameters]
            }
        };
    }

    // TEMPLATE

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [schema.DATA_JSON_FIELD]
    })
    wiredStep({ data, error }) {
        if (data) {
            this.configJson = getFieldValue(data, schema.DATA_JSON_FIELD);
            this._loadData();
        } else if (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        }
    }

    @wire(getFunctionByApiName, {
        apiName: SFDX_EXECUTE_APEX_FUNCTION_API_NAME
    })
    wiredFunction({ data, error }) {
        if (data) {
            this._functionParameters = JSON.parse(data[schema.PARAMETERS_FIELD.fieldApiName]);
        } else if (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        }
    }

    async connectedCallback() {
        try {
            this.showSpinner = true;
            await this._loadResources();
            this._initEditor();
            this._loadData();
            this.showSpinner = false;
        } catch (error) {
            const errorMessage = reduceErrors(error);
            showToastError(this, { message: errorMessage });
        }
    }

    // PRIVATE

    async _loadResources() {
        await loadScript(this, resource.CODE_MIRROR + '/codemirror-5.46.0/lib/codemirror.js');
        await loadScript(this, resource.CODE_MIRROR + '/codemirror-5.46.0/addon/lint/lint.js');
        await loadScript(this, resource.CODE_MIRROR + '/codemirror-5.46.0/mode/clike/clike.js');
        await loadStyle(this, resource.CODE_MIRROR + '/codemirror-5.46.0/lib/codemirror.css');
        await loadStyle(this, resource.CODE_MIRROR + '/codemirror-5.46.0/addon/lint/lint.css');
    }

    _createTextArea() {
        const result = document.createElement('textarea');
        result.classList.add('script');
        this.template.querySelector('.container').appendChild(result);
        return result;
    }

    _initEditor() {
        // eslint-disable-next-line no-undef
        this._editor =
            this._editor ||
            CodeMirror.fromTextArea(this._createTextArea(), {
                lineNumbers: true,
                lineWrapping: true,
                mode: 'text/x-java',
                readOnly: this.isReadOnly ? 'nocursor' : '',
                gutters: ['CodeMirror-lint-markers'],
                lint: true
            });
    }

    _loadData() {
        this.script = this._script;
        if (this.configJson) {
            const config = JSON.parse(this.configJson);

            if (config.parameters) {
                const scriptParameter = config.parameters.find((parameter) => parameter.name === 'script');
                if (scriptParameter) {
                    this.script = scriptParameter.value;
                }
            }
        }
    }
}