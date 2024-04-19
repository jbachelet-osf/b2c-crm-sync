/**
 * @author Abraham David Lloyd
 * @date July 1st 2021
 * @description This class is used to capture the inputs used to generate
 * a Business Manager UserGrant from B2C Commerce.
 */
public with sharing class B2CContactProcessSourceInput {

    /**
     * @constructor
     * @description Constructor to product an instance of this class.
     **/
    public B2CContactProcessSourceInput() {}

    @AuraEnabled @InvocableVariable(Required=true)
    public String jsonRepresentation;
}
