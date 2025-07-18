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

    if( arguments.keyExists( 'name' ) ){
      this.name( name );
    }

    return this;
  }

  /**
  * @hint Sets the name of the Single Send. This is required. The name must be at least 1 character long and can be up to 100 characters.
  */
  public any function name( required string name ) {
    setName( name );
    return this;
  }

  /**
  * @hint Sets the categories for the Single Send. Maximum of 10 categories allowed.
  * @categories can be passed in as an array or comma separated list. Lists will be converted to arrays
  */
  public any function categories( required any categories ) {
    if( isArray( categories ) ) {
      setCategories( categories );
    } else {
      setCategories( categories.listToArray() );
    }

    return this;
  }

  /**
  * @hint Appends a single category to campaigns array of categories
  */
  public any function addCategory( required string category ) {
    variables.categories.append( category );

    return this;
  }

  /**
  * @hint Sets the send time for the Single Send in ISO8601 timestamp format.
  */
  public any function send_at( required string timestamp ) {
    setSend_at( timestamp );
    return this;
  }

  /**
  * @hint Sets the send_to object for the Single Send.
  * @send_to object can include list_ids, segment_ids, and the all flag.
  */
  public any function send_to( required struct send_to ) {
    setSent_to( send_to );
    return this;
  }

  /**
  * @hint Sets the IDs of the lists you are sending this Single Send to. Maximum of 50 list IDs allowed. Note that you can have both segment IDs and list IDs. If any list Ids were previously set, this method overwrites them.
  * @lists can be passed in as an array or comma separated list. Lists will be converted to arrays
  */
  public any function useLists( required any lists ) {
    if( isArray( lists ) ) {
      variables.sent_to["list_ids"] = lists;
    } else {
      variables.sent_to["list_ids"] = lists.listToArray();
    }

    return this;
  }

  /**
  * @hint Adds a list ID to the send_to object. Maximum of 50 list IDs allowed.
  */
  public any function addListId( required string listId ) {
    variables.sent_to["list_ids"].append(listId);
    return this;
  }

  /**
  * @hint Convenience method for adding a list ID to the send_to object. Delegates to `addListId()`
  */
  public any function useList( required numeric id ) {
    addListId( id );
  }

  /**
  * @hint Sets the segment IDs that you are sending this list to. Maximum of 10 segment IDs allowed. Note that you can have both segment IDs and list IDs. If any segment Ids were previously set, this method overwrites them.
  * @segments can be passed in as an array or comma separated list. Lists will be converted to arrays
  */
  public any function useSegments( required any segments ) {
    if( isArray( segments ) ) {
      variables.sent_to["segment_ids"] = segments;
    } else {
      variables.sent_to["segment_ids"] = segments.listToArray();
    }

    return this;
  }

  /**
  * @hint Adds a segment ID to the send_to object. Maximum of 10 segment IDs allowed.
  */
  public any function addSegmentId( required string segmentId ) {
    variables.sent_to["segment_ids"].append(segmentId);
    return this;
  }

  /**
  * @hint Convenience method for adding a segment ID to the send_to object. Delegates to `addSegmentId()`
  */
  public any function useSegment( required numeric id ) {
    addSegmentId( id );
  }

  /**
  * @hint Sets the all flag in the send_to object.
  */
  public any function setAll( required boolean all ) {
    variables.sent_to["all"] = all;
    return this;
  }

  /**
  * @hint Configures the email content for the Single Send. Overwrites any properties that have previously been set.
  * @config is a struct containing email configuration details.
  */
  public any function emailConfig( required struct config ) {
    setEmail_config( variables.email_config );
    return this;
  }

  /**
  * @hint Convenience method for setting the subject of the email.
  * @subject The subject line of the Single Send. Do not include this field if you are using a design_id.
  */
  public any function subject( required string subject ) {
    variables.email_config["subject"] = subject;
    return this;
  }

  /**
  * @hint Convenience method for setting the HTML content of the email.
  * @html The HTML content of the Single Send. Do not include this field if you are using a design_id.
  */
  public any function htmlContent( required string html ) {
    variables.email_config["html_content"] = html;
    return this;
  }

  /**
  * @hint Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `htmlContent()`
  */
  public any function html( required string html ) {
    return htmlContent( html );
  }

  /**
  * @hint Convenience method for setting the plain text content of the email.
  * @plain The plain text content of the Single Send. Do not include this field if you are using a design_id.
  */
  public any function plainContent( required string plain ) {
    variables.email_config["plain_content"] = plain;
    return this;
  }

  /**
  * @hint Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `plainContent()`
  */
  public any function plain( required string plain ) {
    return plainContent( plain );
  }

  /**
  * @hint Convenience method for generating plain content from the HTML content.
  * @generate if true, the API will generate plain text content from the HTML content.
  * @default true
  */
  public any function generatePlainContent( required boolean generate ) {
    variables.email_config["generate_plain_content"] = generate;
    return this;
  }

  /**
  * @hint Convenience method for setting both html and plain at the same time. You can either pass in the HTML content, and both will be set from it (using a method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.
  */
  public any function plainFromHtml( string message = '' ) {

    if( !message.len() ) {

      var htmlContent = variables.email_config["html_content"];

      if( !htmlContent.len() ) {
        throw( 'The html content needs to be set prior to calling #getFunctionCalledName()# without the message argument.' );
      }

      plain( removeHTML( htmlContent ) );

    } else {
      plain( removeHTML( message ) );
      html( message );
    }

    return this;
  }

  /**
  * @hint Convenience method for setting the design ID for the email.
  * @designId can be used in place of the subject, HTML content, and/or plain content.
  */
  public any function designId( required string designId ) {
    variables.email_config["design_id"] = designId;
    return this;
  }

  /**
  * @hint Convenience method for setting the editor type for the email.
  * @editor can be "code" or "design".
  * @default "code"
  */
  public any function editor( required string editor ) {
    variables.email_config["editor"] = editor;
    return this;
  }

  /**
  * @hint The editor used in the UI. Because it defaults to `code`, it really only needs to be toggled to `design`
  */
  public any function useDesignEditor() {
    editor( 'design' );
    return this;
  }

  /**
  * @hint The editor used in the UI. It defaults to `code`, so this shouldn't be needed, but it's provided for consistency.
  */
  public any function useCodeEditor() {
    editor( 'code' );
    return this;
  }

  /**
  * @hint Convenience method for setting the suppression group ID.
  * @id The ID of the Suppression Group to allow recipients to unsubscribe. You must provide this or the custom_unsubscribe_url.
  */
  public any function suppressionGroupId( required numeric id ) {
    variables.email_config["suppression_group_id"] = id;
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `suppressionGroupId()`
  */
  public any function useSuppressionGroup( required numeric id ) {
    return suppressionGroupId( id );
  }

  /**
  * @hint Convenience method for setting a custom unsubscribe URL.
  * @url The URL allowing recipients to unsubscribe. You must provide this or the suppression_group_id.
  */
  public any function customUnsubscribeUrl( required string url ) {
    variables.email_config["custom_unsubscribe_url"] = url;
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `customUnsubscribeUrl()`
  */
  public any function useCustomUnsubscribeUrl( required string url ) {
    return customUnsubscribeUrl( url );
  }

  /**
  * @hint Convenience method for setting the sender ID.
  * @id The ID of the verified sender
  */
  public any function senderId( required numeric id ) {
    variables.email_config["sender_id"] = id;
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `senderId()`
  */
  public any function sender( required numeric id ) {
    return senderId( id );
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `senderId()`
  */
  public any function fromSender( required numeric id ) {
    return senderId( id );
  }

  /**
   * @hint Sets the IP Pool for the Single Send.
   * @pool The name of the IP Pool from which the Single Send emails are sent.
   */
  public any function ipPool( required string pool ) {
    variables.email_config["ip_pool"] = pool;
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `ipPool()`
  */
  public any function fromIpPool( required string pool ) {
    return ipPool( pool );
  }

  /**
  * @hint Assembles the JSON payload to send to the API. Generally, you shouldn't need to call this directly.
  */
  public string function build() {
    var body = {
      "name": getName(),
      "categories": getCategories(),
      "send_at": getSend_at(),
      "sent_to": getSent_to(),
      "email_config": getEmail_config()
    };

    return serializeJSON( body );
  }

  /** This could probably go in a separate utils CFC, but it's here for now
  * Removes All HTML from a string removing tags, script blocks, style blocks, and replacing special character code.
  *
  * @author Scott Bennett (scott@coldfusionguy.com)
  * @version 1, November 14, 2007
  */
  private string function removeHTML( required string source ){

    // Remove all spaces becuase browsers ignore them
    var result = ReReplace(trim(source), "[[:space:]]{2,}", " ","ALL");

    // Remove the header
    result = ReReplace(result, "<[[:space:]]*head.*?>.*?</head>","", "ALL");

    // remove all scripts
    result = ReReplace(result, "<[[:space:]]*script.*?>.*?</script>","", "ALL");

    // remove all styles
    result = ReReplace(result, "<[[:space:]]*style.*?>.*?</style>","", "ALL");

    // insert tabs in spaces of <td> tags
    result = ReReplace(result, "<[[:space:]]*td.*?>","  ", "ALL");

    // insert line breaks in places of <BR> and <LI> tags
    result = ReReplace(result, "<[[:space:]]*br[[:space:]]*>",chr(13), "ALL");
    result = ReReplace(result, "<[[:space:]]*li[[:space:]]*>",chr(13), "ALL");

    // insert line paragraphs (double line breaks) in place
    // if <P>, <DIV> and <TR> tags
    result = ReReplace(result, "<[[:space:]]*div.*?>",chr(13), "ALL");
    result = ReReplace(result, "<[[:space:]]*tr.*?>",chr(13), "ALL");
    result = ReReplace(result, "<[[:space:]]*p.*?>",chr(13), "ALL");

    // Remove remaining tags like <a>, links, images,
    // comments etc - anything thats enclosed inside < >
    result = ReReplace(result, "<.*?>","", "ALL");

    // replace special characters:
    result = ReReplace(result, "&nbsp;"," ", "ALL");
    result = ReReplace(result, "&bull;"," * ", "ALL");
    result = ReReplace(result, "&lsaquo;","<", "ALL");
    result = ReReplace(result, "&rsaquo;",">", "ALL");
    result = ReReplace(result, "&trade;","(tm)", "ALL");
    result = ReReplace(result, "&frasl;","/", "ALL");
    result = ReReplace(result, "&lt;","<", "ALL");
    result = ReReplace(result, "&gt;",">", "ALL");
    result = ReReplace(result, "&copy;","(c)", "ALL");
    result = ReReplace(result, "&reg;","(r)", "ALL");

    // Remove all others. More special character conversions
    // can be added above if needed
    result = ReReplace(result, "&(.{2,6});", "", "ALL");

    // Thats it.
    return result;

  }

}
