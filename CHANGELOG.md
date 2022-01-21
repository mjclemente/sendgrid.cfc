# Changelog

I will attempt to document all notable changes to this project in this file. I did not keep a changelog for pre-1.0 releases. Apologies.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [1.0.0] - 2022-01-20

### Added

- A changelog
- Methods `deleteBlock()`, `getCampaignSchedule()`, and `deleteBounce()`
- Parameters `page` and `page_size` to method `listRecipientsBySegment()`
- Parameter `limit` to method `getCampaignSchedule()`
- Support for passing your own struct/json into `updateEventWebhookSettings()` and `testEventWebhook()` instead of using the helper component.

### Changed

- Order of arguments in `listKeys()`, `listBrandedLinks()`, `listAllDomains()`. Moved `on_behalf_of` to be the final parameter, to match the rest of the methods using Subuser functionality.
- Argument name in `getSubuserReputations()` from `username` to `usernames` to match SendGrid.
- Argument name in `getUserProfile()` from `username` to `on_behalf_of` to match convention used throughout component for accessing Subuser information.
- Removed parameter defaults from `updateAuthenticatedDomain()` so that only explicit values are used in API requests.
- Updated `createAuthenticatedDomain()` to use `helpers.domain` instead of accepting all parameters.
- Moved most component documentation to `/docs`

### Fixed

- In `helpers.campaign`, the `useLists()` method now accepts arrays *and* lists, as documented.
