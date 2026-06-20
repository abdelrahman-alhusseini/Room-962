// Legacy wrapper kept for compatibility with earlier builds.
// Use the production email dispatcher in ../email-dispatcher for real emails.
// This function now only marks unread admin application notifications as seen
// after the queued email rows are created by database triggers.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );

  const { count, error } = await supabase
    .from('admin_notifications')
    .update({ delivered: true })
    .eq('delivered', false)
    .eq('source_type', 'application')
    .select('*', { count: 'exact', head: true });

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  return new Response(JSON.stringify({ ok: true, marked_delivered: count ?? 0 }));
});
