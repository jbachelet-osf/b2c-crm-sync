/**
 * @author Abraham David Lloyd
 * @date February 11th, 2021
 *
 * @description This class is used to retrieve B2C Commerce customer data and details
 * from custom object definitions.  Each customer should also have an associated
 * default customerList.
 */
public with sharing class B2CContactAccountManager extends B2CBaseMeta {

    /**
     * @description Attempts to retrieve a Contact configured via custom objects.
     *
     * @param contactId {String} Describes the Contact identifier used to retrieve a given definition
     * @param returnEmptyObject {Boolean} Describes if an empty sObject should be returned if no results are found
     * @param fieldMappings {List<B2C_Integration_Field_Mappings__mdt>} Represents the fieldMappings
     * @return {Account} Returns an instance of a Contact
     */
    public static Account getAccountById(
        String accountId, Boolean returnEmptyObject, List<B2C_Integration_Field_Mappings__mdt> fieldMappings
    ) {

        // Initialize local variables
        List<Account> accounts;
        String errorMsg;
        Query accountQuery;
        Account output;

        // Default the error message
        errorMsg = B2CConstant.buildErrorMessage(B2CConstant.ERRORS_META_ACCOUNTNOTFOUND, accountId);

        // Seed the default query structure to leverage
        accountQuery = getDefaultQuery(fieldMappings);

        // Define the record limit for the query
        accountQuery.setLimit(1);

        // Define the default where-clause for the query
        accountQuery.addConditionEq('Id', accountId);

        // Execute the query and evaluate the results
        accounts = accountQuery.run();

        // Process the return results in a consistent manner
        output = (Account)processReturnResult('Account', returnEmptyObject, accounts, errorMsg);

        // Return the customerList result
        return output;

    }

    /**
     * @description Helper function that takes an existing contact, and fieldMappings -- and creates an
     * object representation only containing mapped B2C Commerce properties that can be updated via the
     * OCAPI Data REST API.
     *
     * @param customerProfile {Account} Represents the account being processed for B2C Commerce updates
     * @param fieldMappings {List<B2C_Integration_Field_Mappings__mdt>} Represents the collection of
     * fieldMappings being evaluated
     * @return {Map<String, Object>} Returns an object representation of the properties to update
     */
    public static Map<String, Object> getPublishProfile(
        Account customerProfile, List<B2C_Integration_Field_Mappings__mdt> fieldMappings, Map<String, Object> contactBasedMap
    ) {

        // Initialize local variables
        Map<String, Object> output;
        List<String> deleteNode;
        Object accountPropertyValue;
        String oCAPISubKey;

        // Initialize the output map
        output = contactBasedMap.clone();
        deleteNode = new List<String>();

        // Attach the contact and account Ids to the profile
        if (!contactBasedMap.containsKey('c_b2ccrm_contactId')) {
            output.put('c_b2ccrm_contactId', customerProfile.PersonContactId);
        }
        if (!contactBasedMap.containsKey('c_b2ccrm_accountId')) {
            output.put('c_b2ccrm_accountId', customerProfile.Id);
        }

        // Loop over the collection of field mappings
        for (B2C_Integration_Field_Mappings__mdt thisFieldMapping: fieldMappings) {
            // Ensure contact-based mapping has priority on account-based fields
            if (output.containsKey(thisFieldMapping.B2C_Commerce_OCAPI_Attribute__c)) {
                continue;
            }

            // Create a reference to the property value for this contact
            accountPropertyValue = customerProfile.get(thisFieldMapping.Service_Cloud_Attribute__c);

            // Is this property empty and is this not a child node?  If so, then add it to the delete node
            if (accountPropertyValue == null && !thisFieldMapping.B2C_Commerce_OCAPI_Attribute__c.contains('.')) {

                // If so, then add it to the delete node (fields to clear out)
                deleteNode.add(thisFieldMapping.B2C_Commerce_OCAPI_Attribute__c);

            } else {

                // Otherwise, attach the OCAPI property value to the object root
                output.put(thisFieldMapping.B2C_Commerce_OCAPI_Attribute__c, accountPropertyValue);

            }

        }

        // Do we have properties to delete?  If so, then include it in the output
        if (deleteNode.size() > 0) {
            if (!output.containsKey('_delete')) {
                output.put('_delete', new List<String>());
            }

            ((List<String>)output.get('_delete')).addAll(deleteNode);
        }

        // Returns the output collection
        return output;

    }

    /**
     * @description Helper method that provides a consistent set of columns to leverage
     * when selecting sObject data via SOQL
     *
     * @param fieldMappings {List<B2C_Integration_Field_Mappings__mdt>} Represents the fieldMappings
     * @return {Query} Returns the query template to leverage for customerLists
     */
    private static Query getDefaultQuery(List<B2C_Integration_Field_Mappings__mdt> fieldMappings) {

        // Initialize local variables
        Query accountQuery;

        // Create the profile query that will be used to drive resolution
        accountQuery = new Query('Account');

        // Add the base fields to retrieve (identifiers first)
        accountQuery.selectField('Id');

        // Iterate over the field mappings and attach the mapped fields to the query
        for (B2C_Integration_Field_Mappings__mdt thisFieldMapping: fieldMappings) {

            // Add the Salesforce Platform attribute to the query
            accountQuery.selectField(thisFieldMapping.Service_Cloud_Attribute__c);

        }

        // Return the default query structure
        return accountQuery;
    }
}
