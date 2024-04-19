/**
 * @author Abraham David Lloyd
 * @date February 8th, 2021
 *
 * @description This is a helper class that takes the REST API Response from B2C Commerce
 * and moves forward with parsing, processing, and writing updates to the corresponding customerProfile.
*/
public with sharing class B2CIAProcessCustomerProfile extends B2CBaseAttributeAssignment {

    /**
     * @description This method is used to process the customerProfile results retrieved from B2C Commerce
     * and update the Salesforce Account / Contact pair representing the customer.
     *
     * @param customerProfileResults {List<B2CIAGetCustomerProfileResult>} Represents the profileResults retrieved
     * from B2C Commerce that will drive the customerProfile updates
     */
    @InvocableMethod(Label='B2C: Update Customer Profile Definitions' Description='Attempts to update a Contact with the latest REST API results from B2C Commerce')
    public static void updateCustomerProfiles(List<B2CIAGetCustomerProfileResult> customerProfileResults) {

        // Initialize local variables
        JSONParse customerProfileJSON;
        List<SObject> customerProfiles = new List<SObject>();
        List<SObject> customerProfilesAccounts = new List<SObject>();
        SObject thisCustomerProfile;
        SObject thisCustomerProfileAccount;
        SObject originalCustomerProfile;
        SObject originalCustomerProfileAccount;
         // Retrieve the fieldMappings to leverage based on the Account / Contact Model being employed
        List<B2C_Integration_Field_Mappings__mdt> contactFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Contact', false);
        List<B2C_Integration_Field_Mappings__mdt> accountFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Account', true);

        Boolean hasSObjectBeenUpdated;
        Boolean hasSObjectBeenUpdatedAccount;
        Integer totalContactUpdates;
        // Start by retrieving the default account / contactModel
        String accountContactModel = B2CConfigurationManager.getDefaultAccountContactModel();

        // Iterate over the collection of customerProfile results
        for (B2CIAGetCustomerProfileResult thisCustomerProfileResult : customerProfileResults) {

            // Check for any errors -- if an error was caught then skip this result
            if (thisCustomerProfileResult.isError == true) { continue; }

            // Default the tracking flag
            hasSObjectBeenUpdated = false;
            hasSObjectBeenUpdatedAccount = false;

            // Deserialize the REST API response into a generic and typed object
            customerProfileJSON = new JSONParse(thisCustomerProfileResult.responseBody);

            // Retrieve the current customerProfile using the specified crmId
            thisCustomerProfile = B2CContactManager.getContactById(thisCustomerProfileResult.crmContactId, true, contactFieldMappings);
            String accountId = (String)thisCustomerProfile.get('AccountId');

            // Are we currently using the personAccount accountContact model?
            if (accountContactModel == B2CConstant.ACCOUNTCONTACTMODEL_PERSON) {
                // Remove the AccountID as we can't update it when the person customerModel is employed
                thisCustomerProfile = B2CBaseAttributeAssignment.removePersonAccountProperties(thisCustomerProfile);
            }

            // Create a copy of the cloned customerProfile -- so that we can compare specific values
            originalCustomerProfile = thisCustomerProfile.clone(true, true, true, true);

            // Update the key properties of the current object
            thisCustomerProfile = applyMappedFieldValues(thisCustomerProfile, customerProfileJSON, contactFieldMappings);

            // Evaluate the updates made and determine if the object has been updated
            hasSObjectBeenUpdated = hasSObjectBeenUpdated(originalCustomerProfile, thisCustomerProfile, contactFieldMappings);

            if (String.isNotEmpty(accountId)) {
                thisCustomerProfileAccount = B2CContactAccountManager.getAccountById(accountId, true, accountFieldMappings);
                originalCustomerProfileAccount = thisCustomerProfileAccount.clone(true, true, true, true);
                thisCustomerProfileAccount = applyMappedFieldValues(thisCustomerProfileAccount, customerProfileJSON, accountFieldMappings);
                hasSObjectBeenUpdatedAccount = hasSObjectBeenUpdated(originalCustomerProfileAccount, thisCustomerProfileAccount, accountFieldMappings);
            }

            // Has the object been updated?
            if (hasSObjectBeenUpdated == true || hasSObjectBeenUpdatedAccount == true) {
                // Audit that the PlatformEvent applied updates and record the date
                thisCustomerProfile.put('Last_Platform_Event_Processed_Date__c', System.Datetime.now());
                thisCustomerProfile.put('Last_B2C_Commerce_Update_Processed__c', System.Datetime.now());
                thisCustomerProfile.put('Last_Platform_Event_Applied_Updates__c', true);

                // Increment the count of updates applied to the specified contact
                totalContactUpdates = thisCustomerProfile.get('Total_Updates_From_B2C_Commerce__c') == null ? 1 : Integer.valueOf(thisCustomerProfile.get('Total_Updates_From_B2C_Commerce__c')) + 1;

                // Increase the total updates and flag that this record was updated via a B2C Platform Event
                thisCustomerProfile.put('Total_Updates_From_B2C_Commerce__c', totalContactUpdates);
                thisCustomerProfile.put('Updated_by_B2C_Platform_Event__c', true);

                // Append the customerProfile to the processing collection
                if (hasSObjectBeenUpdated == true) {
                    customerProfiles.add(thisCustomerProfile);
                }
                if (hasSObjectBeenUpdatedAccount == true) {
                    customerProfilesAccounts.add(thisCustomerProfileAccount);
                }
            } else {
                // Audit that the PlatformEvent did not apply updates
                originalCustomerProfile.put('Last_Platform_Event_Processed_Date__c', System.Datetime.now());
                originalCustomerProfile.put('Last_Platform_Event_Applied_Updates__c', false);

                // Append the customerProfile to the processing collection
                customerProfiles.add(originalCustomerProfile);
            }
        }

        // Was at least one customerProfile record processed?
        if (customerProfiles.size() > 0
        && (Contact.SObjectType.getDescribe().isUpdateable() &&
        Contact.SObjectType.getDescribe().isCreateable() &&
        Contact.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.Contact.fields.LastName.isUpdateable() &&
        Schema.SObjectType.Contact.fields.LastName.isCreateable())) {
            // If so, then process the customerProfiles
            Map<id,SObject> contactMap = new Map<id,SObject>();
            contactMap.putall(customerProfiles);
            upsert contactMap.values();
        }

        // Was at least one customerProfileAccount record processed?
        if (customerProfilesAccounts.size() > 0
        && (Account.SObjectType.getDescribe().isUpdateable() &&
        Account.SObjectType.getDescribe().isCreateable() &&
        Account.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.Account.fields.LastName.isUpdateable() &&
        Schema.SObjectType.Account.fields.LastName.isCreateable())) {
            // If so, then process the customerProfiles
            Map<id,SObject> accountMap = new Map<id,SObject>();
            accountMap.putall(customerProfilesAccounts);
            upsert accountMap.values();
        }
    }
}
