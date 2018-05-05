component {

	this.title = "SendGrid Web API v3";
	this.author = "Matthew Clemente";
	this.webURL = "";
	this.description = "This module will provide you with connectivity to the SendGrid Web API v3 for any ColdFusion (CFML) application.";
	this.version = "@version.number@+@build.number@";
	this.viewParentLookup = true;
	this.layoutParentLookup = true;
	this.entryPoint = 'sendGrid';
	this.modelNamespace = 'sendGrid';
	this.cfmapping = 'sendGrid';
	this.autoMapModels = false;

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
		parseParentSettings();
		var sendGridAPISettings = controller.getConfigSettings().sendGrid;

		binder.map( "sendGrid@sendGrid" )
			.to( "#moduleMapping#.sendgrid" )
			.initArg( name="apiKey", value=sendGridAPISettings.apiKey )
			.initArg( name="baseUrl", value=sendGridAPISettings.baseUrl )
			.initArg( name="forceTestMode", value=sendGridAPISettings.forceTestMode )
			.initArg( name="httpTimeout", value=sendGridAPISettings.httpTimeout )
			.initArg( name="includeRaw", value=sendGridAPISettings.includeRaw );
	}

	function onUnload(){
	}

	private function parseParentSettings(){
		var oConfig      = controller.getSetting( "ColdBoxConfig" );
		var configStruct = controller.getConfigSettings();
		var sendGridDSL  = oConfig.getPropertyMixin( "sendGrid", "variables", structnew() );

		//defaults
		configStruct.sendGrid = variables.settings;

		// incorporate settings
		structAppend( configStruct.sendGrid, sendGridDSL, true );
	}

}