public class RenewalSummary {

    public Decimal totalRecurringValue;
    public Integer itemCount;
    public Map<String, Decimal> familyTotals;

    public RenewalSummary() {
        totalRecurringValue = 0;
        itemCount = 0;
        familyTotals = new Map<String, Decimal>();
    }
}