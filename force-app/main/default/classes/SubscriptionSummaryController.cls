public with sharing class SubscriptionSummaryController {

    public class SubscriptionSummary {
        @AuraEnabled public Decimal activeRecurringValue;
        @AuraEnabled public List<Subscription__c> subscriptions;

        public SubscriptionSummary() {
            activeRecurringValue = 0;
            subscriptions = new List<Subscription__c>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static SubscriptionSummary getSummary(Id accountId) {

        SubscriptionSummary summary = new SubscriptionSummary();

        if (accountId == null) {
            return summary;
        }

        // Get active subscriptions for the Account
        List<Subscription__c> subscriptions = [
            SELECT Id,
                   Name,
                   Start_Date__c,
                   End_Date__c,
                   Renewal_Date__c,
                   Status__c,
                   Auto_Renew__c
            FROM Subscription__c
            WHERE Account__c = :accountId
            AND Status__c = 'Active'
            ORDER BY Renewal_Date__c ASC
        ];

        summary.subscriptions = subscriptions;

        if (subscriptions.isEmpty()) {
            return summary;
        }

        Set<Id> subscriptionIds = new Set<Id>();

        for (Subscription__c subscription : subscriptions) {
            subscriptionIds.add(subscription.Id);
        }

        // Get recurring values from Subscription Items
        for (Subscription_Item__c item : [
            SELECT Subscription__c,
                   Recurring_Value__c
            FROM Subscription_Item__c
            WHERE Subscription__c IN :subscriptionIds
        ]) {

            if (item.Recurring_Value__c != null) {
                summary.activeRecurringValue += item.Recurring_Value__c;
            }
        }

        return summary;
    }
}