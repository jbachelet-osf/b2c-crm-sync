/**
 * @author Eric Schultz
 * @date April 28th, 2021
 *
 * @description This class helps identify relevant duplicates for a contact which can be
 * used to decide how to process updates or inserts
*/
//noinspection LongLine
public inherited sharing class B2CIACustomerResolutionPA {

    /**
     * @description Invocable action to retrieve relevant person account duplicates for person account models
     *
     * @param accountsList{List<List<Account>>} A list of person accounts but is expected to have only 1 item.
     * This is to support use within Flow.
     * @return {List<B2CIACustomerResolutionResult>} Returns a list of list of contacts. This is expected to have
     * only 1 item in the main list to support use with Flow.
     */
    @InvocableMethod(Label='B2C: Customer Resolution Person Accounts' Description='Finds matching person accounts based on B2C matching rules')
    public static List<B2CIACustomerResolutionResult> resolve(List<List<Account>> accountList) {

        // Initialize local variables
        B2CIACustomerResolutionResult resolutionResults;
        List<B2CIACustomerResolutionResult> output;
        List<Account> accountsToResolve;

        // Initialize the output variable
        output = new List<B2CIACustomerResolutionResult>();

        // Initialize the resolution results
        resolutionResults = new B2CIACustomerResolutionResult();
        resolutionResults.isError = false;

        // Was the sourceContact collection populated?
        if (accountList.size() == 0) {

            // If not, indicate an error occurred
            resolutionResults.isError = true;
            resolutionResults.errorMessage = 'No sourcePersonAccountCollection provided to B2CIACustomerResolutionPA class.  ' +
                'Check your input and please try again.';

        } else {

            // Get access to the actual list of contact(s) to resolve
            accountsToResolve = accountList.get(0);

            // Was a contact found in the input parameter?
            if (accountsToResolve.size() == 0) {

                // If not, indicate an error occurred
                resolutionResults.isError = true;
                resolutionResults.errorMessage = 'No source person account provided to B2CIACustomerResolutionPA class.  ' +
                    'Check your input and please try again.';

            } else {

                // Loop over the collection of contacts to resolve
                for (Account a : accountsToResolve) {
                    try {

                        // Add the resolution results to the output class
                        resolutionResults.contactList = findDupes(a);

                    } catch (System.HandledException e) {

                        // Indicate that an error occurred
                        resolutionResults.isError = true;

                        // Capture the error message from the exception
                        resolutionResults.errorMessage = e.getMessage();

                    }

                    // Build the output variable with the processing results
                    output.add(resolutionResults);

                }

            }

        }

        // Return the output variable
        return output;

    }

    /**
     * @description Runs B2C duplicate rules, retrieve potential duplicates, and filter through a companion Flow
     *
     * @param pAccount {Account} A specific person account to run find duplicates on
     * @return {List<Contact>} The final list of contacts that exist that are relevant duplicates
     */
    public static List<Contact> findDupes(Account pAccount) {
        System.debug(LoggingLevel.DEBUG, '--> Find dupes for person account :');
        System.debug(LoggingLevel.DEBUG, pAccount);

        // Initialize local variables
        List<Account> accountToResolve = new List<Account>();
        List<Contact> duplicateContactRecords = new List<Contact>();
        List<Account> matchedAccountRecords = new List<Account>();
        Datacloud.FindDuplicatesResult[] results;

        accountToResolve.add(pAccount.clone(true));
        results = Datacloud.FindDuplicates.findDuplicates(accountToResolve);

        System.debug(LoggingLevel.DEBUG, '--> Iterating over DataCloud results (' + results.size() + ')');

        //If so, iterate over them and start checking for potential matches
        for (Datacloud.FindDuplicatesResult fdrI : results) {

            System.debug(LoggingLevel.DEBUG, '--> FindDuplicatesResult: ' + fdrI);
            System.debug(LoggingLevel.DEBUG, '--> Iterating over duplicate rules results (' + fdrI.getDuplicateResults() + ')');

            // find duplicates based on what was passed in
            for (Datacloud.DuplicateResult dupeResultI : fdrI.getDuplicateResults()) {

                System.debug(LoggingLevel.DEBUG, '--> DuplicateResult: ' + dupeResultI);
                System.debug(LoggingLevel.DEBUG, '--> Iterating over matching rule results (' + dupeResultI.getMatchResults() + ')');

                // Iterate over the collection of match / duplicate rules
                for (Datacloud.MatchResult matchResultI : dupeResultI.getMatchResults()) {

                    // Create a reference to the current rule being processed
                    String matchRule = matchResultI.getRule();

                    System.debug(LoggingLevel.DEBUG, '--> MatchRule: ' + matchRule);
                    System.debug(LoggingLevel.DEBUG, '--> Iterating over matching rule records (' + matchResultI.getMatchRecords().size() + ')');

                    // Instead of processing all rules, we only want to process B2C Commerce-specific rules
                    if (matchRule.contains('B2C') && matchResultI.getMatchRecords().size() > 0) {

                        // Loop over the collection of match records
                        for (Datacloud.MatchRecord dmrI : matchResultI.getMatchRecords()) {

                            System.debug(LoggingLevel.DEBUG, '--> MatchRecord: ' + dmrI);

                            // Add the record to the Account Collection
                            matchedAccountRecords.add((Account)dmrI.getRecord());

                        }

                    }

                }

            }

        }

        // Were any matchedResults found?
        if (!matchedAccountRecords.isEmpty()) {

            if (
                // Validate that we have access to the Contact object
                Contact.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Contact.fields.Id.isAccessible()
            ) {

                // If so, then retrieve Contacts from the Account
                duplicateContactRecords = [
                    SELECT  Id
                    FROM    Contact
                    WHERE   AccountId IN :matchedAccountRecords
                ];

            }

        }

        // Return the collection of contacts that matched the sourceContact
        // by leveraging our configured duplicate rules
        return new List<Contact>([
            SELECT  Id,
                    AccountId,
                    B2C_CustomerList__c,
                    B2C_CustomerList_ID__c,
                    B2C_Customer_ID__c,
                    B2C_Customer_No__c,
                    FirstName,
                    LastName,
                    Email,
                    B2C_UserName__c,
                    B2C_Disable_Integration__c,
                    B2C_Date_Last_Modified__c,
                    Audit_OCAPI_API_Response__c,
                    CreatedDate,
                    LastModifiedDate
            FROM    Contact
            WHERE   Id = :duplicateContactRecords
            ORDER
            BY      LastModifiedDate DESC
        ]);

    }

}
