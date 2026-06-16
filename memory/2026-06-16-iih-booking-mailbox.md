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
- Skill Workshop update proposal created for the reusable `iih-booking-system` skill: `iih-booking-system-20260616-a88678251c`.
