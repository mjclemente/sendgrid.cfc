# Reference Manual for `helpers.campaign`

This section documents every public method in the `helpers/campaign.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.

#### `title( required string title )`

Sets the display title of your campaign. This will be viewable by you in the Marketing Campaigns UI. This is the only required field for creating a campaign.

#### `subject( required string subject )`

Sets the subject of your campaign that your recipients will see.

#### `sender( required numeric id )`

Sets who the email is "from", using the ID of the "sender" identity that you have created.

#### `fromSender( required numeric id )`

Included in order to provide a more fluent interface; delegates to `sender()`.

#### `useLists( required any lists )`

Sets the IDs of the lists you are sending this campaign to. Note that you can have both segment IDs and list IDs. If any list Ids were previously set, this method overwrites them. The parameter `lists` can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `useList( required numeric id )`

Appends a single list Id to the array of List Ids that this campaign is being sent to.

#### `useSegments( required any segments )`

Sets the segment IDs that you are sending this list to. Note that you can have both segment IDs and list IDs. If any segment Ids were previously set, this method overwrites them. The parameter `segments` can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `useSegment( required numeric id )`

Appends a single segment Id to the array of Segment Ids that this campaign is being sent to.

#### `categories( required any categories )`

Set an array of categories you would like associated to this campaign. If categories are already set, this overwrites them. The parameter `categories` can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `addCategory( required string category )`

Appends a single category to campaigns array of categories.

#### `suppressionGroupId( required numeric id )`

Assigns the suppression group that this marketing email belongs to, allowing recipients to opt-out of emails of this type. Note that you cannot provide both a suppression group Id and a custom unsubscribe url. The two are mutually exclusive. The parameter `id` is the supression group Id.

#### `useSuppressionGroup( required numeric id )`

Included in order to provide a more fluent interface; delegates to `suppressionGroupId()`.

#### `customUnsubscribeUrl( required string uri )`

This is the url of the custom unsubscribe page that you provide for customers to unsubscribe from mailings. Using this takes the place of having SendGrid manage your suppression groups. The parameter `uri` is the web address where you're hosting your custom unsubscribe page.

#### `useCustomUnsubscribeUrl( required string uri )`

Included in order to provide a more fluent interface; delegates to `customUnsubscribeUrl()`.

#### `ipPool( required string name )`

The pool of IPs that you would like to send this email from. Note that your SendGrid plan must include dedicated IPs in order to use this. The parameter `name` is the name of the IP pool.

#### `fromIpPool( required string name )`

Included in order to provide a more fluent interface; delegates to `ipPool()`.

#### `html( required string message )`

Convenience method for adding the text/html content.

#### `htmlContent( required string message )`

Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `html()`.

#### `plain( required string message )`

Convenience method for adding the text/plain content.

#### `plainContent( required string message )`

Redundant, but included for consistency in naming the methods for setting attributes. Delegates to `plain()`.

#### `plainFromHtml( string message="" )`

Convenience method for setting both html and plain at the same time. You can either pass in the HTML content, and both will be set from it (using a method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.

#### `useDesignEditor()`

The editor used in the UI. Because it defaults to `code`, it really only needs to be toggled to `design`.

#### `useCodeEditor()`

The editor used in the UI. It defaults to `code`, so this shouldn't be needed, but it's provided for consistency.

#### `build()`

Assembles the JSON to send to the API. Generally, you shouldn't need to call this directly.
