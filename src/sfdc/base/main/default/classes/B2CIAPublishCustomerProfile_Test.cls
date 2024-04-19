/**
 * @author Eric Schultz
 * @date April 11th, 2021
 *
 * @description This test class exercises the publishEvent behavior for customerProfiles.  It
 * exercises successful and failed publishEvents.
*/
@IsTest
private class B2CIAPublishCustomerProfile_Test {

    /**
     * @see B2CIAValidateContact.validateContact
     * @description This test method exercises publishEvents and verifies that successful events
     * are processed correctly.  We expect a 200 http-status to be included in the response.
     */
    @IsTest
    static void publishEventSucceeded() {

        // Initialize local variables
        List<B2CIAPublishCustomerProfileInput> inputList = new List<B2CIAPublishCustomerProfileInput>();
        List<B2CIAPublishCustomerProfileResult> publishResult = new List<B2CIAPublishCustomerProfileResult>();
        B2CIAPublishCustomerProfileInput input = new B2CIAPublishCustomerProfileInput();

        // Initialize and create the test contact
        Contact c = new Contact(
            LastName = 'lastname',
            Total_Updates_to_B2C_Commerce__c = 0,
            Last_Update_Pushed_to_B2C_Commerce__c = System.Datetime.now(),
            Last_Platform_Event_Applied_Updates__c = false,
            Last_Platform_Event_Processed_Date__c = System.Datetime.now()
        );

        Database.insert( c );

        // Seed the publishEvent properties
        input.apiVersion = 'apiVersion';
        input.b2cCustomerListId = 'id';
        input.b2cCustomerNo = 'customerno';
        input.b2cCustomerId = 'customerid';
        input.crmCustomerListId = 'crmCustomerListId';
        input.crmContactId = c.Id;
        input.crmContact = c;
        input.b2cProfileJSON = '{}';

        // Add the publishEvent to the collection
        inputList.add( input );

        Test.startTest();

            // Initialize the mock and execute the test
            Test.setMock(HttpCalloutMock.class, new B2CHttpTestCalloutMockGenerator('CustomerDetailsSuccess'));
            publishResult = B2CIAPublishCustomerProfile.publishCustomerProfile(inputList);

        Test.stopTest();

        // Iterate over the collection of publish results
        for (B2CIAPublishCustomerProfileResult thisResult : publishResult) {

            // Validate that the results were processed successfully
            System.assertEquals(thisResult.statusCode, 200, 'Expected the statusCode to equal 200 -- indicating a successful publishingEvent');

        }

    }

    /**
     * @see B2CIAValidateContact.validateContact
     * @description This test method exercises publishEvents and verifies that successful events
     * are processed correctly.  We expect a 200 http-status to be included in the response.
     */
    @IsTest
    static void publishEventSucceededWithCalculatedBody() {

        // Initialize local variables
        List<B2CIAPublishCustomerProfileInput> inputList = new List<B2CIAPublishCustomerProfileInput>();
        List<B2CIAPublishCustomerProfileResult> publishResult = new List<B2CIAPublishCustomerProfileResult>();
        B2CIAPublishCustomerProfileInput input = new B2CIAPublishCustomerProfileInput();

        // Initialize and create the test contact
        Contact c = new Contact(
            LastName = 'lastname',
            Total_Updates_to_B2C_Commerce__c = 0,
            Last_Update_Pushed_to_B2C_Commerce__c = System.Datetime.now(),
            Last_Platform_Event_Applied_Updates__c = false,
            Last_Platform_Event_Processed_Date__c = System.Datetime.now()
        );

        Database.insert( c );

        // Seed the publishEvent properties
        input.apiVersion = 'apiVersion';
        input.b2cCustomerListId = 'id';
        input.b2cCustomerNo = 'customerno';
        input.b2cCustomerId = 'customerid';
        input.crmCustomerListId = 'crmCustomerListId';
        input.crmContactId = c.Id;
        input.crmContact = c;

        // Add the publishEvent to the collection
        inputList.add( input );

        Test.startTest();

            // Initialize the mock and execute the test
            Test.setMock(HttpCalloutMock.class, new B2CHttpTestCalloutMockGenerator('CustomerDetailsSuccess'));
            publishResult = B2CIAPublishCustomerProfile.publishCustomerProfile(inputList);

        Test.stopTest();

        // Iterate over the collection of publish results
        for (B2CIAPublishCustomerProfileResult thisResult : publishResult) {

            // Validate that the results were processed successfully
            System.assertEquals(thisResult.statusCode, 200, 'Expected the statusCode to equal 200 -- indicating a successful publishingEvent');

        }

    }

    /**
     * @see B2CIAValidateContact.validateContact
     * @description This test method exercises publishEvents and verifies that successful events
     * failed correctly.  We expect a non-200 http-status to be included in the response.
     */
    @IsTest
    static void publishEventFailed() {

        // Initialize local variables
        List<B2CIAPublishCustomerProfileInput> inputList = new List<B2CIAPublishCustomerProfileInput>();
        List<B2CIAPublishCustomerProfileResult> publishResult = new List<B2CIAPublishCustomerProfileResult>();
        B2CIAPublishCustomerProfileInput input = new B2CIAPublishCustomerProfileInput();

        // Initialize and create the test contact
        Contact c = new Contact(
                LastName = 'lastname',
                Total_Updates_to_B2C_Commerce__c = 0,
                Last_Update_Pushed_to_B2C_Commerce__c = System.Datetime.now(),
                Last_Platform_Event_Applied_Updates__c = false,
                Last_Platform_Event_Processed_Date__c = System.Datetime.now()
        );

        Database.insert( c );

        // Seed the publishEvent properties
        input.apiVersion = 'apiVersion';
        input.b2cCustomerListId = 'id';
        input.b2cCustomerNo = 'customerno';
        input.b2cCustomerId = 'customerid';
        input.crmCustomerListId = 'crmCustomerListId';
        input.crmContactId = c.Id;
        input.crmContact = c;
        input.b2cProfileJSON = '{}';

        // Add the publishEvent to the collection
        inputList.add( input );

        Test.startTest();

        // Initialize the mock and execute the test
        Test.setMock(HttpCalloutMock.class, new B2CHttpTestCalloutMockGenerator('CustomerDetailsFailure'));
        publishResult = B2CIAPublishCustomerProfile.publishCustomerProfile(inputList);

        Test.stopTest();

        // Iterate over the collection of publish results
        for (B2CIAPublishCustomerProfileResult thisResult : publishResult) {

            // Validate that the results were processed successfully
            System.assertEquals(thisResult.statusCode, 404, 'Expected the statusCode to equal 404 -- indicating a error occurred during the publishingEvent');

        }

    }

    /**
     * @see B2CIAValidateContact.validateContact
     * @description This test method exercises publishEvents and verifies that successful events
     * are processed correctly.  We expect a 200 http-status to be included in the response.
     */
    @IsTest
    static void publishEventWithMergedContactAndAccountSucceeded() {
        List<B2C_Integration_Field_Mappings__mdt> accountFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Account', true);
        if (accountFieldMappings.size() == 0) {
            Assert.isTrue(true, 'No Account based fields mapping, abort this test.');
            return;
        }

        // Initialize local variables
        List<B2CIAPublishCustomerProfileInput> inputList = new List<B2CIAPublishCustomerProfileInput>();
        List<B2CIAPublishCustomerProfileResult> publishResult = new List<B2CIAPublishCustomerProfileResult>();
        B2CIAPublishCustomerProfileInput input = new B2CIAPublishCustomerProfileInput();

        // Create a test account that we'll exercise
        Account a = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'Name' => 'Name',
            accountFieldMappings.get(0).Service_Cloud_Attribute__c => 'OriginalValue',
            'RecordTypeId' => B2CIACustomerResolution_TestHelper.getRecordType(B2CConfigurationManager.getAccountRecordTypeDeveloperName()).Id
        });

        // Initialize and create the test contact
        Contact c = new Contact(
            AccountId = a.Id,
            LastName = 'lastname',
            Total_Updates_to_B2C_Commerce__c = 0,
            Last_Update_Pushed_to_B2C_Commerce__c = System.Datetime.now(),
            Last_Platform_Event_Applied_Updates__c = false,
            Last_Platform_Event_Processed_Date__c = System.Datetime.now()
        );

        Database.insert(c);

        // Seed the publishEvent properties
        input.apiVersion = 'apiVersion';
        input.b2cCustomerListId = 'id';
        input.b2cCustomerNo = 'customerno';
        input.b2cCustomerId = 'customerid';
        input.crmCustomerListId = 'crmCustomerListId';
        input.crmContactId = c.Id;
        input.crmContact = c;

        // Add the publishEvent to the collection
        inputList.add( input );

        Test.startTest();

            // Initialize the mock and execute the test
            Test.setMock(HttpCalloutMock.class, new B2CHttpTestCalloutMockGenerator('CustomerDetailsSuccess'));
            publishResult = B2CIAPublishCustomerProfile.publishCustomerProfile(inputList);

        Test.stopTest();

        // Iterate over the collection of publish results
        for (B2CIAPublishCustomerProfileResult thisResult : publishResult) {

            // Validate that the results were processed successfully
            Assert.areEqual(200, thisResult.statusCode, 'Expected the statusCode to equal 200 -- indicating a successful publishingEvent');

            // Validate that the JSON body is a merge of both Account & Contact properties
            Assert.areEqual('OriginalValue', thisResult.b2cCustomerProfile.get(accountFieldMappings.get(0).B2C_Commerce_OCAPI_Attribute__c).getStringValue(), 'Expected the account value to be part of the b2c profile JSON');

        }

    }

}
