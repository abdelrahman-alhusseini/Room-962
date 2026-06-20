// ROOM +962 email dispatcher.
// Deploy as a Supabase Edge Function and run from a scheduled job/webhook.
// Required secrets:
//   SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
//   RESEND_API_KEY
//   ROOM962_FROM_EMAIL     e.g. Room +962 <no-reply@room962.com>

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { buildEmail } from '../_shared/email_templates.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const resendApiKey = Deno.env.get('RESEND_API_KEY') ?? '';
  const fromEmail = Deno.env.get('ROOM962_FROM_EMAIL') ?? 'Room +962 <no-reply@example.com>';

  if (!supabaseUrl || !serviceRoleKey || !resendApiKey) {
    return new Response(
      JSON.stringify({ error: 'Missing required environment variables.' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data: deliveries, error } = await supabase
    .from('notification_deliveries')
    .select('id, recipient_email, template_key, payload, attempts')
    .eq('status', 'queued')
    .eq('channel', 'email')
    .not('recipient_email', 'is', null)
    .order('created_at', { ascending: true })
    .limit(25);

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  const results: Array<Record<string, unknown>> = [];

  for (const delivery of deliveries ?? []) {
    const template = buildEmail(delivery.template_key ?? 'generic', delivery.payload ?? {});

    try {
      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${resendApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: fromEmail,
          to: [delivery.recipient_email],
          subject: template.subject,
          html: template.html,
          text: template.text,
        }),
      });

      const providerResult = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(providerResult?.message ?? `Resend returned ${response.status}`);
      }

      await supabase
        .from('notification_deliveries')
        .update({
          status: 'sent',
          sent_at: new Date().toISOString(),
          provider_message_id: providerResult?.id ?? null,
          attempts: (delivery.attempts ?? 0) + 1,
        })
        .eq('id', delivery.id);

      results.push({ id: delivery.id, status: 'sent' });
    } catch (err) {
      await supabase
        .from('notification_deliveries')
        .update({
          status: 'failed',
          error_message: err instanceof Error ? err.message : String(err),
          attempts: (delivery.attempts ?? 0) + 1,
        })
        .eq('id', delivery.id);

      results.push({ id: delivery.id, status: 'failed' });
    }
  }

  return new Response(JSON.stringify({ ok: true, processed: results.length, results }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
});
