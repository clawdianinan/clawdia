# IIH Booking System Setup - 2026-06-15

- Temi asked Clawdia to digest an IIH Space Booking Agent setup guide and implement it as a special IIH Booking System.
- Aisha was created/assigned as the IIH Booking Operations Agent.
- Clawdia remains orchestrator and approval gate for outbound emails, invoice sends, calendar invites, payment confirmation, refunds, discounts, waivers, and booking exceptions.
- Created a secret-safe booking system spec, machine-readable config, and dry-run quote/operations bundle helper.
- A reusable skill proposal was created through Skill Workshop: `iih-booking-system-20260615-c459874f7a`.
- The source guide included Zoho credentials/OAuth material; do not reproduce them.
- Temi later approved using those secrets/tokens as-is with no rotation required before production.
- Keep credentials in secure runtime environment, macOS Keychain, or approved secret store only.
- Temi instructed that Aisha and all booking-related email use eventbookings@iih.ng.
- md@iih.ng is excluded from the IIH Booking System entirely.
