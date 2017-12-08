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
  * Contacts API - Recipients
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/add-recipients
  */

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/add-recipients
  * @hint This endpoint allows you to add Marketing Campaigns recipients. Note that it also appears to update existing records, so it basically functions like a PATCH
  * @recipients an array of objects, with at minimum, and 'email' key/value
  */
  public struct function addRecipients( required array recipients ) {
    return apiCall( 'POST', '/contactdb/recipients', {}, recipients );
  }

  /**
  * @hint convenience method for adding a single recipient at a time. Delegates to addRecipients()
  * @recipient Facilitates two means of adding a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required.
  * @customFields keys correspond to the custom field names, along with their assigned values
  */
  public struct function addRecipient( required any recipient, string first_name = '', string last_name = '', struct customFields = {} ) {
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

    return addRecipients( recipients );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/get-recipient-upload-status
  * @hint This endpoint allows you to check the upload status of a Marketing Campaigns recipient.
  */
  public struct function getRecipientUploadStatus() {
    return apiCall( 'GET', "/contactdb/status" );
  }

  /**
  * https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/update-recipient
  * @hint This endpoint allows you to update one or more recipients. Note that it will also add non-existing records.
  * @recipients an array of objects, with at minimum, and 'email' key/value
  */
  public struct function updateRecipients( required array recipients ) {
    return apiCall( 'PATCH', '/contactdb/recipients', {}, recipients );
  }


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

      if ( arrayFindNoCase( [ 'POST','PUT','PATCH' ], httpMethod ) && isJSON( requestBody ) )
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

}