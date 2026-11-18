# POST — Logs Specification

Журнал событий `logs/events.jsonl` ведётся в формате **Append-Only** (каждая строка — валидный JSON-объект). Старые строки не перезаписываются (I1); исправления — новой записью.

## Схема события

* `ts` — ISO-8601 UTC timestamp (формат `date -u +%FT%TZ`)
* `event` — тип события (см. словарь ниже)
* `actor` — `architect` | `executor` | `editor` | `archivist`
* `record_id` — `"YYYY-NNN"` или `null` (для системных событий)
* `details` — текстовое описание

## Канон сериализации

* Компактный JSON, одна строка на событие: `jq -c`.
* Ключи всегда в порядке: `ts`, `event`, `actor`, `record_id`, `details`.
* Новые записи — только через append (`>>`), с проверкой `jq -c .`.

## Словарь типов (event)

**Жизненный цикл записи:**
* `RECORD_CREATED` — создана карточка в `records/`
* `RESEARCH_COMPLETED` — Gate 2 завершён (доказательная база готова)
* `DRAFT_COMPLETED` — Gate 3 завершён (черновик + обложка 3:4)
* `APPROVED` — финальный статус Архитектора
* `POST_PUBLISHED` — публикация в канале

**Системные и архитектурные:**
* `INIT_SYSTEM` — инициализация/перестройка репозитория
* `TRIAGE_COMPLETED` — Gate 1 (триаж дайджеста)
* `POLICY_UPDATED` — правка редакционной политики
* `CHANNEL_DESCRIPTION_APPROVED` — утверждение описания канала
* `ARCHITECTURE_HUB_AND_SPOKE_DOCUMENTED` — фиксация Hub & Spoke, трёхролевого регламента, портала
* `ERRATUM_RECORDED` — фиксация опечатки в неизменяемых (`I1`) блоках без их правки
* `SYNC_GITHUB` — синхронизация с `origin/main`
