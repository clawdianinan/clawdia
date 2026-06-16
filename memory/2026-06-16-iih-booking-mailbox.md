# IIH Booking Mailbox Change - 2026-06-16

- Temi clarified that the bookings mailbox identity changed from `eventbookings@iih.ng` to `facilitybookings@iih.ng`.
- The mailbox is understood to be the same underlying Zoho mailbox/credentials, with only the name/alias changed.
- Runtime booking config, connector defaults, keychain prompt labels, Aisha instructions, and local booking documentation were updated to use `facilitybookings@iih.ng`.
- Himalaya account `facilitybookings` was added using Zoho IMAP/SMTP and the booking app-password keychain service `iih-booking-ZOHO_APP_PASSWORD`.
- `ZOHO_APP_PASSWORD` was saved locally in Keychain after Temi generated a Zoho app password using app name "IIH Booking Agent".
- SMTP login for `facilitybookings@iih.ng` succeeds.
- IMAP login for `facilitybookings@iih.ng` succeeds after Temi enabled IMAP.
- Himalaya folder listing works for the `facilitybookings` account.
- Remaining blocker for full Zoho Books/CRM/Calendar connector use: OAuth/client/org/calendar secrets are still missing locally.
- Zoho OAuth Client ID and Client Secret for "IIH Booking Agent" were saved into Keychain services `iih-booking-ZOHO_CLIENT_ID` and `iih-booking-ZOHO_CLIENT_SECRET`.
- OAuth authorization URL was generated with scopes for Zoho Books contacts/invoices, Zoho CRM contacts, and Zoho Calendar read/events.
- Zoho OAuth code exchange succeeded and refresh token was saved into `iih-booking-ZOHO_REFRESH_TOKEN`.
- Calendar UID was discovered and saved into `iih-booking-ZOHO_CALENDAR_UID`; selected calendar name: `facilitybookings`.
- Books organization discovery returned code 57 because the first scope set omitted `ZohoBooks.settings.READ`; regenerate OAuth with `ZohoBooks.settings.READ` included.
- Expanded-scope token worked for Calendar and Zoho Mail API, but CRM Contacts search returned `OAUTH_SCOPE_MISMATCH`; add `ZohoCRM.modules.search.READ` for the CRM search endpoint and `ZohoCRM.settings.modules.READ` for module diagnostics.
- Books organization discovery with expanded scopes returned zero organizations, meaning the authorized Zoho user may not have access to a Zoho Books organization; verify the correct Zoho account/org if this persists after final scope update.
- Skill Workshop update proposal created for the reusable `iih-booking-system` skill: `iih-booking-system-20260616-a88678251c`.
