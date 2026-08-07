@IsTest
private class RenewalServiceTest {

    @TestSetup
    static void setupData() {

        // Create Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        // Create Products
        Product2 software = new Product2(
            Name = 'Office 365',
            Family = 'Software',
            IsActive = true
        );

        Product2 support = new Product2(
            Name = 'Premium Support',
            Family = 'Support',
            IsActive = true
        );

        insert new List<Product2>{ software, support };

        // Create Subscription
        Subscription__c sub = new Subscription__c(
            Account__c = acc.Id,
            Status__c = 'Active'
        );

        insert sub;

        // Create Subscription Items
        List<Subscription_Item__c> items = new List<Subscription_Item__c>();

        items.add(new Subscription_Item__c(
            Subscription__c = sub.Id,
            Product__c = software.Id,
            Recurring_Value__c = 1000
        ));

        items.add(new Subscription_Item__c(
            Subscription__c = sub.Id,
            Product__c = support.Id,
            Recurring_Value__c = 500
        ));

        insert items;
    }

    @IsTest
static void testCalculateRecurringTotals() {

    // Retrieve the test subscription
    Subscription__c sub = [
        SELECT Id
        FROM Subscription__c
        LIMIT 1
    ];

    Test.startTest();

    RenewalSummary summary = RenewalService.calculate(sub.Id);

    Test.stopTest();

    System.assertEquals(2, summary.itemCount);
    System.assertEquals(1500, summary.totalRecurringValue);

    System.assertEquals(1000, summary.familyTotals.get('Software'));
    System.assertEquals(500, summary.familyTotals.get('Support'));
}

}