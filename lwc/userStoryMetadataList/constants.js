import RetrieveSpecific from '@salesforce/label/c.RetrieveSpecific';
import SelectType from '@salesforce/label/c.SelectType';
import SearchByNameRetrieveChanges from '@salesforce/label/c.SearchByNameRetrieveChanges';
import SelectMetadataWarning from '@salesforce/label/c.SelectMetadataWarning';
import RetrieveMetadataHelpText from '@salesforce/label/c.RetrieveMetadataHelpText';
import Type from '@salesforce/label/c.Type';
import Name from '@salesforce/label/c.Name';
import ListMetadata from '@salesforce/label/c.ListMetadata';
import GetMetadataList from '@salesforce/label/c.GetMetadataList';

import VERSION_DATA from '@salesforce/schema/ContentVersion.VersionData';

export const METADATA = 'MetaData';
export const ERROR = 'Error';
export const CUSTOM_OBJECT = 'CustomObject';

export const label = {
    RetrieveSpecific,
    SelectType,
    SearchByNameRetrieveChanges,
    RetrieveMetadataHelpText,
    Type,
    Name,
    SelectMetadataWarning,
    ListMetadata,
    GetMetadataList
};

export const schema = {
    VERSION_DATA
};