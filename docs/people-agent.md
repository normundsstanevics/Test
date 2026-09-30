# Relationship Management module (inside Chief of Staff) – design notes

Lives inside the "AI Chief of Staff" n8n workflow, marked with purple
"RELATIONSHIP MANAGEMENT" notes and the workflow tag "Relationship Management".

No personal data lives in this repository; the contact list itself is stored
only in the n8n data table **People**.

## Owner decisions
- The starting list was reviewed and approved by the owner (35 contacts).
- **Never add a contact silently.** When a new person shows up in WhatsApp,
  email (Gmail, iCloud, Amber summaries), calendars or Plaud, the assistant
  must *ask* the owner whether to add them, showing name, where they appeared
  and a suggested role. Only an explicit "yes" adds the contact.
- Contacts the owner declines are kept as `status = declined` (name only) so
  they are never suggested again; they are not used for anything else.
- Family contacts are added only when the owner explicitly asks.
- Cards hold role and relationship only – no details of sensitive matters
  (legal cases, restructuring, health, politics).

## Planned steps
1. ✅ People table created and seeded from the reviewed spreadsheet.
2. ✅ Chief of Staff routes: "Who is …?", "Prep me for my meeting with …",
   "Who should I reconnect with?" (read-only, sourced).
3. ✅ Research route: "Research <name>" = public professional background for external
   contacts only (OpenAI web search; no Facebook/Instagram, no private life).
   "save profile <name>" stores a summary on the card after WhatsApp approval.
4. Weekly people update: refresh `last_contact` from calendars and mail
   metadata, and send a WhatsApp list of *new* contacts for yes/no approval
   (see the rule above). Reconnect reminders for starred people.
