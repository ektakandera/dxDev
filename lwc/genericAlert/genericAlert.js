import { LightningElement, api } from 'lwc';

const VARIANT_CONFIGURATION = new Map([
    ['Error', { iconName: 'utility:error', theme: 'slds-theme_error' }],
    ['Warning', { iconName: 'utility:warning', theme: 'slds-theme_warning' }],
    ['Success', { iconName: 'utility:success', theme: 'slds-theme_success' }],
    ['Info', { iconName: 'utility:info', theme: 'slds-theme_alt-inverse' }]
]);

export default class GenericAlert extends LightningElement {
    @api title;
    @api message;
    @api variant;

    get alertTheme() {
        const variant = VARIANT_CONFIGURATION.has(this.variant) ? VARIANT_CONFIGURATION.get(this.variant).theme : '';
        return `slds-notify--toast ${variant}`;
    }

    get iconName() {
        return VARIANT_CONFIGURATION.has(this.variant) ? VARIANT_CONFIGURATION.get(this.variant).iconName : '';
    }
}