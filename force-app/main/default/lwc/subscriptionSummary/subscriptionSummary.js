import { LightningElement, api, wire } from 'lwc';
import getSummary from '@salesforce/apex/SubscriptionSummaryController.getSummary';

export default class SubscriptionSummary extends LightningElement {

    @api recordId;

    activeRecurringValue = 0;
    subscriptions = [];
    isLoading = true;
    error;

    @wire(getSummary, { accountId: '$recordId' })
    wiredSummary({ data, error }) {

        this.isLoading = false;

        if (data) {
            this.activeRecurringValue = data.activeRecurringValue;
            this.subscriptions = data.subscriptions;
            this.error = undefined;
        } else if (error) {
            this.activeRecurringValue = 0;
            this.subscriptions = [];
            this.error = error;
        }
    }

    get hasSubscriptions() {
        return this.subscriptions.length > 0;
    }

    get formattedRecurringValue() {
        return new Intl.NumberFormat('en-IN', {
            style: 'currency',
            currency: 'INR',
            maximumFractionDigits: 2
        }).format(this.activeRecurringValue);
    }
}