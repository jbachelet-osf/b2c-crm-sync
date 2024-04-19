@isTest
public with sharing class B2CContactProcessEvaluateSource_Test {
    @isTest
    static void testEvaluate_WithValidSourceInputs_ShouldReturnSourceContact() {
        List<B2CContactProcessSourceInput> sourceInputs = new List<B2CContactProcessSourceInput>();
        B2CContactProcessSourceInput input = new B2CContactProcessSourceInput();
        Map<String, String> obj = new Map<String, String>();
        obj.put('B2C_Customer_ID__c', '0000001');
        obj.put('B2C_Customer_No__c', '0000001');
        obj.put('B2C_CustomerList_ID__c', 'CustomerList');
        obj.put('FirstName', 'FirstName');
        obj.put('LastName', 'LastName');
        obj.put('Email', 'Email@Email.com');
        input.jsonRepresentation = JSON.serialize(obj);
        sourceInputs.add(input);
        List<B2CContactProcessEvaluateSourceResult> results = B2CContactProcessEvaluateSourceInput.evaluate(sourceInputs);
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertNotEquals(null, results.get(0).sourceContact, 'Expected source contact to be filled.');
        System.assertEquals('0000001', results.get(0).sourceContact.B2C_Customer_ID__c, 'Expected source contact to contain the input data');
    }

    @isTest
    static void testEvaluate_WithValidSourceInputs_ShouldReturnSourceContactAndAccount() {
        List<B2C_Integration_Field_Mappings__mdt> accountFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Account', true);
        if (accountFieldMappings.size() == 0) {
            Assert.isTrue(true, 'No Account based fields mapping, abort this test.');
            return;
        }

        List<B2CContactProcessSourceInput> sourceInputs = new List<B2CContactProcessSourceInput>();
        B2CContactProcessSourceInput input = new B2CContactProcessSourceInput();
        Map<String, String> obj = new Map<String, String>();
        obj.put('B2C_Customer_ID__c', '0000001');
        obj.put('B2C_Customer_No__c', '0000001');
        obj.put('B2C_CustomerList_ID__c', 'CustomerList');
        obj.put('FirstName', 'FirstName');
        obj.put('LastName', 'LastName');
        obj.put('Email', 'Email@Email.com');
        obj.put(accountFieldMappings.get(0).Service_Cloud_Attribute__c, 'SomeValue');
        input.jsonRepresentation = JSON.serialize(obj);
        sourceInputs.add(input);
        List<B2CContactProcessEvaluateSourceResult> results = B2CContactProcessEvaluateSourceInput.evaluate(sourceInputs);
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertNotEquals(null, results.get(0).sourceContact, 'Expected source contact to be filled.');
        System.assertNotEquals(null, results.get(0).sourcePersonAccount, 'Expected source person account to be filled.');
        System.assertEquals('0000001', results.get(0).sourceContact.B2C_Customer_ID__c, 'Expected source contact to contain the input data');
        System.assertEquals('SomeValue', results.get(0).sourcePersonAccount.get(accountFieldMappings.get(0).Service_Cloud_Attribute__c), 'Expected source person account to contain the input data');
    }

    @isTest
    static void testEvaluate_WithEmptySourceInputs_ShouldReturnEmptyResults() {
        List<B2CContactProcessSourceInput> sourceInputs = new List<B2CContactProcessSourceInput>();
        List<B2CContactProcessEvaluateSourceResult> results = B2CContactProcessEvaluateSourceInput.evaluate(sourceInputs);
        System.assertEquals(0, results.size(), 'Expected empty results');
    }

}