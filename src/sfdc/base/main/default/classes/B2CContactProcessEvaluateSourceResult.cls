public with sharing class B2CContactProcessEvaluateSourceResult {
    /**
     * @constructor
     * @description Constructor to product an instance of this class.
     **/
    public B2CContactProcessEvaluateSourceResult() {}

    @AuraEnabled @InvocableVariable
    public Contact sourceContact;

    @AuraEnabled @InvocableVariable
    public Account sourcePersonAccount;
}