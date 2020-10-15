/**
* sendgrid.cfc
* Copyright 2017-2020 Matthew Clemente, John Berquist
* Licensed under MIT (https://github.com/mjclemente/sendgrid.cfc/blob/master/LICENSE)
*/
component output="false" displayname="SendGrid.cfc"  {

  variables._sendgridcfc_version = '0.10.0';

  public any function init(
    string apiKey = '',
    string emailValidationApiKey = '',
    string baseUrl = "https://api.sendgrid.com/v3",
    boolean forceTestMode = false,
    numeric httpTimeout = 50,
    boolean includeRaw = false ) {

    structAppend( variables, arguments );

    //map sensitive args to env variables or java system props
    var secrets = {
      'apiKey': 'SENDGRID_API_KEY',
      'emailValidationApiKey': 'SENDGRID_EMAIL_VALIDATION_API_KEY'
    };
    var system = createObject( 'java', 'java.lang.System' );

    for ( var key in secrets ) {
      //arguments are top priority
      if ( variables[ key ].len() ) continue;

      //check environment variables
      var envValue = system.getenv( secrets[ key ] );
      if ( !isNull( envValue ) && envValue.len() ) {
        variables[ key ] = envValue;
        continue;
      }

      //check java system properties
      var propValue = system.getProperty( secrets[ key ] );
      if ( !isNull( propValue ) && propValue.len() ) {
        variables[ key ] = propValue;
      }
    }

    variables.utcBaseDate = dateAdd( "l", createDate( 1970,1,1 ).getTime() * -1, createDate( 1970,1,1 ) );

    return this;
  }

  /**
  * Mail Send
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/index.html
  */

  /**
  * @hint Send email, using SendGrid's REST API
  * @mail must be an instance of the `helpers.mail` component
  */
  public struct function sendMail( required component mail ) {
    if ( variables.forceTestMode ) mail.enableSandboxMode();

    return apiCall( 'POST', '/mail/send', {}, mail.build() );
  }


  /**
  * API Keys API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/API_Keys/index.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/api-keys/retrieve-all-api-keys-belonging-to-the-authenticated-user
  * @hint Retrieve all API Keys belonging to the authenticated user
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function listKeys( string on_behalf_of = '', numeric limit = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( limit ) params[ 'limit' ] = limit;

    return apiCall( 'GET', "/api_keys", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/api-keys/retrieve-an-existing-api-key
  * @hint Retrieve an existing API Key
  * @api_key_id The ID of the API Key for which you are requesting information. This is everything in the API key after the SG and before the second dot, so if this were an example API key: SG.aaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbb, your api_key_id would be aaaaaaaaaaaaaa
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call (Optional)
  */
  public struct function getAPIKey( required string api_key_id, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/api_keys/#api_key_id#", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/api-keys/create-api-keys
  * @hint Create API keys
  * @name this should be an the name of your new key
  * @scopes The individual permissions that you are giving to this API Key.  https://sendgrid.api-docs.io/v3.0/how-to-use-the-sendgrid-v3-api/api-authorization
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call (Optional)
  */
  public struct function createAPIKey( required string name, array scopes = ['mail.send'], string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    // Build JSON body
    body = '{"name":"#arguments.name#","scopes":#serializeJSON(arguments.scopes)#}';

    return apiCall( 'POST', '/api_keys', params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/api-keys/delete-api-keys
  * @hint Delete API keys
  * @api_key_id The ID of the API Key for which you are requesting information. This is everything in the API key after the SG and before the second dot, so if this were an example API key: SG.aaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbb, your api_key_id would be aaaaaaaaaaaaaa
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call (Optional)
  */
  public struct function deleteAPIKey( required string api_key_id, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'DELETE', "/api_keys/#api_key_id#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/api-keys/update-api-keys
  * @hint This endpoint allows you to update the name of an existing API Key.
  * @api_key_id The ID of the API Key for which you are updating. This is everything in the API key after the SG and before the second dot, so if this were an example API key: SG.aaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbb, your api_key_id would be aaaaaaaaaaaaaa
  * @name The new name for the API Key for which you are updating.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call (Optional)
  */
  public struct function updateAPIKeyName( required string api_key_id, required string name,  string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    // Build JSON body
    body = '{"name":"#arguments.name#"}';

    return apiCall( 'PATCH', "/api_keys/#api_key_id#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/api-keys/update-the-name-and-scopes-of-an-api-key
  * @hint This endpoint allows you to update the name and scopes of a given API key.
  * @api_key_id The ID of the API Key for which you are updating. This is everything in the API key after the SG and before the second dot, so if this were an example API key: SG.aaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbb, your api_key_id would be aaaaaaaaaaaaaa
  * @scopes The individual permissions that you are giving to this API Key.  https://sendgrid.api-docs.io/v3.0/how-to-use-the-sendgrid-v3-api/api-authorization    (Optional)  defaults to mail.send
  * @name The updated name for the API Key for which you are updating.  (required)
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call (Optional)
  */
  public struct function updateAPIKey( required string api_key_id, required string name, array scopes = ['mail.send'],  string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    // Build JSON body
    body = '{"scopes":#serializeJSON(arguments.scopes)#}';

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( len(arguments.name) gt 0)  body = '{"name":"#arguments.name#","scopes":#serializeJSON(arguments.scopes)#}';;

    return apiCall( 'PUT', "/api_keys/#api_key_id#", params, body, headerparams );
  }



  /**
  * Subusers API
  * https://sendgrid.com/docs/ui/account-and-settings/subusers/
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/list-all-subusers
  * @hint Retrieve all API Keys belonging to the authenticated user
  * @username The username of the subuser to return.  (Optional)
  * @limit The number of results you would like to get in each request. (Optional)
  * @offset The number of subusers to skip (Optional)
  */
  public struct function listAllSubusers( string username = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) params[ 'username' ] = arguments.username;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/subusers", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-monitor-settings-for-a-subuser
  * @hint Retrieve monitor settings for a subuser
  * @subuser_name The name of the subuser to return.
  */
  public struct function getSubuserMonitorSettings( required string subuser_name ) {
    var params = {};
    var body = {};
    var headerparams = {};

    return apiCall( 'GET', "/subusers/#arguments.subuser_name#/monitor", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-subuser-reputations
  * @hint Retrieve Subuser Reputations
  * @username The name of the subuser which you are obtaining the reputation score.
  */
  public struct function getSubuserReputations( required string username ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) params[ 'usernames' ] = arguments.username;

    return apiCall( 'GET', "/subusers/reputations", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-the-monthly-email-statistics-for-a-single-subuser
  * @hint Retrieve the monthly email statistics for a single subuser
  * @subuser_name The name of the subuser to return.
  * @date The date the stastics were gathered.   Format: YYYY-MM-DD
  * @sort_by_metric The metric that you want to sort by.  (Optional)
  * @sort_by_direction The direction you want to sort. (Optional)
  * @limit The number of results you would like to get in each request. (Optional)
  * @offset The number of subusers to skip (Optional)
  */
  public struct function getSubuserMonthlyStats( required string subuser_name, required string date = '', string sort_by_metric = '', string sort_by_direction = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if (len(arguments.date) gt 0) params[ 'date' ] = dateFormat(arguments.date, 'YYYY-mm-dd');
    else params[ 'date' ] = dateFormat(now(), 'YYYY-mm-dd');

    if ( len(arguments.sort_by_metric) gt 0 ) params[ 'sort_by_metric' ] = arguments.sort_by_metric;
    if ( len(arguments.sort_by_direction) gt 0 ) params[ 'sort_by_direction' ] = arguments.sort_by_direction;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/subusers/#arguments.subuser_name#/stats/monthly", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-monthly-stats-for-all-subusers
  * @hint Retrieve monthly stats for all subusers
  * @date The date the stastics were gathered.   Format: YYYY-MM-DD
  * @subuser A substring search of your subusers.  (Optional)
  * @sort_by_metric The metric that you want to sort by.  (Optional)
  * @sort_by_direction The direction you want to sort. (Optional)
  * @limit The number of results you would like to get in each request. (Optional)
  * @offset The number of subusers to skip (Optional)
  */
  public struct function getSubuserMonthlyStatsAllSubusers( required string date = '', string subuser = '', string sort_by_metric = '', string sort_by_direction = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if (len(arguments.date) gt 0) params[ 'date' ] = dateFormat(arguments.date, 'YYYY-mm-dd');
    else params[ 'date' ] = dateFormat(now(), 'YYYY-mm-dd');

    if ( len(arguments.subuser) gt 0 ) params[ 'subuser' ] = arguments.subuser;
    if ( len(arguments.sort_by_metric) gt 0 ) params[ 'sort_by_metric' ] = arguments.sort_by_metric;
    if ( len(arguments.sort_by_direction) gt 0 ) params[ 'sort_by_direction' ] = arguments.sort_by_direction;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/subusers/stats/monthly", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-the-totals-for-each-email-statistic-metric-for-all-subusers
  * @hint Retrieve the totals for each email statistic metric for all subusers.
  * @start_date The starting date of the statistics to retrieve. Must follow format YYYY-MM-DD.
  * @end_date The end date of the statistics to retrieve. Defaults to today. Must follow format YYYY-MM-DD.
  * @sort_by_metric The metric that you want to sort by.  (Optional)
  * @sort_by_direction The direction you want to sort. (Optional)
  * @aggregated_by How to group the statistics. Defaults to today. Must follow format YYYY-MM-DD. (Optional)
  * @limit The number of results you would like to get in each request. (Optional)
  * @offset The number of subusers to skip (Optional)
  */
  public struct function getAllSubuserTotals( required string start_date, string end_date = '', string sort_by_metric = '', string sort_by_direction = '', string aggregated_by = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    params[ 'start_date' ] = arguments.start_date;

    if (len(arguments.end_date) gt 0) params[ 'end_date' ] = arguments.end_date;
    if (len(arguments.aggregated_by) gt 0) params[ 'aggregated_by' ] = arguments.aggregated_by;
    if ( len(arguments.sort_by_metric) gt 0 ) params[ 'sort_by_metric' ] = arguments.sort_by_metric;
    if ( len(arguments.sort_by_direction) gt 0 ) params[ 'sort_by_direction' ] = arguments.sort_by_direction;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/subusers/stats/sums", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-email-statistics-for-your-subusers
  * @hint Retrieve email statistics for your subusers.
  * @subusers The subuser you want to retrieve statistics for. You may include this parameter up to 10 times to retrieve statistics for multiple subusers.  (Optional)
  * @start_date The starting date of the statistics to retrieve. Must follow format YYYY-MM-DD.
  * @end_date The end date of the statistics to retrieve. Defaults to today. Must follow format YYYY-MM-DD.
  * @sort_by_metric The metric that you want to sort by.  (Optional)
  * @sort_by_direction The direction you want to sort. (Optional)
  * @aggregated_by How to group the statistics. Defaults to today. Must follow format YYYY-MM-DD. (Optional)
  * @limit The number of results you would like to get in each request. (Optional)
  * @offset The number of subusers to skip (Optional)
  */
  public struct function getSubuserStats( required string subusers, required string start_date, string end_date = '', string sort_by_metric = '', string sort_by_direction = '', string aggregated_by = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    params[ 'subusers' ] = arguments.subusers;
    params[ 'start_date' ] = arguments.start_date;

    if (len(arguments.end_date) gt 0) params[ 'end_date' ] = arguments.end_date;
    if (len(arguments.aggregated_by) gt 0) params[ 'aggregated_by' ] = arguments.aggregated_by;
    if ( len(arguments.sort_by_metric) gt 0 ) params[ 'sort_by_metric' ] = arguments.sort_by_metric;
    if ( len(arguments.sort_by_direction) gt 0 ) params[ 'sort_by_direction' ] = arguments.sort_by_direction;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/subusers/stats", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/create-subuser
  * @hint Create Subuser
  * @username this should be an the name of your new key
  * @email this should be an the name of your new key
  * @password this should be an the name of your new key
  * @ips The individual permissions that you are giving to this API Key.  https://sendgrid.api-docs.io/v3.0/how-to-use-the-sendgrid-v3-api/api-authorization
  */
  public struct function createSubuser( required string username, required string email, required string password, required array ips = [] ) {
    var params = {};
    var body = {};
    var headerparams = {};

    // Build JSON body
    /*
    {
      "username": "John@example.com",
      "email": "John@example.com",
      "password": "johns_password",
      "ips": [
        "1.1.1.1",
        "2.2.2.2"
      ]
    }
    */
    body = '{"username":"#arguments.username#","email":"#arguments.email#","password":"#arguments.password#","ips":#serializeJSON(arguments.ips)#}';

    return apiCall( 'POST', '/subusers', params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/delete-a-subuser
  * @hint Delete a subuser
  * @subuser_name The subuser name to delete
  */
  public struct function deleteSubuser( required string subuser_name ) {
    var params = {};
    var body = {};
    var headerparams = {};

    return apiCall( 'DELETE', "/subusers/#arguments.subuser_name#", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/subusers-api/update-ips-assigned-to-a-subuser
  * @hint Update IPs assigned to a subuser
  * @subuser_name The subuser to update
  * @ips The IP addresses that are assigned to the subuser.
  */
  public struct function updateSubuserIPs( required string subuser_name, required array ips = [] ) {
    var params = {};
    var body = {};
    var headerparams = {};

    body = '#serializeJSON(arguments.ips)#';

    return apiCall( 'PUT', "/subusers/#arguments.subuser_name#/ips", params, body, headerparams );
  }


  /**
  * Link branding
  * https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-all-link-branding
  */


  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-all-link-branding
  * @hint Retrieve all branded links
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function listBrandedLinks( string on_behalf_of = '', numeric limit = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( limit ) params[ 'limit' ] = limit;

    return apiCall( 'GET', "/whitelabel/links", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-branded-link
  * @hint Retrieve a branded link
  * @id The id of the branded link you want to retrieve.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function getBrandedLink( required numeric id = 0, string on_behalf_of = '', numeric limit = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( limit ) params[ 'limit' ] = limit;

    return apiCall( 'GET', "/whitelabel/links/#arguments.id#", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-the-default-branded-link
  * @hint Retrieve the default branded link
  * @domain The domain to match against when finding a corresponding branded link.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function getDefaultBrandedLink( string domain = '', string on_behalf_of = '', numeric limit = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( len(arguments.domain) gt 0 ) params[ 'domain' ] = arguments.domain;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;

    return apiCall( 'GET', "/whitelabel/links/default", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-a-subusers-branded-link
  * @hint Retrieve a subusers branded link
  * @username The username of the subuser to retrieve associated branded links for.
  */
  public struct function getSubuserBrandedLink( required string username = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) params[ 'username' ] = arguments.username;

    return apiCall( 'GET', "/whitelabel/links/subuser", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/create-a-link-branding
  * @hint Create a branded link
  * @domain The root domain for your subdomain that you are creating the link branding for. This should match your FROM email address.
  * @subdomain The subdomain to create the link branding for. Must be different from the subdomain you used for authenticating your domain.
  * @default Indicates if you want to use this link branding as the fallback, or as the default.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function createLinkBranding( required string domain = '', string subdomain = '', string default = 'false', string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    /*
      {
        "domain": "example.com",
        "subdomain": "mail",
        "default": true
      }
    */

    // Build JSON body
    body = '{"domain":"#arguments.domain#","subdomain":"#arguments.subdomain#","default":#arguments.default#}';

    return apiCall( 'POST', "/whitelabel/links", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/delete-a-branded-link
  * @hint Delete a branded link
  * @id The id of the branded link you want to delete.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function deleteBrandedLink( required numeric id = 0, string on_behalf_of = '', numeric limit = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( limit ) params[ 'limit' ] = limit;

    return apiCall( 'DELETE', "/whitelabel/links/#arguments.id#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/validate-a-branded-link
  * @hint Validate a branded link
  * @id The id of the branded link you want to delete.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function validateLinkBranding(  required numeric id = 0, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'POST', "/whitelabel/links/#arguments.id#/validate", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/associate-a-branded-link-with-a-subuser
  * @hint Associate a branded link with a subuser
  * @id The id of the branded link you want to delete.
  * @username The username of the subuser account that you want to associate the branded link with.
  */
  public struct function associateLinkBranding( required numeric link_id = 0, required string username = '') {
    var params = {};
    var body = {};
    var headerparams = {};

    /*
    {
      "username": "jane@example.com"
    }
    */
    // Build JSON body
    body = '{"username":"#arguments.username#"}';

    return apiCall( 'POST', "/whitelabel/links/#arguments.id#/subuser", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/link-branding/disassociate-link-branding-from-a-subuser
  * @hint Disassociate link branding from a subuser
  * @id The id of the branded link you want to delete.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  */
  public struct function disassociateBrandedLink( required string username ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) params[ 'username' ] = arguments.username;

    return apiCall( 'DELETE', "/whitelabel/links/subuser", params, body, headerparams );
  }



  /**
  * Domain Authentication
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/list-all-authenticated-domains
  */


  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/list-all-authenticated-domains
  * @hint List all authenticated domains
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  * @limit limit the number of rows returned.
  * @offset Paging offset.
  * @exclude_subusers Exclude subuser domains from the result.
  * @username The username associated with an authenticated domain.
  * @domain Search for authenticated domains.
  */
  public struct function listAllDomains( string on_behalf_of = '', numeric limit = 0, numeric offset = 0, boolean exclude_subusers = false, string username = '', string domain = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;
    params[ 'exclude_subusers' ] = arguments.exclude_subusers;
    if ( len(arguments.username) gt 0 ) params[ 'username' ] = arguments.username;
    if ( len(arguments.domain) gt 0 ) params[ 'domain' ] = arguments.domain;

    return apiCall( 'GET', "/whitelabel/domains", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/retrieve-a-authenticated-domain
  * @hint Retrieve an authenticated domain
  * @domain_id The id of the branded link you want to retrieve.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getAuthenticatedDomain( required numeric domain_id = 0, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/whitelabel/domains/#arguments.domain_id#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/authenticate-a-domain
  * @hint Authenticate a domain
  * @domain Domain being authenticated.
  * @subdomain The subdomain to use for this authenticated domain
  * @username The username associated with this domain.
  * @ips The IP addresses that will be included in the custom SPF record for this authenticated domain.
  * @custom_spf Specify whether to use a custom SPF or allow SendGrid to manage your SPF. This option is only available to authenticated domains set up for manual security.
  * @default Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain.
  * @automatic_security Whether to allow SendGrid to manage your SPF records, DKIM keys, and DKIM key rotation.
  * @custom_dkim_selector Add a custom DKIM selector. Accepts three letters or numbers.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function createAuthenticatedDomain( required string domain, string subdomain = '', string username = '', array ips = [],
                                                    boolean custom_spf = false, boolean default = false, boolean automatic_security = false,
                                                    string custom_dkim_selector = '', string on_behalf_of = '') {
    var params = {};
    var body = {};
    var headerparams = {};

    /*
      {
        "domain": "example.com",
        "subdomain": "news",
        "username": "john@example.com",
        "ips": [
          "192.168.1.1",
          "192.168.1.2"
        ],
        "custom_spf": true,
        "default": true,
        "automatic_security": false,
        "custom_dkim_selector": "tes"
      }
    */
    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;


    // Build JSON body
    local.domain = createObject("modules.sendgridcfc.helpers.domain").init( domain=arguments.domain, subdomain=arguments.subdomain, username=arguments.username, ips=arguments.ips,
                                                                            custom_spf=arguments.custom_spf, default=arguments.default, automatic_security=arguments.automatic_security,
                                                                            custom_dkim_selector=arguments.custom_dkim_selector );

    body = local.domain.build();
    return apiCall( 'POST', "/whitelabel/domains", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/update-an-authenticated-domain
  * @hint Update an authenticated domain
  * @domain_id Domain ID to be updated.
  * @custom_spf Specify whether to use a custom SPF or allow SendGrid to manage your SPF. This option is only available to authenticated domains set up for manual security.
  * @default Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function updateAuthenticatedDomain( required numeric domain_id = 0, boolean custom_spf = false, boolean default = false, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    /*
      {
        "default": false,
        "custom_spf": true
      }
    */
    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    // Build JSON body  -  May create a helper later  ****** NEED to finish
    body = '{"default":#arguments.default#, "custom_spf":#arguments.custom_spf#}';

    return apiCall( 'PATCH', "/whitelabel/domains/#arguments.domain_id#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/delete-an-authenticated-domain
  * @hint Delete an authenticated domain.
  * @domain_id The id of the branded link you want to delete.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function deleteAuthenticatedDomain( required numeric domain_id = 0, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'DELETE', "/whitelabel/domains/#arguments.domain_id#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/get-the-default-authentication
  * @hint Get the default authentication
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getDefaultAuthenticatedDomain( string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/whitelabel/domains/default", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/add-an-ip-to-an-authenticated-domain
  * @hint Add an IP to an authenticated domain
  * @domain_id Domain ID to be updated.
  * @ip IP to associate with the domain. Used for manually specifying IPs for custom SPF.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function addIPAuthenticatedDomain( required numeric domain_id, required string ip, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};
    /*
      {
        "ip": "192.168.0.1"
      }
    */
    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    // Build JSON body
    body = '{"ip":"#arguments.ip#"}';

    return apiCall( 'POST', "/whitelabel/domains/#arguments.domain_id#/ips", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/remove-an-ip-from-an-authenticated-domain
  * @hint Remove an IP from an authenticated domain.
  * @domain_id 	ID of the domain to delete the IP from.
  * @ip IP to remove from the domain.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function deleteIPForAuthenticatedDomain( required numeric domain_id, required string ip, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'DELETE', "/whitelabel/domains/#arguments.domain_id#/ips/#arguments.ip#", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/validate-a-domain-authentication
  * @hint Validate a domain authentication.
  * @domain_id ID of the domain to validate.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function validateAuthenticatedDomain( required numeric domain_id, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'POST', "/whitelabel/domains/#arguments.domain_id#/validate", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/list-the-authenticated-domain-associated-with-the-given-user
  * @hint List the authenticated domain associated with the given user.
  * @username Username for the subuser to find associated authenticated domain.
  */
  public struct function listSubuserAuthenticatedDomain( required string username ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) params[ 'username' ] = arguments.username;

    return apiCall( 'GET', "/whitelabel/domains/subuser", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/disassociate-an-authenticated-domain-from-a-given-user
  * @hint Disassociate a authenticated domain from a given user.
  * @username Username for the subuser to find associated authenticated domain.
  */
  public struct function disassociateSubuserAuthenticatedDomain( required string username ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) params[ 'username' ] = arguments.username;

    return apiCall( 'DELETE', "/whitelabel/domains/subuser", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/domain-authentication/associate-an-authenticated-domain-with-a-given-user
  * @hint Associate a authenticated domain with a given user.
  * @domain_id 	ID of the authenticated domain to associate with the subuser.
  * @username Username to associate with the authenticated domain.
  */
  public struct function associateSubuserWithAuthenticatedDomain( required numeric domain_id, required string username ) {
    var params = {};
    var body = {};
    var headerparams = {};

    /*
    {
      "username": "jane@example.com"
    }
    */
    // Build JSON body
    body = '{"username":"#arguments.username#"}';

    return apiCall( 'POST', "/whitelabel/domains/#arguments.domain_id#/subuser", params, body, headerparams );
  }




  /**
  * IP Addresses
  * https://sendgrid.api-docs.io/v3.0/ip-addresses
  */


  /**
  * https://sendgrid.api-docs.io/v3.0/ip-addresses/ips-add
  * @hint Add IPs
  * @count 	The amount of IPs to add to the account.
  * @subusers Array of usernames to be assigned a send IP.
  * @warmpup Whether or not to warmup the IPs being added.
  */
  public struct function addIPs( required numeric count = 0, array subusers = [], boolean warmpup = false ) {
    var params = {};
    var body = {};
    var headerparams = {};
    /*
      {
        "count": 90323478,
        "subusers": [
          "subuser1",
          "subuser2"
        ],
        "warmup": true
      }
    */
    // Build JSON body
    body = '{"count":#arguments.count#,"subusers":#serializeJSON(arguments.subusers)#,"warmup":#arguments.warmup#}';

    return apiCall( 'POST', "/ips", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-addresses/ips-remaining
  * @hint Get remaining IPs count
  */
  public struct function getIPsRemaining( ) {
    return apiCall( 'GET', "/ips/remaining");
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/ip-addresses/retrieve-all-ip-addresses
  * @hint Retrieve all IP addresses
  * @ip The IP address to get
  * @subuser The subuser you are requesting for.
  * @exclude_whitelabels Should we exclude reverse DNS records (whitelabels)?
  * @sort_by_direction The direction to sort the results.  (desc, asc)
  * @limit limit the number of rows returned.
  * @offset Paging offset.
  */
  public struct function listAllIPs( string ip = '', string subuser = '', boolean exclude_whitelabels = false, string sort_by_direction = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.ip) gt 0 ) params[ 'ip' ] = arguments.ip;
    if ( len(arguments.subuser) gt 0 ) params[ 'subuser' ] = arguments.subuser;
    params[ 'exclude_whitelabels' ] = arguments.exclude_whitelabels;
    if ( len(arguments.sort_by_direction) gt 0 ) params[ 'sort_by_direction' ] = arguments.sort_by_direction;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/ips", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-addresses/retrieve-all-assigned-ips
  * @hint Retrieve all assigned IPs  (Throws internal error even on sendgrids sample)
  */
  public struct function getIPsAssigned( ) {
    return apiCall( 'GET', "/ips/assigned");
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-addresses/retrieve-all-ip-pools-an-ip-address-belongs-to
  * @hint Retrieve all IP pools an IP address belongs to
  * @ip The IP address to get
  */
  public struct function getIPPools( required string ip = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    return apiCall( 'GET', "/ips/#arguments.ip#", params, body, headerparams );
  }


  /**
  * IP Pools
  * https://sendgrid.api-docs.io/v3.0/ip-pools
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/create-an-ip-pool
  * @hint Create an IP pool.
  * @name   * @name 	The amount of IPs to add to the account.
  */
  public struct function createIPPool( required string name ) {
    var params = {};
    var body = {};
    var headerparams = {};
    /*
      {
        "name": "marketing"
      }
    */
    // Build JSON body
    body = '{"name":"#arguments.name#"}';

    return apiCall( 'POST', "/ips/pools", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/retrieve-all-ip-pools
  * @hint Retrieve all IP pools.
  */
  public struct function listAllIPPools( ) {
    return apiCall( 'GET', "/ips/pools");
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/retrieve-all-ips-in-a-specified-pool
  * @hint Retrieve all IPs in a specified pool.
  * @ippool The IP address to get
  */
  public struct function getPoolIPs( required string ippool = '' ) {
    return apiCall( 'GET', "/ips/pools/#arguments.ippool#");
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/update-an-ip-pool-s-name
  * @hint Update an IP pool’s name.
  * @name   The name of the IP pool that you want to rename.
  * @new_pool_name The new name for your IP pool.
  */
  public struct function updatePoolName( required string name, required string new_pool_name ) {
    var params = {};
    var body = {};
    var headerparams = {};
    /*
      {
        "name": "new_pool_name"
      }
    */
    // Build JSON body
    body = '{"name":"#arguments.new_pool_name#"}';

    return apiCall( 'PUT', "/ips/pools/#arguments.name#", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/delete-an-ip-pool
  * @hint Delete an IP pool.
  * @name The name of the IP pool that you want to delete.
  */
  public struct function deleteIPPool( required string name ) {
    return apiCall( 'DELETE', "/ips/pools/#arguments.name#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/add-an-ip-address-to-a-pool
  * @hint Add an IP address to a pool
  * @name   The name of the IP pool that you want to add the IP to.
  * @ip The IP address that you want to add to an IP pool.
  */
  public struct function addIPToPool( required string name, required string ip ) {
    var params = {};
    var body = {};
    var headerparams = {};
    /*
      {
        "ip": "0.0.0.0"
      }
    */
    // Build JSON body
    body = '{"ip":"#arguments.ip#"}';

    return apiCall( 'POST', "/ips/pools/#arguments.name#/ips", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/ip-pools/remove-an-ip-address-from-a-pool
  * @hint Remove an IP address from a pool.
  * @name The name of the IP pool that you want to delete.
  * @ip The IP address that you are removing.
  */
  public struct function deleteIPFromPool( required string name, required string ip ) {
    return apiCall( 'DELETE', "/ips/pools/#arguments.name#/ips/#arguments.ip#" );
  }


  /**
  * Users API
  * https://sendgrid.api-docs.io/v3.0/users-api
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/get-a-user-s-profile
  * @hint Get a user's profile
  * @username Username for the subuser to find associated authenticated domain.
  */
  public struct function getUserProfile( required string username ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.username) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.username;

    return apiCall( 'GET', "/user/profile", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/update-a-user-s-profile
  * @hint Update a user's profile
  * @firstName  The first name of the user.
  * @lastName   The last name of the user.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function updateUserProfile( required string firstName, required string lastName, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    /*
      {
        "first_name": "Example",
        "last_name": "User",
        "city": "Orange"
      }
    */
    // Build JSON body
    body = '{"first_name":"#arguments.firstName#","last_name":"#arguments.lastName#"}';

    return apiCall( 'PATCH', "/user/profile", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/get-a-user-s-account-information
  * @hint Get a user's account information.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getUserAccount( string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/account", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/retrieve-your-account-email-address
  * @hint Retrieve your account email address
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getUserEmail( string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/email", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/update-your-account-email-address
  * @hint Update your account email address
  * @email The new email address that you would like to use for your account.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function updateUserEmail( required string email, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    /*
      {
        "email": "example@example.com"
      }
    */
    // Build JSON body
    body = '{"email":"#arguments.email#"}';

    return apiCall( 'PUT', "/user/email", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/retrieve-your-username
  * @hint Retrieve your username
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getUserUsername( string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/username", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/update-your-username
  * @hint Update your username
  * @username The new username you would like to use for your account.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function updateUserUsername( required string username, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    /*
      {
        "username": "test_username"
      }
    */
    // Build JSON body
    body = '{"username":"#arguments.username#"}';

    return apiCall( 'PUT', "/user/username", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/update-your-password
  * @hint Update your password
  * @oldpassword The old password for your account.
  * @newpassword The new password you would like to use for your account.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function updateUserPassword( required string oldpassword, required string newpassword, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    /*
      {
        "new_password": "new_password",
        "old_password": "old_password"
      }
    */
    // Build JSON body
    body = '{"old_password":"#arguments.oldpassword#","new_password":"#arguments.newpassword#"}';

    return apiCall( 'PUT', "/user/password", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/users-api/retrieve-your-credit-balance
  * @hint Retrieve your credit balance
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getUserCreditBalance( string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/credits", params, body, headerparams );
  }



  /**
  * Webhooks API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Webhooks/event.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/retrieve-event-webhook-settings
  * @hint Retrieve Event Webhook settings
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getEventWebhookSettings( string on_behalf_of = '') {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/webhooks/event/settings", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/update-event-notification-settings
  * @hint Update Event Notification Settings
  * @webhook The webhook helper component
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function updateEventWebhookSettings( required any webhook, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    // Build JSON body
    body = arguments.webhook.build();

    return apiCall( 'PATCH', "/user/webhooks/event/settings", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/test-event-notification-settings
  * @hint Test Event Notification Settings
  * @webhook The webhook helper component
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function testEventWebhook( required any webhook, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    /*
      {
        "url": "mollit non ipsum magna",
        "oauth_client_id": "nisi",
        "oauth_client_secret": "veniam commodo ex sunt",
        "oauth_token_url": "dolor Duis"
      }
    */
    // Build JSON body
    body = arguments.webhook.buildTest();

    return apiCall( 'POST', "/user/webhooks/event/test", params, body, headerparams );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/retrieve-signed-webhook-public-key
  * @hint Retrieve Signed Webhook Public Key
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getEventWebhookSignedPublicKey( string on_behalf_of = '') {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/webhooks/event/settings/signed", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/enable-disable-signed
  * @hint Enable/Disable Signed Webhook
  * @enabled You may either enable or disable signing of the Event Webhook using this endpoint.
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function enableEventSignedWebhook( required boolean enabled, string on_behalf_of = '' ) {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;
    /*
    {
      "enabled": true
    }
    */
    // Build JSON body
    body = '{"enabled":#arguments.enabled#}';

    return apiCall( 'PATCH', "/user/webhooks/event/settings/signed", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/retrieve-parse-webhook-settings
  * @hint Retrieve Parse Webhook settings
  * @on_behalf_of The subuser's username. This header generates the API call as if the subuser account was making the call
  */
  public struct function getEventWebhookParseSettings( string on_behalf_of = '') {
    var params = {};
    var body = {};
    var headerparams = {};

    if ( len(arguments.on_behalf_of) gt 0 ) headerparams[ 'on-behalf-of' ] = arguments.on_behalf_of;

    return apiCall( 'GET', "/user/webhooks/parse/settings", params, body, headerparams );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/webhooks/retrieves-inbound-parse-webhook-statistics
  * @hint Retrieves Inbound Parse Webhook statistics.
  * @start_date The starting date of the statistics to retrieve. Must follow format YYYY-MM-DD.
  * @end_date The end date of the statistics to retrieve. Defaults to today. Must follow format YYYY-MM-DD.
  * @aggregated_by How you would like the statistics to by grouped.   Allowed Values: day, week, month (Optional)
  * @limit The number of results you would like to get in each request. (Optional)
  * @offset The number of subusers to skip (Optional)
  */
  public struct function getEventWebhookParseStats( required string start_date, string end_date = '', string aggregated_by = '', numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    var body = {};
    var headerparams = {};

    params[ 'start_date' ] = arguments.start_date;

    if (len(arguments.end_date) gt 0) params[ 'end_date' ] = arguments.end_date;
    if (len(arguments.aggregated_by) gt 0) params[ 'aggregated_by' ] = arguments.aggregated_by;
    if ( arguments.limit ) params[ 'limit' ] = arguments.limit;
    if ( arguments.offset ) params[ 'offset' ] = arguments.offset;

    return apiCall( 'GET', "/user/webhooks/parse/stats", params, body, headerparams );
  }


  /**
  * Blocks API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/blocks.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/blocks-api/retrieve-all-blocks
  * @hint Retrieve a list of all email addresses that are currently on your blocks list.
  * @start_time Start of the time range when the blocked email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  * @end_time End of the time range when the blocked email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  */
  public struct function listBlocks( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    if ( !isValid( 'integer', start_time ) )
      params[ 'start_time' ] = returnUnixTimestamp( start_time );
    else if ( start_time )
      params[ 'start_time' ] = start_time;

    if ( !isValid( 'integer', end_time ) )
      params[ 'end_time' ] = returnUnixTimestamp( end_time );
    else if ( end_time )
      params[ 'end_time' ] = end_time;

    if ( limit ) params[ 'limit' ] = limit;
    if ( offset ) params[ 'offset' ] = offset;

    return apiCall( 'GET', "/suppression/blocks", params );
  }

  /**
  * @todo Look into workaround, as CF doesn't send the request body for DELETE
  * https://sendgrid.api-docs.io/v3.0/blocks-api/delete-blocks
  * @hint Delete email addresses on your blocks list
  */
  // public struct function deleteBlocks( boolean delete_all = false, array emails = [] ) {
  //   var body = {
  //     'delete_all' : delete_all,
  //     'emails' : emails
  //   };
  //   return apiCall( 'DELETE', "/suppression/blocks", {}, body );
  // }

  /**
  * https://sendgrid.api-docs.io/v3.0/blocks-api/retrieve-a-specific-block
  * @hint Retrieve a specific email address from your blocks list.
  */
  public struct function getBlock( required string email ) {
    return apiCall( 'GET', "/suppression/blocks/#email#" );
  }


  /**
  * Bounces API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/bounces.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/bounces-api/retrieve-all-bounces
  * @hint Retrieve a list of bounces that are currently on your bounces list.
  * @start_time Start of the time range when the bounce was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  * @end_time End of the time range when the bounce was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  */
  public struct function listBounces( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    if ( !isValid( 'integer', start_time ) )
      params[ 'start_time' ] = returnUnixTimestamp( start_time );
    else if ( start_time )
      params[ 'start_time' ] = start_time;

    if ( !isValid( 'integer', end_time ) )
      params[ 'end_time' ] = returnUnixTimestamp( end_time );
    else if ( end_time )
      params[ 'end_time' ] = end_time;

    if ( limit ) params[ 'limit' ] = limit;
    if ( offset ) params[ 'offset' ] = offset;

    return apiCall( 'GET', "/suppression/bounces", params );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/bounces-api/retrieve-a-bounce
  * @hint Retrieve specific bounce information for a given email address.
  */
  public struct function getBounce( required string email ) {
    return apiCall( 'GET', "/suppression/bounces/#email#" );
  }

  /**
  * Campaigns API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/campaigns.html
  */

  /**
  * @hint Create a marketing campaign.
  * @campaign this should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can.
  */
  public struct function createCampaign( required any campaign ) {
    var body = {};
    if ( isValid( 'component', campaign ) )
      body = campaign.build();
    else
      body = campaign;
    return apiCall( 'POST', '/campaigns', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/campaigns-api/retrieve-all-campaigns
  * @hint Retrieve a list of all of your campaigns.
  */
  public struct function listCampaigns() {
    return apiCall( 'GET', "/campaigns" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/campaigns-api/retrieve-a-single-campaign
  * @hint Retrieve a single campaign by ID.
  */
  public struct function getCampaign( required numeric id ) {
    return apiCall( 'GET', "/campaigns/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/campaigns-api/delete-a-campaign
  * @hint Delete a single campaign by ID.
  */
  public struct function deleteCampaign( required numeric id ) {
    return apiCall( 'DELETE', "/campaigns/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/campaigns-api/update-a-campaign
  * @hint Update a campaign by ID.
  * @campaign this should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can.
  */
  public struct function updateCampaign( required numeric id, required any campaign ) {
    var body = {};
    if ( isValid( 'component', campaign ) )
      body = campaign.build();
    else
      body = campaign;
    return apiCall( 'PATCH', '/campaigns/#id#', {}, body );
  }


  /**
  * Contacts API - Recipients
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Recipients
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/add-recipients
  * @hint Add Marketing Campaigns recipients. Note that it also appears to update existing records, so it basically functions like a PATCH.
  * @recipients an array of objects, with at minimum, and 'email' key/value
  */
  public struct function addRecipients( required array recipients ) {
    return upsertRecipients( 'POST', recipients );
  }

  /**
  * @hint Convenience method for adding a single recipient at a time.
  * @recipient Facilitates two means of adding a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required.
  * @customFields keys correspond to the custom field names, along with their assigned values
  */
  public struct function addRecipient( required any recipient, string first_name = '', string last_name = '', struct customFields = {} ) {
    return upsertRecipient( 'POST', recipient, first_name, last_name, customFields );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/update-recipient
  * @hint Update one or more Marketing Campaign recipients. Note that it will also add non-existing records.
  * @recipients an array of objects, with at minimum, and 'email' key/value
  */
  public struct function updateRecipients( required array recipients ) {
    return upsertRecipients( 'PATCH', recipients );
  }

  /**
  * @hint convenience method for updating a single recipient at a time.
  * @recipient Facilitates two means of updating a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required.
  * @customFields keys correspond to the custom field names, along with their assigned values
  */
  public struct function updateRecipient( required any recipient, string first_name = '', string last_name = '', struct customFields = {} ) {
    return upsertRecipient( 'PATCH', recipient, first_name, last_name, customFields );
  }

  /**
  * @hint shared private method for handling insert/update requests for individual recipients. Deletegates to `upsertRecipients()`
  */
  private struct function upsertRecipient( required string method, required any recipient, string first_name = '', string last_name = '', struct customFields = {} ) {
    var recipients = [];
    var contact = {};

    if ( isStruct( recipient ) )
      contact.append( recipient );
    else
      contact[ 'email' ] = recipient;

    if ( first_name.len() )
      contact[ 'first_name' ] = first_name;

    if ( last_name.len() )
      contact[ 'last_name' ] = last_name;

    if ( !customFields.isEmpty() )
      contact.append( customFields, false );

    recipients.append( contact );

    return upsertRecipients( method, recipients );
  }

  /**
  * @hint shared private method for inserting/updating recipients
  */
  private struct function upsertRecipients( required string method, required array recipients ) {
    return apiCall( method, '/contactdb/recipients', {}, recipients );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/get-recipient-upload-status
  * @hint Check the upload status of a Marketing Campaigns recipient.
  */
  public struct function getRecipientUploadStatus() {
    return apiCall( 'GET', "/contactdb/status" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/delete-a-recipient
  * @hint Delete a single recipient with the given ID from your contact database.
  * @id the recipient ID or email address (which will be converted to the recipient ID).
  */
  public struct function deleteRecipient( required string id ) {
    return apiCall( 'DELETE', "/contactdb/recipients/#returnRecipientId( id )#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/delete-recipient
  * @hint Deletes one or more recipients. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/recipients`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the recipients through the individual delete method.
  * @recipients An array of the recipient IDs you want to delete. You can also provide their email addresses, and they will be converted to recipient IDs
  */
  public struct function deleteRecipients( required array recipients ) {
    var result = {};
    for ( var recipientId in recipients ) {
      result = deleteRecipient( recipientId );
    }
    return result;
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-recipients
  * @hint Retrieve all of your Marketing Campaign recipients.
  * @page Page index of first recipients to return (must be a positive integer)
  * @pageSize Number of recipients to return at a time (must be a positive integer between 1 and 1000)
  */
  public struct function listRecipients( numeric page = 0, numeric pageSize = 0 ) {
    var params = {};
    if ( page )
      params[ 'page' ] = page;
    if ( pageSize )
      params[ 'page_size' ] = pageSize;

    return apiCall( 'GET', "/contactdb/recipients", params );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-a-single-recipient
  * @hint Retrieve a single recipient by ID from your contact database.
  * @id the recipient ID or email address (which will be converted to the recipient ID).
  */
  public struct function getRecipient( required string id ) {
    return apiCall( 'GET', "/contactdb/recipients/#returnRecipientId( id )#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-the-lists-that-a-recipient-is-on
  * @hint Retrieve the lists that a given recipient belongs to.
  * @id the recipient ID or email address (which will be converted to the recipient ID).
  */
  public struct function listListsByRecipient( required string id ) {
    return apiCall( 'GET', "/contactdb/recipients/#returnRecipientId( id )#/lists" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-the-count-of-billable-recipients
  * @hint Retrieve the number of Marketing Campaigns recipients that you will be billed for.
  */
  public struct function getBillableRecipientCount() {
    return apiCall( 'GET', "/contactdb/recipients/billable_count" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-a-count-of-recipients
  * @hint Retrieve the total number of Marketing Campaigns recipients.
  */
  public struct function getRecipientCount() {
    return apiCall( 'GET', "/contactdb/recipients/count" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-recipients-matching-search-criteria
  * @hint Perform a search on all of your Marketing Campaigns recipients.
  * @fieldName the name of a custom field or reserved field
  * @search the value to search for within the specified field. Date fields must be unix timestamps. Currently, searches that are formatted as a U.S. date in the format mm/dd/yyyy (1-2 digit days and months, 1-4 digit years) are converted automatically.
  */
  public struct function searchRecipients( required string fieldName, any search = '' ) {
    var params = {
      "#fieldName#" : !isValid( 'USdate', search ) ? search : returnUnixTimestamp( search )
    };
    return apiCall( 'GET', "/contactdb/recipients/search", params );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/Create_Search%20with%20conditions
  * POST /contactdb/recipients/search
  * Note that this endpoint exists, providing more robust, segmented search. However, I don't see support for it in any of the official libraries, so I'm not going to bother to put it together here, unless there's a need for it.
  */

  /**
  * @hint Helper method, which allows for passing in the recipient id or email address and returns the id, which is needed. The recipient Id is a URL-safe base64 encoding of the recipient's lower cased email address
  */
  private string function returnRecipientId( required string id ) {
    return isValid( 'email', id ) ? toBase64( id ) : id;
  }

  /**
  * Contacts API - Custom Fields
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Custom-Fields
  */

  /**
  * @hint Create a custom field.
  * @type allowed values are 'text', 'date', and 'number'
  */
  public struct function createCustomField( required string name, required string type ) {
    var body = {
      'name' : name,
      'type' : type
    };
    return apiCall( 'POST', '/contactdb/custom_fields', {}, body );
  }

  /**
  * @hint Retrieve all custom fields.
  */
  public struct function listCustomFields() {
    return apiCall( 'GET', "/contactdb/custom_fields" );
  }

  /**
  * @hint Retrieve a custom field by ID.
  */
  public struct function getCustomField( required numeric id ) {
    return apiCall( 'GET', "/contactdb/custom_fields/#id#" );
  }

  /**
  * @hint Delete a custom field by ID.
  */
  public struct function deleteCustomField( required numeric id ) {
    return apiCall( 'DELETE', "/contactdb/custom_fields/#id#" );
  }

  /**
  * @hint List all fields that are reserved and can't be used for custom field names.
  */
  public struct function listReservedFields() {
    return apiCall( 'GET', "/contactdb/reserved_fields" );
  }


  /**
  * Contacts API - Lists
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Lists
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/create-a-list
  * @hint Create a list for your recipients.
  */
  public struct function createList( required string name ) {
    var body = {
      'name' : name
    };
    return apiCall( 'POST', '/contactdb/lists', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-all-lists
  * @hint Retrieve all of your recipient lists. If you don't have any lists, an empty array will be returned.
  */
  public struct function listLists() {
    return apiCall( 'GET', '/contactdb/lists' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-multiple-lists
  * @hint Delete multiple recipient lists. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/lists`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the lists through the individual delete method.
  * @recipients An array of the list IDs you want to delete
  */
  public struct function deleteLists( required array lists ) {
    var result = {};
    for ( var listId in lists ) {
      result = deleteList( listId );
    }
    return result;
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-a-list
  * @hint Delete a single list with the given ID from your contact database.
  */
  public struct function deleteList( required numeric id ) {
    return apiCall( 'DELETE', "/contactdb/lists/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-a-single-list
  * @hint Retrieve a single recipient list by ID.
  */
  public struct function getList( required numeric id ) {
    return apiCall( 'GET', "/contactdb/lists/#id#" );
  }

  /**
  * @hint Update the name of one of your recipient lists.
  */
  public struct function updateList( required numeric id, required string name ) {
    var body = {
      'name' : name
    };
    return apiCall( 'PATCH', "/contactdb/lists/#id#", {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-all-recipients-on-a-list
  * @hint Retrieve all recipients on the list with the given ID.
  * @page Page index of first recipient to return (must be a positive integer)
  * @pageSize Number of recipients to return at a time (must be a positive integer between 1 and 1000)
  */
  public struct function listRecipientsByList( required numeric id, numeric page = 0, numeric pageSize = 0 ) {
    var params = {};

    if ( page )
      params[ 'page' ] = page;
    if ( pageSize )
      params[ 'page_size' ] = pageSize;

    return apiCall( 'GET', "/contactdb/lists/#id#/recipients", params );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/add-a-single-recipient-to-a-list
  * @hint Add a single recipient to a list.
  * @recipientId The recipient ID or email address (which will be converted to the recipient ID)
  */
  public struct function addRecipientToList( required numeric listId, required string recipientId ) {
    return apiCall( 'POST', '/contactdb/lists/#listId#/recipients/#returnRecipientId( recipientId )#' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-a-single-recipient-from-a-single-list
  * @hint Delete a single recipient from a list.
  * @recipientId The recipient ID or email address (which will be converted to the recipient ID)
  */
  public struct function deleteRecipientFromList( required numeric listId, required string recipientId ) {
    return apiCall( 'DELETE', '/contactdb/lists/#listId#/recipients/#returnRecipientId( recipientId )#' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/add-multiple-recipients-to-a-list
  * @hint Add multiple recipients to a list.
  * @recipients an array of recipient IDs or email addresses
  */
  public struct function addRecipientsToList( required numeric listId, required array recipients ) {
    var recipientIds = recipients;

    if ( recipients.len() && isValid( 'email', recipients[1] ) ) {
      recipientIds = recipients.map(
        function( item, index ) {
          return returnRecipientId( item );
        }
      );
    }

    return apiCall( 'POST', '/contactdb/lists/#listId#/recipients', {}, recipientIds );
  }

  /**
  * Contacts API - Segments
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Segments
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-segments/create-a-segment
  * @hint Create a segment using search conditions.
  * @conditions an array of structs making up the search conditions that define this segment. Read SendGrid documentation for specifics on how to segment contacts.
  * @listId The list id from which to make this segment. Not including this ID will mean your segment is created from the main contactdb rather than a list.
  */
  public struct function createSegment( required string name, required array conditions, numeric listId = 0 ) {
    var body = {
      'name' : name,
      'conditions' : conditions
    };
    if ( listID )
      body[ 'list_id' ] = listId;
    return apiCall( 'POST', '/contactdb/segments', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-segments/retrieve-all-segments
  * @hint Retrieve all of your segments.
  */
  public struct function listSegments() {
    return apiCall( 'GET', '/contactdb/segments' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-segments/retrieve-a-segment
  * @hint Retrieve a single segment with the given ID.
  */
  public struct function getSegment( required numeric id ) {
    return apiCall( 'GET', "/contactdb/segments/#id#" );
  }

  /**
  * @hint Update a segment. Functions similarly to `createSegment()`, but you only need to include the parameters you are updating.
  * @listId The list id from which to make this segment. Note that this can be used to change the list for this segment, but once a list has been set, the segment cannot be returned to the main contactdb
  */
  public struct function updateSegment( required numeric id, string name = '', array conditions = [], numeric listId = 0 ) {
    var body = {};
    if ( name.len() )
      body[ 'name' ] = name;
    if ( conditions.len() )
      body[ 'conditions' ] = conditions;
    if ( listID )
      body[ 'list_id' ] = listId;
    return apiCall( 'PATCH', "/contactdb/segments/#id#", {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-segments/delete-a-segment
  * @hint Delete a segment from your recipients database.
  */
  public struct function deleteSegment( required numeric id ) {
    return apiCall( 'DELETE', "/contactdb/segments/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-segments/retrieve-recipients-on-a-segment
  * @hint Retrieve all of the recipients in a segment with the given ID.
  */
  public struct function listRecipientsBySegment( required numeric id ) {
    return apiCall( 'GET', "/contactdb/segments/#id#/recipients" );
  }

  /**
  * Invalid Emails API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/invalid_emails.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/invalid-emails-api/retrieve-all-invalid-emails
  * @hint Retrieve a list of invalid emails that are currently on your invalid emails list.
  * @start_time Start of the time range when the invalid email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  * @end_time End of the time range when the invalid email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  */
  public struct function listInvalidEmails( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    if ( !isValid( 'integer', start_time ) )
      params[ 'start_time' ] = returnUnixTimestamp( start_time );
    else if ( start_time )
      params[ 'start_time' ] = start_time;

    if ( !isValid( 'integer', end_time ) )
      params[ 'end_time' ] = returnUnixTimestamp( end_time );
    else if ( end_time )
      params[ 'end_time' ] = end_time;

    if ( limit ) params[ 'limit' ] = limit;
    if ( offset ) params[ 'offset' ] = offset;

    return apiCall( 'GET', "/suppression/invalid_emails", params );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/invalid-emails-api/retrieve-a-specific-invalid-email
  * @hint Retrieve information about a specific invalid email address.
  */
  public struct function getInvalidEmail( required string email ) {
    return apiCall( 'GET', "/suppression/invalid_emails/#email#" );
  }

  /**
  * Sender Identities API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/sender_identities.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/sender-identities-api/create-a-sender-identity
  * @hint Create a new sender identity.
  * @sender this should be an instance of the `helpers.sender` component. However, if you want to create and pass in the struct or json yourself, you can.
  */
  public struct function createSender( required any sender ) {
    var body = {};
    if ( isValid( 'component', sender ) )
      body = sender.build();
    else
      body = sender;
    return apiCall( 'POST', '/senders', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/sender-identities-api/get-all-sender-identities
  * @hint Retrieve a list of all sender identities that have been created for your account.
  */
  public struct function listSenders() {
    return apiCall( 'GET', '/senders' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/sender-identities-api/update-a-sender-identity
  * @hint Update a sender identity by ID.
  * @sender this should be an instance of the `helpers.sender` component. However, if you want to create and pass in the struct or json yourself, you can.
  */
  public struct function updateSender( required numeric id, required any sender ) {
    var body = {};
    if ( isValid( 'component', sender ) )
      body = sender.build();
    else
      body = sender;
    return apiCall( 'PATCH', '/senders/#id#', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/sender-identities-api/delete-a-sender-identity
  * @hint Delete a single sender identity by ID.
  */
  public struct function deleteSender( required numeric id ) {
    return apiCall( 'DELETE', "/senders/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/sender-identities-api/resend-sender-identity-verification
  * @hint Resend a sender identity verification email.
  */
  public struct function resendSenderVerification( required numeric id ) {
    return apiCall( 'POST', "/senders/#id#/resend_verification" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/sender-identities-api/view-a-sender-identity
  * @hint Retrieve a single sender identity by ID.
  */
  public struct function getSender( required numeric id ) {
    return apiCall( 'GET', "/senders/#id#" );
  }

  /**
  * Cancel Scheduled Sends
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/cancel_schedule_send.html
  */


  /**
  * https://sendgrid.api-docs.io/v3.0/cancel-scheduled-sends/create-a-batch-id
  * @hint Generate a new batch ID. This batch ID can be associated with scheduled sends via the mail/send endpoint.
  */
  public struct function generateBatchId() {
    return apiCall( 'POST', "/mail/batch" );
  }

  /**
  * Spam Reports API
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/spam_reports.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/spam-reports-api/retrieve-all-spam-reports
  * @hint Retrieve a list of spam reports that are currently on your spam reports list.
  * @start_time Start of the time range when the spam reports was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  * @end_time End of the time range when the spam reports was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically
  */
  public struct function listSpamReports( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 ) {
    var params = {};
    if ( !isValid( 'integer', start_time ) )
      params[ 'start_time' ] = returnUnixTimestamp( start_time );
    else if ( start_time )
      params[ 'start_time' ] = start_time;

    if ( !isValid( 'integer', end_time ) )
      params[ 'end_time' ] = returnUnixTimestamp( end_time );
    else if ( end_time )
      params[ 'end_time' ] = end_time;

    if ( limit ) params[ 'limit' ] = limit;
    if ( offset ) params[ 'offset' ] = offset;

    return apiCall( 'GET', "/suppression/spam_reports", params );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/spam-reports-api/retrieve-a-specific-spam-report
  * @hint Retrieve a specific spam report by email address
  */
  public struct function getSpamReport( required string email ) {
    return apiCall( 'GET', "/suppression/spam_reports/#email#" );
  }

  /**
  * Suppressions - Suppressions
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Suppression_Management/suppressions.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/add-suppressions-to-a-suppression-group
  * @hint Add email addresses to an unsubscribe group. If you attempt to add suppressions to a group that has been deleted or does not exist, the suppressions will be added to the global suppressions list.
  * @emails an array of email addresses
  */
  public struct function addEmailsToUnsubscribeGroup( required numeric id, required array emails ) {
    var recipientEmails = {
      'recipient_emails' : emails
    };
    return apiCall( 'POST', '/asm/groups/#id#/suppressions', {}, recipientEmails );
  }

  /**
  * @hint Convenience method for adding a single email address to an unsubscribe group. Delegates to `addEmailsToUnsubscribeGroup()`
  */
  public struct function addEmailToUnsubscribeGroup( required numeric id, required string email ) {
    return addEmailsToUnsubscribeGroup( id, [ email ] );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/retrieve-all-suppressions-for-a-suppression-group
  * @hint Retrieve all suppressed email addresses belonging to the given group.
  */
  public struct function listEmailsByUnsubscribeGroup( required numeric id ) {
    return apiCall( 'GET', "/asm/groups/#id#/suppressions" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/delete-a-suppression-from-a-suppression-group
  * @hint Remove a suppressed email address from the given suppression group.
  */
  public struct function deleteEmailFromUnsubscribeGroup( required numeric id, required string email ) {
    return apiCall( 'DELETE', '/asm/groups/#id#/suppressions/#email#' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/retrieve-all-suppressions
  * @hint Retrieve a list of all suppressions.
  */
  public struct function listAllSupressions() {
    return apiCall( 'GET', "/asm/suppressions" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/retrieve-all-suppression-groups-for-an-email-address
  * @hint Appears to slightly differ from the documentation. Returns all supressions groups, with an indication if the email address is supressed or not.
  */
  public struct function listUnsubscribeGroupsByEmail( required string email ) {
    return apiCall( 'GET', "/asm/suppressions/#email#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/search-for-suppressions-within-a-group
  * @hint Search a suppression group for multiple suppressions.
  */
  public struct function searchUnsubscribeGroupForEmails( required numeric id, required array emails ) {
    var recipientEmails = {
      'recipient_emails' : emails
    };
    return apiCall( 'POST', "/asm/groups/#id#/suppressions/search", {}, recipientEmails );
  }

  /**
  * @hint Convenience method for searching for a single email within an unsubscribe group. Delegates to `searchUnsubscribeGroupForEmails()`
  */
  public struct function searchUnsubscribeGroupForEmail( required numeric id, required string email ) {
    return searchUnsubscribeGroupForEmails( id, [ email ] );
  }

  /**
  * Suppressions - Unsubscribe Groups
  * https://sendgrid.com/docs/API_Reference/Web_API_v3/Suppression_Management/groups.html
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/create-a-new-suppression-group
  * @hint Create a new unsubscribe suppression group.
  * @name Can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (30) by silently trimming excess characters.
  * @description Can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (100) by silently trimming excess characters.
  */
  public struct function createUnsubscribeGroup( required string name, required string description, boolean isDefault ) {
    var body = {
      'name' : name,
      'description' : description
    };
    if ( arguments.keyExists( isDefault ) )
      body[ 'is_default' ] = isDefault;

    return apiCall( 'POST', '/asm/groups', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/retrieve-all-suppression-groups-associated-with-the-user
  * @hint Retrieve a list of all suppression groups created by this user.
  */
  public struct function listUnsubscribeGroups() {
    return apiCall( 'GET', '/asm/groups' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/get-information-on-a-single-suppression-group
  * @hint Retrieve a single suppression group.
  */
  public struct function getUnsubscribeGroup( required numeric id ) {
    return apiCall( 'GET', '/asm/groups/#id#' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/update-a-suppression-group
  * @hint Update an unsubscribe suppression group.
  * @name Can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (30) by silently trimming excess characters.
  * @description Can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (100) by silently trimming excess characters.
  * @isDefault Required by this library, because if you don't supply it, SendGrid assumes false, which is confusing.
  */
  public struct function updateUnsubscribeGroup( required numeric id, string name = '', string description = '', required boolean isDefault ) {
    var body = {
      'is_default' : isDefault
    };
    if ( arguments.name.len() )
      body[ 'name' ] = name;
    if ( arguments.description.len() )
      body[ 'description' ] = description;

    return apiCall( 'PATCH', '/asm/groups/#id#', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/delete-a-suppression-group
  * @hint Delete a suppression group.
  */
  public struct function deleteUnsubscribeGroup( required numeric id ) {
    return apiCall( 'DELETE', '/asm/groups/#id#' );
  }


  /**
  * https://sendgrid.api-docs.io/v3.0/email-address-validation/validate-an-email
  * https://sendgrid.com/docs/ui/managing-contacts/email-address-validation/
  * @hint Validates an email
  * @email Email address to validate
  * @source One word classifier for the validation
  */
  public struct function validateEmail( required string email, string source = '' ) {
    var body = {
      'email': arguments.email,
      'source': arguments.source
    };

    if( !len( variables.emailValidationApiKey ) ) {
      throw( "Use of email validation endpoint requires a separate API key. Please read the documentation for further details.");
    }

    var headers = {
      'Authorization' : 'Bearer #variables.emailValidationApiKey#'
    };
    return apiCall( 'POST', '/validations/email', {}, body, headers );
  }


  // PRIVATE FUNCTIONS
  private struct function apiCall(
    required string httpMethod,
    required string path,
    struct queryParams = { },
    any body = '',
    struct headers = { } )  {

    var fullApiPath = variables.baseUrl & path;
    var requestHeaders = getBaseHttpHeaders();
    requestHeaders.append( headers, true );

    var requestStart = getTickCount();
    var apiResponse = makeHttpRequest( httpMethod = httpMethod, path = fullApiPath, queryParams = queryParams, headers = requestHeaders, body = body );

    var result = {
      'responseTime' = getTickCount() - requestStart,
      'statusCode' = listFirst( apiResponse.statuscode, " " ),
      'statusText' = listRest( apiResponse.statuscode, " " )
    };

    var deserializedFileContent = {};

    if ( isJson( apiResponse.fileContent ) )
      deserializedFileContent = deserializeJSON( apiResponse.fileContent );

    //needs to be cusomtized by API integration for how errors are returned
    if ( result.statusCode >= 400 ) {
      if ( isStruct( deserializedFileContent ) )
        result.append( deserializedFileContent );
    }

    //stored in data, because some responses are arrays and others are structs
    result[ 'data' ] = deserializedFileContent;

    if ( variables.includeRaw ) {
      result[ 'raw' ] = {
        'method' : ucase( httpMethod ),
        'path' : fullApiPath,
        'params' : serializeJSON( queryParams ),
        'response' : apiResponse.fileContent,
        'responseHeaders' : apiResponse.responseheader
      };
    }

    return result;
  }

  private struct function getBaseHttpHeaders() {
    return {
      'Accept' : 'application/json',
      'Content-Type' : 'application/json',
      'User-Agent' : 'sendgrid.cfc/#variables._sendgridcfc_version# (ColdFusion)',
      'Authorization' : 'Bearer #variables.apiKey#'
    };
  }

  private any function makeHttpRequest(
    required string httpMethod,
    required string path,
    struct queryParams = { },
    struct headers = { },
    any body = ''
  ) {
    var result = '';

    var fullPath = path & ( !queryParams.isEmpty()
      ? ( '?' & parseQueryParams( queryParams, false ) )
      : '' );

    var requestHeaders = parseHeaders( headers );
    var requestBody = parseBody( body );

    cfhttp( url = fullPath, method = httpMethod, result = 'result', timeout = variables.httpTimeout ) {

      for ( var header in requestHeaders ) {
        cfhttpparam( type = "header", name = header.name, value = header.value );
      }

      if ( arrayFindNoCase( [ 'POST','PUT','PATCH','DELETE' ], httpMethod ) && isJSON( requestBody ) )
        cfhttpparam( type = "body", value = requestBody );

    }
    return result;
  }

  /**
  * @hint convert the headers from a struct to an array
  */
  private array function parseHeaders( required struct headers ) {
    var sortedKeyArray = headers.keyArray();
    sortedKeyArray.sort( 'textnocase' );
    var processedHeaders = sortedKeyArray.map(
      function( key ) {
        return { name: key, value: trim( headers[ key ] ) };
      }
    );
    return processedHeaders;
  }

  /**
  * @hint converts the queryparam struct to a string, with optional encoding and the possibility for empty values being pass through as well
  */
  private string function parseQueryParams( required struct queryParams, boolean encodeQueryParams = true, boolean includeEmptyValues = true ) {
    var sortedKeyArray = queryParams.keyArray();
    sortedKeyArray.sort( 'text' );

    var queryString = sortedKeyArray.reduce(
      function( queryString, queryParamKey ) {
        var encodedKey = encodeQueryParams
          ? encodeUrl( queryParamKey )
          : queryParamKey;
        if ( !isArray( queryParams[ queryParamKey ] ) ) {
          var encodedValue = encodeQueryParams && len( queryParams[ queryParamKey ] )
            ? encodeUrl( queryParams[ queryParamKey ] )
            : queryParams[ queryParamKey ];
        } else {
          var encodedValue = encodeQueryParams && ArrayLen( queryParams[ queryParamKey ] )
            ?  encodeUrl( serializeJSON( queryParams[ queryParamKey ] ) )
            : queryParams[ queryParamKey ].toList();
          }
        return queryString.listAppend( encodedKey & ( includeEmptyValues || len( encodedValue ) ? ( '=' & encodedValue ) : '' ), '&' );
      }, ''
    );

    return queryString.len() ? queryString : '';
  }

  private string function parseBody( required any body ) {
    if ( isStruct( body ) || isArray( body ) )
      return serializeJson( body );
    else if ( isJson( body ) )
      return body;
    else
      return '';
  }

  private string function encodeUrl( required string str, boolean encodeSlash = true ) {
    var result = replacelist( urlEncodedFormat( str, 'utf-8' ), '%2D,%2E,%5F,%7E', '-,.,_,~' );
    if ( !encodeSlash ) result = replace( result, '%2F', '/', 'all' );

    return result;
  }

  private numeric function returnUnixTimestamp( required any dateToConvert ) {
    return dateDiff( "s", variables.utcBaseDate, dateToConvert );
  }

}
