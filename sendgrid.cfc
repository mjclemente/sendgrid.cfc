/*
  Copyright (c) 2017, Matthew Clemente, John Berquist
  v0.2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
component output="false" displayname="SendGrid.cfc"  {

  public any function init( required string apiKey, string baseUrl = "https://api.sendgrid.com/v3", boolean forceTestMode = false, numeric httpTimeout = 60, boolean includeRaw = true ) {
    variables.utcBaseDate = dateAdd( "l", createDate( 1970,1,1 ).getTime() * -1, createDate( 1970,1,1 ) );
    structAppend( variables, arguments );
    return this;
  }

  //Mail

  /**
  * @mail must be an instance of the helpers.mail component
  */
  public struct function sendMail( required component mail ) {
    if ( variables.forceTestMode ) mail.enableSandboxMode();

    return apiCall( 'POST', '/mail/send', {}, mail.build() );
  }

  /**
  * Campaigns API
  * https://sendgrid.api-docs.io/v3.0/campaigns-api
  */

  /**
  * @hint Allows you to create a marketing campaign.
  * @campaign must be an instance of the helpers.campaign component
  */
  public struct function createCampaign( required component campaign ) {
    return apiCall( 'POST', '/campaigns', {}, campaign.build() );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/campaigns-api/retrieve-all-campaigns
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
  * @campaign must be an instance of the helpers.campaign component
  */
  public struct function updateCampaign( required numeric id, required component campaign ) {
    return apiCall( 'PATCH', '/campaigns/#id#', {}, campaign.build() );
  }


  /**
  * Contacts API - Recipients
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/add-recipients
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/add-recipients
  * @hint This endpoint allows you to add Marketing Campaigns recipients. Note that it also appears to update existing records, so it basically functions like a PATCH.
  * @recipients an array of objects, with at minimum, and 'email' key/value
  */
  public struct function addRecipients( required array recipients ) {
    return upsertRecipients( 'POST', recipients );
  }

  /**
  * @hint convenience method for adding a single recipient at a time.
  * @recipient Facilitates two means of adding a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required.
  * @customFields keys correspond to the custom field names, along with their assigned values
  */
  public struct function addRecipient( required any recipient, string first_name = '', string last_name = '', struct customFields = {} ) {
    upsertRecipient( 'POST', recipient, first_name, last_name, customFields );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/update-recipient
  * @hint This endpoint allows you to update one or more recipients. Note that it will also add non-existing records.
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
    upsertRecipient( 'PATCH', recipient, first_name, last_name, customFields );
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
  * @hint This endpoint allows you to check the upload status of a Marketing Campaigns recipient.
  */
  public struct function getRecipientUploadStatus() {
    return apiCall( 'GET', "/contactdb/status" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/delete-recipient
  * @hint This endpoint allows you to deletes one or more recipients. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/recipients`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the recipients through the individual delete method.
  * @recipients An array of the recipient IDs you want to delete
  */
  public struct function deleteRecipients( required array recipients ) {
    var result = {};
    for ( var recipientId in recipients ) {
      result = deleteRecipient( recipientId );
    }
    return result;
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/delete-a-recipient
  * @hint This endpoint allows you to delete a single recipient with the given ID from your contact database.
  */
  public struct function deleteRecipient( required string id ) {
    return apiCall( 'DELETE', "/contactdb/recipients/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-recipients
  * @hint This endpoint allows you to retrieve all of your Marketing Campaigns recipients.
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
  * @hint This endpoint allows you to retrieve a single recipient by ID from your contact database.
  */
  public struct function getRecipient( required string id ) {
    return apiCall( 'GET', "/contactdb/recipients/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-the-lists-that-a-recipient-is-on
  * @hint This endpoint allows you to retrieve the lists that a given recipient belongs to.
  */
  public struct function listListsByRecipient( required string id ) {
    return apiCall( 'GET', "/contactdb/recipients/#id#/lists" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-the-count-of-billable-recipients
  * @hint This endpoint allows you to retrieve the number of Marketing Campaigns recipients that you will be billed for.
  */
  public struct function getBillableRecipientCount() {
    return apiCall( 'GET', "/contactdb/recipients/billable_count" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-a-count-of-recipients
  * @hint This endpoint allows you to retrieve the total number of Marketing Campaigns recipients.
  */
  public struct function getRecipientCount() {
    return apiCall( 'GET', "/contactdb/recipients/count" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-recipients-matching-search-criteria
  * @hint This endpoint allows you to perform a search on all of your Marketing Campaigns recipients.
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
  * Contacts API - Custom Fields
  * https://sendgrid.api-docs.io/v3.0/contacts-api-custom-fields/create-a-custom-field
  */

  /**
  * @hint This endpoint allows you to create a custom field.
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
  * @hint This endpoint allows you to retrieve all custom fields.
  */
  public struct function listCustomFields() {
    return apiCall( 'GET', "/contactdb/custom_fields" );
  }

  /**
  * @hint This endpoint allows you to retrieve a custom field by ID.
  */
  public struct function getCustomField( required numeric id ) {
    return apiCall( 'GET', "/contactdb/custom_fields/#id#" );
  }

  /**
  * @hint This endpoint allows you to delete a custom field by ID.
  */
  public struct function deleteCustomField( required numeric id ) {
    return apiCall( 'DELETE', "/contactdb/custom_fields/#id#" );
  }

  /**
  * @hint This endpoint allows you to list all fields that are reserved and can't be used for custom field names.
  */
  public struct function listReservedFields() {
    return apiCall( 'GET', "/contactdb/reserved_fields" );
  }


  /**
  * Contacts API - Lists
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/create-a-list
  * @hint This endpoint allows you to create a list for your recipients.
  */
  public struct function createList( required string name ) {
    var body = {
      'name' : name
    };
    return apiCall( 'POST', '/contactdb/lists', {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-all-lists
  * @hint This endpoint allows you to retrieve all of your recipient lists. If you don't have any lists, an empty array will be returned.
  */
  public struct function listLists() {
    return apiCall( 'GET', '/contactdb/lists' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-multiple-lists
  * @hint This endpoint allows you to delete multiple recipient lists. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/lists`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the lists through the individual delete method.
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
  * @hint This endpoint allows you to delete a single list with the given ID from your contact database.
  */
  public struct function deleteList( required numeric id ) {
    return apiCall( 'DELETE', "/contactdb/lists/#id#" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-a-single-list
  * @hint This endpoint allows you to retrieve a single recipient list by ID.
  */
  public struct function getList( required numeric id ) {
    return apiCall( 'GET', "/contactdb/lists/#id#" );
  }

  /**
  * @hint This endpoint allows you to update the name of one of your recipient lists.
  */
  public struct function updateList( required numeric id, required string name ) {
    var body = {
      'name' : name
    };
    return apiCall( 'PATCH', "/contactdb/lists/#id#", {}, body );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-all-recipients-on-a-list
  * @hint This endpoint allows you to retrieve all recipients on the list with the given ID.
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
  * @hint This endpoint allows you to add a single recipient to a list.
  */
  public struct function addRecipientToList( required numeric listId, required string recipientId ) {
    return apiCall( 'POST', '/contactdb/lists/#listId#/recipients/#recipientId#' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-a-single-recipient-from-a-single-list
  * @hint This endpoint allows you to delete a single recipient from a list.
  */
  public struct function deleteRecipientFromList( required numeric listId, required string recipientId ) {
    return apiCall( 'DELETE', '/contactdb/lists/#listId#/recipients/#recipientId#' );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-lists/add-multiple-recipients-to-a-list
  * @hint This endpoint allows you to add multiple recipients to a list.
  * @recipients an array of recipient IDs
  */
  public struct function addRecipientsToList( required numeric listId, required array recipients ) {
    return apiCall( 'POST', '/contactdb/lists/#listId#/recipients', {}, recipients );
  }


  //Batches
  public struct function generateBatchId() {
    return apiCall( 'POST', "/mail/batch" );
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
      'Content-Type' : 'application/json',
      'User-Agent' : 'sendgrid.cfc',
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

    cfhttp( url = fullPath, method = httpMethod, result = 'result' ) {

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