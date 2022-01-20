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

The reference manual for all public methods in `helpers/mail.cfc` can be found in the `docs` directory, [in `mail.md`](https://github.com/mjclemente/sendgrid.cfc/blob/master/docs/mail.md).

## Reference Manual for `helpers.campaign`

The reference manual for all public methods in `helpers/campaign.cfc` can be found in the `docs` directory, [in `campaign.md`](https://github.com/mjclemente/sendgrid.cfc/blob/master/docs/campaign.md).

## Reference Manual for `helpers.sender`

The reference manual for all public methods in `helpers/sender.cfc` can be found in the `docs` directory, [in `sender.md`](https://github.com/mjclemente/sendgrid.cfc/blob/master/docs/sender.md).

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
