# Reference Manual for `helpers.sender`

This section documents every public method in the `helpers/sender.cfc` file. A few notes about structure, data, and usage:

- Unless indicated, all methods are chainable.
- Email address parameters can be passed in either as strings or structs.
  - When passed as a string, they can be in the format: Person \<name@email.com\>, in order to pass both name and email address.
  - When passed as a struct, the keys should be `email` and `name`, respectively.

#### `nickname( required string nickname )`

Sets the nickname for the sender identity. Not used for sending, but required.

#### `from( required any email )`

Set where the email will appear to originate from for your recipients. The parameter `email` facilitates two means of setting who the email is from. You can pass in a struct with keys for `name` and `email` (only email is required), or you can pass in the email as a string. Note that, despite what the documentation says, both email address and name need to be provided. If a string is passed in and the name is not provided, the email address will be used as the name as well.

#### `replyTo( required any email )`

Set where your recipients will reply to. The parameter `email` Facilitates two means of setting who the recipient replies to. You can pass in a struct with keys for `name` and `email` (only email is required), or you can pass in the email as a string. If a string is passed in and the name is not provided, the email address will be used as the name as well.

#### `address( required string address )`

Required. Sets the physical address of the sender identity.

#### `address2( required string address )`

Optional. Provides additional sender identity address information.

#### `city( required string city )`

Required.

#### `state( required string state )`

Optional.

#### `zip( required string zip )`

Optional.

#### `country( required string country )`

Required.

#### `build()`

Assembles the JSON to send to the API. Generally, you shouldn't need to call this directly.
