import { LightningElement, api, wire } from 'lwc';
import getActiveSubscriptions from '@salesforce/apex/RenewalPlannerController.getActiveSubscriptions';
import prepareRenewal from '@salesforce/apex/RenewalPlannerController.prepareRenewal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RenewalPlanner extends LightningElement {

    @api recordId;

    subscriptions = [];
    selectedSubscriptionId;
    error;
    isLoading = false;

    columns = [
        {
            label: 'Subscription',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Renewal Date',
            fieldName: 'Renewal_Date__c',
            type: 'date'
        },
        {
            label: 'Auto Renew',
            fieldName: 'Auto_Renew__c',
            type: 'boolean'
        }
    ];

    @wire(getActiveSubscriptions, { accountId: '$recordId' })
    wiredSubscriptions({ data, error }) {

        if (data) {
            this.subscriptions = data;
            this.error = undefined;
        } else if (error) {
            this.subscriptions = [];
            this.error = error;
        }
    }

    handleRowSelection(event) {

        const selectedRows = event.detail.selectedRows;

        if (selectedRows.length > 0) {
            this.selectedSubscriptionId = selectedRows[0].Id;
        } else {
            this.selectedSubscriptionId = undefined;
        }
    }

    get hasSelection() {
        return this.selectedSubscriptionId !== undefined;
    }

    async handlePrepareRenewal() {

        if (!this.selectedSubscriptionId) {
            this.showToast(
                'Selection Required',
                'Please select a subscription.',
                'warning'
            );
            return;
        }

        this.isLoading = true;

        try {

            const opportunityId = await prepareRenewal({
                subscriptionId: this.selectedSubscriptionId
            });

            this.showToast(
                'Renewal Prepared',
                'Renewal Opportunity is ready.',
                'success'
            );

            // Refresh the page data
            this.selectedSubscriptionId = undefined;

        } catch (error) {

            this.showToast(
                'Error',
                this.getErrorMessage(error),
                'error'
            );

        } finally {
            this.isLoading = false;
        }
    }

    getErrorMessage(error) {

        if (error?.body?.message) {
            return error.body.message;
        }

        return 'An unexpected error occurred.';
    }

    showToast(title, message, variant) {

        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}