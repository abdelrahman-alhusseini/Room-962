// Supabase Edge Function stub: notify members when a gathering is published.
// Only send to all members when visible_to_all_members is true. Otherwise send
// only to event_visibility_members.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const { event_id } = await req.json();

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );

  const { data: event, error: eventError } = await supabase
    .from('events')
    .select('*')
    .eq('id', event_id)
    .single();

  if (eventError || !event) {
    return new Response(JSON.stringify({ error: eventError?.message ?? 'Event not found' }), { status: 404 });
  }

  if (!event.is_published || !event.notify_members_on_publish) {
    return new Response(JSON.stringify({ ok: true, skipped: true }));
  }

  let membersQuery = supabase
    .from('members')
    .select('id, email, fcm_token')
    .eq('status', 'active');

  if (!event.visible_to_all_members) {
    // Production version: join event_visibility_members and send only to selected members.
  }

  const { data: members } = await membersQuery;

  for (const member of members ?? []) {
    if (member.fcm_token) {
      // TODO: send FCM push: title 'Room +962', body 'A new gathering has been announced.'
    }
  }

  return new Response(JSON.stringify({ ok: true, recipients: members?.length ?? 0 }));
});
