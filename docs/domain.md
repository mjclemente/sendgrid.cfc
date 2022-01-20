# Reference Manual for `helpers.domain`

This section documents every public method in the `helpers/domain.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.

#### `domain( required string domain )`

Required. Sets the domain being authenticated.

#### `subdomain( required string subdomain )`

Sets the subdomain to use for this authenticated domain.

#### `username( required string username )`

Sets the username associated with this domain.

#### `custom_spf( required boolean custom_spf )`

Specify whether to use a custom SPF or allow SendGrid to manage your SPF. This option is only available to authenticated domains set up for manual security.

#### `default( required boolean default )`

Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain.

#### `automatic_security( required boolean automatic_security )`

Whether to allow SendGrid to manage your SPF records, DKIM keys, and DKIM key rotation.

#### `custom_dkim_selector( required string custom_dkim_selector )`

Sets a custom DKIM selector. Accepts three letters or numbers.

#### `ips( required any ips )`

Set an array of ips you would like associated to this domain. If ips are already set, this overwrites them. The parameter `ips` can be passed in as an array or comma separated list. Lists will be converted to arrays.

#### `addIp( required string ip )`

Appends a single ip to the ips array.

#### `build()`

Assembles the JSON to send to the API. Generally, you shouldn't need to call this directly.
