# `sendgrid.cfc` Reference

## Mail Send Reference

*View SendGrid Docs for [Sending Mail](https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/index.html)*

#### `sendMail( required component mail )`

Sends email, using SendGrid's REST API. The parameter `mail` must be an instance of the `helpers.mail` component. The README provides examples of how to build and send an email.

---

### API Keys API Reference

*View SendGrid Docs for [API Keys](https://sendgrid.com/docs/API_Reference/Web_API_v3/API_Keys/index.html)*

#### `listKeys( numeric limit=0, string on_behalf_of="" )`

Retrieve all API Keys belonging to the authenticated user. The parameter `limit` limits the number of rows returned. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/api-keys/retrieve-all-api-keys-belonging-to-the-authenticated-user)*

#### `getAPIKey( required string api_key_id, string on_behalf_of="" )`

Retrieve an existing API Key. The parameter `api_key_id` is the ID of the API Key for which you are requesting information. The SendGrid docs for this endpoint explain where to find this. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/api-keys/retrieve-an-existing-api-key)*

#### `createAPIKey( required string name, array scopes=['mail.send'], string on_behalf_of="" )`

Creates an API key. The parameter `name` should be the name of your new key. The parameter `scopes` refers to the individual permissions that you are giving to this API Key ( [options listed here](https://sendgrid.api-docs.io/v3.0/how-to-use-the-sendgrid-v3-api/api-authorization) ). The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/api-keys/create-api-keys)*

#### `deleteAPIKey( required string api_key_id, string on_behalf_of="" )`

Delete an API key. The parameter `api_key_id` is the ID of the API Key for which you are requesting information. The SendGrid docs for this endpoint explain where to find this. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/api-keys/delete-api-keys)*

#### `updateAPIKeyName( required string api_key_id, required string name, string on_behalf_of="" )`

Updates the name of an existing API Key. The parameter `api_key_id` is the ID of the API Key for which you are requesting information. The SendGrid docs for this endpoint explain where to find this. The parameter `name` is the new name for the API Key that you are updating. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/api-keys/update-api-keys)*

#### `updateAPIKey( required string api_key_id, required string name, array scopes=['mail.send'], string on_behalf_of="" )`

Updates the name and scopes of a given API key. The parameter `api_key_id` is the ID of the API Key for which you are requesting information. The SendGrid docs for this endpoint explain where to find this. The parameter `name` is the updated name for the API Key that you are updating. It is required. The parameter `scopes` is optional and defaults to `mail.send`. It refers to the individual permissions that you are giving to this API Key ( [options listed here](https://sendgrid.api-docs.io/v3.0/how-to-use-the-sendgrid-v3-api/api-authorization) ). The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/api-keys/update-the-name-and-scopes-of-an-api-key)*

---

### Subusers API Reference

*View SendGrid Docs for [Subusers](https://sendgrid.com/docs/ui/account-and-settings/subusers/)*

#### `listAllSubusers( string username="", numeric limit=0, numeric offset=0 )`

Retrieve a list of all of your subusers. The parameter `username` is the username of the subuser to return.  (Optional). The parameter `limit` limits the number of results you would like to get in each request. (Optional). The parameter `offset` is the number of subusers to skip (Optional). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/list-all-subusers)*

#### `getSubuserMonitorSettings( required string subuser_name )`

Retrieves monitor settings for a subuser. The parameter `subuser_name` is the name of the subuser to return. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-monitor-settings-for-a-subuser)*

#### `getSubuserReputations( required string usernames )`

Retrieves subuser reputations. The parameter `usernames` is the name of the subuser that you are obtaining the reputation score for. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-subuser-reputations)*

#### `getSubuserMonthlyStats( required string subuser_name, required string date="", string sort_by_metric="", string sort_by_direction="", numeric limit=0, numeric offset=0 )`

Retrieve the monthly email statistics for a single subuser. The parameter `subuser_name` is the name of the subuser to return. The parameter `date` is the date the statistics were gathered in the format: YYYY-MM-DD. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-the-monthly-email-statistics-for-a-single-subuser)*

#### `getSubuserMonthlyStatsAllSubusers( required string date="", string subuser="", string sort_by_metric="", string sort_by_direction="", numeric limit=0, numeric offset=0 )`

Retrieve monthly stats for all subusers. The parameter `date` is the date the statistics were gathered in the format: YYYY-MM-DD. The parameter `subuser` is a substring search of your subusers. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-monthly-stats-for-all-subusers)*

#### `getAllSubuserTotals( required string start_date, string end_date="", string sort_by_metric="", string sort_by_direction="", string aggregated_by="", numeric limit=0, numeric offset=0 )`

Retrieve the totals for each email statistic metric for all subusers. The parameter `start_date` is the starting date of the statistics to retrieve in the format YYYY-MM-DD. The parameter `end_date` is the end date of the statistics to retrieve in the format YYYY-MM-DD. It defaults to today. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-the-totals-for-each-email-statistic-metric-for-all-subusers)*

#### `getSubuserStats( required string subusers, required string start_date, string end_date="", string sort_by_metric="", string sort_by_direction="", string aggregated_by="", numeric limit=0, numeric offset=0 )`

Allows you to retrieve the email statistics for the given subusers. The parameter `subusers` is the subusers you want to retrieve statistics for. You may include this parameter up to 10 times to retrieve statistics for multiple subusers. The parameter `start_date` is the starting date of the statistics to retrieve in the format YYYY-MM-DD. The parameter `end_date` is the end date of the statistics to retrieve in the format YYYY-MM-DD. It defaults to today. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/retrieve-email-statistics-for-your-subusers)*

#### `createSubuser( required string username, required string email, required string password, required array ips=[] )`

Creates a Subuser. The parameter `username` is the username for this subuser. The parameter `email` is the email address of the subuser. The parameter `password` is the password this subuser will use when logging into SendGrid. The parameter `ips` are the IP addresses that should be assigned to this subuser. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/create-subuser)*

#### `deleteSubuser( required string subuser_name )`

Delete a subuser. The parameter `subuser_name` is the name of the subuser to delete. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/delete-a-subuser)*

#### `updateSubuserIPs( required string subuser_name, required array ips=[] )`

Update IPs assigned to a subuser. The parameter `subuser_name` is the name of the subuser to update. The parameter `ips` are the IP addresses that are assigned to the subuser. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/subusers-api/update-ips-assigned-to-a-subuser)*

---

### Link Branding API Reference

*View SendGrid Docs for [Link Branding](https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-all-link-branding)*

#### `listBrandedLinks( numeric limit=0, string on_behalf_of="" )`

Retrieve all branded links. The parameter `limit` limits the number of rows returned. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-all-link-branding)*

#### `getBrandedLink( required numeric id=0, string on_behalf_of="" )`

Retrieve a branded link. The parameter `id` is the id of the branded link you want to retrieve. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-branded-link)*

#### `getDefaultBrandedLink( string domain="", string on_behalf_of="" )`

Retrieve the default branded link. The default branded link is the actual URL to be used when sending messages. The parameter `domain` is the domain to match against when finding a corresponding branded link. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-the-default-branded-link)*

#### `getSubuserBrandedLink( required string username="" )`

Retrieve a subuser's branded link. The parameter `username` specifies the username of the subuser to retrieve associated branded links for. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/retrieve-a-subusers-branded-link)*

#### `createLinkBranding( required string domain, string subdomain="", boolean default, string on_behalf_of="" )`

Create a branded link. The parameter `domain` is the root domain for your subdomain that you are creating the link branding for. This should match your FROM email address. The parameter `subdomain` is the subdomain to create the link branding for. Must be different from the subdomain you used for authenticating your domain. The parameter `default` indicates if you want to use this link branding as the fallback, or as the default. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/create-a-link-branding)*

#### `deleteBrandedLink( required numeric id, string on_behalf_of="" )`

Delete a branded link. The parameter `id` is the id of the branded link you want to delete. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/delete-a-branded-link)*

#### `validateLinkBranding( required numeric id=0, string on_behalf_of="" )`

Validate a branded link. The parameter `id` is the id of the branded link you want to delete. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/validate-a-branded-link)*

#### `associateLinkBranding( required numeric link_id, string username="" )`

Associate a branded link with a subuser. The parameter `link_id` is the id of the branded link you want to associate. The parameter `username` is the username of the subuser account that you want to associate the branded link with. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/associate-a-branded-link-with-a-subuser)*

#### `disassociateBrandedLink( required string username )`

Disassociate link branding from a subuser. The parameter `username` is the username of the subuser account that you want to disassociate link branding from. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/link-branding/disassociate-link-branding-from-a-subuser)*

---

### Domain Authentication API Reference

*View SendGrid Docs for [Domains](https://sendgrid.com/docs/API_Reference/Web_API_v3/Whitelabel/domains.html)*

#### `listAllDomains( numeric limit=0, numeric offset=0, boolean exclude_subusers=false, string username="", string domain="", string on_behalf_of="" )`

List all authenticated domains. The parameter `exclude_subusers` excludes subuser domains from the result. The parameter `username` is the username associated with an authenticated domain. The parameter `domain` searches for authenticated domains. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/list-all-authenticated-domains)*

#### `getAuthenticatedDomain( required numeric domain_id=0, string on_behalf_of="" )`

Retrieve an authenticated domain. The parameter `domain_id` is the id of the authenticated domain you want to retrieve. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/retrieve-a-authenticated-domain)*

#### `createAuthenticatedDomain( required any domain, string on_behalf_of="" )`

Authenticate a domain. The parameter `domain` should be an instance of the `helpers.domain` component. However, if you want to create and pass in the struct or json yourself, you can. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/authenticate-a-domain)*

#### `updateAuthenticatedDomain( required numeric domain_id, boolean custom_spf, boolean default, string on_behalf_of="" )`

Update an authenticated domain. The parameter `domain_id` is the domain ID to be updated. The parameter `custom_spf` specifies whether to use a custom SPF or allow SendGrid to manage your SPF. This option is only available to authenticated domains set up for manual security. The parameter `default` indicates whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/update-an-authenticated-domain)*

#### `deleteAuthenticatedDomain( required numeric domain_id=0, string on_behalf_of="" )`

Delete an authenticated domain. The parameter `domain_id` is the id of the domain you want to delete. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/delete-an-authenticated-domain)*

#### `getDefaultAuthenticatedDomain( string on_behalf_of="" )`

Get the default authenticated domain. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/get-the-default-authentication)*

#### `addIPAuthenticatedDomain( required numeric domain_id, required string ip, string on_behalf_of="" )`

Add an IP to an authenticated domain. The parameter `domain_id` is the ID of the domain to be updated. The parameter `ip` is the IP to associate with the domain. Used for manually specifying IPs for custom SPF. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/add-an-ip-to-an-authenticated-domain)*

#### `deleteIPForAuthenticatedDomain( required numeric domain_id, required string ip, string on_behalf_of="" )`

Remove an IP from an authenticated domain. The parameter `domain_id` is the ID of the domain to delete the IP from. The parameter `ip` is the IP to remove from the domain. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/remove-an-ip-from-an-authenticated-domain)*

#### `validateAuthenticatedDomain( required numeric domain_id, string on_behalf_of="" )`

Validate a domain authentication. The parameter `domain_id` is the ID of the domain to validate. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/validate-a-domain-authentication)*

#### `listSubuserAuthenticatedDomain( required string username )`

List the authenticated domain associated with the given user. The parameter `username` is the username for the subuser to find associated authenticated domain. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/list-the-authenticated-domain-associated-with-the-given-user)*

#### `disassociateSubuserAuthenticatedDomain( required string username )`

Disassociate a authenticated domain from a given user. The parameter `username` is the username for the subuser to disassociate from an authenticated domain. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/disassociate-an-authenticated-domain-from-a-given-user)*

#### `associateSubuserWithAuthenticatedDomain( required numeric domain_id, required string username )`

Associate a authenticated domain with a given user. The parameter `domain_id` is the ID of the authenticated domain to associate with the subuser. The parameter `username` is the username to associate with the authenticated domain. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/domain-authentication/associate-an-authenticated-domain-with-a-given-user)*

---

### IP Addresses API Reference

*View SendGrid Docs for [IP Addresses](https://sendgrid.com/docs/API_Reference/Web_API_v3/IP_Management/ip_addresses.html)*

#### `addIPs( required numeric count, array subusers=[], boolean warmpup=false )`

Add IPs to your account. The parameter `count` is the number of IPs to add to the account. The parameter `subusers` can be an array of usernames to be assigned a send IP. The parameter `warmpup` indicates whether or not to warmup the IPs being added. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-addresses/ips-add)*

#### `getIPsRemaining()`

Gets amount of IP Addresses that can still be created during a given period and the price of those IPs. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-addresses/ips-remaining)*

#### `listAllIPs( string ip="", string subuser="", boolean exclude_whitelabels=false, string sort_by_direction="", numeric limit=0, numeric offset=0 )`

Retrieve all IP addresses. The parameter `ip` is an IP address to get (Optional). The parameter `subuser` is a subuser you are requesting for (Optional). The parameter `exclude_whitelabels` provides the ability to exclude reverse DNS records (whitelabels). The parameter `sort_by_direction` is the direction to sort the results (desc, asc). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-addresses/retrieve-all-ip-addresses)*

#### `getIPsAssigned()`

Retrieve all assigned IPs  (Throws internal error even on sendgrids sample). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-addresses/retrieve-all-assigned-ips)*

#### `getIPPools( required string ip="" )`

Retrieve all IP pools an IP address belongs to. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-addresses/retrieve-all-ip-pools-an-ip-address-belongs-to)*

#### `createIPPool( required string name )`

Create an IP pool. Note that before you can create an IP Pool, you need to activate the IP in your SendGrid account. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/create-an-ip-pool)*

#### `listAllIPPools()`

Retrieve all IP pools. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/retrieve-all-ip-pools)*

#### `getPoolIPs( required string ippool="" )`

Retrieve all IPs in a specified pool. The parameter `ippool` is the name of the IP pool you are retrieving IPs for. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/retrieve-all-ips-in-a-specified-pool)*

#### `updatePoolName( required string name, required string new_pool_name )`

Update an IP pool’s name. The parameter `name` is the name of the IP pool that you want to rename. The parameter `new_pool_name` is the new name for your IP pool. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/update-an-ip-pool-s-name)*

#### `deleteIPPool( required string name )`

Delete an IP pool. The parameter `name` is the name of the IP pool that you want to delete. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/delete-an-ip-pool)*

#### `addIPToPool( required string name, required string ip )`

Add an IP address to a pool. The parameter `name` is the name of the IP pool that you want to add the IP to. The parameter `ip` is the IP address that you want to add to an IP pool. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/add-an-ip-address-to-a-pool)*

#### `deleteIPFromPool( required string name, required string ip )`

Remove an IP address from a pool. The parameter `name` is the name of the IP pool that you want to delete an IP from. The parameter `ip` is the IP address that you are removing. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/ip-pools/remove-an-ip-address-from-a-pool)*

---

### Users API Reference

*View SendGrid Docs for [Users](https://sendgrid.com/docs/API_Reference/Web_API_v3/user.html)*

#### `getUserProfile( string on_behalf_of="" )`

Get a user's profile. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/get-a-user-s-profile)*

#### `updateUserProfile( string firstName="", string lastName="", string on_behalf_of="" )`

Update a user's profile. The parameter `firstName` is the first name of the user. The parameter `lastName` is the last name of the user. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/update-a-user-s-profile)*

#### `getUserAccount( string on_behalf_of="" )`

Get a user's account information. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/get-a-user-s-account-information)*

#### `getUserEmail( string on_behalf_of="" )`

Retrieve your account email address. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/retrieve-your-account-email-address)*

#### `updateUserEmail( required string email, string on_behalf_of="" )`

Update your account email address. The parameter `email` is the new email address that you would like to use for your account. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/update-your-account-email-address)*

#### `getUserUsername( string on_behalf_of="" )`

Retrieve your username. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/retrieve-your-username)*

#### `updateUserUsername( required string username, string on_behalf_of="" )`

Update your username. The parameter `username` is the new username you would like to use for your account. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/update-your-username)*

#### `updateUserPassword( required string oldpassword, required string newpassword, string on_behalf_of="" )`

Update your password. The parameter `oldpassword` is the old password for your account. The parameter `newpassword` is the new password you would like to use for your account. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/update-your-password)*

#### `getUserCreditBalance( string on_behalf_of="" )`

Retrieve your credit balance. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/users-api/retrieve-your-credit-balance)*

---

### Webhooks API Reference

*View SendGrid Docs for [Webhooks](https://sendgrid.com/docs/API_Reference/Web_API_v3/Webhooks/event.html)*

#### `getEventWebhookSettings( string on_behalf_of="" )`

Retrieve Event Webhook settings. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/retrieve-event-webhook-settings)*

#### `updateEventWebhookSettings( required any webhook, string on_behalf_of="" )`

Update a webhook's event notification settings. The parameter `webhook` should be an instance of the `helpers.webhook` component. However, if you want to create and pass in the struct or json yourself, you can. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/update-event-notification-settings)*

#### `testEventWebhook( required any webhook, string on_behalf_of="" )`

Test your event webhook by sending a fake event notification post to the provided URL. The parameter `webhook` should be an instance of the `helpers.webhook` component. However, if you want to create and pass in the struct or json yourself, you can. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/test-event-notification-settings)*

#### `getEventWebhookSignedPublicKey( string on_behalf_of="" )`

Retrieve your signed webhook's public key. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/retrieve-signed-webhook-public-key)*

#### `enableEventSignedWebhook( required boolean enabled, string on_behalf_of="" )`

Enable or disable signing of the Event Webhook. The parameter `enabled` is boolean value that either enables or disables signing of the Event Webhook using this endpoint. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/enable-disable-signed)*

#### `getEventWebhookParseSettings( string on_behalf_of="" )`

Retrieve your current inbound parse webhook settings. The parameter `on_behalf_of` generates the API call as if the subuser account was making the request. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/retrieve-parse-webhook-settings)*

#### `getEventWebhookParseStats( required string start_date, string end_date="", string aggregated_by="", numeric limit=0, numeric offset=0 )`

Retrieve the statistics for your Parse Webhook usage. The parameter `start_date` is the starting date of the statistics to retrieve. Must follow format YYYY-MM-DD. The parameter `end_date` is the end date of the statistics to retrieve. Defaults to today. Must follow format YYYY-MM-DD. The parameter `aggregated_by` indicates how you would like the statistics to by grouped. Allowed Values: `day`, `week`, `month` (Optional). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/webhooks/retrieves-inbound-parse-webhook-statistics)*

---

### Blocks API Reference

*View SendGrid Docs for [Blocks](https://sendgrid.com/docs/API_Reference/Web_API_v3/blocks.html)*

#### `listBlocks( any start_time=0, any end_time=0, numeric limit=0, numeric offset=0 )`

Retrieve a list of all email addresses that are currently on your blocks list. The parameter `start_time` is the start of the time range when the blocked email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. The parameter `end_time` is the end of the time range when the blocked email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/blocks-api/retrieve-all-blocks)*

#### `getBlock( required string email )`

Retrieve a specific email address from your blocks list. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/blocks-api/retrieve-a-specific-block)*

#### `deleteBlock( required string email )`

Remove a specific email address from your blocks list. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/blocks-api/delete-a-specific-block)*

---

### Bounces API Reference

*View SendGrid Docs for [Bounces](https://sendgrid.com/docs/API_Reference/Web_API_v3/bounces.html)*

#### `listBounces( any start_time=0, any end_time=0, numeric limit=0, numeric offset=0 )`

Retrieve a list of bounces that are currently on your bounces list. The parameter `start_time` is the start of the time range when the bounce was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. The parameter `end_time` is the end of the time range when the bounce was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/bounces-api/retrieve-all-bounces)*

#### `getBounce( required string email )`

Retrieve bounce information for a given email address. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/bounces-api/retrieve-a-bounce)*

#### `deleteBounce( required string email )`

Remove an email address from your block list. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/bounces-api/delete-a-bounce)*

---

### Campaigns API Reference

*View SendGrid Docs for [Campaigns](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/campaigns.html)*

#### `createCampaign( required any campaign )`

Create a marketing campaign. The parameter `campaign` should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can.

#### `listCampaigns( numeric limit=0 )`

Retrieve a list of all of your campaigns. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/campaigns-api/retrieve-all-campaigns)*

#### `getCampaign( required numeric id )`

Retrieve a single campaign by ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/campaigns-api/retrieve-a-single-campaign)*

#### `deleteCampaign( required numeric id )`

Delete a single campaign by ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/campaigns-api/delete-a-campaign)*

#### `updateCampaign( required numeric id, required any campaign )`

Update a campaign by ID. The parameter `campaign` this should be an instance of the `helpers.campaign` component. However, if you want to create and pass in the struct or json yourself, you can. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/campaigns-api/update-a-campaign)*

#### `getCampaignSchedule( required numeric id )`

View scheduled time of a Campaign. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/campaigns-api/view-scheduled-time-of-a-campaign)*

---

### Contacts API - Recipients Reference

*View SendGrid Docs for [Contacts API - Recipients](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Recipients)*

#### `addRecipients( required array recipients )`

Add Marketing Campaigns recipients. Note that it also appears to update existing records, so it basically functions like a PATCH. The parameter `recipients` is an array of objects, with at minimum an `email` key/value. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/add-recipients)*

#### `addRecipient( required any recipient, string first_name="", string last_name="", struct customFields={} )`

Convenience method for adding a single recipient at a time. The parameter `recipient` Facilitates two means of adding a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required. The parameter `customFields` is a struct with keys corresponding to the custom field names, along with their assigned values.

#### `updateRecipients( required array recipients )`

Update one or more Marketing Campaign recipients. Note that it will also add non-existing records. The parameter `recipients` an array of objects, with at minimum, an `email` key/value. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/update-recipient)*

#### `updateRecipient( required any recipient, string first_name="", string last_name="", struct customFields={} )`

Convenience method for updating a single recipient at a time. The parameter `recipient` Facilitates two means of updating a recipient. You can pass in a struct with key/value pairs providing all relevant recipient information. Alternatively, you can use this to simply pass in the recipient's email address, which is all that is required. The parameter `customFields` is a struct with keys corresponding to the custom field names, along with their assigned values.

#### `getRecipientUploadStatus()`

Check the upload status of a Marketing Campaigns recipient. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/get-recipient-upload-status)*

#### `deleteRecipient( required string id )`

Delete a single recipient with the given ID from your contact database. The parameter `id` is the recipient ID or email address (which will be automatically converted to the recipient ID). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/delete-a-recipient)*

#### `deleteRecipients( required array recipients )`

Deletes one or more recipients. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/recipients`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the recipients through the individual delete method. The parameter `recipients` is an array of the recipient IDs you want to delete. You can also provide their email addresses, and they will be converted to recipient IDs. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/delete-recipient)*

#### `listRecipients( numeric page=0, numeric pageSize=0 )`

Retrieve all of your Marketing Campaign recipients. The parameter `page` is the page index of first recipients to return (must be a positive integer). The parameter `pageSize` is the number of recipients to return at a time (must be a positive integer between 1 and 1000). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-recipients)*

#### `getRecipient( required string id )`

Retrieve a single recipient by ID from your contact database. The parameter `id` is the recipient ID or email address (which will be automatically converted to the recipient ID). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-a-single-recipient)*

#### `listListsByRecipient( required string id )`

Retrieve the lists that a given recipient belongs to. The parameter `id` is the recipient ID or email address (which will be automatically converted to the recipient ID). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-the-lists-that-a-recipient-is-on)*

#### `getBillableRecipientCount()`

Retrieve the number of Marketing Campaigns recipients that you will be billed for. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-the-count-of-billable-recipients)*

#### `getRecipientCount()`

Retrieve the total number of Marketing Campaigns recipients. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-a-count-of-recipients)*

#### `searchRecipients( required string fieldName, any search="" )`

Perform a search on all of your Marketing Campaigns recipients. The parameter `fieldName` is the name of a custom field or reserved field. The parameter `search` is the value to search for within the specified field. Date fields must be unix timestamps. Currently, searches that are formatted as a U.S. date in the format mm/dd/yyyy (1-2 digit days and months, 1-4 digit years) are converted automatically. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-recipients/retrieve-recipients-matching-search-criteria)*

---

### Contacts API - Custom Fields Reference

*View SendGrid Docs for [Contacts API - Custom Fields](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Custom-Fields)*

#### `createCustomField( required string name, required string type )`

Create a custom field. The parameter `type` accepts the values 'text', 'date', and 'number'.

#### `listCustomFields()`

Retrieve all custom fields.

#### `getCustomField( required numeric id )`

Retrieve a custom field by ID.

#### `deleteCustomField( required numeric id )`

Delete a custom field by ID.

#### `listReservedFields()`

List all fields that are reserved and can't be used for custom field names.

---

### Contacts API - Lists Reference

*View SendGrid Docs for [Contacts API - Lists](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Lists)*

#### `createList( required string name )`

Create a list for your recipients. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/create-a-list)*

#### `listLists()`

Retrieve all of your recipient lists. If you don't have any lists, an empty array will be returned. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-all-lists)*

#### `deleteLists( required array lists )`

Delete multiple recipient lists. This is an incomplete implementation of the SendGrid API. Technically, this should send a DELETE request to `/contactdb/lists`, with an array of IDs as the body. But ColdFusion doesn't currently include the request body in DELETE calls. So we loop the lists through the individual delete method. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-multiple-lists)*

#### `deleteList( required numeric id )`

Delete a single list with the given ID from your contact database. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-a-list)*

#### `getList( required numeric id )`

Retrieve a single recipient list by ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-a-single-list)*

#### `updateList( required numeric id, required string name )`

Update the name of one of your recipient lists.

#### `listRecipientsByList( required numeric id, numeric page=0, numeric pageSize=0 )`

Retrieve all recipients on the list with the given ID. The parameter `page` is the page index of first recipient to return (must be a positive integer). The parameter `pageSize` is the number of recipients to return at a time (must be a positive integer between 1 and 1000). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/retrieve-all-recipients-on-a-list)*

#### `addRecipientToList( required numeric listId, required string recipientId )`

Add a single recipient to a list. The parameter `recipientId` is the recipient ID or email address (which will be automatically converted to the recipient ID). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/add-a-single-recipient-to-a-list)*

#### `deleteRecipientFromList( required numeric listId, required string recipientId )`

Delete a single recipient from a list. The parameter `recipientId` is the recipient ID or email address (which will be automatically converted to the recipient ID). *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/delete-a-single-recipient-from-a-single-list)*

#### `addRecipientsToList( required numeric listId, required array recipients )`

Add multiple recipients to a list. The parameter `recipients` is an array of recipient IDs or email addresses. The first element of the array is checked to determine if it is an array of IDs or email addresses. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-lists/add-multiple-recipients-to-a-list)*

---

### Contacts API - Segments Reference

*View SendGrid Docs for [Contacts API - Segments](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/contactdb.html#-Segments)*

#### `createSegment( required string name, required array conditions, numeric listId=0 )`

Create a segment using search conditions. The parameter `conditions` is an array of structs making up the search conditions that define this segment. Read SendGrid documentation for specifics on how to segment contacts. The parameter `listId` is the list id from which to make this segment. Not including this ID will mean your segment is created from the main contactdb rather than a list. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-segments/create-a-segment)*

#### `listSegments()`

Retrieve all of your segments. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-segments/retrieve-all-segments)*

#### `getSegment( required numeric id )`

Retrieve a single segment with the given ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-segments/retrieve-a-segment)*

#### `updateSegment( required numeric id, string name="", array conditions=[], numeric listId=0 )`

Update a segment. Functions similarly to `createSegment()`, but you only need to include the parameters you are updating. The parameter `listId` is the list id from which to make this segment. Note that this can be used to change the list for this segment, but once a list has been set, the segment cannot be returned to the main contactdb.

#### `deleteSegment( required numeric id )`

Delete a segment from your recipients database. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-segments/delete-a-segment)*

#### `listRecipientsBySegment( required numeric id, numeric page=0, numeric page_size=0 )`

Retrieve all of the recipients in a segment with the given ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/contacts-api-segments/retrieve-recipients-on-a-segment)*

---

### Invalid Emails API Reference

*View SendGrid Docs for [Invalid Emails](https://sendgrid.com/docs/API_Reference/Web_API_v3/invalid_emails.html)*

#### `listInvalidEmails( any start_time=0, any end_time=0, numeric limit=0, numeric offset=0 )`

Retrieve a list of invalid emails that are currently on your invalid emails list. The parameter `start_time` is the start of the time range when the invalid email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. The parameter `end_time` is the end of the time range when the invalid email was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/invalid-emails-api/retrieve-all-invalid-emails)*

#### `getInvalidEmail( required string email )`

Retrieve information about a specific invalid email address. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/invalid-emails-api/retrieve-a-specific-invalid-email)*

---

### Sender Identities API Reference

*View SendGrid Docs for [Sender Identities](https://sendgrid.com/docs/API_Reference/Web_API_v3/Marketing_Campaigns/sender_identities.html)*

#### `createSender( required any sender )`

Create a new sender identity. The parameter `sender` should be an instance of the `helpers.sender` component. However, if you want to create and pass in the struct or json yourself, you can. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/sender-identities-api/create-a-sender-identity)*

#### `listSenders()`

Retrieve a list of all sender identities that have been created for your account. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/sender-identities-api/get-all-sender-identities)*

#### `updateSender( required numeric id, required any sender )`

Update a sender identity by ID. The parameter `sender` should be an instance of the `helpers.sender` component. However, if you want to create and pass in the struct or json yourself, you can. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/sender-identities-api/update-a-sender-identity)*

#### `deleteSender( required numeric id )`

Delete a single sender identity by ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/sender-identities-api/delete-a-sender-identity)*

#### `resendSenderVerification( required numeric id )`

Resend a sender identity verification email. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/sender-identities-api/resend-sender-identity-verification)*

#### `getSender( required numeric id )`

Retrieve a single sender identity by ID. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/sender-identities-api/view-a-sender-identity)*

---

### Cancel Scheduled Sends Reference

*View SendGrid Docs for [Cancel Scheduled Sends](https://sendgrid.com/docs/API_Reference/Web_API_v3/cancel_schedule_send.html)*

#### `generateBatchId()`

Generate a new batch ID. This batch ID can be associated with scheduled sends via the mail/send endpoint. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/cancel-scheduled-sends/create-a-batch-id)*

---

### Spam Reports API Reference

*View SendGrid Docs for [Spam Reports](https://sendgrid.com/docs/API_Reference/Web_API_v3/spam_reports.html)*

#### `listSpamReports( any start_time=0, any end_time=0, numeric limit=0, numeric offset=0 )`

Retrieve a list of spam reports that are currently on your spam reports list. The parameter `start_time` is the start of the time range when the spam reports was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. The parameter `end_time` is the end of the time range when the spam reports was created. If numeric, it's assumed to be a unix timestamp. Otherwise, it's presumed to be a valid date that will be converted to a unix timestamp automatically. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/spam-reports-api/retrieve-all-spam-reports)*

#### `getSpamReport( required string email )`

Retrieve a specific spam report by email address. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/spam-reports-api/retrieve-a-specific-spam-report)*

---

### Suppressions - Suppressions Reference

*View SendGrid Docs for [Suppressions - Suppressions](https://sendgrid.com/docs/API_Reference/Web_API_v3/Suppression_Management/suppressions.html)*

#### `addEmailsToUnsubscribeGroup( required numeric id, required array emails )`

Add email addresses to an unsubscribe group. If you attempt to add suppressions to a group that has been deleted or does not exist, the suppressions will be added to the global suppressions list. The parameter `emails` is an array of email addresses. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/add-suppressions-to-a-suppression-group)*

#### `addEmailToUnsubscribeGroup( required numeric id, required string email )`

Convenience method for adding a single email address to an unsubscribe group. Delegates to `addEmailsToUnsubscribeGroup()`.

#### `listEmailsByUnsubscribeGroup( required numeric id )`

Retrieve all suppressed email addresses belonging to the given group. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/retrieve-all-suppressions-for-a-suppression-group)*

#### `deleteEmailFromUnsubscribeGroup( required numeric id, required string email )`

Remove a suppressed email address from the given suppression group. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/delete-a-suppression-from-a-suppression-group)*

#### `listAllSupressions()`

Retrieve a list of all suppressions. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/retrieve-all-suppressions)*

#### `listUnsubscribeGroupsByEmail( required string email )`

Appears to slightly differ from the documentation. Returns all supressions groups, with an indication if the email address is supressed or not. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/retrieve-all-suppression-groups-for-an-email-address)*

#### `searchUnsubscribeGroupForEmails( required numeric id, required array emails )`

Search a suppression group for multiple suppressions. The parameter `emails` is an array of email address that you want to search the suppression group for. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-suppressions/search-for-suppressions-within-a-group)*

#### `searchUnsubscribeGroupForEmail( required numeric id, required string email )`

Convenience method for searching for a single email within an unsubscribe group. Delegates to `searchUnsubscribeGroupForEmails()`.

---

### Suppressions - Unsubscribe Groups Reference

*View SendGrid Docs for [Suppressions - Unsubscribe Groups](https://sendgrid.com/docs/API_Reference/Web_API_v3/Suppression_Management/groups.html)*

#### `createUnsubscribeGroup( required string name, required string description, boolean isDefault )`

Create a new unsubscribe suppression group. The parameter `name` is the name of the group and can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (30) by silently trimming excess characters. The parameter `description` is a description of the group that can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (100) by silently trimming excess characters. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/create-a-new-suppression-group)*

#### `listUnsubscribeGroups()`

Retrieve a list of all suppression groups created by this user. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/retrieve-all-suppression-groups-associated-with-the-user)*

#### `getUnsubscribeGroup( required numeric id )`

Retrieve a single suppression group. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/get-information-on-a-single-suppression-group)*

#### `updateUnsubscribeGroup( required numeric id, string name="", string description="", required boolean isDefault )`

Update an unsubscribe suppression group. The parameter `name` is the name of the group and can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (30) by silently trimming excess characters. The parameter `description` is a description of the group that can be seen by recipients on the unsubscribe landing page. SendGrid enforces the max length (100) by silently trimming excess characters. The parameter `isDefault` is required by this library, because if you don't supply it, SendGrid assumes false, which is confusing. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/update-a-suppression-group)*

#### `deleteUnsubscribeGroup( required numeric id )`

Delete a suppression group. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/suppressions-unsubscribe-groups/delete-a-suppression-group)*

---

### Validate Email

*View SendGrid Docs for [Validate Email](https://sendgrid.api-docs.io/v3.0/email-address-validation/validate-an-email)*

#### `validateEmail( required string email, string source="" )`

Retrive a validation information about an email address. **Important**: SendGrid's email validation endpoint requires a separate API key from their primary email API. Additionally, this service is only available on their "Pro" tier, or higher. For a bit more information about SendGrid's email validation, you can read their [documentation](https://sendgrid.com/docs/ui/managing-contacts/email-address-validation/) and [product page](https://sendgrid.com/solutions/email-validation-api/). The parameter `email` is the address to validate. The parameter `source` is a one word classifier for the validation. *[Endpoint docs](https://sendgrid.api-docs.io/v3.0/email-address-validation/validate-an-email)*
