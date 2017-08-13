component accessors="true" {

  property name="from" default="";
  property name="subject" default="";
  property name="personalizations";
  property name="content" default="";
  property name="reply_to" default="";
  property name="attachments" default="";
  property name="template_id" default="";
  property name="sections" default="";
  property name="headers" default="";
  property name="categories" default="";
  property name="custom_args" default="";
  property name="send_at" default="";
  property name="batch_id" default="";
  property name="asm" default="";
  property name="ip_pool_name" default="";
  property name="mail_settings" default="";
  property name="tracking_settings" default="";

  /**
  * @hint You don't need to init this with any variables, but it's an optional approach
  * @content The assumption, when this is passed in, is that it is HTML, and that both html and plain text should be set and sent. Don't use the shortcut to init if you only want plain text
  */
  public any function init( any from, string subject, any to, string content ) {

    setPersonalizations( [] );
    setContent( [] );

    if ( arguments.keyExists( 'from' ) )
      this.from( from );

    if ( arguments.keyExists( 'subject' ) )
      setSubject( subject );

    if ( arguments.keyExists( 'to' ) )
      this.to( to );

    if ( arguments.keyExists( 'content' ) )
      plainFromHtml( content );

    return this;
  }

  public any function from( required any email ) {
    setFrom( parseEmail( email ) );
    return this;
  }

  /**
  * @hint sets the global, or "message level", subject. This may be overridden by personalizations[x].subject.
  */
  public any function subject( required string subject ) {
    setSubject( subject );
    return this;
  }

  /**
  * @hint convenience method for adding the text/html content
  */
  public any function html( required string message ) {
    var htmlContent = {
        'type' : 'text/html',
        'value' : message
      };
    return emailContent( htmlContent );
  }

  /**
  * @hint convenience method for adding the text/plain content
  */
  public any function plain( required string message ) {
    var plainContent = {
        'type' : 'text/plain',
        'value' : message
      };
    return emailContent( plainContent, false );
  }

  /**
  * @hint method for setting any content mimetype. The default is that the new mimetype is appended, but you can override this
  */
  public any function emailContent( required struct content, boolean doAppend = true ) {
    if ( doAppend )
      variables[ 'content' ].append( content );
    else
      variables[ 'content' ].prepend( content );
    return this;
  }

  /**
  * @hint convenience method for setting both text/html and text/plain at the same time. You can either pass in the HTML content, and both will be set from it (using a method to strip the HTML for the plain text version), or you can call the method without an argument, after having set the HTML, and that will be used.
  */
  public any function plainFromHtml( string message = '' ) {

    var plainContent = getPlainContent(); //don't know if this is needed. Not sure how SendGrid would handle it if mimetype were set twice.
    if ( plainContent.len() ) throw( 'The text/plain content has already been set.' );

    if ( !message.len() ) {

      var htmlContent = getHtmlContent();

      if ( !htmlContent.len() ) throw( 'The text/html content needs to be set prior to calling #getFunctionCalledName()# without the html argument.' );

      plain( removeHTML( htmlContent ) );

    } else {
      plain( removeHTML( message ) );
      html( message );
    }

    return this;
  }

  /**
  * @hint Adds a NEW personalization envelope, with only the specified email address. The personalization can then be further customized with later commands
  //TODO handle arrays?
  */
  public any function to( required any email ) {
    addPersonalization(
      {
        'to': [ parseEmail( email ) ]
      }
    );
    return this;
  }

  /**
  * @hint Adds an additional 'to' recipient to the CURRENT personalization envelope
  //TODO handle arrays?
  */
  public any function addTo( required any email ) {
    var count = countPersonalizations();

    if ( count ) {
      variables.personalizations[ count ][ 'to' ].append( parseEmail( email ) );

      return this;
    } else {
      return to( email );
    }
  }

  /**
  * @hint Adds an additional 'cc' recipient to the CURRENT personalization envelope
  */
  public any function addCC( required any email ) {
    return addCarbonCopies( email, 'cc' );
  }

  /**
  * @hint Adds an additional 'bcc' recipient to the CURRENT personalization envelope
  */
  public any function addBCC( required any email ) {
    return addCarbonCopies( email, 'bcc' );
  }

  /**
  * @hint Adds an additional cc/bcc receipients to the CURRENT personalization envelope
  */
  private any function addCarbonCopies( required any email, required string type ) {
    var count = countPersonalizations();
    if ( !count ) throw( "You must add a 'to' reciptient to this email before you can #type# additional recipients." );

    if ( !variables.personalizations[ count ].keyExists( type ) )
      variables.personalizations[ count ][ type ] = [];

    variables.personalizations[ count ][ type ].append( parseEmail( email ) );

    return this;
  }

  /**
  * @hint Creates and sets a new personalization envelope
  * Documentation about personalizations here: https://sendgrid.com/docs/Classroom/Send/v3_Mail_Send/personalizations.html
  * I find the easiest way to understand this is that each personalization object is an individual email. That it, all of its properties, even if there are multiple to/cc/bcc, refer to the same email. So if you're adding a second personalization object, you're basically referring to a separate email... except that the sender/content of the email is the same
  * Note: custom_args = internal tracking, while substitutions are for the content of the email/subject
  */
  public void function addPersonalization( required struct personalization ) {

    if ( !personalization.keyExists( 'to' ) ) throw( 'You must include at least one "to" object within the personalization object.' );

    variables.personalizations.append( personalization );
  }

  /**
  * @hint The function that puts it all together and build the JSON body for /mail/send
  */
  public struct function build() {
    var body = {
      'personalizations' : getPersonalizations(),
      'from' : getFrom(),
      'subject' : getSubject(),
      'content' : getContent()
    };

    return body;
  }

  private numeric function countPersonalizations() {
    return getPersonalizations().len();
  }

  private string function getHtmlContent() {
    return getContentByMimeType( 'text/html' );
  }

  private string function getPlainContent() {
    return getContentByMimeType( 'text/plain' );
  }

  private string function getContentByMimeType( required string mimetype ) {
    var mimeTypeContent = variables[ 'content' ].reduce(
        function( result, item, index ) {

          if ( item.type == mimetype );
            result = item.value;

          return result;
        }, ''
      );
    return mimeTypeContent;
  }

  /**
  * @hint If a struct is received, it is assumed it's in the proper format. Strings are parsed to check for bracketed email format
  */
  private struct function parseEmail( any email ) {
    if ( isStruct( email ) ) {
      return email;
    } else {
      var regex = '<([^>]+)>';
      var bracketedEmails = email.reMatchNoCase( regex );
      if ( bracketedEmails.len() ) {
        var bracketedEmail = bracketedEmails[1];
        return {
          'email' : bracketedEmail.REReplace( '[<>]', '', 'all'),
          'name' : email.replacenocase( bracketedEmail, '' ).trim()
        };

      } else {
        return {
          'email' : email,
          'name' : ''
        };

      }
    }
  }

  /** This could probably go in a separate utils CFC, but it's here for now
  * Removes All HTML from a string removing tags, script blocks, style blocks, and replacing special character code.
  *
  * @author Scott Bennett (scott@coldfusionguy.com)
  * @version 1, November 14, 2007
  */
  private string function removeHTML( required string source ){

    // Remove all spaces becuase browsers ignore them
    var result = ReReplace(trim(source), "[[:space:]]{2,}", " ","ALL");

    // Remove the header
    result = ReReplace(result, "<[[:space:]]*head.*?>.*?</head>","", "ALL");

    // remove all scripts
    result = ReReplace(result, "<[[:space:]]*script.*?>.*?</script>","", "ALL");

    // remove all styles
    result = ReReplace(result, "<[[:space:]]*style.*?>.*?</style>","", "ALL");

    // insert tabs in spaces of <td> tags
    result = ReReplace(result, "<[[:space:]]*td.*?>","  ", "ALL");

    // insert line breaks in places of <BR> and <LI> tags
    result = ReReplace(result, "<[[:space:]]*br[[:space:]]*>",chr(13), "ALL");
    result = ReReplace(result, "<[[:space:]]*li[[:space:]]*>",chr(13), "ALL");

    // insert line paragraphs (double line breaks) in place
    // if <P>, <DIV> and <TR> tags
    result = ReReplace(result, "<[[:space:]]*div.*?>",chr(13), "ALL");
    result = ReReplace(result, "<[[:space:]]*tr.*?>",chr(13), "ALL");
    result = ReReplace(result, "<[[:space:]]*p.*?>",chr(13), "ALL");

    // Remove remaining tags like <a>, links, images,
    // comments etc - anything thats enclosed inside < >
    result = ReReplace(result, "<.*?>","", "ALL");

    // replace special characters:
    result = ReReplace(result, "&nbsp;"," ", "ALL");
    result = ReReplace(result, "&bull;"," * ", "ALL");
    result = ReReplace(result, "&lsaquo;","<", "ALL");
    result = ReReplace(result, "&rsaquo;",">", "ALL");
    result = ReReplace(result, "&trade;","(tm)", "ALL");
    result = ReReplace(result, "&frasl;","/", "ALL");
    result = ReReplace(result, "&lt;","<", "ALL");
    result = ReReplace(result, "&gt;",">", "ALL");
    result = ReReplace(result, "&copy;","(c)", "ALL");
    result = ReReplace(result, "&reg;","(r)", "ALL");

    // Remove all others. More special character conversions
    // can be added above if needed
    result = ReReplace(result, "&(.{2,6});", "", "ALL");

    // Thats it.
    return result;

  }

}
