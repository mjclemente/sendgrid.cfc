# Reference Manual for `helpers.mail`

This section documents every public method in the `helpers/mail.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.
- Top level parameters are referred to as "global" or "message level", as opposed to personalized parameters. As the SendGrid docs state: "Individual fields within the personalizations array will override any other global, or “message level”, parameters that are defined outside of personalizations."
- Email address parameters can be passed in either as strings or structs.

- When passed as a string, they can be in the format: Person \<name@email.com\>, in order to pass both name and email address.

- When passed as a struct, the keys should be `email` and `name`, respectively. Only email is required.

#### `from( required any email )`

Set the address the email is from.

#### `replyTo( required any email )`

Set the reply-to email address.

#### `subject( required string subject )`

Sets the global subject. This may be overridden by personalizations[x].subject.

#### `html( required string message )`

Convenience method for adding the text/html content.

#### `plain( required string message )`

Convenience method for adding the text/plain content.

#### `emailContent( required struct content, boolean doAppend=true )`

Method for setting any content mime-type. The default is that the new mime-type is appended to the Content array, but you can override this and have it prepended. This is used internally to ensure that `text/plain` precedes `text/html`, in accordance with the RFC specs, as enforced by SendGrid.

#### `plainFromHtml( string message="" )`

Convenience method for setting both `text/html` and `text/plain` at the same time. You can either pass in the HTML content as the message argument, and both will be set from it (using an internal method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.

#### `attachments( required array attachments )`

Sets the `attachments` property for the global message. If any attachments were previously set, this method overwrites them.

#### `addAttachment( required struct attachment )`

Appends a single attachment to the message. The parameter `attachment` is a struct with at minimum keys for `content` and `filename`. View [the SendGrid docs](https://sendgrid.api-docs.io/v3.0/mail-send) for the full makeup and requirements of the object.

#### `attachFile( required string filePath, string fileName, string type, string disposition="attachment", string content_id )`

Convenience method for appending a single file attachment to the message. The parameter `filePath` is the relative or absolute path to an on-disk file. Its properties are used if the additional arguments aren't provided.

#### `templateId( required string templateId )`

Sets the id of a template that you would like to use for the message. *[Further docs](https://sendgrid.com/docs/User_Guide/Transactional_Templates/index.html)*

#### `section( required any section, any value )`

Appends a single section block to the global message's `sections` property. I'd recommend reading up on the somewhat [limited](https://sendgrid.com/docs/Classroom/Build/Add_Content/substitution_and_section_tags.html) [documentation](https://sendgrid.com/docs/API_Reference/SMTP_API/section_tags.html) SendGrid provides about sections and substitutions for more clarity on how they should be structured and used. The parameter `section` facilitates two means of adding a section. You can pass in a struct with a key/value pair for the section tag and code block to replace it with, for example, `{ "-greeting-" : 'Welcome -first_name- -last_name-,' }`. Alternatively, you can use this to pass in the section tag, and provide the replacement value as a second argument. *[Further docs](https://sendgrid.com/docs/Classroom/Build/Add_Content/substitution_and_section_tags.html)*

#### `sections( required struct sections )`

Sets the `sections` property for the global message. If any sections were previously set, this method overwrites them. The parameter `sections` is an object containing key/value pairs of section tags and their replacement values.

#### `header( required any header, any value )`

Appends a single header to the global message's `headers` property. This can be overridden by a personalized header. The parameter `header` facilitates two means of setting a header. You can pass in a struct with a key/value pair for the name and value of the header, for example, `{ "X-my-application-name" : 'testing' }`. Alternatively, you can use this to pass in the name of the header, and provide the value as a second argument.

#### `headers( required struct headers )`

Sets the `headers` property for the global message. Headers can be overridden by a personalized header. If any headers were previously set, this method overwrites them. The parameter `headers` is an object containing key/value pairs of header names and their value. You must ensure these are properly encoded if they contain unicode characters. Must not be any of the following reserved headers: x-sg-id, x-sg-eid, received, dkim-signature, Content-Type, Content-Transfer-Encoding, To, From, Subject, Reply-To, CC, BCC.

#### `categories( required any categories )`

Sets the category array for the global message. If categories are already set, this overwrites them. The parameter `categories` can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `addCategory( required string category )`

Appends a single category to the global message category array.

#### `customArg( required any arg, any value )`

Appends a single custom argument on the global message's `custom_args` property. This can be overridden by a personalized custom argument. The parameter `arg` facilitates two means of setting a custom argument. You can pass in a struct with a key/value pair, for example, { "Team": "Engineering" }, or you can use this to pass in the custom argument's name, and provide the value as a second argument.

#### `customArgs( required struct args )`

Sets the `custom_args` property for the global message. Custom arguments can be overridden by a personalized custom argument. If any custom arguments were previously set, this overwrites them. The parameter `args` is an object containing the key/value pairs of parameter names and their values. For example, { "Team": "Engineering", "Color": "Gray" }.

#### `sendAt( required date timeStamp )`

Sets the global `send_at` property, which specifies when you want the email delivered. This may be overridden by the personalizations[x].send_at.

#### `batchId( required string batchId )`

Sets the global `batch_id` property, which represents a group of emails that are associated with each other. The sending of emails in a batch can be cancelled or paused. Note that you must generate the batchID value via the API.

#### `mailSettings( required struct settings )`

Sets the `mail_settings` property for the global message. If any mail settings were previously set, this method overwrites them. While this makes it possible to pass in the fully constructed mail settings struct, the preferred method of setting mail settings is by using their dedicated methods. The parameter `settings` is an object containing key/value pairs of each defined mail setting and its value.

#### `mailSetting( required any setting, any value )`

Generic method for defining individual mail settings. Using the dedicated methods for defining mail settings is usually preferable to invoking this directly. The parameter `setting` Facilitates two means of defining a setting. You can pass in a struct with a key/value pair for the setting and its value, for example, `{ "sandbox_mode" : { "enable" : true } }`. Alternatively, you can use this to pass in the setting key, and provide the value as a second argument.

#### `bccSetting( required boolean enable, string email="" )`

Sets the global `mail_settings.bcc` property, which allows you to have a blind carbon copy automatically sent to the specified email address for every email that is sent. Using the dedicated enable/disable bcc methods is usually preferable.

#### `enableBcc( required string email )`

Convenience method for enabling the `bcc` mail setting and setting the address.

#### `disableBcc()`

Convenience method for disabling the `bcc` mail setting.

#### `bypassListManagementSetting( required boolean enable )`

Sets the global `mail_settings.bypass_list_management` property, which allows you to bypass all unsubscribe groups and suppressions to ensure that the email is delivered to every single recipient. According to SendGrid, this should only be used in emergencies when it is absolutely necessary that every recipient receives your email. Using the dedicated enable/disable methods is usually preferable to invoking this directly.

#### `enableBypassListManagement()`

Convenience method for enabling the `bypass_list_management` mail setting.

#### `disableBypassListManagement()`

Convenience method for disabling the `bypass_list_management` mail setting.

#### `footerSetting( required boolean enable, string text="", string html="" )`

Sets the global `mail_settings.footer` property, which provides the option for setting a default footer that you would like included on every email. Using the dedicated enable/disable methods is usually preferable.

#### `enableFooter( required string text, required string html )`

Convenience method for enabling the `footer` mail setting and setting the text/html.

#### `disableFooter()`

Convenience method for disabling the `footer` mail setting.

#### `sandboxModeSetting( required boolean enable )`

Sets the global `mail_settings.sandbox_mode` property, which allows allows you to send a test email to ensure that your request body is valid and formatted correctly. Sandbox mode is only used to validate your request. The email will never be delivered while this feature is enabled! Using the dedicated enable/disable methods is usually preferable to invoking this directly. *[Further docs](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/sandbox_mode.html)*

#### `enableSandboxMode()`

Convenience method for enabling the `sandbox_mode` mail setting.

#### `disableSandboxMode()`

Convenience method for disabling the `sandbox_mode` mail setting.

#### `spamCheckSetting( required boolean enable, numeric threshold=0, string post_to_url="" )`

Sets the global `mail_settings.spam_check` property, which allows you to test the content of your email for spam. Using the dedicated enable/disable methods is usually preferable.

#### `enableSpamCheck( required numeric threshold, required string post_to_url )`

Convenience method for enabling the `spam_check` mail setting and setting the threshold and post_to_url.

#### `disableSpamCheck()`

Convenience method for disabling the `spam_check` mail setting.

#### `to( required any email )`

Adds a **new** personalization envelope, with only the specified email address. The personalization can then be further customized with later commands. I found personalizations a little tricky. You can [read more here](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/personalizations.html).

#### `addTo( required any email )`

Adds an additional 'to' recipient to the **current** personalization envelope.

#### `addCC( required any email )`

Adds an additional 'cc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.

#### `addBCC( required any email )`

Adds an additional 'bcc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.

#### `withSubject( required string subject )`

Sets the subject for the **current** personalization envelope. This overrides the global email subject for these recipients. A basic personalization envelope (with a 'to' recipient) needs to be in place before this can be added.

#### `withHeader( any header, any value )`

functions like `header()`, except it adds the header to the **current** personalization envelope. You can set a header by providing the header and value, or by passing in a struct. The parameter `header` facilitates two means of setting a header. You can pass in a struct with a key/value pair for the name and value of the header. Alternatively, you can use this to pass in the name of the header, and provide the value as a second argument.

#### `withHeaders( required struct headers )`

functions like `headers()`, except it sets the `headers` property for the **current** personalization envelope. If any personalized headers were previously set, this method overwrites them.

#### `withDynamicTemplateData( required struct dynamicTemplateData )`

sets the `dynamic_template_data` property for the **current** personalization envelope. If any dynamic template data had been previously set, this method overwrites it. Note that dynamic template data is not compatible with Legacy Dynamic Templates. The parameter `dynamicTemplateData` An object containing key/value pairs of the dynamic template data. Basically, the Handlebars input object that provides the actual values for the dynamic template. *[Further docs](https://sendgrid.com/docs/ui/sending-email/how-to-send-an-email-with-dynamic-transactional-templates/)*

#### `withSubstitution( any substitution, any value )`

appends a substitution ( "substitution_tag":"value to substitute" ) to the **current** personalization envelope. You can add a substitution by providing the tag and value to substitute, or by passing in a struct. The parameter `substitution` Facilitates two means of adding a substitution. You can pass in a struct with a tag/value for the substitution tag and value to substitute. Alternatively, you can use this argument to pass in the substitution tag, and provide the replacement value as a second argument.

#### `withSubstitutions( required struct substitutions )`

sets the `substitutions` property for the **current** personalization envelope. If any substitutions were previously set, this method overwrites them. The parameter `substitutions` An object containing key/value pairs of substitution tags and their replacement values.

#### `withCustomArg( required any arg, any value )`

functions like `customArg()`, except it adds the custom argument to the **current** personalization envelope. The parameter `arg` Facilitates two means of setting a custom argument. You can pass in a struct with a key/value pair, for example, { "Team": "Engineering" }, or you can use this to pass in the custom argument's name, and provide the value as a second argument.

#### `withCustomArgs( required struct args )`

functions like `customArgs()`, except it sets the `custom_args` property for the **current** personalization envelope. If any personalized custom arguments were previously set, this method overwrites them.

#### `withSendAt( required date timeStamp )`

functions like `sendAt()`, except it sets the desired send time for the **current** personalization envelope.

#### `addPersonalization( required struct personalization )`

Creates and sets a new personalization envelope. I find the easiest way to understand this is that each personalization object is an individual email. That it, all of its properties, even if there are multiple to/cc/bcc, refer to the same email. So if you're adding a second personalization object, you're basically referring to a separate email... except that the sender/content of the email is the same. Note: custom_args = internal tracking, while substitutions are for the content of the email/subject. *[Further docs](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/personalizations.html)*

#### `build()`

Assembles the JSON to send to the API. Generally, you shouldn't need to call this directly.
