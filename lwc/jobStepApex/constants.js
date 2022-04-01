import CODE_MIRROR from '@salesforce/resourceUrl/copado__CodeMirror';
import SCRIPT from '@salesforce/label/c.Script';
import DATA_JSON_FIELD from '@salesforce/schema/copado__JobStep__c.copado__ConfigJson__c';
import PARAMETERS_FIELD from '@salesforce/schema/copado__Function__c.copado__Parameters__c';

export const label = {
    SCRIPT
};

export const schema = {
    DATA_JSON_FIELD,
    PARAMETERS_FIELD
};

export const resource = {
    CODE_MIRROR
};

export const SFDX_EXECUTE_APEX_FUNCTION_API_NAME = 'sfdx_execute_apex';