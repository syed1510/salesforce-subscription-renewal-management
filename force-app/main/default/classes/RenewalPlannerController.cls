public with sharing class RenewalPlannerController {

    @AuraEnabled(cacheable=true)
    public static List<Subscription__c> getActiveSubscriptions(Id accountId) {

        if (accountId == null) {
            return new List<Subscription__c>();
        }

        return [
            SELECT Id,
                   Name,
                   Renewal_Date__c,
                   Status__c,
                   Auto_Renew__c
            FROM Subscription__c
            WHERE Account__c = :accountId
            AND Status__c = 'Active'
            ORDER BY Renewal_Date__c ASC
        ];
    }

    @AuraEnabled
    public static String prepareRenewal(Id subscriptionId) {

        if (subscriptionId == null) {
            throw new AuraHandledException('Subscription is required.');
        }

        Subscription__c subscription = [
            SELECT Id,
                   Name,
                   Account__c,
                   Renewal_Date__c
            FROM Subscription__c
            WHERE Id = :subscriptionId
            LIMIT 1
        ];

        if (subscription.Account__c == null) {
            throw new AuraHandledException(
                'Subscription must be associated with an Account.'
            );
        }

        // Check whether a renewal Opportunity already exists.
        List<Opportunity> existingRenewals = [
            SELECT Id, Name
            FROM Opportunity
            WHERE Subscription__c = :subscription.Id
            LIMIT 1
        ];

        if (!existingRenewals.isEmpty()) {
            return existingRenewals[0].Id;
        }

        // Get Account information for the Opportunity name.
        Account acc = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :subscription.Account__c
            LIMIT 1
        ];

        Opportunity renewalOpp = new Opportunity(
            Name = acc.Name + ' - ' + subscription.Name + ' - Renewal',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = subscription.Renewal_Date__c != null
                ? subscription.Renewal_Date__c
                : Date.today().addDays(30),
            Subscription__c = subscription.Id
        );

        insert renewalOpp;

        return renewalOpp.Id;
    }
}