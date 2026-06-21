# ROOM +962 — Flutter App MVP

A Flutter Web/mobile MVP for Room +962 with verified applicant accounts, questionnaire submission, member sign-in, event RSVP capacity, and an in-app admin layer.

## Production direction

The app now follows the professional account-first flow:

1. User downloads/opens the app.
2. User creates an account with a real email and password.
3. User verifies the email address.
4. Questionnaire opens only after verification.
5. Applicant receives an automated confirmation email.
6. Admin receives an automated review email asking them to open the app.
7. Admin accepts or declines the applicant.
8. Applicant receives an automated decision email.
9. Accepted applicants can sign in as members using the same verified email account.

## Current local demo

This project is still a front-end MVP. The UI simulates the verified email callback locally so the flow can be tested without paid services.

Admin sign-in:

- Email: `admin@room962.com`
- Password: `admin962`

Demo member sign-in:

- Email: `member@room962.com`
- Password: `member962`

Seed applicant sign-in:

- Email: `leen@example.org`
- Password: `applicant962`

## Run locally

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

## Build for web

```powershell
flutter build web --release
```

## What is included

- Public landing screen
- Account creation before questionnaire
- Email format validation and disposable-domain blocking in the demo UI
- Email verification step before questionnaire access
- Email/password sign-in screen
- Applicant status screen after submission
- Role-based demo routing for applicants, members, and admins
- Multi-step application questionnaire
- Particulars section with locked verified email
- Five application questions
- Covenant section
- Signature pad
- Received screen with 5-business-day review message
- Accepted-member side with Home, Gatherings, About, Profile, RSVP, membership card, and QR
- Event capacity display
- Full gathering state
- RSVP blocking when a gathering is full
- Admin applicant review with pending / under-review / accepted / declined states
- Admin application acceptance that creates a member record
- Admin calendar control for creating gatherings
- Required gathering capacity field
- Gathering controls for published vs draft, visible to all members vs selected only, RSVP count visibility, and member notification intent
- Admin notices / announcements for the member Home feed
- Admin notification center showing applicant/admin email and push delivery events
- Supabase migration and Edge Function starter files
- Resend-ready email dispatcher Edge Function
- Production setup guide
- Cost estimate guide
- `robots.txt` disallow all

## Supabase files

- `supabase/migrations/001_room962_admin.sql`
- `supabase/migrations/002_auth_flow.sql`
- `supabase/migrations/003_verified_applicant_flow.sql`
- `supabase/migrations/004_production_auth_notifications_capacity.sql`
- `supabase/functions/email-dispatcher/index.ts`
- `supabase/functions/_shared/email_templates.ts`
- `supabase/functions/application-notifications/index.ts`
- `supabase/functions/event-notifications/index.ts`

## Setup docs

- `docs/PRODUCTION_SETUP.md`
- `docs/COST_ESTIMATE.md`

## Important note

Real email verification and automated emails require Supabase Auth plus a transactional email provider. The project now includes the database migration, email templates, and Edge Function needed to wire this into production, but the real service keys must be added in your Supabase dashboard.


## v12 Home brief updates

This build applies the Home Screen brief more exactly: warmer near-black background, cooler gold, borderless next-gathering panel, hairline-separated announcements, `ENTER →` CTA, text-only navigation, and DM Sans utility text for labels, navigation, dates, metadata, and announcement body copy.


## v13 Gatherings brief implementation

This build applies the Gatherings brief: borderless event panels, #0B0A09 background, #141412 panels, #C4A96B hairlines, text-only navigation, DM Sans structural labels, Cormorant Garamond Light Italic event names, solid primary RSVP button, quieter secondary RSVP action, long-form date treatment, updated attendance/full copy, and fuller event detail descriptions.
