/**
 * @author Eric Schultz
 * @date April 28th, 2021
 *
 * @description This class helps to evalutate the source input from the REST API
*/
//noinspection LongLine
public inherited sharing class B2CContactProcessEvaluateSourceInput extends B2CBaseAttributeAssignment {

    /**
     * @description Invocable action to evaluate source inputs and map either a source contact or source account
     *
     * @param sourceInputs{List<B2CContactProcessSourceInput>} A list of source inputs to evaluate
     * This is to support use within Flow.
     * @return {List<B2CContactProcessEvaluateSourceResult>} Returns a list sources.
     */
    @InvocableMethod(Label='B2C: Contact Process - Evaluate Source Inputs' Description='Evaluate source inputs')
    public static List<B2CContactProcessEvaluateSourceResult> evaluate(List<B2CContactProcessSourceInput> sourceInputs) {
        List<B2CContactProcessEvaluateSourceResult> outputs = new List<B2CContactProcessEvaluateSourceResult>();
        List<B2C_Integration_Field_Mappings__mdt> contactFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Contact', false);
        List<B2C_Integration_Field_Mappings__mdt> accountFieldMappings = B2CMetaFieldMappings.getFieldMappingsForRetrieval('Account', true);
        String defaultContactModel = B2CConfigurationManager.getDefaultAccountContactModel();

        for (B2CContactProcessSourceInput sourceInput : sourceInputs) {
            B2CContactProcessEvaluateSourceResult output = new B2CContactProcessEvaluateSourceResult();
            JSONParse json = new JSONParse(sourceInput.jsonRepresentation);
            Contact c = new Contact();
            Account a = new Account();

            // Person account handling
            if (defaultContactModel == B2CConstant.ACCOUNTCONTACTMODEL_PERSON) {
                String thisSObjectType = c.getSObjectType().getDescribe().getName();
                Map<String,Schema.SObjectField> schemaMap = getSchemaMap(c);

                for (B2C_Integration_Field_Mappings__mdt thisFieldMapping : contactFieldMappings) {
                    // Determine if this field exists in the processed JSON object
                    Boolean hasJSONObjProperty = doesFieldExistInJSONObject(json, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (hasJSONObjProperty == false) { continue; }

                    // Determine if this field exists in the specified Salesforce object
                    Boolean hasSObjProperty = doesFieldExist(schemaMap, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (hasSObjProperty == false) { continue; }

                    // Retrieve the schema for the current field being processed
                    Schema.DisplayType fieldDisplayType = getFieldDisplayType(schemaMap, thisSObjectType, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (fieldDisplayType == null) { continue; }

                    // Write the field to the property value specified by parsing it from the JSON field
                    output.sourceContact = (Contact)assignB2CAttributeValue(json, fieldDisplayType, (SObject)c, thisFieldMapping.Service_Cloud_Attribute__c, thisFieldMapping.Service_Cloud_Attribute__c);
                }

                thisSObjectType = a.getSObjectType().getDescribe().getName();
                schemaMap = getSchemaMap(a);

                // Copy over contact-based attributes to the person account as we'll use it within the duplicate rules afterwards
                a = translateContactToPersonAccount(output.sourceContact, contactFieldMappings, accountFieldMappings);

                // then reapply the account-level attributes from the source input JSON
                for (B2C_Integration_Field_Mappings__mdt thisFieldMapping : accountFieldMappings) {
                    // Determine if this field exists in the processed JSON object
                    Boolean hasJSONObjProperty = doesFieldExistInJSONObject(json, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (hasJSONObjProperty == false) { continue; }

                    // Determine if this field exists in the specified Salesforce object
                    Boolean hasSObjProperty = doesFieldExist(schemaMap, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (hasSObjProperty == false) { continue; }

                    // Retrieve the schema for the current field being processed
                    Schema.DisplayType fieldDisplayType = getFieldDisplayType(schemaMap, thisSObjectType, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (fieldDisplayType == null) { continue; }

                    // Write the field to the property value specified by parsing it from the JSON field
                    a = (Account)assignB2CAttributeValue(json, fieldDisplayType, (SObject)a, thisFieldMapping.Service_Cloud_Attribute__c, thisFieldMapping.Service_Cloud_Attribute__c);
                }

                output.sourcePersonAccount = a;
            } else {
                String thisSObjectType = c.getSObjectType().getDescribe().getName();
                Map<String,Schema.SObjectField> schemaMap = getSchemaMap(c);

                for (B2C_Integration_Field_Mappings__mdt thisFieldMapping : contactFieldMappings) {
                    // Determine if this field exists in the processed JSON object
                    Boolean hasJSONObjProperty = doesFieldExistInJSONObject(json, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (hasJSONObjProperty == false) { continue; }

                    // Determine if this field exists in the specified Salesforce object
                    Boolean hasSObjProperty = doesFieldExist(schemaMap, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (hasSObjProperty == false) { continue; }

                    // Retrieve the schema for the current field being processed
                    Schema.DisplayType fieldDisplayType = getFieldDisplayType(schemaMap, thisSObjectType, thisFieldMapping.Service_Cloud_Attribute__c);
                    if (fieldDisplayType == null) { continue; }

                    // Write the field to the property value specified by parsing it from the JSON field
                    output.sourceContact = (Contact)assignB2CAttributeValue(json, fieldDisplayType, (SObject)c, thisFieldMapping.Service_Cloud_Attribute__c, thisFieldMapping.Service_Cloud_Attribute__c);
                }
            }

            outputs.add(output);
        }

        return outputs;
    }
}
