# sendgridcfc
A CFML wrapper for the SendGrid API

This project borrows heavily from the API frameworks built by [jcberquist](https://github.com/jcberquist), such as [stripecfc](https://github.com/jcberquist/stripecfc), [xero-cfml](https://github.com/jcberquist/xero-cfml), and [aws-cfml](https://github.com/jcberquist/aws-cfml).

This is a very early stage API wrapper. Feel free to use the issue tracker to report bugs or suggest improvements!

# Quick Start (with helper)

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

Here are the currently available public methods for building the mail object (unless indicated, all methods are chainable):

### `from( required any email )`
### `subject( required string subject )`
Sets the global, or "message level", subject. This may be overridden by personalizations[x].subject.
### `html( required string message )`
Convenience method for adding the text/html content
### `plain( required string message )`
Convenience method for adding the text/plain content
### `emailContent( required struct content, boolean doAppend = true )`
Method for setting any content mime-type. The default is that the new mime-type is appended to the Content array, but you can override this and have it prepended. This is used internally to ensure that `text/plain` precedes `text/html`, in accordance with the RFC specs, as enforced by SendGrid.
### `plainFromHtml( string message = '' )`
Convenience method for setting both `text/html` and `text/plain` at the same time. You can either pass in the HTML content as the message argument, and both will be set from it (using an internal method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.
### `to( required any email )`
Adds a **new** personalization envelope, with only the specified email address. The personalization can then be further customized with later commands. I found personalizations a little tricky. You can [read more here](https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/personalizations.html).
### `addTo( required any email )`
Adds an additional 'to' recipient to the **current** personalization envelope
### `addCC( required any email )`
Adds an additional 'cc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.
### `addBCC( required any email )`
Adds an additional 'bcc' recipient to the **current** personalization envelope. You need to add a 'to' recipient before using this.
### `build()`
The function that puts it all together and builds the body for `/mail/send`


## Notes

* Email address parameters can be passed in either as strings or structs.
  * When passed as a string, they can be in the format: Person \<name@email.com\>, in order to pass both name and email address.
  * When passed as a struct, the keys should be `email` and `name`, respectively. Only email is required.