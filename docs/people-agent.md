# People (relationship memory) – design notes

No personal data lives in this repository; the contact list itself is stored
only in the n8n data table **People**.

## Owner decisions
- The starting list was reviewed and approved by the owner (35 contacts).
- **Never add a contact silently.** When a new person shows up in WhatsApp,
  email (Gmail, iCloud, Amber summaries), calendars or Plaud, the assistant
  must *ask* the owner whether to add them, showing name, where they appeared
  and a suggested role. Only an explicit "yes" adds the contact.
- Family contacts are added only when the owner explicitly asks.
- Cards hold role and relationship only – no details of sensitive matters
  (legal cases, restructuring, health, politics).

## Planned steps
1. ✅ People table created and seeded from the reviewed spreadsheet.
2. Chief of Staff routes: "Who is …?", "Prep me for my meeting with …",
   "Who should I reconnect with?" (read-only, sourced).
3. Weekly people update: refresh `last_contact` from calendars and mail
   metadata, and send a WhatsApp list of *new* contacts for yes/no approval
   (see the rule above). Reconnect reminders for starred people.
