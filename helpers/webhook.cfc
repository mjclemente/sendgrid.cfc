component accessors="true" {

    property name="url" default="";
    property name="bounce" default=true type="boolean";
    property name="click" default=true type="boolean";
    property name="deferred" default=true type="boolean";
    property name="delivered" default=true type="boolean";
    property name="dropped" default=true type="boolean";
    property name="enabled" default=true type="boolean";
    property name="group_resubscribe" default=false type="boolean";
    property name="group_unsubscribe" default=false type="boolean";
    property name="open" default=true type="boolean";
    property name="processed" default=true type="boolean";
    property name="spam_report" default=true type="boolean";
    property name="unsubscribe" default=false type="boolean";
    property name="oauth_client_id" default="";
    property name="oauth_client_secret" default="";
    property name="oauth_token_url" default="";


    /**
    * @hint Only the URL can be set by the init.   The URL is the only required key needed to create a webhook.
    */
    public any function init( required string url ) {

        if ( arguments.keyExists( 'url' ) )
            this.url( arguments.url );

        return this;
    }

    /**
    * @hint Required. The URL that you want the event webhook to POST to.
    */
    public any function url( required string url ) {
      setUrl( arguments.url );
      return this;
    }

    /**
    * @hint Sets bounce flag - Receiving server could not or would not accept message.
    */
    public any function bounce( required boolean bounce ) {
        setBounce( bounce );
        return this;
    }

    /**
    * @hint Sets click flag - Recipient clicked on a link within the message. You need to enable Click Tracking for getting this type of event.
    */
    public any function click( required boolean click ) {
        setClick( click );
        return this;
    }

    /**
    * @hint Sets deferred flag - Recipient's email server temporarily rejected message.
    */
    public any function deferred( required boolean deferred ) {
        setDeferred( deferred );
        return this;
    }

    /**
    * @hint Sets delivered flag - Recipient's email server temporarily rejected message.
    */
    public any function delivered( required boolean delivered ) {
        setDelivered( delivered );
        return this;
    }

    /**
    * @hint Sets dropped flag - You may see the following drop reasons: Invalid SMTPAPI header, Spam Content (if spam checker app enabled), Unsubscribed Address, Bounced Address, Spam Reporting Address, Invalid, Recipient List over Package Quota
    */
    public any function dropped( required boolean dropped ) {
        setDropped( dropped );
        return this;
    }

    /**
    * @hint Sets enabled flag - Indicates if the event webhook is enabled.
    */
    public any function enabled( required boolean enabled ) {
        setEnabled( enabled );
        return this;
    }

    /**
    * @hint Sets group_resubscribe flag - Recipient resubscribes to specific group by updating preferences. You need to enable Subscription Tracking for getting this type of event.
    */
    public any function group_resubscribe( required boolean group_resubscribe ) {
        setGroup_resubscribe( group_resubscribe );
        return this;
    }

    /**
    * @hint Sets group_unsubscribe flag - Recipient unsubscribe from specific group, by either direct link or updating preferences. You need to enable Subscription Tracking for getting this type of event.
    */
    public any function group_unsubscribe( required boolean group_unsubscribe ) {
        setGroup_unsubscribe( group_unsubscribe );
        return this;
    }

    /**
    * @hint Sets open flag - Recipient has opened the HTML message. You need to enable Open Tracking for getting this type of event.
    */
    public any function open( required boolean open ) {
        setOpen( open );
        return this;
    }

    /**
    * @hint Sets processed flag - Message has been received and is ready to be delivered.
    */
    public any function processed( required boolean processed ) {
        setProcessed( processed );
        return this;
    }

    /**
    * @hint Sets spam_report flag - Recipient marked a message as spam.
    */
    public any function spam_report( required boolean spam_report ) {
        setSpam_report( spam_report );
        return this;
    }

    /**
    * @hint Sets unsubscribe flag - Recipient clicked on message's subscription management link. You need to enable Subscription Tracking for getting this type of event.
    */
    public any function unsubscribe( required boolean unsubscribe ) {
        setUnsubscribe( unsubscribe );
        return this;
    }

    /**
    * @hint Sets the oath client id - The client ID Twilio SendGrid sends to your OAuth server or service provider to generate an OAuth access token. When passing data in this field, you must also include the oauth_token_url field.
    */
    public any function oauth_client_id( required string oauth_client_id ) {
        setOauth_client_id( oauth_client_id );
        return this;
    }

    /**
    * @hint Set the oath client secret - This secret is needed only once to create an access token. SendGrid will store this secret, allowing you to update your Client ID and Token URL without passing the secret to SendGrid again. When passing data in this field, you must also include the oauth_client_id and oauth_token_url fields.
    */
    public any function oauth_client_secret( required string oauth_client_secret ) {
        setOauth_client_secret( oauth_client_secret );
        return this;
    }

    /**
    * @hint Set the oath token URL - The URL where Twilio SendGrid sends the Client ID and Client Secret to generate an access token. This should be your OAuth server or service provider. When passing data in this field, you must also include the oauth_client_id field.
    */
    public any function oauth_token_url( required string oauth_token_url ) {
        setOauth_token_url( oauth_token_url );
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
            switch (property.key) {
                case "bounce": case "click": case "deferred": case "delivered": case "dropped": case "enabled": case "group_resubscribe": case "group_unsubscribe": case "open": case "processed": case "spam_report": case "unsubscribe":
                    var value = property.value;
                    break;
                default:
                    var value = serializeJSON( property.value );
            }
          body &= '"#property.key#": ' & value & '#index NEQ count ? "," : ""#';
        }
      );
      return '{' & body & '}';
    }

    /**
    * @hint converts the array of properties to an array of their keys/values, while filtering those that have not been set
    */
    private array function getPropertyValues(boolean excludeBooleanValues = false) {

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
        else if ( isBoolean( item.value ) AND excludeBooleanValues )
            return false;
        else if ( isBoolean( item.value ) )
            return true;
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
