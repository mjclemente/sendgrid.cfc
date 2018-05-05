component {

	// Module Properties
	this.title = "SendGrid Web API v3";
	this.author = "Matthew Clemente";
	this.webURL = "";
	this.description = "This module will provide you with connectivity to the SendGrid Web API v3 for any ColdFusion (CFML) application.";
	this.version = "@version.number@+@build.number@";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup = true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	this.entryPoint = 'sendGrid';
	this.modelNamespace = 'sendGrid';
	this.cfmapping = 'sendGrid';
	this.autoMapModels = false;

	/**
	 * Configure
	 */
	function configure(){

		// Settings
		settings = {
			apiKey = '', // Required
			baseUrl = 'https://api.sendgrid.com/v3', // Default value in init
			forceTestMode = false, // Default value in init
			httpTimeout = 60, // Default value in init
			includeRaw = true // Default value in init
		};
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		parseParentSettings();
		var sendGridAPISettings = controller.getConfigSettings().sendGrid;

		// Map Library
		binder.map( "sendGrid@sendGrid" )
			.to( "#moduleMapping#.sendgrid" )
			.initArg( name="apiKey", value=sendGridAPISettings.apiKey )
			.initArg( name="baseUrl", value=sendGridAPISettings.baseUrl )
			.initArg( name="forceTestMode", value=sendGridAPISettings.forceTestMode )
			.initArg( name="httpTimeout", value=sendGridAPISettings.httpTimeout )
			.initArg( name="includeRaw", value=sendGridAPISettings.includeRaw );
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}

	/**
	* parse parent settings
	*/
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