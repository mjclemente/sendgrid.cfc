/**
* sendgrid.cfc
* Copyright 2017-2019 Matthew Clemente, John Berquist
* Licensed under MIT (https://github.com/mjclemente/sendgrid.cfc/blob/master/LICENSE)
*/
component accessors="true" {

  property name="name" default="";
  property name="categories" default="";
  property name="send_at" default="";
  property name="sent_to" default="";
  property name="email_config" default="";

  /**
  * @hint Initializes the Single Send with a name. The name is required to create a Single Send.
  */
  public any function init( string name ) {

    setCategories([]);
    setSent_to({});
    setEmail_config({});

    if ( arguments.keyExists( 'name' ) )
      this.name( name );

    return this;
  }

  /**
  * @hint Sets the name of the Single Send. This is required. The name must be at least 1 character long and can be up to 100 characters.
  */
  public any function name( required string name ) {
    // validate minimum length
    if( !name.len() ){
      throw( type="InvalidArgumentException", message="The name must be at least 1 character long." );
    }

    // trim to 100 characters if longer
    if( name.len() > 100 ){
      name = name.left(100);
    }

    setName( name );
    return this;
  }

  // TODO: throw exception or slice if length exceeds 10
  /**
  * @hint Sets the categories for the Single Send. Maximum of 10 categories allowed.
  */
  public any function categories( required array categories ) {
    // Ensure the array is not longer than 10 items
    if( categories.len() > 10 ){
      categories = categories.slice(1, 10);
    }

    setCategories( categories );
    return this;
  }

  /**
  * @hint Sets the send time for the Single Send in ISO8601 timestamp format.
  */
  public any function send_at( required string timestamp ) {
    timestamp = timestamp.dateTimeFormat('iso');
    setSend_at( timestamp );
    return this;
  }

  /**
  * @hint Sets the send_to object for the Single Send.
  * @send_to object can include list_ids, segment_ids, and the all flag.
  */
  public any function send_to( required struct send_to ) {
    if( send_to.keyExists("list_ids") ){
      if( !isArray(send_to.list_ids) ){
        throw( type="InvalidArgumentException", message="list_ids must be an array of UUIDs." );
      }
      if( send_to.list_ids.len() > 50 ){
        send_to.list_ids = send_to.list_ids.slice(1, 50);
      }
    }

    // Validate segment_ids
    if( send_to.keyExists("segment_ids") ){
      if( !isArray(send_to.segment_ids) ){
        throw( type="InvalidArgumentException", message="segment_ids must be an array of UUIDs." );
      }
      if( send_to.segment_ids.len() > 10 ){
        send_to.segment_ids = send_to.segment_ids.slice(1, 10);
      }
    }

    if( send_to.keyExists("all") && !isBoolean(send_to.all) ){
      throw( type="InvalidArgumentException", message="The all property must be a boolean." );
    }

    setSent_to( send_to );
    return this;
  }

  /**
  * @hint Adds a list ID to the send_to object. Maximum of 50 list IDs allowed.
  */
  public any function addListId( required string listId ) {
    if( !variables.sent_to.keyExists("list_ids") ){
      variables.sent_to["list_ids"] = [];
    }
    if( variables.sent_to["list_ids"].len() >= 50 ){
      throw( type="InvalidArgumentException", message="A maximum of 50 list IDs is allowed." );
    }
    variables.sent_to["list_ids"].append(listId);
    return this;
  }

  /**
  * @hint Adds a segment ID to the send_to object. Maximum of 10 segment IDs allowed.
  */
  public any function addSegmentId( required string segmentId ) {
    if( !variables.sent_to.keyExists("segment_ids") ){
      variables.sent_to["segment_ids"] = [];
    }
    if( variables.sent_to["segment_ids"].len() >= 10 ){
      throw( type="InvalidArgumentException", message="A maximum of 10 segment IDs is allowed." );
    }
    variables.sent_to["segment_ids"].append(segmentId);
    return this;
  }

  /**
  * @hint Sets the all flag in the send_to object.
  */
  public any function setAll( required boolean all ) {
    if( !variables.sent_to.keyExists("all") ) {
      variables.sent_to["all"] = false;
    }
    variables.sent_to["all"] = all;
    return this;
  }

  /**
  * @hint Configures the email content for the Single Send.
  * @config is a struct containing email configuration details.
  */
  public any function emailConfig( required struct config ) {
    if( config.keyExists("subject") ){
      subject(config.subject);
    }
    if( config.keyExists("html_content") ){
      htmlContent(config.html_content);
    }
    if( config.keyExists("plain_content") ){
      plainContent(config.plain_content);
    }
    if( config.keyExists("generate_plain_content") ){
      if( !isBoolean(config.generate_plain_content) ){
        throw( type="InvalidArgumentException", message="generate_plain_content must be a boolean." );
      }
      variables.email_config["generate_plain_content"] = config.generate_plain_content;
    }
    if( config.keyExists( "design_id") ){
      variables.email_config.delete("subject");
      variables.email_config.delete("html_content");
      variables.email_config.delete("plain_content");
      variables.email_config["design_id"] = config.design_id;
    }
    if( config.keyExists("editor") ){
      if( !(config.editor == "code" || config.editor == "design") ){
        throw( type="InvalidArgumentException", message="editor must be 'code' or 'design'." );
      }
      variables.email_config["editor"] = config.editor;
    }
    if( !config.keyExists("suppression_group_id") && !config.keyExists("custom_unsubscribe_url") ){
      throw( type="InvalidArgumentException", message="Either suppression_group_id or custom_unsubscribe_url must be provided." );
    }
    if( config.keyExists("suppression_group_id") ){
      variables.email_config["suppression_group_id"] = config.suppression_group_id;
    }
    if( config.keyExists("custom_unsubscribe_url") ){
      variables.email_config["custom_unsubscribe_url"] = config.custom_unsubscribe_url;
    }
    if( config.keyExists("sender_id") ){
      senderId(config.sender_id);
    }
    if( config.keyExists("ip_pool") ){
      variables.email_config["ip_pool"] = config.ip_pool;
    }

    setEmail_config( variables.email_config );
    return this;
  }

  /**
  * @hint Convenience method for setting the subject of the email.
  */
  public any function subject( required string subject ) {
    variables.email_config["subject"] = subject;
    return this;
  }

  /**
  * @hint Convenience method for setting the HTML content of the email.
  */
  public any function htmlContent( required string html ) {
    variables.email_config["html_content"] = html;
    return this;
  }

  /**
  * @hint Convenience method for setting the plain text content of the email.
  */
  public any function plainContent( required string plain ) {
    variables.email_config["plain_content"] = plain;
    return this;
  }

  /**
  * @hint Convenience method for setting the sender ID.
  */
  public any function senderId( required numeric id ) {
    variables.email_config["sender_id"] = id;
    return this;
  }

  /**
  * @hint Assembles the JSON payload to send to the API. Generally, you shouldn't need to call this directly.
  */
  public string function build() {
    var body = {
      name: getName(),
      categories: getCategories(),
      send_at: getSend_at(),
      sent_to: getSent_to(),
      email_config: getEmail_config()
    };

    return serializeJSON( body );
  }

  // /**
  // * @hint converts the array of properties to an array of their keys/values, while filtering those that have not been set
  // */
  // private array function getPropertyValues() {

  //   var propertyValues = getProperties().map(
  //     function( item, index ) {
  //       return {
  //         "key" : item.name,
  //         "value" : getPropertyValue( item.name )
  //       };
  //     }
  //   );

  //   return propertyValues.filter(
  //     function( item, index ) {
  //       if ( isStruct( item.value ) )
  //         return !item.value.isEmpty();
  //       else
  //         return item.value.len();
  //     }
  //   );
  // }

  // private array function getProperties() {

  //   var metaData = getMetaData( this );
  //   var properties = [];

  //   for( var prop in metaData.properties ) {
  //     properties.append( prop );
  //   }

  //   return properties;
  // }

  // private any function getPropertyValue( string key ){
  //   var method = this["get#key#"];
  //   var value = method();
  //   return value;
  // }
}