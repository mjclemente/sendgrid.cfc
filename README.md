# sendgrid.cfc

A CFML wrapper for the SendGrid's [Web API v3](https://sendgrid.com/docs/API_Reference/api_v3.html). It currently supports building and sending transactional emails, as well as portions of the API related to marketing emails.

## Acknowledgements

This project borrows heavily from the API frameworks built by [jcberquist](https://github.com/jcberquist). Thanks to John for all the inspiration!

## Table of Contents

- [Installation](#installation)
  - [Standalone Usage](#standalone-usage)
  - [Use as a ColdBox Module](#use-as-a-coldbox-module)
- [Quick Start for Sending](#quick-start)
- [Setup and Authentication](#setup-and-authentication)
	- [A Note on Email Validation](#a-note-on-email-validation)
- [How to build an email](#how-to-build-an-email)
- [`sendgrid.cfc` Reference Manual](#sendgridcfc-reference-manual)
	- [Mail Send](#mail-send-reference)
  - [API Keys](#api-keys-api-reference)
  - [Blocks](#blocks-api-reference)
  - [Bounces](#bounces-api-reference)
  - [Campaigns](#campaigns-api-reference)
  - [Contacts API - Recipients](#contacts-api---recipients-reference)
  - [Contacts API - Segments](#contacts-api---segments-reference)
  - [Contacts API - Custom Fields](#contacts-api---custom-fields-reference)
  - [Contacts API - Lists](#contacts-api---lists-reference)
  - [Domain Authentication](#domain-authentication-api-reference)
  - [Invalid Emails](#invalid-emails-api-reference)
  - [IP Addresses](#ip-addresses-api-reference)
  - [IP Pools](#ip-pools-api-reference)
  - [Link Branding](#link-branding-api-reference)
  - [Sender Identities API](#sender-identities-api-reference)
  - [Subusers](#subusers-api-reference)
  - [Suppressions - Suppressions](#suppressions---suppressions-reference)
  - [Suppressions - Unsubscribe Groups](#suppressions---unsubscribe-groups-reference)
  - [Cancel Scheduled Sends](#cancel-scheduled-sends-reference)
  - [Spam Reports](#spam-reports-api-reference)
  - [Users](#users-api-reference)
  - [Validate Email](#validate-email)
  - [Webhooks](#webhooks-api-reference)
- [Reference Manual for `helpers.mail`](#reference-manual-for-helpersmail)
- [Reference Manual for `helpers.campaign`](#reference-manual-for-helperscampaign)
- [Reference Manual for `helpers.sender`](#reference-manual-for-helperssender)
- [Reference Manual for `helpers.domain`](#reference-manual-for-helpersdomain)
- [Reference Manual for `helpers.webhook`](#reference-manual-for-helperswebhook)
- [Questions](#questions)
- [Contributing](#contributing)

## Installation

This wrapper can be installed as standalone component or as a ColdBox Module. Either approach requires a simple CommandBox command:

```bash
box install sendgridcfc
```

If you can't use CommandBox, all you need to use this wrapper as a standalone component is the `sendgrid.cfc` file and the helper components, located in `/helpers`; add them to your application wherever you store cfcs. But you should really be using CommandBox.

### Standalone Usage

This component will be installed into a directory called `sendgridcfc` in whichever directory you have chosen and can then be instantiated directly like so:

```cfc
sendgrid = new sendgridcfc.sendgrid( apiKey = 'xxx' );
```

Note that this wrapper was not designed to be placed within the shared CustomTags directory. If implemented as a CustomTag, it will conflict with the older `mail()` [function syntax](https://helpx.adobe.com/coldfusion/cfml-reference/script-functions-implemented-as-cfcs/mail.html), as discussed in [this issue](https://github.com/mjclemente/sendgrid.cfc/issues/4).

### Use as a ColdBox Module

To use the wrapper as a ColdBox Module you will need to pass the configuration settings in from your `config/Coldbox.cfc`. This is done within the `moduleSettings` struct:

```cfc
moduleSettings = {
  sendgridcfc = {
    apiKey = 'xxx'
  }
};
```

You can then leverage the CFC via the injection DSL: `sendgrid@sendgridcfc`; the helper components follow the same pattern:

```cfc
property name="sendgrid" inject="sendgrid@sendgridcfc";
property name="mail" inject="mail@sendgridcfc";
property name="campaign" inject="campaign@sendgridcfc";
property name="sender" inject="sender@sendgridcfc";
```

## Quick Start

The following is a minimal example of sending an email, using the `mail` helper object.

```cfc
sg = new sendgrid( apiKey = 'xxx' );

mail = new helpers.mail()
  .from( 'test@example.com' )
  .subject( 'Sending with SendGrid is Fun' )
  .to( 'test@example.com' )
  .plain( 'and easy to do anywhere, even with ColdFusion');

sg.sendMail( mail );
```

## Setup and Authentication

To get started with SendGrid, you'll need an API key. First, you'll need to [create an account with SendGrid](https://signup.sendgrid.com/); then follow the instructions in the docs for [creating an API key](https://sendgrid.com/docs/ui/account-and-settings/api-keys/#creating-an-api-key). The relevant section is located in your account within **Settings > API Keys > Create API Key**.

Once you have an API key, you can provide it to this wrapper manually when creating the component, as in the Quick Start example above, or via an environment variable named `SENDGRID_API_KEY`, which will get picked up automatically. This latter approach is generally preferable, as it keeps hardcoded credentials out of your codebase.

### A Note on Email Validation

For reasons unclear to me, if you want to use SendGrid's email validation endpoint, you're required to set up a second, separate API key. Note that the email validation service is only available to users of SendGrid's "Pro" tier or higher. If you have a "Pro" account, you can generate a dedicated Email Validation API key in the same manner as the standard API key outlined above, and as [explained in their documentation](https://sendgrid.com/docs/ui/managing-contacts/email-address-validation/).

To provide the Email Validation API key to the wrapper, you can include it manually when creating the component:

```cfc
sg = new sendgrid( apiKey = 'xxx', emailValidationApiKey = 'zzz' );
```

Alternatively, it will automatically be picked up via an environment variable named `SENDGRID_EMAIL_VALIDATION_API_KEY`. It will then be used automatically for requests to the email validation endpoint.

If you don't have a SendGrid "Pro" account and/or don't want to use SendGrid's email validation service, you can ignore this - there's no need to provide the `emailValidationApiKey` for using the other methods in the wrapper.

## How to build an email

SendGrid enables you to do a lot with their endpoint for sending emails. This functionality comes with a tradeoff: a more complicated mail object that many other transactional email providers. So, following the example of their official libraries, I've put together a mail helper to make creating and manipulating the mail object easier.

As seen in the Quick Start example, a basic helper can be created via chaining methods:

```cfc
mail = new helpers.mail().from( 'name@youremail.com' ).subject( 'Hi, I love your emails' ).to( 'myfriend@email.com' ).html( '<p>Hi,</p><p>Thanks for all your emails</p>');
```

Alternatively, you can create the basic object with arguments, on init:

```cfc
from = 'name@youremail.com';
subject = 'Hi, I love your emails';
to = 'myfriend@email.com';
content = '<p>Hi,</p><p>Thanks for all your emails</p>';
mail = new helpers.mail( from, subject, to, content );
```

Note that for this API wrapper, the assumption when the `content` argument is passed in to `init()`, is that it is HTML, and that both html and plain text should be set and sent.

The `from`, `subject`, `to`, and message content, whether plain or html, are minimum required fields for sending an email.

I've found two places where the `/mail/send` endpoint JSON body are explained, and the (77!) possible parameters outlined. Familiarizing yourself with these will be of great help when using the API: [V3 Mail Send API Overview](https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/index.html) and [Mail Send Endpoint Documentation](https://sendgrid.api-docs.io/v3.0/mail-send).

## `sendgrid.cfc` Reference Manual

### Mail Send Reference

*View SendGrid Docs for [Sending Mail](https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/index.html)*

#### `sendMail( required component mail )`

Sends email, using SendGrid's REST API. The `mail` argument must be an instance of the `helpers.mail` component. See [the quick start for sending](#quick-start) and [how to build an email](#how-to-build-an-email) for more information on how this is used.

---

### API Keys API Reference

*View SendGrid Docs for [API Keys](https://sendgrid.com/docs/API_Reference/Web_API_v3/API_Keys/index.html)*

#### `listKeys( string on_behalf_of = '', numeric limit = 0 )`

Retrieve all API Keys belonging to the authenticated user.

#### `getAPIKey( required string api_key_id, string on_behalf_of = '' )`

Retrieve an existing API Key.  The ID of the API Key for which you are requesting information. This is everything in the API key after the SG and before the second dot, so if this were an example API key: SG.aaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbb, your api_key_id would be aaaaaaaaaaaaaa

#### `createAPIKey( required string name, array scopes = ['mail.send'], string on_behalf_of = '' )`

Create an API key. This endpoint allows you to create a new API Key for the user.

#### `deleteAPIKey( required string api_key_id, string on_behalf_of = '' )`

Delete API keys

#### `updateAPIKeyName( required string api_key_id, required string name,  string on_behalf_of = '' )`

This endpoint allows you to update the name of an existing API Key.

---

### Blocks API Reference

*View SendGrid Docs for [Blocks](https://sendgrid.com/docs/API_Reference/Web_API_v3/blocks.html)*

#### `listBlocks( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 )`

Retrieve a list of all email addresses that are currently on your blocks list. The `start_time` and `end_time` arguments, if numeric, are assumed to be unix timestamps. Otherwise, they are presumed to be a valid date that will be converted to unix timestamps automatically.

#### `getBlock( required string email )`

Retrieve a specific email address from your blocks list.

---

### Bounces API Reference

*View SendGrid Docs for [Bounces](https://sendgrid.com/docs/API_Reference/Web_API_v3/bounces.html)*

#### `listBounces( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 )`

Retrieve a list of bounces that are currently on your bounces list. The `start_time` and `end_time` arguments, if numeric, are assumed to be unix timestamps. Otherwise, they are presumed to be a valid date that will be converted to unix timestamps automatically.

#### `getBounce( required string email )`

Retrieve specific bounce information for a given email address.

---

### Campaigns API Reference

*View SendGrid Docs for [Campaigns](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/campaigns.html)*

#### `createCampaign( required any campaign )`

Allows you to create a marketing campaign. The `campaign` argument should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can. See [the campaign helper reference manual](#reference-manual-for-helperscampaign) for more information on how this is used.

#### `listCampaigns()`

Retrieve a list of all of your campaigns.

#### `getCampaign( required numeric id )`

Retrieve a single campaign by ID.

#### `deleteCampaign( required numeric id )`

Delete a single campaign by ID.

#### `updateCampaign( required numeric id, required any campaign )`

Update a campaign by ID. The `campaign` arguments should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can. See [the campaign helper reference manual](#reference-manual-for-helperscampaign) for more information on how this is used.

---

### Contacts API - Recipients Reference

*View SendGrid Docs for [Contacts API - Recipients](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Recipients)*

#### `addRecipients( required array recipients )`

Add Marketing Campaigns recipients. Note that it also appears to update existing records, so it basically functions like a PATCH. The `recipients` arguments is an array of objects, with at minimum, and 'email' key/value.

#### `addRecipient( required any recipient, string first_name = '', string last_name = '', struct customFields = {} )`

Convenience method for adding a single recipient at a time. The `recipient` arguments facilitates two means of adding a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required. The `customFields` keys correspond to your custom field names, along with their assigned values.

#### `updateRecipients( required array recipients )`

Update one or more Marketing Campaign recipients. Note that it will also add non-existing records. The `recipients` arguments is an array of objects, with at minimum, and 'email' key/value.

#### `updateRecipient( required any recipient, string first_name = '', string last_name = '', struct customFields = {} )`

Convenience method for updating a single recipient at a time. The `recipient` arguments facilitates two means of adding a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required. The `customFields` keys correspond to your custom field names, along with their assigned values.

#### `getRecipientUploadStatus()`

Check the upload status of a Marketing Campaigns recipient.

#### `deleteRecipient( required string id )`

Delete a single recipient with the given ID from your contact database. The `id` arguments can be the recipient ID or email address (which will be converted to the recipient ID)

#### `deleteRecipients( required array recipients )`

Deletes one or more recipients. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/recipients`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the recipients through the individual delete method. The `recipients` arguments is an array of the recipient IDs you want to delete. You can also provide their email addresses, and they will be converted to recipient IDs

#### `listRecipients( numeric page = 0, numeric pageSize = 0 )`

Retrieve all of your Marketing Campaign recipients.

#### `getRecipient( required string id )`

Retrieve a single recipient by ID from your contact database. The `id` argument can be the recipient ID or email address (which will be converted to the recipient ID).

#### `listListsByRecipient( required string id )`

Retrieve the lists that a given recipient belongs to. The `id` argument can be the recipient ID or email address (which will be converted to the recipient ID).

#### `getBillableRecipientCount()`

Retrieve the number of Marketing Campaigns recipients that you will be billed for.

#### `getRecipientCount()`

Retrieve the total number of Marketing Campaigns recipients.

#### `searchRecipients( required string fieldName, any search = '' )`

Perform a search on all of your Marketing Campaigns recipients. The `fieldName` argument is the name of a custom field or reserved field. The `search` argument is the value to search for within the specified field. Date fields must be unix timestamps. Currently, searches that are formatted as a U.S. date in the format mm/dd/yyyy (1-2 digit days and months, 1-4 digit years) are converted automatically.

---

### Contacts API - Segments Reference

*View SendGrid Docs for [Contacts API - Segments](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Segments)*

#### `createSegment( required string name, required array conditions, numeric listId = 0 )`

Create a segment using search conditions.

The `conditions` argument is an array of structs making up the search conditions that define this segment. Read [SendGrid documentation](https://sendgrid.api-docs.io/v3.0/contacts-api-segments/create-a-segment) for specifics on how to segment contacts.

The `listId` argument indicates the list from which to make this segment. Not including this ID will mean your segment is created from the main contactdb rather than a list.

#### `listSegments()`

Retrieve all of your segments.

#### `getSegment( required numeric id )`

Retrieve a single segment with the given ID.

#### `updateSegment( required numeric id, string name = '', array conditions = [], numeric listId = 0 )`

Update a segment. Functions similarly to `createSegment()`, but you only need to include the parameters you are updating.

Note that the `listId` argument can be used to change the list for this segment, but once a list has been set, the segment cannot be returned to the main contactdb.

#### `deleteSegment( required numeric id )`

Delete a segment from your recipients database.

#### `listRecipientsBySegment( required numeric id )`

Retrieve all of the recipients in a segment with the given ID.

---

### Contacts API - Custom Fields Reference

*View SendGrid Docs for [Contacts API - Custom Fields](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Custom-Fields)*

#### `createCustomField( required string name, required string type )`

Create a custom field. For the `type` arguments, the allowed values are 'text', 'date', and 'number'.

#### `listCustomFields()`

Retrieve all custom fields.

#### `getCustomField( required numeric id )`

Retrieve a custom field by ID.

#### `deleteCustomField( required numeric id )`

Delete a custom field by ID.

#### `listReservedFields()`

List all fields that are reserved and can't be used for custom field names.

---

### Contacts API - Lists Reference

*View SendGrid Docs for [Contacts API - Lists](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Lists)*

#### `createList( required string name )`

Create a list for your recipients.

#### `listLists()`

Retrieve all of your recipient lists. If you don't have any lists, an empty array will be returned.

#### `deleteLists( required array lists )`

Delete multiple recipient lists. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/lists`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the lists through the individual delete method. The `recipients` argument is an array of the list IDs you want to delete.

#### `deleteList( required numeric id )`

Delete a single list with the given ID from your contact database.

#### `getList( required numeric id )`

Retrieve a single recipient list by ID.

#### `updateList( required numeric id, required string name )`

Update the name of one of your recipient lists.

#### `listRecipientsByList( required numeric id, numeric page = 0, numeric pageSize = 0 )`

Retrieve all recipients on the list with the given ID.

#### `addRecipientToList( required numeric listId, required string recipientId )`

Add a single recipient to a list. The `recipientId` argument can be the recipient ID or email address (which will be converted to the recipient ID).

#### `deleteRecipientFromList( required numeric listId, required string recipientId )`

Delete a single recipient from a list. The `recipientId` argument can be the recipient ID or email address (which will be converted to the recipient ID).

#### `addRecipientsToList( required numeric listId, required array recipients )`

Add multiple recipients to a list. The `recipients` argument is an array of recipient IDs or email addresses. The first element of the array is checked to determine if it is an array of IDs or email addresses.

---

### Domain Authentication API Reference

*View SendGrid Docs for [Domains](https://sendgrid.com/docs/API_Reference/Web_API_v3/Whitelabel/domains.html)*

#### `listAllDomains( string on_behalf_of = '', numeric limit = 0, numeric offset = 0, boolean exclude_subusers = false, string username = '', string domain = '' )`

List all authenticated domains.

An authenticated domain allows you to remove the “via” or “sent on behalf of” message that your recipients see when they read your emails. Authenticating a domain allows you to replace sendgrid.net with your personal sending domain. You will be required to create a subdomain so that SendGrid can generate the DNS records which you must give to your host provider. If you choose to use Automated Security, SendGrid will provide you with 3 CNAME records. If you turn Automated Security off, you will get 2 TXT records and 1 MX record.

#### `getAuthenticatedDomain( required numeric domain_id = 0, string on_behalf_of = '' )`

Retrieve an authenticated domain

#### `createAuthenticatedDomain( required string domain, string subdomain = '', string username = '', array ips = [], boolean custom_spf = false, boolean default = false, boolean automatic_security = false, string custom_dkim_selector = '', string on_behalf_of = '')`

Authenticate a domain

If you are authenticating a domain for a subuser, you have two options:

- Use the "username" parameter. This allows you to authenticate a domain on behalf of your subuser. This means the subuser is able to see and modify the authenticated domain.
- Use the Association workflow (see Associate Domain section). This allows you to authenticate a domain created by the parent to a subuser. This means the subuser will default to the assigned domain, but will not be able to see or modify that authenticated domain. However, if the subuser authenticates their own domain it will overwrite the assigned domain.

An authenticated domain allows you to remove the “via” or “sent on behalf of” message that your recipients see when they read your emails. It replaces sendgrid.net with your personal sending domain. If you choose to use Automated Security, SendGrid provids 3 CNAME records. If you turn Automated Security off, you will be given 2 TXT records and 1 MX record. You need to enter these records into your DNS provider.

#### `updateAuthenticatedDomain( required numeric domain_id = 0, boolean custom_spf = false, boolean default = false, string on_behalf_of = '' )`

Update an authenticated domain

#### `deleteAuthenticatedDomain( required numeric domain_id = 0, string on_behalf_of = '' )`

Delete an authenticated domain.

#### `getDefaultAuthenticatedDomain( string on_behalf_of = '' )`

Get the default authentication

#### `addIPAuthenticatedDomain( required numeric domain_id, required string ip, string on_behalf_of = '' )`

Add an IP to an authenticated domain

#### `deleteIPForAuthenticatedDomain( required numeric domain_id, required string ip, string on_behalf_of = '' )`

Remove an IP from an authenticated domain.

#### `validateAuthenticatedDomain( required numeric domain_id, string on_behalf_of = '' )`

Validate a domain authentication.

#### `listSubuserAuthenticatedDomain( required string username )`

List the authenticated domain associated with the given user.

#### `disassociateSubuserAuthenticatedDomain( required string username )`

Disassociate a authenticated domain from a given user.

#### `associateSubuserWithAuthenticatedDomain( required numeric domain_id, required string username )`

Associate a authenticated domain with a given user.

---

### Invalid Emails API Reference

*View SendGrid Docs for [Invalid Emails](https://sendgrid.com/docs/API_Reference/Web_API_v3/invalid_emails.html)*

#### `listInvalidEmails( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 )`

Retrieve a list of invalid emails that are currently on your invalid emails list. The `start_time` and `end_time` arguments, if numeric, are assumed to be unix timestamps. Otherwise, they are presumed to be a valid date that will be converted to unix timestamps automatically.

#### `getInvalidEmail( required string email )`

Retrieve information about a specific invalid email address.

---

### IP Addresses API Reference

*View SendGrid Docs for [IP Addresses](https://sendgrid.com/docs/API_Reference/Web_API_v3/IP_Management/ip_addresses.html)*

#### `addIPs( required numeric count = 0, array subusers = [], boolean warmpup = false )`

Add IPs

#### `getIPsRemaining( )`

Gets amount of IP Addresses that can still be created during a given period and the price of those IPs.

#### `listAllIPs( string ip = '', string subuser = '', boolean exclude_whitelabels = false, string sort_by_direction = '', numeric limit = 0, numeric offset = 0 )`

Retrieve all IP addresses.  Response includes warm up status, pools, assigned subusers, and reverse DNS info. The start_date field corresponds to when warmup started for that IP.

#### `getIPsAssigned( )`

Retrieve all assigned IPs  (Throws internal error even on sendgrids sample)

#### `getIPPools( required string ip = '' )`

Retrieve all IP pools an IP address belongs to

---

### IP Pools API Reference

*View SendGrid Docs for [IP Pools](https://sendgrid.com/docs/API_Reference/Web_API_v3/IP_Management/ip_pools.html)*

#### `createIPPool( required string name )`

Create an IP pool.

#### `listAllIPPools( )`

Retrieve all IP pools.

#### `getPoolIPs( required string ippool = '' )`

Retrieve all IPs in a specified pool.

#### `updatePoolName( required string name, required string new_pool_name )`

Update an IP pool’s name.

#### `deleteIPPool( required string name )`

Delete an IP pool.

#### `addIPToPool( required string name, required string ip )`

Add an IP address to a pool

#### `deleteIPFromPool( required string name, required string ip )`

Remove an IP address from a pool.

---

### Link Branding API Reference

*View SendGrid Docs for [Link Branding](https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-all-link-branding)*

#### `listBrandedLinks( string on_behalf_of = '', numeric limit = 0 )`

Retrieve all branded links.  Email link branding allows all of the click-tracked links you send in your emails to include the URL of your domain instead of sendgrid.net.

#### `getBrandedLink( required numeric id = 0, string on_behalf_of = '', numeric limit = 0 )`

Retrieve a branded link

#### `getDefaultBrandedLink( string domain = '', string on_behalf_of = '', numeric limit = 0 )`

Retrieve the default branded link.  The default branded link is the actual URL to be used when sending messages. If there are multiple branded links, the default is determined by the following order:

#### `getSubuserBrandedLink( required string username = '' )`

Retrieve a subusers branded link

#### `createLinkBranding( required string domain = '', string subdomain = '', string default = 'false', string on_behalf_of = '' )`

Create a branded link.  Link branding can be associated with subusers from the parent account. This functionality allows subusers to send mail using their parent's link branding. To associate link branding, the parent account must first create a branded link and validate it. The parent may then associate that branded link with a subuser via the API or the Subuser Management page in the user interface.

Link branding allow all of the click-tracked links you send in your emails to include the URL of your domain instead of sendgrid.net.

#### `deleteBrandedLink( required numeric id = 0, string on_behalf_of = '', numeric limit = 0 )`

Delete a branded link

#### `validateLinkBranding(  required numeric id = 0, string on_behalf_of = '' )`

Validate a branded link

#### `associateLinkBranding( required numeric link_id = 0, required string username = '')`

Associate a branded link with a subuser

#### `disassociateBrandedLink( required string username )`

Disassociate link branding from a subuser

---

### Sender Identities API Reference

*View SendGrid Docs for [Sender Identities](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/sender_identities.html)*

#### `createSender( required any sender )`

Allows you to create a new sender identity. The `sender` argument should be an instance of the `helpers.sender` component. However, if you want to create and pass in the struct or json yourself, you can. See [the sender helper reference manual](#reference-manual-for-helperssender) for more information on how this is used.

#### `listSenders()`

Retrieve a list of all sender identities that have been created for your account.

#### `updateSender( required numeric id, required any sender )`

Update a sender identity by ID. The `sender` argument should be an instance of the `helpers.sender` component. However, if you want to create and pass in the struct or json yourself, you can. See [the sender helper reference manual](#reference-manual-for-helperssender) for more information on how this is used.

#### `deleteSender( required numeric id )`

Delete a single sender identity by ID.

#### `resendSenderVerification( required numeric id )`

Resend a sender identity verification email.

#### `getSender( required numeric id )`

Retrieve a single sender identity by ID.

---

### Subusers API Reference

*View SendGrid Docs for [Subusers](https://sendgrid.com/docs/ui/account-and-settings/subusers/)*

#### `listAllSubusers( string username = '', numeric limit = 0, numeric offset = 0 )`

Retrieve all API Keys belonging to the authenticated user

#### `getSubuserMonitorSettings( required string subuser_name )`

Retrieve monitor settings for a subuser.  Subuser monitor settings allow you to receive a sample of an outgoing message by a specific customer at a specific frequency of emails.

#### `getSubuserReputations( required string username )`

Retrieve Subuser Reputations.  Subuser sender reputations give a good idea how well a sender is doing with regards to how recipients and recipient servers react to the mail that is being received. When a bounce, spam report, or other negative action happens on a sent email, it will effect your sender rating.

#### `getSubuserMonthlyStats( required string subuser_name, required string date = '', string sort_by_metric = '', string sort_by_direction = '', numeric limit = 0, numeric offset = 0 )`

Retrieve Subuser Reputations.  Subuser sender reputations give a good idea how well a sender is doing with regards to how recipients and recipient servers react to the mail that is being received. When a bounce, spam report, or other negative action happens on a sent email, it will effect your sender rating.

#### `getSubuserMonthlyStatsAllSubusers( required string date = '', string subuser = '', string sort_by_metric = '', string sort_by_direction = '', numeric limit = 0, numeric offset = 0 )`

Retrieve monthly stats for all subusers

#### `getAllSubuserTotals( required string start_date, string end_date = '', string sort_by_metric = '', string sort_by_direction = '', string aggregated_by = '', numeric limit = 0, numeric offset = 0 )`

Retrieve the totals for each email statistic metric for all subusers.

#### `getSubuserStats( required string subusers, required string start_date, string end_date = '', string sort_by_metric = '', string sort_by_direction = '', string aggregated_by = '', numeric limit = 0, numeric offset = 0 )`

Retrieve email statistics for your subusers.

#### `createSubuser( required string username, required string email, required string password, required array ips = [] )`

Create a Subuser

#### `deleteSubuser( required string subuser_name )`

Delete a subuser

#### `updateSubuserIPs( required string subuser_name, required array ips = [] )`

Update IPs assigned to a subuser.  Each subuser should be assigned to an IP address, from which all of this subuser's mail will be sent. Often, this is the same IP as the parent account, but each subuser can have their own, or multiple, IP addresses as well.

---

### Suppressions - Suppressions Reference

*View SendGrid Docs for [Suppressions - Suppressions](https://sendgrid.com/docs/API_Reference/Web_API_v3/Suppression_Management/suppressions.html)*

#### `addEmailsToUnsubscribeGroup( required numeric id, required array emails )`

Add email addresses to an unsubscribe group. If you attempt to add suppressions to a group that has been deleted or does not exist, the suppressions will be added to the global suppressions list.

#### `addEmailToUnsubscribeGroup( required numeric id, required string email )`

Convenience method for adding a single email address to an unsubscribe group. Delegates to `addEmailsToUnsubscribeGroup()`

#### `listEmailsByUnsubscribeGroup( required numeric id )`

Retrieve all suppressed email addresses belonging to the given group.

#### `deleteEmailFromUnsubscribeGroup( required numeric id, required string email )`

Remove a suppressed email address from the given suppression group.

#### `listAllSupressions()`

Retrieve a list of all suppressions.

#### `listUnsubscribeGroupsByEmail( required string email )`

Appears to slightly differ from the documentation. Returns all supressions groups, with an indication if the email address is supressed or not.

#### `searchUnsubscribeGroupForEmails( required numeric id, required array emails )`

Search a suppression group for multiple suppressions.

#### `searchUnsubscribeGroupForEmail( required numeric id, required string email )`

Convenience method for searching for a single email within an unsubscribe group. Delegates to `searchUnsubscribeGroupForEmails()`

---

### Suppressions - Unsubscribe Groups Reference

*View SendGrid Docs for [Suppressions - Unsubscribe Groups](https://sendgrid.com/docs/API_Reference/Web_API_v3/Suppression_Management/groups.html)*

#### `createUnsubscribeGroup( required string name, required string description, boolean isDefault )`

Create a new unsubscribe suppression group. The `name` and `description` arguments are both required. They can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length of these arguments by silently trimming their values to 30 and 100 characters, respectively.

#### `listUnsubscribeGroups()`

Retrieve a list of all suppression groups created by this user.

#### `getUnsubscribeGroup( required numeric id )`

Retrieve a single suppression group.

#### `updateUnsubscribeGroup( required numeric id, string name = '', string description = '', required boolean isDefault )`

Update an unsubscribe suppression group. The `name` and `description` arguments can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length of these arguments by silently trimming their values to 30 and 100 characters, respectively. For updates, the `isDefault` argument is required by this library, because if you don't supply it, SendGrid assumes false, which is confusing.

#### `deleteUnsubscribeGroup( required numeric id )`

Delete a suppression group.

---

### Cancel Scheduled Sends Reference

*View SendGrid Docs for [Cancel Scheduled Sends](https://sendgrid.com/docs/API_Reference/Web_API_v3/cancel_schedule_send.html)*

#### `generateBatchId()`

Generate a new batch ID. This batch ID can be associated with scheduled sends via the mail/send endpoint.

---

### Spam Reports API Reference

*View SendGrid Docs for [Spam Reports](https://sendgrid.com/docs/API_Reference/Web_API_v3/spam_reports.html)*

#### `listSpamReports( any start_time = 0, any end_time = 0, numeric limit = 0, numeric offset = 0 )`

Retrieve a list of spam reports that are currently on your spam reports list. The `start_time` and `end_time` arguments, if numeric, are assumed to be unix timestamps. Otherwise, they are presumed to be a valid date that will be converted to unix timestamps automatically.

#### `getSpamReport( required string email )`

Retrieve a specific spam report by email address.

---

### Users API Reference

*View SendGrid Docs for [Users](https://sendgrid.com/docs/API_Reference/Web_API_v3/user.html)*

#### `getUserProfile( required string username )`

Get a user's profile

#### `updateUserProfile( required string firstName, required string lastName, string on_behalf_of = '' )`

Update a user's profile

#### `getUserAccount( string on_behalf_of = '' )`

Get a user's account information.

#### `getUserEmail( string on_behalf_of = '' )`

Retrieve your account email address

#### `updateUserEmail( required string email, string on_behalf_of = '' )`

Update your account email address

#### `getUserUsername( string on_behalf_of = '' )`

Retrieve your username

#### `updateUserUsername( required string username, string on_behalf_of = '' )`

Update your username

#### `updateUserPassword( required string oldpassword, required string newpassword, string on_behalf_of = '' )`

Update your password

#### `getUserCreditBalance( string on_behalf_of = '' )`

Retrieve your credit balance

---

### Validate Email

*View SendGrid Docs for [Validate Email](https://sendgrid.api-docs.io/v3.0/email-address-validation/validate-an-email)*

#### `validateEmail( string email, string source = '' )`

Retrive a validation information about an email address. The source param is just an one word classifier for the validation call.

**Important**: SendGrid's email validation endpoint requires a separate API key from their primary email API. Additionally, this service is only available on their "Pro" tier, or higher. For a bit more information about SendGrid's email validation, you can read their [documentation](https://sendgrid.com/docs/ui/managing-contacts/email-address-validation/) and [product page](https://sendgrid.com/solutions/email-validation-api/). For a little more context on how this impact this wrapper, see the [note on email validation](#a-note-on-email-validation).

---

### Webhooks API Reference

*View SendGrid Docs for [Webhooks](https://sendgrid.com/docs/API_Reference/Web_API_v3/Webhooks/event.html)*

#### `getEventWebhookSettings( string on_behalf_of = '')`

Retrieve Event Webhook settings

#### `updateEventWebhookSettings( required any webhook, string on_behalf_of = '' )`

Update Event Notification Settings

#### `testEventWebhook( required any webhook, string on_behalf_of = '' )`

Test Event Notification Settings

#### `getEventWebhookSignedPublicKey( string on_behalf_of = '')`

Retrieve Signed Webhook Public Key

#### `enableEventSignedWebhook( required boolean enabled, string on_behalf_of = '' )`

Enable/Disable Signed Webhook

#### `getEventWebhookParseSettings( string on_behalf_of = '')`

Retrieve Parse Webhook settings

#### `getEventWebhookParseStats( required string start_date, string end_date = '', string aggregated_by = '', numeric limit = 0, numeric offset = 0 )`

Retrieves Inbound Parse Webhook statistics.

---

## Reference Manual for `helpers.mail`

This section documents every public method in the `helpers/mail.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.
- Top level parameters are referred to as "global" or "message level", as opposed to personalized parameters. As the SendGrid docs state: "Individual fields within the personalizations array will override any other global, or “message level”, parameters that are defined outside of personalizations."
- Email address parameters can be passed in either as strings or structs.
  - When passed as a string, they can be in the format: Person \<name@email.com\>, in order to pass both name and email address.
  - When passed as a struct, the keys should be `email` and `name`, respectively. Only email is required.

#### `from( required any email )`

#### `replyTo( required any email )`

#### `subject( required string subject )`

Sets the global subject. This may be overridden by personalizations[x].subject.

#### `html( required string message )`

Convenience method for adding the text/html content

#### `plain( required string message )`

Convenience method for adding the text/plain content

#### `emailContent( required struct content, boolean doAppend = true )`

Method for setting any content mime-type. The default is that the new mime-type is appended to the Content array, but you can override this and have it prepended. This is used internally to ensure that `text/plain` precedes `text/html`, in accordance with the RFC specs, as enforced by SendGrid.

#### `plainFromHtml( string message = '' )`

Convenience method for setting both `text/html` and `text/plain` at the same time. You can either pass in the HTML content as the message argument, and both will be set from it (using an internal method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.

#### `attachments( required array attachments )`

Sets the `attachments` property for the global message. If any attachments were previously set, this method overwrites them.

#### `addAttachment( required struct attachment )`

Appends a single attachment to the message. The attachment argument is struct with at minimum keys for `content` and `filename`. View [the SendGrid docs](https://sendgrid.api-docs.io/v3.0/mail-send) for the full makeup and requirements of the object.

#### `attachFile( required string filePath, string fileName, string type, string disposition = 'attachment', string content_id )`

A convenience method for appending a single file attachment to the message. All that is required is the relative or absolute path to an on-disk file. Its properties are used if the additional arguments aren't provided.

#### `templateId( required string templateId )`

Sets the id of a template that you would like to use for the message

#### `section( required any section, any value )`

Appends a single section block to the global message's `sections` property. I'd recommend reading up on the somewhat [limited](https://sendgrid.com/docs/Classroom/Build/Add_Content/substitution_and_section_tags.html) [documentation](https://sendgrid.com/docs/API_Reference/SMTP_API/section_tags.html) SendGrid provides about sections and substitutions for more clarity on how they should be structured and used.

You can set a section by providing the section tag and replacement value separately, or by passing in a struct with a key/value pair; for example, `{ "-greeting-" : 'Welcome -first_name- -last_name-,' }`.

#### `sections( required struct sections )`

Sets the `sections` property for the global message. If any sections were previously set, this method overwrites them.

#### `header( required any header, any value )`

Appends a single header to the global message's `headers` property. This can be overridden by a personalized header.

You can set a header by providing the header and value separately, or by passing in a struct with a key/value pair; for example, `{ "X-my-application-name" : 'testing' }`.

#### `headers( required struct headers )`

Sets the `headers` property for the global message. Headers can be overridden by a personalized header. If any headers are set, this method overwrites them.

#### `categories( required any categories )`

Sets the category array for the global message. If categories are already set, this overwrites them. The argument can be passed in as an array or comma separated list. Lists will be converted to arrays

#### `addCategory( required string category )`

Appends a single category to the global message category array

#### `customArg( required any arg, any value )`

Appends a single custom argument on the global message's `custom_args` property. This can be overridden by a personalized custom argument.

You can set a custom argument by providing the argument's name and value separately, or by passing in a struct with a key/value pair; for example, `{ "Team": "Engineering" }`.

#### `customArgs( required struct args )`

Sets the `custom_args` property for the global message. Custom arguments can be overridden by a personalized custom argument. If any custom arguments are set, this overwrites them.

#### `sendAt( required date timeStamp )`

Sets the global `send_at` property, which specifies when you want the email delivered. This may be overridden by the personalizations[x].send_at.

#### `batchId( required string batchId )`

Sets the global `batch_id` property, which represents a group of emails that are associated with each other. The sending of emails in a batch can be cancelled or paused. Note that you must generate the batchID value via the API.

#### `mailSettings( required struct settings )`

Sets the `mail_settings` property for the global message. If any mail settings were previously set, this method overwrites them. While this makes it possible to pass in the fully constructed mail settings struct, the preferred method of setting mail settings is by using their dedicated methods.

#### `mailSetting( required any setting, any value )`

Generic method for defining individual mail settings. Using the dedicated methods for defining mail settings is usually preferable to invoking this directly.

You can define a setting by providing the setting key and its value separately, or by passing in a struct with a key/value pair; for example, `{ "sandbox_mode" : { "enable" : true } }`.

#### `bccSetting( required boolean enable, string email = '' )`

Sets the global `mail_settings.bcc` property, which allows you to have a blind carbon copy automatically sent to the specified email address for every email that is sent. Using the dedicated enable/disable bcc methods is usually preferable.

#### `enableBcc( required string email )`

Convenience method for enabling the `bcc` mail setting and setting the address

#### `disableBcc()`

Convenience method for disabling the `bcc` mail setting

#### `bypassListManagementSetting( required boolean enable )`

Sets the global `mail_settings.bypass_list_management` property, which allows you to bypass all unsubscribe groups and suppressions to ensure that the email is delivered to every single recipient. According to SendGrid, this should only be used in emergencies when it is absolutely necessary that every recipient receives your email. Using the dedicated enable/disable methods is usually preferable to invoking this directly

#### `enableBypassListManagement()`

Convenience method for disabling the `bypass_list_management` mail setting

#### `disableBypassListManagement()`

Convenience method for disabling the `bypass_list_management` mail setting

#### `footerSetting( required boolean enable, string text = '', string html = '' )`

Sets the global `mail_settings.footer` property, which provides the option for setting a default footer that you would like included on every email. Using the dedicated enable/disable methods is usually preferable.

#### `enableFooter( required string text, required string html )`

Convenience method for enabling the `footer` mail setting and setting the text/html

#### `disableFooter()`

Convenience method for disabling the `footer` mail setting

#### `sandboxModeSetting( required boolean enable )`

Sets the global `mail_settings.sandbox_mode` property, which allows allows you to send a test email to ensure that your request body is valid and formatted correctly. Sandbox mode is only used to validate your request. The email will never be delivered while this feature is enabled! Using the dedicated enable/disable methods is usually preferable to invoking this directly. You can [read more here](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/sandbox_mode.html).

#### `enableSandboxMode()`

Convenience method for disabling the `sandbox_mode` mail setting

#### `disableSandboxMode()`

Convenience method for disabling the `sandbox_mode` mail setting

#### `spamCheckSetting( required boolean enable, numeric threshold = 0, string post_to_url = '' )`

Sets the global `mail_settings.spam_check` property, which allows you to test the content of your email for spam. Using the dedicated enable/disable methods is usually preferable.

#### `enableSpamCheck( required numeric threshold, required string post_to_url )`

Convenience method for enabling the `spam_check` mail setting and setting the threshold and post_to_url

#### `disableSpamCheck()`

Convenience method for disabling the `spam_check` mail setting

#### `to( required any email )`

Adds a **new** personalization envelope, with only the specified email address. The personalization can then be further customized with later commands. I found personalizations a little tricky. You can [read more here](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/personalizations.html).

#### `addTo( required any email )`

Adds an additional 'to' recipient to the **current** personalization envelope

#### `addCC( required any email )`

Adds an additional 'cc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.

#### `addBCC( required any email )`

Adds an additional 'bcc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.

#### `withSubject ( required string subject )`

Sets the subject for the current personalization envelope. This overrides the global email subject for these recipients. A basic personalization envelope (with a 'to' recipient) needs to be in place before this can be added.

#### `withHeader ( any header, any value )`

Functions like `header()`, except it adds the header to the **current** personalization envelope.

#### `withHeaders( required struct headers )`

Functions like `headers()`, except it sets the `headers` property for the **current** personalization envelope. If any personalized headers are set, this method overwrites them.

#### `withDynamicTemplateData( required struct dynamicTemplateData )`

Sets the `dynamic_template_data` property for the **current** personalization envelope. If any dynamic template data had been previously set, this method overwrites it.

Note that dynamic template data is not compatible with Legacy Dynamic Templates. For more on Dynamic Templates, [read the docs here](https://sendgrid.com/docs/ui/sending-email/how-to-send-an-email-with-dynamic-transactional-templates/).

The `dynamicTemplateData`  argument is an object containing key/value pairs of the dynamic template data. Basically, the Handlebars input object that provides the actual values for the dynamic template.

#### `withSubstitution ( any substitution, any value )`

Appends a substitution ( "substitution_tag" : "value to substitute" ) to the **current** personalization envelope. You can add a substitution by providing the tag and value to substitute, or by passing in a struct.

#### `withSubstitutions( required struct substitutions )`

Sets the `substitutions` property for the **current** personalization envelope. If any substitutions are set, this method overwrites them.

#### `withCustomArg( required any arg, any value )`

Functions like `customArg()`, except it adds the custom argument to the **current** personalization envelope.

#### `withCustomArgs( required struct args )`

Functions like `customArgs()`, except it sets the `custom_args` property for the **current** personalization envelope. If any personalized custom arguments are set, this method overwrites them.

#### `withSendAt( required date timeStamp )`

Functions like `sendAt()`, except it sets the desired send time for the **current** personalization envelope.

#### `build()`

The function that puts it all together and builds the body for `/mail/send`

## Reference Manual for `helpers.campaign`

This section documents every public method in the `helpers/campaign.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.

#### `title( required string title )`

Sets the display title of your campaign. This will be viewable by you in the Marketing Campaigns UI. This is the only required field for creating a campaign

#### `subject( required string subject )`

Sets the subject of your campaign that your recipients will see.

#### `sender( required numeric id )`

Sets who the email is "from", using the ID of the "sender" identity that you have created.

#### `fromSender( required numeric id )`

Included in order to provide a more fluent interface; delegates to `sender()`

#### `useLists( required array lists )`

Sets the IDs of the lists you are sending this campaign to. Note that you can have both segment IDs and list IDs. If any list Ids were previously set, this method overwrites them. The `lists` arguments can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `useList( required numeric id )`

Appends a single list Id to the array of List Ids that this campaign is being sent to.

#### `useSegments( required any segments )`

Sets the segment IDs that you are sending this list to. Note that you can have both segment IDs and list IDs. If any segment Ids were previously set, this method overwrites them. The `segments` argument can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `useSegment( required numeric id )`

Appends a single segment Id to the array of Segment Ids that this campaign is being sent to.

#### `categories( required any categories )`

Set an array of categories you would like associated to this campaign. If categories are already set, this overwrites them. The `categories` argument can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `addCategory( required string category )`

Appends a single category to campaigns array of categories.

#### `suppressionGroupId( required numeric id )`

Assigns the suppression group that this marketing email belongs to, allowing recipients to opt-out of emails of this type. Note that you cannot provide both a suppression group Id and a custom unsubscribe url. The two are mutually exclusive.

#### `useSuppressionGroup( required numeric id )`

Included in order to provide a more fluent interface; delegates to `suppressionGroupId()`

#### `customUnsubscribeUrl( required string uri )`

This is the url of the custom unsubscribe page that you provide for customers to unsubscribe from mailings. Using this takes the place of having SendGrid manage your suppression groups.

#### `useCustomUnsubscribeUrl( required string uri )`

Included in order to provide a more fluent interface; delegates to `customUnsubscribeUrl()`

#### `ipPool( required string name )`

The pool of IPs that you would like to send this email from. Note that your SendGrid plan must include dedicated IPs in order to use this.

#### `fromIpPool( required string name )`

Included in order to provide a more fluent interface; delegates to `ipPool()`

#### `html( required string message )`

Convenience method for adding the text/html content

#### `htmlContent( required string message )`

Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `html()`

#### `plain( required string message )`

Convenience method for adding the text/plain content

#### `plainContent( required string message )`

Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `plain()`

#### `plainFromHtml( string message = '' )`

Convenience method for setting both html and plain at the same time. You can either pass in the HTML content, and both will be set from it (using a method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.

#### `useDesignEditor()`

The editor used in the UI. Because it defaults to `code`, it really only needs to be toggled to `design`

#### `useCodeEditor()`

The editor used in the UI. It defaults to `code`, so this shouldn't be needed, but it's provided for consistency.

#### `build()`

The function that puts it all together and builds the body for campaign related API operations.

## Reference Manual for `helpers.sender`

This section documents every public method in the `helpers/sender.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.
- Email address parameters can be passed in either as strings or structs.
  - When passed as a string, they can be in the format: Person \<name@email.com\>, in order to pass both name and email address.
  - When passed as a struct, the keys should be `email` and `name`, respectively.

#### `nickname( required string nickname )`

Sets the nickname for the sender identity. Not used for sending, but required.

#### `from( required any email )`

Set where the email will appear to originate from for your recipients. Note that, despite what the documentation says, both email address and name need to be provided. If a string is passed in and the name is not provided, the email address will be used as the name as well.

#### `replyTo( required any email )`

Set where your recipients will reply to. If a string is passed in and the name is not provided, the email address will be used as the name as well.

#### `address( required string address )`

Required. Sets the physical address of the sender identity.

#### `address2( required string address )`

Provides additional sender identity address information.

#### `city( required string city )`

Required.

#### `state( required string state )`

#### `zip( required string zip )`

#### `country( required string country )`

Required.

#### `build()`

The function that puts it all together and builds the body for sender related API operations

## Reference Manual for `helpers.domain`

This section documents every public method in the `helpers/domain.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.

#### `domain( required string domain )`

Required.  The domain name to create an authenticated domain.

#### `subdomain( required string subdomain )`

Sets the subdomain to use for this authenticated domain

#### `username( required string username )`

Sets the username associated with this domain.

#### `custom_spf( required bolean custom_spf )`

Specify whether to use a custom SPF or allow SendGrid to manage your SPF. This option is only available to authenticated domains set up for manual security.

#### `default( required boolean default )`

Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain.

#### `automatic_security( required boolean automatic_security )`

Whether to allow SendGrid to manage your SPF records, DKIM keys, and DKIM key rotation.

#### `custom_dkim_selector( required string custom_dkim_selector )`

Sets a custom DKIM selector. Accepts three letters or numbers.

#### `ips( required any ips )`

Set an array of ips you would like associated to this domain. If ips are already set, this overwrites them.

#### `addIp( required string ip )`

Appends a single ip to the ips array

#### `build()`

The function that puts it all together and builds the body for sender related API operations

## Reference Manual for `helpers.webhook`

This section documents every public method in the `helpers/webhook.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.

#### `url( required string url )`

Required.  The URL that you want the event webhook to POST to.

#### `bounce( required bolean bounce )`

Sets bounce flag - Receiving server could not or would not accept message.

#### `click( required boolean click )`

Sets click flag - Recipient clicked on a link within the message. You need to enable Click Tracking for getting this type of event.

#### `deferred( required boolean deferred )`

Sets deferred flag - Recipient's email server temporarily rejected message.

#### `delivered( required boolean delivered )`

Sets delivered flag - Recipient's email server temporarily rejected message.

#### `dropped( required boolean dropped )`

Sets dropped flag - You may see the following drop reasons: Invalid SMTPAPI header, Spam Content (if spam checker app enabled), Unsubscribed Address, Bounced Address, Spam Reporting Address, Invalid, Recipient List over Package Quota

#### `enabled( required boolean enabled )`

Sets enabled flag - Indicates if the event webhook is enabled.

#### `group_resubscribe( required boolean group_resubscribe )`

Sets group_resubscribe flag - Recipient resubscribes to specific group by updating preferences. You need to enable Subscription Tracking for getting this type of event.

#### `group_unsubscribe( required boolean group_unsubscribe )`

Sets group_unsubscribe flag - Recipient unsubscribe from specific group, by either direct link or updating preferences. You need to enable Subscription Tracking for getting this type of event.

#### `open( required boolean open )`

Sets open flag - Recipient has opened the HTML message. You need to enable Open Tracking for getting this type of event.

#### `spam_report( required boolean spam_report )`

Sets spam_report flag - Recipient marked a message as spam.

#### `unsubscribe( required boolean unsubscribe )`

Sets unsubscribe flag - Recipient clicked on message's subscription management link. You need to enable Subscription Tracking for getting this type of event.

#### `oauth_client_id( required string oauth_client_id )`

Sets the oath client id - The client ID Twilio SendGrid sends to your OAuth server or service provider to generate an OAuth access token. When passing data in this field, you must also include the oauth_token_url field.

#### `oauth_client_secret( required string oauth_client_secret )`

Set the oath client secret - This secret is needed only once to create an access token. SendGrid will store this secret, allowing you to update your Client ID and Token URL without passing the secret to SendGrid again. When passing data in this field, you must also include the oauth_client_id and oauth_token_url fields.

#### `oauth_token_url( required string oauth_token_url )`

Set the oath token URL - The URL where Twilio SendGrid sends the Client ID and Client Secret to generate an access token. This should be your OAuth server or service provider. When passing data in this field, you must also include the oauth_client_id field.

#### `build()`

The function that puts it all together and builds the body for sender related API operations

## Questions

For questions that aren't about bugs, feel free to hit me up on the [CFML Slack Channel](http://cfml-slack.herokuapp.com); I'm @mjclemente. You'll likely get a much faster response than creating an issue here.

## Contributing

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

Before putting the work into creating a PR, I'd appreciate it if you opened an issue. That way we can discuss the best way to implement changes/features, before work is done.

Changes should be submitted as Pull Requests on the `develop` branch.
