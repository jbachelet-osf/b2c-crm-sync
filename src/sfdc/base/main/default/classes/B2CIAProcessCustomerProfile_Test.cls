/**
 * @author Eric Schultz
 * @date April 16, 2020
 *
 * @description This class is used to exercise the processCustomerProfile class and
 * exercise the logic used to interact / synchronize with B2C Commerce customerProfiles.
 */
@IsTest
private class B2CIAProcessCustomerProfile_Test {

    @IsTest
    static void testProcessCustomerProfileUpdateSuccess() {

        // Initialize local variables
        List<B2CIAGetCustomerProfileResult> requestArguments = new List<B2CIAGetCustomerProfileResult>();
        B2CIAGetCustomerProfileResult input = new B2CIAGetCustomerProfileResult();
        Contact updatedContact;

        // Create a test contact that we'll exercise
        Contact c = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'FirstName' => 'firstName',
            'LastName' => 'originalLastName',
            'Email' => 'test-user@b2csa.qa.salesforce.com'
        });

        // Seed the request arguments
        input.crmContactId = c.Id;
        input.responseBody = '{"last_name": "updatedLastName"}';
        requestArguments.add(input);

        Test.startTest();

            // Attempt to update the customerProfiles using the properties / specified
            B2CIAProcessCustomerProfile.updateCustomerProfiles(requestArguments);

            // Retrieve the updatedContact using the same fields
            updatedContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :c.Id];

        Test.stopTest();

        // Validate that the specific customerProfile updates were processed successfully
        System.assertEquals(updatedContact.LastName,'updatedLastName', 'Expected the lastName for the contact to be updated with the responseBody contents');

    }

    @IsTest
    static void testProcessCustomerProfileNoUpdateSuccess() {

        // Initialize local variables
        List<B2CIAGetCustomerProfileResult> requestArguments = new List<B2CIAGetCustomerProfileResult>();
        B2CIAGetCustomerProfileResult input = new B2CIAGetCustomerProfileResult();
        Contact updatedContact;

        // Create a test contact that we'll exercise
        Contact c = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'FirstName' => 'firstName',
            'LastName' => 'originalLastName',
            'Email' => 'test-user@b2csa.qa.salesforce.com'
        });

        // Seed the request arguments
        input.crmContactId = c.Id;
        input.responseBody = '{}';
        requestArguments.add(input);

        Test.startTest();

        // Attempt to update the customerProfiles using the properties / specified
        B2CIAProcessCustomerProfile.updateCustomerProfiles(requestArguments);

        // Retrieve the updatedContact using the same fields
        updatedContact = [SELECT Id, FirstName, LastName, Email, Last_Platform_Event_Applied_Updates__c FROM Contact WHERE Id = :c.Id];

        Test.stopTest();

        // Validate that the specific customerProfile updates were processed successfully -- but no updates were made
        System.assertEquals(updatedContact.Last_Platform_Event_Applied_Updates__c, false, 'Expected that no platformEvent updates were processed');

    }

    @IsTest
    static void testProcessCustomerProfileAccountUpdateSuccess() {

        // Initialize local variables
        List<B2CIAGetCustomerProfileResult> requestArguments = new List<B2CIAGetCustomerProfileResult>();
        B2CIAGetCustomerProfileResult input = new B2CIAGetCustomerProfileResult();

        List<B2C_Integration_Field_Mappings__mdt> accountFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Account', true);
        if (accountFieldMappings.size() == 0) {
            Assert.isTrue(true, 'No Account based fields mapping, abort this test.');
            return;
        }

        // Create a test account that we'll exercise
        Account a = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'Name' => 'Name',
            accountFieldMappings.get(0).Service_Cloud_Attribute__c => 'OriginalValue',
            'RecordTypeId' => B2CIACustomerResolution_TestHelper.getRecordType(B2CConfigurationManager.getAccountRecordTypeDeveloperName()).Id
        });

        // Create a test contact that we'll exercise
        Contact c = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'AccountId' => a.Id,
            'FirstName' => 'firstName',
            'LastName' => 'originalLastName',
            'Email' => 'test-user@b2csa.qa.salesforce.com'
        });

        // Seed the request arguments
        input.crmContactId = c.Id;
        input.responseBody = '{"' + accountFieldMappings.get(0).B2C_Commerce_OCAPI_Attribute__c + '": "updatedValue"}';
        requestArguments.add(input);

        Test.startTest();

            // Attempt to update the customerProfiles using the properties / specified
            B2CIAProcessCustomerProfile.updateCustomerProfiles(requestArguments);

            // Retrieve the updatedAccount using the same fields
            String query = 'SELECT Id, ' + accountFieldMappings.get(0).Service_Cloud_Attribute__c + ' FROM Account WHERE Id = :accountId LIMIT 1';
            Account updatedAccount = Database.queryWithBinds(query, new Map<String, Object> {
                'accountId' => a.Id
            }, AccessLevel.SYSTEM_MODE);

        Test.stopTest();

        // Validate that the specific customerProfile updates were processed successfully
        System.assertEquals(updatedAccount.get(accountFieldMappings.get(0).Service_Cloud_Attribute__c), 'updatedValue', 'Expected the site for the account to be updated with the responseBody contents');

    }

}
