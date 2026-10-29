// Plantillas del email de reactivación (issue #107).
//
// El texto vive aquí, no en `index.ts`: un idioma = una entrada. Si mañana se
// añade otro idioma, basta con ampliar `TEMPLATES` y la lista de `user_settings`
// aceptada en `reactivation_candidates` (es/en/pt).
//
// HTML de email: tablas + estilos en línea (los clientes de correo ignoran
// <style> y las fuentes externas). Paleta de la app: voidBg #05070E,
// surface #11131B, manaCyan #00E5FF, royalGold #FFC700.

export type EmailLocale = 'es' | 'en' | 'pt';

export interface EmailParams {
  name: string;
  streak: number;
  daysInactive: number;
  appUrl: string;
  unsubscribeUrl: string;
}

export interface EmailContent {
  subject: string;
  html: string;
  text: string;
}

export function normalizeLocale(value: unknown): EmailLocale {
  return value === 'en' || value === 'pt' ? value : 'es';
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

interface Copy {
  tagline: string;
  subject: (p: EmailParams) => string;
  heading: (name: string) => string;
  body: (p: EmailParams) => string;
  cta: string;
  fallbackName: string;
  reason: string;
  unsubscribe: string;
  footerNote: string;
}

const COPY: Record<EmailLocale, Copy> = {
  es: {
    tagline: 'Dungeon of English',
    subject: (p) =>
      p.streak > 0
        ? `${p.name}, tu racha de ${p.streak} días sigue en pie`
        : `${p.name}, la mazmorra te está esperando`,
    heading: (name) => `La mazmorra no se cierra, ${name}.`,
    body: (p) =>
      p.streak > 0
        ? `Han pasado ${p.daysInactive} días desde tu última incursión. Tu racha de ${p.streak} días queda guardada y el Oráculo ya tiene una conversación nueva preparada para ti.`
        : `Han pasado ${p.daysInactive} días desde tu última incursión. El Oráculo ya tiene una conversación nueva preparada para ti.`,
    cta: 'Volver a la mazmorra',
    fallbackName: 'cazador',
    reason: 'Recibes este correo porque tienes una cuenta en Dungeon of English.',
    unsubscribe: 'Cancelar estos correos',
    footerNote: 'Es un email de servicio de tu cuenta; no afecta a tu plan ni a tu progreso.',
  },
  en: {
    tagline: 'Dungeon of English',
    subject: (p) =>
      p.streak > 0
        ? `${p.name}, your ${p.streak}-day streak is still standing`
        : `${p.name}, the dungeon is waiting for you`,
    heading: (name) => `The dungeon does not close, ${name}.`,
    body: (p) =>
      p.streak > 0
        ? `It has been ${p.daysInactive} days since your last run. Your ${p.streak}-day streak is safe and the Oracle has a new conversation ready for you.`
        : `It has been ${p.daysInactive} days since your last run. The Oracle has a new conversation ready for you.`,
    cta: 'Back to the dungeon',
    fallbackName: 'hunter',
    reason: 'You receive this email because you have a Dungeon of English account.',
    unsubscribe: 'Stop these emails',
    footerNote: 'This is a service email about your account; it does not affect your plan or progress.',
  },
  pt: {
    tagline: 'Dungeon of English',
    subject: (p) =>
      p.streak > 0
        ? `${p.name}, sua sequência de ${p.streak} dias continua viva`
        : `${p.name}, a masmorra está esperando por você`,
    heading: (name) => `A masmorra não fecha, ${name}.`,
    body: (p) =>
      p.streak > 0
        ? `Já se passaram ${p.daysInactive} dias desde a sua última incursão. Sua sequência de ${p.streak} dias está guardada e o Oráculo já tem uma nova conversa pronta para você.`
        : `Já se passaram ${p.daysInactive} dias desde a sua última incursão. O Oráculo já tem uma nova conversa pronta para você.`,
    cta: 'Voltar à masmorra',
    fallbackName: 'caçador',
    reason: 'Você recebe este e-mail porque tem uma conta no Dungeon of English.',
    unsubscribe: 'Cancelar estes e-mails',
    footerNote: 'É um e-mail de serviço da sua conta; não afeta seu plano nem seu progresso.',
  },
};

export function renderEmail(
  locale: EmailLocale,
  params: EmailParams,
): EmailContent {
  const copy = COPY[locale];
  const name = params.name.trim() || copy.fallbackName;
  const safeName = escapeHtml(name);
  const safeAppUrl = escapeHtml(params.appUrl);
  const safeUnsubscribe = escapeHtml(params.unsubscribeUrl);

  const subject = copy.subject({ ...params, name });
  const heading = escapeHtml(copy.heading(name));
  const body = escapeHtml(copy.body({ ...params, name }));

  const html = `<!doctype html>
<html lang="${locale}">
  <body style="margin:0;padding:0;background:#05070E;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0"
           style="background:#05070E;padding:24px 12px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0"
                 style="max-width:520px;background:#11131B;border:1px solid #272A32;border-radius:4px;">
            <tr>
              <td style="padding:28px 28px 8px;font-family:-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
                <p style="margin:0 0 18px;font-size:11px;letter-spacing:3px;text-transform:uppercase;color:#00E5FF;">
                  ${copy.tagline}
                </p>
                <h1 style="margin:0 0 16px;font-size:24px;line-height:1.25;color:#E1E2ED;font-weight:700;">
                  ${heading}
                </h1>
                <p style="margin:0 0 22px;font-size:15px;line-height:1.6;color:#BAC9CC;">
                  ${body}
                </p>
                <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 26px;">
                  <tr>
                    <td style="background:#00E5FF;border-radius:4px;">
                      <a href="${safeAppUrl}" target="_blank" rel="noopener"
                         style="display:inline-block;padding:13px 22px;font-size:14px;font-weight:700;color:#05070E;text-decoration:none;">
                        ${copy.cta}
                      </a>
                    </td>
                  </tr>
                </table>
                ${
                  params.streak > 0
                    ? `<p style="margin:0 0 8px;font-size:14px;color:#FFC700;font-weight:600;">
                         ${locale === 'en' ? 'Streak' : locale === 'pt' ? 'Sequência' : 'Racha'}: ${params.streak}
                       </p>`
                    : ''
                }
              </td>
            </tr>
            <tr>
              <td style="padding:16px 28px 26px;border-top:1px solid #272A32;font-family:-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
                <p style="margin:0 0 8px;font-size:12px;line-height:1.6;color:#849396;">
                  ${copy.reason}
                  <a href="${safeUnsubscribe}" target="_blank" rel="noopener"
                     style="color:#9CF0FF;text-decoration:underline;">${copy.unsubscribe}</a>.
                </p>
                <p style="margin:0;font-size:11px;line-height:1.6;color:#5B686B;">
                  ${copy.footerNote}
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>`;

  const rawHeading = copy.heading(name);
  const rawBody = copy.body({ ...params, name });
  const streakLine = params.streak > 0
    ? `${
      locale === 'en' ? 'Streak' : locale === 'pt' ? 'Sequence' : 'Racha'
    }: ${params.streak}`
    : '';

  const text = [
    copy.tagline,
    '',
    rawHeading,
    '',
    rawBody,
    streakLine,
    '',
    `→ ${params.appUrl}`,
    '',
    `${copy.reason} ${copy.unsubscribe}: ${params.unsubscribeUrl}`,
  ]
    .join('\n')
    .replace(/\n{3,}/g, '\n\n');

  return { subject, html, text };
}
