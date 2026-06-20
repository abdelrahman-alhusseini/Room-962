# ROOM +962 — Production Cost Estimate

This is the expected monthly cost for a professional small launch.

## Recommended launch stack

- Backend/auth/database/storage: Supabase Pro
- Auth emails: Supabase Auth with custom SMTP
- Transactional emails: Resend or Postmark
- Mobile push: Firebase Cloud Messaging
- Hosting/admin web preview: Netlify/Vercel/Supabase static hosting if needed
- Store publishing: Apple Developer Program + Google Play Console

## Cost ranges

### Lean but professional

Use this when the member base is small and traffic is low.

- Supabase Pro: about $25/month
- Resend Free or Postmark Free for early testing: $0/month, but not ideal for production volume
- Firebase Cloud Messaging: $0/month
- Domain: usually around $10–25/year depending on registrar and TLD
- Apple Developer Program: $99/year
- Google Play Console: $25 one-time

Estimated monthly operating cost after store accounts: **about $25–45/month**.

### Recommended professional setup

Use this for a real public App Store / Google Play launch.

- Supabase Pro: about $25/month
- Resend Pro: about $20/month, or Postmark Basic: about $15/month
- Firebase Cloud Messaging: $0/month
- Domain: usually around $10–25/year
- Optional web hosting/pro plan: $0–20/month depending on where the landing/admin build is hosted
- Apple Developer Program: $99/year
- Google Play Console: $25 one-time

Estimated monthly operating cost: **about $40–65/month**, plus store and domain fees.

### Higher-volume setup

Use this if the app grows or emails must have stricter deliverability monitoring.

- Supabase Pro plus usage: $25+/month
- Resend Scale or Postmark higher plans: $90+/month or usage-based
- Dedicated IP for email: optional, usually not needed at the start
- More storage/bandwidth: usage-based

Estimated monthly operating cost: **$100+/month** only after growth.

## My recommendation

Start with:

- Supabase Pro
- Resend Pro
- Firebase FCM
- One branded domain
- Apple + Google developer accounts

That gives the app a professional backbone without overpaying early.

## What is not included

This estimate does not include paid UI/UX design, legal/privacy-policy writing, App Store screenshots, business email inboxes, or developer labor.
