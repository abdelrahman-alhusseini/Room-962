export type EmailTemplate = {
  subject: string;
  text: string;
  html: string;
};

const shell = (title: string, body: string) => `
<div style="margin:0;padding:0;background:#080808;color:#f5efe6;font-family:Inter,Arial,sans-serif;">
  <div style="max-width:560px;margin:0 auto;padding:40px 24px;">
    <div style="font-family:Georgia,serif;color:#d6bd93;letter-spacing:5px;font-size:22px;margin-bottom:28px;">ROOM +962</div>
    <div style="height:1px;background:#8f7b5c;margin-bottom:28px;"></div>
    <h1 style="font-family:Georgia,serif;font-weight:400;color:#f5efe6;font-size:24px;margin:0 0 18px;">${title}</h1>
    <div style="color:#d8d0c4;font-size:14px;line-height:1.8;">${body}</div>
    <div style="height:1px;background:#2e2e2e;margin:34px 0 18px;"></div>
    <div style="color:#787878;font-size:11px;letter-spacing:1.4px;text-transform:uppercase;">Room +962 · Amman, Jordan</div>
  </div>
</div>`;

export function buildEmail(templateKey: string, payload: Record<string, unknown>): EmailTemplate {
  const fullName = String(payload.full_name ?? '');
  const applicantName = String(payload.applicant_name ?? 'An applicant');
  const applicantEmail = String(payload.applicant_email ?? '');
  const eventTitle = String(payload.event_title ?? 'A gathering');
  const eventDate = String(payload.event_date ?? '');
  const capacity = String(payload.capacity ?? '');

  switch (templateKey) {
    case 'application_received': {
      const body = `Thank you for applying. Your application has been received and will be reviewed within up to 5 business days.`;
      return {
        subject: 'Room +962 application received',
        text: body,
        html: shell('Application received', body),
      };
    }
    case 'admin_new_application': {
      const body = `${applicantName} has completed the questionnaire. ${applicantEmail ? `Email: ${applicantEmail}. ` : ''}Open the admin side of the app to review the application.`;
      return {
        subject: 'New Room +962 application',
        text: body,
        html: shell('New application', body),
      };
    }
    case 'application_accepted': {
      const body = `${fullName ? `${fullName}, ` : ''}your application has been accepted. You can now sign in with the verified email and password used during application.`;
      return {
        subject: 'Room +962 membership',
        text: body,
        html: shell('Membership confirmed', body),
      };
    }
    case 'application_declined': {
      const body = `${fullName ? `${fullName}, ` : ''}thank you for your interest in Room +962. We are unable to move forward with the application at this time.`;
      return {
        subject: 'Room +962 application update',
        text: body,
        html: shell('Application update', body),
      };
    }
    case 'event_published': {
      const body = `${eventTitle} has been added to the calendar.${eventDate ? ` Date: ${eventDate}.` : ''}${capacity ? ` Capacity: ${capacity}.` : ''}`;
      return {
        subject: 'New Room +962 gathering',
        text: body,
        html: shell('New gathering', body),
      };
    }
    default: {
      const body = 'There is a Room +962 update available.';
      return {
        subject: 'Room +962 update',
        text: body,
        html: shell('Room +962 update', body),
      };
    }
  }
}
