/**
* sendgrid.cfc
* Copyright 2017-2019 Matthew Clemente, John Berquist
* Licensed under MIT (https://github.com/mjclemente/sendgrid.cfc/blob/master/LICENSE)
*/
component accessors="true" {

  property name="title" default="";
  property name="subject" default="";
  property name="sender_id" default="0";
  property name="list_ids" default="";
  property name="segment_ids" default="";
  property name="categories" default="";
  property name="suppression_group_id" default="0";
  property name="custom_unsubscribe_url" default="";
  property name="ip_pool" default="";
  property name="html_content" default="";
  property name="plain_content" default="";
  property name="editor" default="";

  /**
  * @hint You don't need to init the campaign with a title, but it's an option. The title is the only parameter required to create a campaign. More are required to send.
  */
  public any function init( string title ) {

    setList_ids( [] );
    setSegment_ids( [] );
    setCategories( [] );

    if ( arguments.keyExists( 'title' ) )
      this.title( title );

    return this;
  }

  /**
  * @hint Sets the display title of your campaign. This will be viewable by you in the Marketing Campaigns UI. This is the only required field for creating a campaign
  */
  public any function title( required string title ) {
    setTitle( title );
    return this;
  }

  /**
  * @hint Sets the subject of your campaign that your recipients will see.
  */
  public any function subject( required string subject ) {
    setSubject( subject );
    return this;
  }

  /**
  * @hint Sets who the email is "from", using the ID of the "sender" identity that you have created.
  */
  public any function sender( required numeric id ) {
    setSender_id( id );
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `sender()`
  */
  public any function fromSender( required numeric id ) {
    return sender( id );
  }

  /**
  * @hint Sets the IDs of the lists you are sending this campaign to. Note that you can have both segment IDs and list IDs. If any list Ids were previously set, this method overwrites them.
  * @lists can be passed in as an array or comma separated list. Lists will be converted to arrays
  */
  public any function useLists( required any lists ) {
    if ( isArray( lists ) )
      setList_ids( lists );
    else
      setList_ids( lists.listToArray() );

    return this;
  }

  /**
  * @hint Appends a single list Id to the array of List Ids that this campaign is being sent to.
  */
  public any function useList( required numeric id ) {
    variables.list_ids.append( id );
    return this;
  }

  /**
  * @hint Sets the segment IDs that you are sending this list to. Note that you can have both segment IDs and list IDs. If any segment Ids were previously set, this method overwrites them.
  * @segments can be passed in as an array or comma separated list. Lists will be converted to arrays
  */
  public any function useSegments( required any segments ) {
    if ( isArray( segments ) )
      setSegment_ids( segments );
    else
      setSegment_ids( segments.listToArray() );

    return this;
  }

  /**
  * @hint Appends a single segment Id to the array of Segment Ids that this campaign is being sent to.
  */
  public any function useSegment( required numeric id ) {
    variables.segment_ids.append( id );

    return this;
  }

  /**
  * @hint Set an array of categories you would like associated to this campaign. If categories are already set, this overwrites them.
  * @categories can be passed in as an array or comma separated list. Lists will be converted to arrays
  */
  public any function categories( required any categories ) {
    if ( isArray( categories ) )
      setCategories( categories );
    else
      setCategories( categories.listToArray() );

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
  * @hint Assigns the suppression group that this marketing email belongs to, allowing recipients to opt-out of emails of this type. Note that you cannot provide both a suppression group Id and a custom unsubscribe url. The two are mutually exclusive.
  * @id is the supression group Id
  */
  public any function suppressionGroupId( required numeric id ) {
    setSuppression_group_id( id );
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `suppressionGroupId()`
  */
  public any function useSuppressionGroup( required numeric id ) {
    return suppressionGroupId( id );
  }

  /**
  * @hint This is the url of the custom unsubscribe page that you provide for customers to unsubscribe from mailings. Using this takes the place of having SendGrid manage your suppression groups.
  * @uri is the web address where you're hosting your custom unsubscribe page
  */
  public any function customUnsubscribeUrl( required string uri ) {
    setCustom_unsubscribe_url( uri );
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `customUnsubscribeUrl()`
  */
  public any function useCustomUnsubscribeUrl( required string uri ) {
    return customUnsubscribeUrl( uri );
  }

  /**
  * @hint The pool of IPs that you would like to send this email from. Note that your SendGrid plan must include dedicated IPs in order to use this.
  * @name is the name of the IP pool.
  */
  public any function ipPool( required string name ) {
    setIp_pool( name );
    return this;
  }

  /**
  * @hint Included in order to provide a more fluent interface; delegates to `ipPool()`
  */
  public any function fromIpPool( required string name ) {
    return ipPool( name );
  }

  /**
  * @hint Convenience method for adding the text/html content
  */
  public any function html( required string message ) {
    setHtml_content( message );
    return this;
  }

  /**
  * @hint Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `html()`
  */
  public any function htmlContent( required string message ) {
    return html( message );
  }

  /**
  * @hint Convenience method for adding the text/plain content
  */
  public any function plain( required string message ) {
    setPlain_content( message );
    return this;
  }

  /**
  * @hint Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `plain()`
  */
  public any function plainContent( required string message ) {
    return plain( message );
  }

  /**
  * @hint Convenience method for setting both html and plain at the same time. You can either pass in the HTML content, and both will be set from it (using a method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.
  */
  public any function plainFromHtml( string message = '' ) {

    if ( !message.len() ) {

      var htmlContent = getHtml_content();

      if ( !htmlContent.len() ) throw( 'The html content needs to be set prior to calling #getFunctionCalledName()# without the message argument.' );

      plain( removeHTML( htmlContent ) );

    } else {
      plain( removeHTML( message ) );
      html( message );
    }

    return this;
  }

  /**
  * @hint The editor used in the UI. Because it defaults to `code`, it really only needs to be toggled to `design`
  */
  public any function useDesignEditor() {
    setEditor( 'design' );
    return this;
  }

  /**
  * @hint The editor used in the UI. It defaults to `code`, so this shouldn't be needed, but it's provided for consistency.
  */
  public any function useCodeEditor() {
    setEditor( 'code' );
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

        var value = property.key != 'categories' ? serializeJSON( property.value ) : serializeCategories( property.value );
        body &= '"#property.key#": ' & value & '#index NEQ count ? "," : ""#';
      }
    );

    return '{' & body & '}';
  }

  private string function serializeCategories( required array data ) {
    var serializedData = data.reduce(
      function( result, item, index ) {
        if ( result.len() ) result &= ',';

        return result & '"#item#"';
      }, ''
    );

    return '[' & serializedData & ']';
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
