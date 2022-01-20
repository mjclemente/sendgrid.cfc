/**
* sendgrid.cfc
* Copyright 2017-2019 Matthew Clemente, John Berquist
* Licensed under MIT (https://github.com/mjclemente/sendgrid.cfc/blob/master/LICENSE)
*/
component accessors="true" {

  property name="nickname" default="";
  property name="from" default="";
  property name="reply_to" default="";
  property name="address" default="";
  property name="address_2" default="";
  property name="city" default="";
  property name="state" default="";
  property name="zip" default="";
  property name="country" default="";

  /**
  * @hint No parameters can be passed to init this component. They must be built manually. When creating and updating sender identities, the following fields are required:
    * nickname,
    * from.email,
    * address,
    * city,
    * country
  Sender Identities are required to be verified before use. If your domain has been whitelabeled it will auto verify on creation. Otherwise an email will be sent to the from.email.
  */
  public any function init() {
    return this;
  }

  /**
  * @hint Sets the nickname for the sender identity. Not used for sending, but required.
  */
  public any function nickname( required string nickname ) {
    setNickname( nickname );
    return this;
  }

  /**
  * @hint Set where the email will appear to originate from for your recipients.
  * @email facilitates two means of setting who the email is from. You can pass in a struct with keys for `name` and `email` (only email is required), or you can pass in the email as a string. Note that, despite what the documentation says, both email address and name need to be provided. If a string is passed in and the name is not provided, the email address will be used as the name as well.
  */
  public any function from( required any email ) {
    setFrom( parseEmail( email ) );
    return this;
  }

  /**
  * @hint Set where your recipients will reply to.
  * @email Facilitates two means of setting who the recipient replies to. You can pass in a struct with keys for `name` and `email` (only email is required), or you can pass in the email as a string. If a string is passed in and the name is not provided, the email address will be used as the name as well.
  */
  public any function replyTo( required any email ) {
    setReply_to( parseEmail( email ) );
    return this;
  }

  /**
  * @hint Required. Sets the physical address of the sender identity.
  */
  public any function address( required string address ) {
    setAddress( address );
    return this;
  }

  /**
  * @hint Optional. Provides additional sender identity address information.
  */
  public any function address2( required string address ) {
    setAddress_2( address );
    return this;
  }

  /**
  * @hint Required
  */
  public any function city( required string city ) {
    setCity( city );
    return this;
  }

  /**
  * @hint Optional
  */
  public any function state( required string state ) {
    setState( state );
    return this;
  }

  /**
  * @hint Optional
  */
  public any function zip( required string zip ) {
    setZip( zip );
    return this;
  }

  /**
  * @hint Required
  */
  public any function country( required string country ) {
    setCountry( country );
    return this;
  }


  /**
  * @hint Assembles the JSON to send to the API. Generally, you shouldn't need to call this directly.
  */
  public string function build() {

    var body = '';
    var properties = getPropertyValues();
    var count = properties.len();

    properties.each(
      function( property, index ) {
        body &= '"#property.key#": ' & serializeJSON( property.value ) & '#index NEQ count ? "," : ""#';
      }
    );

    return '{' & body & '}';
  }

  /**
  * @hint If a struct is received, it is assumed it's in the proper format. Strings are parsed to check for bracketed email format. Functions differently than the parser in mail.cfc, in that it uses the email address in place of the name, if no name is provided, because of requirements for the /senders endpoint.
  */
  private struct function parseEmail( any email ) {
    if ( isStruct( email ) ) {
      return email;
    } else {
      var regex = '<([^>]+)>';
      var bracketedEmails = email.reMatchNoCase( regex );
      if ( bracketedEmails.len() ) {
        var bracketedEmail = bracketedEmails[1];
        var name = email.replacenocase( bracketedEmail, '' ).trim();
        var result = {
          'email' : bracketedEmail.REReplace( '[<>]', '', 'all'),
          'name' : name.len() ? name : bracketedEmail.REReplace( '[<>]', '', 'all')
        };
        return result;
      } else {
        return {
          'email' : email,
          'name' : email
        };

      }
    }
  }

  /**
  * @hint converts the array of properties to an array of their keys/values, while filtering those that have not been set
  */
  private array function getPropertyValues() {

    var propertyValues = getProperties().map(
      function( item, index ) {
        return {
          "key" : item.name,
          "value" : getPropertyValue( item.name )
        };
      }
    );

    return propertyValues.filter(
      function( item, index ) {
        if ( isStruct( item.value ) )
          return !item.value.isEmpty();
        else
          return item.value.len();
      }
    );
  }

  private array function getProperties() {

    var metaData = getMetaData( this );
    var properties = [];

    for( var prop in metaData.properties ) {
      properties.append( prop );
    }

    return properties;
  }

  private any function getPropertyValue( string key ){
    var method = this["get#key#"];
    var value = method();
    return value;
  }
}
