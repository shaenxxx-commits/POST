# POST — Logs Specification

Журнал событий `logs/events.jsonl` ведётся в формате **Append-Only** (каждая строка — валидный JSON-объект). Старые строки не перезаписываются (I1); исправления — новой записью.

## Схема события

- `ts` — ISO-8601 UTC timestamp (формат `date -u +%FT%TZ`)
- `event` — тип события (см. словарь ниже)
- `actor` — `architect` | `executor` | `editor` | `archivist`
- `record_id` — `"YYYY-NNN"` или `null` (для системных событий)
- `details` — текстовое описание

## Канон сериализации

- Компактный JSON, одна строка на событие: `jq -c`.
- Ключи всегда в порядке: `ts`, `event`, `actor`, `record_id`, `details`.
- Новые записи — только через append (`>>`), с проверкой `jq -c .`.

## Словарь типов (event)

**Жизненный цикл записи:**
- `RECORD_CREATED` — создана карточка в `records/`
- `RESEARCH_COMPLETED` — Gate 2 завершён (доказательная база готова)
- `DRAFT_COMPLETED` — Gate 3 завершён (черновик + обложка 3:4)
- `APPROVED` — финальный статус Архитектора
- `POST_PUBLISHED` — публикация в канале

**Системные и архитектурные:**
- `INIT_SYSTEM` — инициализация/перестройка репозитория
- `TRIAGE_COMPLETED` — Gate 1 (триаж дайджеста)
- `DIGEST_TRIAGED` — полная разметка всех 15 позиций дайджеста для калибровки `MAIA` (формат `details`: `date=YYYY-MM-DD | selected: id(code),... | reserve: id(code),... | rejected: id(code),...`)
- `POLICY_UPDATED` — правка редакционной политики
- `CHANNEL_DESCRIPTION_APPROVED` — утверждение описания канала
- `ARCHITECTURE_HUB_AND_SPOKE_DOCUMENTED` — фиксация Hub & Spoke, трёхролевого регламента
- `ERRATUM_RECORDED` — фиксация опечатки в неизменяемых (`I1`) блоках без их правки
- `SYNC_GITHUB` — синхронизация с `origin/main`
- `DDA_STANDARDIZED` — миграция на KARCAS-DDA (единый вход, meta-роли, ультратонкий шаблон)
- `PROTOCOL_ADOPTED` — принят протокол Редактор → Копирайтер (ADR-008)

## Журнал триажа (triage.jsonl)

Отдельный append-only файл `logs/triage.jsonl`: одна строка на каждую из 15 позиций дайджеста. Начало накопления — 2026-11-19 (пилот `maia_id 484476` в Git не занесён; отсев прежних дайджестов не восстанавливается).

### Схема (порядок ключей строгий)

- `ts` — ISO-8601 UTC (`date -u +%FT%TZ`)
- `digest_date` — `YYYY-MM-DD`
- `digest_pos` — int (1..15)
- `maia_id` — int (`incoming_messages.id`)
- `arxiv_id` — `arXiv:XXXX.XXXXX` или `null`
- `score` — int (0..10)
- `scorer` — версия оценщика MAIA или `"—"`
- `decision` — `selected` | `reserve` | `rejected`
- `reason_code` — закрытый список (см. ниже)
- `record_id` — `2026-NNN` для `selected`, иначе `null`
- `actor` — `editor`
- `note` — необязательно, ≤120 знаков

### reason_code (закрытый список)

- `selected`: `score_gt8`, `tier_a`, `tier_b`, `tier_c`
- `reserve`: `utility_below_2`, `niche`, `packaging`, `alarmism_risk`
- `rejected`: `metrics_dispute`, `routine_benchmark`, `theory_only`

### Канон сериализации

- Компактный JSON (`jq -c`), одна строка на позицию.
- Ключи строго в порядке схемы.
- Только append через `>>`, валидация `jq -c .`.

Валидация `logs/triage.jsonl` включена в `scripts/precommit-checks.sh`.
