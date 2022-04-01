import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { cmcSfNamespace } from 'c/copadocoreUtils';

export default class AddApexTestsParent extends NavigationMixin(LightningElement) {
    recordId;

    @wire(CurrentPageReference)
    getParameters(pageReference) {
        if (pageReference && pageReference.state) {
            this.recordId = pageReference.state.recordId;
        }
    }

    connectedCallback() {
        this.navitageToLWCWithoutAura();
    }

    navitageToLWCWithoutAura() {
        let componentDef = {
            componentDef: `${cmcSfNamespace || 'c'}:addApexTests`,
            attributes: {
                recordId: this.recordId
            }
        };

        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef
            }
        });
    }
}