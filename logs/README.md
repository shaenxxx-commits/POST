# POST — Logs Specification

Журнал событий `logs/events.jsonl` ведётся в формате **Append-Only** (каждая строка — валидный JSON-объект).

## Схема события
* `ts` — ISO-8601 timestamp
* `event` — тип события (`INIT_SYSTEM`, `TRIAGE_COMPLETED`, `RESEARCH_COMPLETED`, `DRAFT_COMPLETED`, `APPROVED`, `SYNC_GITHUB`)
* `actor` — `architect` | `executor`
* `record_id` — `YYYY-NNN` или `null`
* `details` — текстовое описание
