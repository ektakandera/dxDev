import LATEST_COMMIT_DATE from '@salesforce/schema/copado__User_Story__c.copado__Latest_Commit_Date__c';
import CREDENTIAL from '@salesforce/schema/copado__User_Story__c.copado__Org_Credential__c';
import SPRINT_START_DATE from '@salesforce/schema/copado__User_Story__c.copado__Sprint__r.copado__Start_Date__c';

import LOADING from '@salesforce/label/c.Loading';
import PullChangesFrom from '@salesforce/label/c.PullChangesFrom';
import PullChanges from '@salesforce/label/c.PullChanges';
import SourceTrackingNotEnabledMessage from '@salesforce/label/c.SourceTrackingNotEnabledMessage';
import RetrieveSpecific from '@salesforce/label/c.RetrieveSpecific';
import SelectType from '@salesforce/label/c.SelectType';
import SearchByNameRetrieveChanges from '@salesforce/label/c.SearchByNameRetrieveChanges';
import PullChangesDateMandatoryWarning from '@salesforce/label/c.PullChangesDateMandatoryWarning';
import SelectMetadataWarning from '@salesforce/label/c.SelectMetadataWarning';
import RetrieveMetadata from '@salesforce/label/c.RetrieveMetadata';
import RetrieveMetadataHelpText from '@salesforce/label/c.RetrieveMetadataHelpText';
import PullChangesFromHelpText from '@salesforce/label/c.PullChangesFromHelpText';
import Type from '@salesforce/label/c.Type';
import Name from '@salesforce/label/c.Name';

export const CUSTOM_OBJECT = 'CustomObject';

export const label = {
    LOADING,
    PullChangesFrom,
    PullChanges,
    SourceTrackingNotEnabledMessage,
    RetrieveSpecific,
    SelectType,
    SearchByNameRetrieveChanges,
    RetrieveMetadata,
    RetrieveMetadataHelpText,
    PullChangesFromHelpText,
    PullChangesDateMandatoryWarning,
    SelectMetadataWarning,
    Type,
    Name
};

export const schema = {
    LATEST_COMMIT_DATE,
    CREDENTIAL,
    SPRINT_START_DATE
};