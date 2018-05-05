component {

	this.title = "SendGrid Web API v3";
	this.author = "Matthew J. Clemente";
	this.webURL = "https://github.com/mjclemente/sendgrid.cfc";
	this.description = "A wrapper for the SendGrid Web API v3";

	function configure(){
		settings = {
			apiKey = '', // Required
			baseUrl = 'https://api.sendgrid.com/v3', // Default value in init
			forceTestMode = false, // Default value in init
			httpTimeout = 60, // Default value in init
			includeRaw = true // Default value in init
		};
	}

	function onLoad(){
		binder.map( "sendgrid@sendgridcfc" )
			.to( "#moduleMapping#.sendgrid" )
      .asSingleton()
      .initWith(
        apiKey = settings.apiKey,
        baseUrl = settings.baseUrl,
        forceTestMode = settings.forceTestMode,
        httpTimeout = settings.httpTimeout,
        includeRaw = settings.includeRaw
      );
	}

}