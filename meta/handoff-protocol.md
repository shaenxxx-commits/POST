# POST — Handoff Protocol (Micro-Payload)

Эталонный шаблон минималистичного пакета `Editor → Archivist`. I12: без текстов постов, без пересказов, без обложек.

## Шаблон Micro-Payload (поля для заполнения)

- **record_id:** 2026-NNN
- **digest_ref:**
  - date: YYYY-MM-DD
  - digest_pos: #N
  - maia_id: <incoming_messages.id>
  - score: X
  - echelon: 1
  - shortlist_pos: M
- **title:** <Оригинальное название>
- **authors_org:** <Авторы> (<Организация>)
- **cluster:** <Тематический кластер>
- **artifact_tier:** A | B | C
- **code_status:** open | closed | not_reported
- **links:**
  - arxiv: https://arxiv.org/abs/XXXX.XXXXX
  - code_or_data: <URL или "—">
  - project_page: <URL или "—">
  - video: <URL или "—">
- **claims:**
  - [FACT] <тезис 1>
  - [FACT] <тезис 2>
  - [FACT] <тезис 3>
  - [HYPOTHESIS] <тезис>
  - [UNKNOWN] <пробел>
- **published:**
  - tg: https://t.me/t_cortex/<post_id>
  - date: YYYY-MM-DD

## Правила валидации (Архиватор)
- Все поля обязательны; пустые — явный "—".
- claims — 3–5 буллитов суммарно, не больше.
- `maia_id` — положительное целое число из БД `MAIA` (`incoming_messages.id`).
- record_id уникален, 2026-NNN сквозной (I2).
- При нарушении — вернуть Редактору на доработку, не создавать карточку.
