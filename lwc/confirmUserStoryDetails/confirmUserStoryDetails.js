import { LightningElement, api } from "lwc";
import getExistingStoryDetails from "@salesforce/apex/PipelineDistributionCtrl.getExistingStoryDetails";
import getNewStoryDetails from "@salesforce/apex/PipelineDistributionCtrl.getNewStoryDetails";

export default class ConfirmUserStoryDetails extends LightningElement {
    @api existingUserStoryId;
    @api newSerializedUserStory;
    result;
    error;

    async connectedCallback() {
        try {
            if (this.existingUserStoryId) {
                this.result = await getExistingStoryDetails({ userStoryId: this.existingUserStoryId });
            } else if (this.newSerializedUserStory) {
                this.result = await getNewStoryDetails({ newSerializedUserStory: this.newSerializedUserStory });
            }
        } catch (ex) {
            this.error = {
                message: ex.message || ex.body?.message,
                variant: "Warning",
                title: "Error"
            };
        }
    }
}