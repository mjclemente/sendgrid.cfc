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

A full reference manual for all public methods in `sendgrid.cfc`  can be found in the `docs` directory, [here](https://github.com/mjclemente/sendgrid.cfc/blob/master/docs/sendgrid.md).

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
