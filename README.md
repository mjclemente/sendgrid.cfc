# sendgrid.cfc
A CFML wrapper for the SendGrid's [Web API v3](https://sendgrid.com/docs/API_Reference/api_v3.html). It currently supports building and sending transactional emails, as well as portions of the API related to marketing emails.

*This is an early stage API wrapper. Feel free to use the issue tracker to report bugs or suggest improvements!*

### Acknowledgements

This project borrows heavily from the API frameworks built by [jcberquist](https://github.com/jcberquist), such as [stripecfc](https://github.com/jcberquist/stripecfc), [xero-cfml](https://github.com/jcberquist/xero-cfml), and [aws-cfml](https://github.com/jcberquist/aws-cfml).

## Table of Contents

- [Quick Start for Sending](#quick-start)
- [How to build an email](#how-to-build-an-email)
- [`sendgrid.cfc` Reference Manual](#sendgridcfc-reference-manual)
	- [Mail Send](#mail-send-reference) 
	- [Campaigns](#campaigns-api-reference) 
	- [Contacts API - Recipients](#contacts-api---recipients-reference) 
- [Reference Manual for `helpers.mail`](#reference-manual-for-helpersmail)
- [Reference Manual for `helpers.campaign`](#reference-manual-for-helperscampaign)

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

### Campaigns API Reference
*View SendGrid Docs for [Campaigns](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/campaigns.html)*

#### `createCampaign( required any campaign )`
Allows you to create a marketing campaign. The `campaign` argument should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can.

#### `listCampaigns()`
Retrieve a list of all of your campaigns.

---

### Contacts API - Recipients Reference
*View SendGrid Docs for [Contacts API - Recipients](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Recipients)*


## Reference Manual for `helpers.mail`
This section documents every public method in the `helpers/mail.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable. 
- Top level parameters are referred to as "global" or "message level", as opposed to personalized parameters. As the SendGrid docs state: "Individual fields within the personalizations array will override any other global, or “message level”, parameters that are defined outside of personalizations." 
- Email address parameters can be passed in either as strings or structs.
  - When passed as a string, they can be in the format: Person \<name@email.com\>, in order to pass both name and email address.
  - When passed as a struct, the keys should be `email` and `name`, respectively. Only email is required.

### `from( required any email )`

### `replyTo( required any email )`

### `subject( required string subject )`
Sets the global subject. This may be overridden by personalizations[x].subject.

### `html( required string message )`
Convenience method for adding the text/html content

### `plain( required string message )`
Convenience method for adding the text/plain content

### `emailContent( required struct content, boolean doAppend = true )`
Method for setting any content mime-type. The default is that the new mime-type is appended to the Content array, but you can override this and have it prepended. This is used internally to ensure that `text/plain` precedes `text/html`, in accordance with the RFC specs, as enforced by SendGrid.

### `plainFromHtml( string message = '' )`
Convenience method for setting both `text/html` and `text/plain` at the same time. You can either pass in the HTML content as the message argument, and both will be set from it (using an internal method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.

### `attachments( required array attachments )`
Sets the `attachments` property for the global message. If any attachments were previously set, this method overwrites them.

### `addAttachment( required struct attachment )`
Appends a single attachment to the message. The attachment argument is struct with at minimum keys for `content` and `filename`. View the SendGrid docs for the full makeup and requirements of the object: https://sendgrid.api-docs.io/v3.0/mail-send

### `attachFile( required string filePath, string fileName, string type, string disposition = 'attachment', string content_id )`
A convenience method for appending a single file attachment to the message. All that is required is the relative or absolute path to an on-disk file. Its properties are used if the additional arguments aren't provided.

### `templateId( required string templateId )`
Sets the id of a template that you would like to use for the message

### `section( required any section, any value )`
Appends a single section block to the global message's `sections` property. I'd recommend reading up on the somewhat [limited](https://sendgrid.com/docs/Classroom/Build/Add_Content/substitution_and_section_tags.html) [documentation](https://sendgrid.com/docs/API_Reference/SMTP_API/section_tags.html) SendGrid provides about sections and substitutions for more clarity on how they should be structured and used.

You can set a section by providing the section tag and replacement value separately, or by passing in a struct with a key/value pair; for example, `{ "-greeting-" : 'Welcome -first_name- -last_name-,' }`.

### `sections( required struct sections )`
Sets the `sections` property for the global message. If any sections were previously set, this method overwrites them.

### `header( required any header, any value )`
Appends a single header to the global message's `headers` property. This can be overridden by a personalized header.

You can set a header by providing the header and value separately, or by passing in a struct with a key/value pair; for example, `{ "X-my-application-name" : 'testing' }`.

### `headers( required struct headers )`
Sets the `headers` property for the global message. Headers can be overridden by a personalized header. If any headers are set, this method overwrites them.

### `categories( required any categories )`
Sets the category array for the global message. If categories are already set, this overwrites them. The argument can be passed in as an array or comma separated list. Lists will be converted to arrays

### `addCategory( required string category )`
Appends a single category to the global message category array

### `customArg( required any arg, any value )`
Appends a single custom argument on the global message's `custom_args` property. This can be overridden by a personalized custom argument.

You can set a custom argument by providing the argument's name and value separately, or by passing in a struct with a key/value pair; for example, `{ "Team": "Engineering" }`.

### `customArgs( required struct args )`
Sets the `custom_args` property for the global message. Custom arguments can be overridden by a personalized custom argument. If any custom arguments are set, this overwrites them.

### `sendAt( required date timeStamp )`
Sets the global `send_at` property, which specifies when you want the email delivered. This may be overridden by the personalizations[x].send_at.

### `batchId( required string batchId )`
Sets the global `batch_id` property, which represents a group of emails that are associated with each other. The sending of emails in a batch can be cancelled or paused. Note that you must generate the batchID value via the API.

### `mailSettings( required struct settings )`
Sets the `mail_settings` property for the global message. If any mail settings were previously set, this method overwrites them. While this makes it possible to pass in the fully constructed mail settings struct, the preferred method of setting mail settings is by using their dedicated methods.

### `mailSetting( required any setting, any value )`
Generic method for defining individual mail settings. Using the dedicated methods for defining mail settings is usually preferable to invoking this directly.

You can define a setting by providing the setting key and its value separately, or by passing in a struct with a key/value pair; for example, `{ "sandbox_mode" : { "enable" : true } }`.

### `bccSetting( required boolean enable, string email = '' )`
Sets the global `mail_settings.bcc` property, which allows you to have a blind carbon copy automatically sent to the specified email address for every email that is sent. Using the dedicated enable/disable bcc methods is usually preferable.

### `enableBcc( required string email )`
Convenience method for enabling the `bcc` mail setting and setting the address

### `disableBcc()`
Convenience method for disabling the `bcc` mail setting

### `bypassListManagementSetting( required boolean enable )`
Sets the global `mail_settings.bypass_list_management` property, which allows you to bypass all unsubscribe groups and suppressions to ensure that the email is delivered to every single recipient. According to SendGrid, this should only be used in emergencies when it is absolutely necessary that every recipient receives your email. Using the dedicated enable/disable methods is usually preferable to invoking this directly

### `enableBypassListManagement()`
Convenience method for disabling the `bypass_list_management` mail setting

### `disableBypassListManagement()`
Convenience method for disabling the `bypass_list_management` mail setting

### `footerSetting( required boolean enable, string text = '', string html = '' )`
Sets the global `mail_settings.footer` property, which provides the option for setting a default footer that you would like included on every email. Using the dedicated enable/disable methods is usually preferable.

### `enableFooter( required string text, required string html )`
Convenience method for enabling the `footer` mail setting and setting the text/html

### `disableFooter()`
Convenience method for disabling the `footer` mail setting

### `sandboxModeSetting( required boolean enable )`
Sets the global `mail_settings.sandbox_mode` property, which allows allows you to send a test email to ensure that your request body is valid and formatted correctly. Sandbox mode is only used to validate your request. The email will never be delivered while this feature is enabled! Using the dedicated enable/disable methods is usually preferable to invoking this directly. You can [read more here](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/sandbox_mode.html).

### `enableSandboxMode()`
Convenience method for disabling the `sandbox_mode` mail setting

### `disableSandboxMode()`
Convenience method for disabling the `sandbox_mode` mail setting

### `spamCheckSetting( required boolean enable, numeric threshold = 0, string post_to_url = '' )`
Sets the global `mail_settings.spam_check` property, which allows you to test the content of your email for spam. Using the dedicated enable/disable methods is usually preferable.

### `enableSpamCheck( required numeric threshold, required string post_to_url )`
Convenience method for enabling the `spam_check` mail setting and setting the threshold and post_to_url

### `disableSpamCheck()`
Convenience method for disabling the `spam_check` mail setting

### `to( required any email )`
Adds a **new** personalization envelope, with only the specified email address. The personalization can then be further customized with later commands. I found personalizations a little tricky. You can [read more here](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/personalizations.html).

### `addTo( required any email )`
Adds an additional 'to' recipient to the **current** personalization envelope

### `addCC( required any email )`
Adds an additional 'cc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.

### `addBCC( required any email )`
Adds an additional 'bcc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.

### `withSubject ( required string subject )`
Sets the subject for the current personalization envelope. This overrides the global email subject for these recipients. A basic personalization envelope (with a 'to' recipient) needs to be in place before this can be added.

### `withHeader ( any header, any value )`
Functions like `header()`, except it adds the header to the **current** personalization envelope.

### `withHeaders( required struct headers )`
Functions like `headers()`, except it sets the `headers` property for the **current** personalization envelope. If any personalized headers are set, this method overwrites them.

### `withSubstitution ( any substitution, any value )`
Appends a substitution ( "substitution_tag" : "value to substitute" ) to the **current** personalization envelope. You can add a substitution by providing the tag and value to substitute, or by passing in a struct.

### `withSubstitutions( required struct substitutions )`
Sets the `substitutions` property for the **current** personalization envelope. If any substitutions are set, this method overwrites them.

### `withCustomArg( required any arg, any value )`
Functions like `customArg()`, except it adds the custom argument to the **current** personalization envelope.

### `withCustomArgs( required struct args )`
Functions like `customArgs()`, except it sets the `custom_args` property for the **current** personalization envelope. If any personalized custom arguments are set, this method overwrites them.

### `withSendAt( required date timeStamp )`
Functions like `sendAt()`, except it sets the desired send time for the **current** personalization envelope.

### `build()`
The function that puts it all together and builds the body for `/mail/send`


## Notes

