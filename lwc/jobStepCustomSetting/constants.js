import RetrieveAndChooseRecords from '@salesforce/label/c.RetrieveAndChooseRecords';
import RetrieveAndChooseHelptext from '@salesforce/label/c.RetrieveAndChooseHelptext';
import CustomSettingRecords from '@salesforce/label/c.CustomSettingRecords';
import NoCustomSettings from '@salesforce/label/c.NoCustomSettings';
import FetchAllRecords from '@salesforce/label/c.FetchAllRecords';
import NoCustomSettingRecords from '@salesforce/label/c.NoCustomSettingRecords';
import ViewAll from '@salesforce/label/c.View_All';
import ViewLess from '@salesforce/label/c.View_Less';
import CustomSettingHeader from '@salesforce/label/c.Custom_Setting_Header';
import CustomSettingRecordsEnvName from '@salesforce/label/c.Custom_Setting_Records_Env_Name';
import Records from '@salesforce/label/c.Records';
import ItemsSelected from '@salesforce/label/c.Items_Selected';
import ItemSelected from '@salesforce/label/c.Item_Selected';
import CustomSettingMinRecordsCriteria from '@salesforce/label/c.Custom_Setting_Min_Records_Criteria';

export const label = {
    RetrieveAndChooseRecords,
    RetrieveAndChooseHelptext,
    CustomSettingRecords,
    NoCustomSettings,
    FetchAllRecords,
    NoCustomSettingRecords,
    ViewAll,
    ViewLess,
    CustomSettingHeader,
    Records,
    ItemsSelected,
    ItemSelected,
    CustomSettingRecordsEnvName,
    CustomSettingMinRecordsCriteria
};

export const columns = [
    { label: 'Id', fieldName: 'Id', type: 'text', sortable: true },
    { label: 'Name', fieldName: 'Name', type: 'text', searchable: true, sortable: true },
    { label: 'Type', fieldName: 'Type', type: 'text', sortable: true },
    { label: 'Setup Owner Id', fieldName: 'SetupOwnerId', type: 'text', sortable: true },
    { label: 'Setup Owner Name', fieldName: 'SetupOwnerName', type: 'text', sortable: true }
];