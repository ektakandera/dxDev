import USER_STORY_OBJECT from '@salesforce/schema/copado__User_Story__c';
import JOB_STEP_OBJECT from '@salesforce/schema/copado__JobStep__c';
import USER_STORY_ORG_NAME from '@salesforce/schema/copado__User_Story__c.copado__Org_Credential__r.Name';
import JOB_STEP_ORG_NAME from '@salesforce/schema/copado__JobStep__c.copado__UserStory__r.copado__Org_Credential__r.Name';

export const schema = {
    USER_STORY_OBJECT,
    JOB_STEP_OBJECT,
    USER_STORY_ORG_NAME,
    JOB_STEP_ORG_NAME
};