# ROOM +962 — Production Setup Guide

## 1. Domain and sender identity

Buy a domain such as `room962.com` or the final brand domain.

Create sender addresses:

- `no-reply@yourdomain.com` for verification and automated emails
- `admin@yourdomain.com` for admin alerts
- Optional: `support@yourdomain.com`

In your email provider, verify DNS records:

- SPF
- DKIM
- DMARC

Do not send production auth emails from a generic provider address.

## 2. Supabase project

Create a Supabase project and enable email/password authentication.

Auth settings:

- Disable auto-confirm email.
- Enable email confirmations.
- Configure Site URL and redirect URLs.
- Add deep links for iOS/Android later.
- Configure custom SMTP using Resend/Postmark/SendGrid SMTP settings.

Apply migrations in this order:

1. `001_room962_admin.sql`
2. `002_auth_flow.sql`
3. `003_verified_applicant_flow.sql`
4. `004_production_auth_notifications_capacity.sql`

## 3. Supabase Edge Function secrets

Set these in Supabase:

```bash
supabase secrets set SUPABASE_URL="https://YOUR_PROJECT.supabase.co"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="YOUR_SERVICE_ROLE_KEY"
supabase secrets set RESEND_API_KEY="re_xxxxxxxxx"
supabase secrets set ROOM962_FROM_EMAIL="Room +962 <no-reply@yourdomain.com>"
```

Never put the service role key or Resend API key inside Flutter.

## 4. Deploy Edge Functions

```bash
supabase functions deploy email-dispatcher
supabase functions deploy application-notifications
supabase functions deploy event-notifications
```

The database triggers create rows in `notification_deliveries`. The `email-dispatcher` sends queued emails through Resend.

For production, trigger `email-dispatcher` using one of these:

- Supabase scheduled function/cron
- Database webhook
- Admin action calls the function immediately after decision

## 5. Flutter production keys

Flutter should only receive public keys:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY" \
  --dart-define=APP_URL="room962://auth"
```

## 6. Real applicant flow

Production flow:

1. User creates account with email + password.
2. Supabase sends verification email through custom SMTP.
3. User opens the verification link.
4. Supabase sets `email_confirmed_at`.
5. Questionnaire opens only if the auth user email is confirmed.
6. Application insert queues applicant confirmation email and admin review email.
7. Admin accepts or declines.
8. Decision queues the correct applicant email.
9. Accepted applicant becomes a member and can sign in.

## 7. Event capacity rules

Events require a positive capacity.

RSVPs are blocked server-side when attendance reaches capacity. The UI also shows the event as full, but the database trigger is the real protection.

## 8. Firebase Cloud Messaging

FCM is optional for the first launch, but recommended for admin mobile alerts.

Required later:

- Firebase project
- Android `google-services.json`
- iOS `GoogleService-Info.plist`
- APNs key connected in Firebase
- Save admin/member FCM tokens to Supabase
- Add push delivery inside an Edge Function

Email notifications are enough for the first production version.
