# Reference Manual for `helpers.webhook`

This section documents every public method in the `helpers/webhook.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.

#### `url( required string url )`

Required. The URL that you want the event webhook to POST to.

#### `bounce( required boolean bounce )`

Sets bounce flag - Receiving server could not or would not accept message.

#### `click( required boolean click )`

Sets click flag - Recipient clicked on a link within the message. You need to enable Click Tracking for getting this type of event.

#### `deferred( required boolean deferred )`

Sets deferred flag - Recipient's email server temporarily rejected message.

#### `delivered( required boolean delivered )`

Sets delivered flag - Recipient's email server temporarily rejected message.

#### `dropped( required boolean dropped )`

Sets dropped flag - You may see the following drop reasons: Invalid SMTPAPI header, Spam Content (if spam checker app enabled), Unsubscribed Address, Bounced Address, Spam Reporting Address, Invalid, Recipient List over Package Quota.

#### `enabled( required boolean enabled )`

Sets enabled flag - Indicates if the event webhook is enabled.

#### `group_resubscribe( required boolean group_resubscribe )`

Sets group_resubscribe flag - Recipient resubscribes to specific group by updating preferences. You need to enable Subscription Tracking for getting this type of event.

#### `group_unsubscribe( required boolean group_unsubscribe )`

Sets group_unsubscribe flag - Recipient unsubscribe from specific group, by either direct link or updating preferences. You need to enable Subscription Tracking for getting this type of event.

#### `open( required boolean open )`

Sets open flag - Recipient has opened the HTML message. You need to enable Open Tracking for getting this type of event.

#### `processed( required boolean processed )`

Sets processed flag - Message has been received and is ready to be delivered.

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

Assembles the JSON to send to the API. Generally, you shouldn't need to call this directly.
