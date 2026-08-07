public with sharing class RenewalService {

    public static RenewalSummary calculate(Id subscriptionId) {

        // Create the response object
        RenewalSummary summary = new RenewalSummary();

        // Validate input
        if (subscriptionId == null) {
            return summary;
        }

        // Retrieve Subscription
        List<Subscription__c> subscriptions = [
            SELECT Id, Status__c
            FROM Subscription__c
            WHERE Id = :subscriptionId
            LIMIT 1
        ];

        // Subscription not found
        if (subscriptions.isEmpty()) {
            return summary;
        }

        Subscription__c subscription = subscriptions[0];

        // Ignore cancelled subscriptions
        if (subscription.Status__c == 'Cancelled') {
            return summary;
        }

        // Retrieve Subscription Items
        List<Subscription_Item__c> items = [
            SELECT Recurring_Value__c,
                   Product__r.Family
            FROM Subscription_Item__c
            WHERE Subscription__c = :subscriptionId
        ];

        // Store item count
        summary.itemCount = items.size();

        // Calculate totals
        for (Subscription_Item__c item : items) {

            Decimal recurringValue =
                (item.Recurring_Value__c == null)
                ? 0
                : item.Recurring_Value__c;

            String family =
                String.isBlank(item.Product__r.Family)
                ? 'Uncategorized'
                : item.Product__r.Family;

            // Grand Total
            summary.totalRecurringValue += recurringValue;

            // Initialize family total if required
            if (!summary.familyTotals.containsKey(family)) {
                summary.familyTotals.put(family, 0);
            }

            // Add recurring value to family total
            summary.familyTotals.put(
                family,
                summary.familyTotals.get(family) + recurringValue
            );
        }

        return summary;
    }
}