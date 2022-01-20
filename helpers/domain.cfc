component accessors="true" {

    property name="domain" default="";
    property name="subdomain" default="";
    property name="username" default="";
    property name="ips" default="";
    property name="custom_spf" default=false type="boolean";
    property name="default" default=false type="boolean";
    property name="automatic_security" default=false type="boolean";
    property name="custom_dkim_selector" default="";

    /**
    * @hint Allow all values to be set by the init. The domain name is the only required key needed to create an authenticated domain.
    */
    public any function init( string domain, string subdomain, string username, array ips, boolean custom_spf, boolean default, boolean automatic_security, string custom_dkim_selector ) {

        if ( arguments.keyExists( 'domain' ) )
            this.domain( arguments.domain );

        if ( arguments.keyExists( 'subdomain' ) )
            this.subdomain( arguments.subdomain );

        if ( arguments.keyExists( 'username' ) )
            this.username( arguments.username );

        if ( isArray( ips ) )
            setIps( arguments.ips );
        else
            setIps( [] );

        if ( arguments.keyExists( 'custom_spf' ) )
            this.custom_spf( arguments.custom_spf );

        if ( arguments.keyExists( 'default' ) )
            this.default( arguments.default );

        if ( arguments.keyExists( 'automatic_security' ) )
            this.automatic_security( arguments.automatic_security );

        if ( arguments.keyExists( 'custom_dkim_selector' ) )
            this.custom_dkim_selector( arguments.custom_dkim_selector );

        return this;
    }

    /**
    * @hint Required. Sets the domain being authenticated.
    */
    public any function domain( required string domain ) {
      setDomain( domain );
      return this;
    }

    /**
    * @hint Sets the subdomain to use for this authenticated domain
    */
    public any function subdomain( required string subdomain ) {
      setSubdomain( subdomain );
      return this;
    }

    /**
    * @hint Sets the username associated with this domain.
    */
    public any function username( required string username ) {
        setUsername( username );
        return this;
    }

    /**
    * @hint Specify whether to use a custom SPF or allow SendGrid to manage your SPF. This option is only available to authenticated domains set up for manual security.
    */
    public any function custom_spf( required boolean custom_spf ) {
        setCustom_spf( custom_spf );
        return this;
    }

    /**
    * @hint Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain.
    */
    public any function default( required boolean default ) {
        setDefault( default );
        return this;
    }

    /**
    * @hint Whether to allow SendGrid to manage your SPF records, DKIM keys, and DKIM key rotation.
    */
    public any function automatic_security( required boolean automatic_security ) {
        setAutomatic_security( automatic_security );
        return this;
    }

    /**
    * @hint Sets a custom DKIM selector. Accepts three letters or numbers.
    */
    public any function custom_dkim_selector( required string custom_dkim_selector ) {
        setCustom_dkim_selector( custom_dkim_selector );
        return this;
    }

    /**
    * @hint Set an array of ips you would like associated to this domain. If ips are already set, this overwrites them.
    * @ips can be passed in as an array or comma separated list. Lists will be converted to arrays
    */
    public any function ips( required any ips ) {
      if ( isArray( ips ) )
        setIps( ips );
      else
        setIps( ips.listToArray() );

      return this;
    }

    /**
    * @hint Appends a single ip to the ips array
    */
    public any function addIp( required string ip ) {
      variables.ips.append( ip );
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
                case "ips":
                    var value = serializeIps( property.value );
                    break;
                case "custom_spf": case "default": case "automatic_security":
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

    private string function serializeIps( required array data ) {
      var serializedData = data.reduce(
        function( result, item, index ) {
          if ( result.len() ) result &= ',';

          return result & '"#item#"';
        }, ''
      );

      return '[' & serializedData & ']';
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
