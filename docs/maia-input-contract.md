# POST — MAIA input contract (read-only)

Интерфейс между `MAIA` и `POST`. Реализация — `scripts/get-digest.sh`. `MAIA` не меняется: ни схема, ни workflow, ни записи.

## Режим 1: дайджест по дате (Gate 1)

Запуск: `bash scripts/get-digest.sh YYYY-MM-DD`

Возвращает markdown-таблицу, по одной строке на каждую позицию дайджеста.

Поля:
- `digest_pos` (int, `row_number()`) — номер в дайджесте (1..15)
- `maia_id` (int, `digest_log.article_id`) — сквозной ID в БД MAIA (`incoming_messages.id`)
- `score` (int, `digest_log.payload->>'score'`) — оценка MAIA (0..10)
- `kind` (text, `digest_log.kind`) — тип (`top` и др.)
- `source` (text, `incoming_messages.source`) — источник (`arxiv_cs_ai` / `arxiv_cs_lg` / ...)
- `title` (text, `digest_log.payload->>'title'`) — название статьи
- `url` (text, `digest_log.payload->>'url'`) — ссылка на arXiv
- `maia_reason` (text, `incoming_messages.meta->'groq'->>'reason'`) — обоснование оценки от Groq

## Режим 2: полное сырьё по maia_id (Gate 2)

Запуск: `bash scripts/get-digest.sh --ids ID1,ID2,...`

Возвращает по каждому `maia_id`:
- `tags` (`incoming_messages.meta->'groq'->'tags'`) — список тегов
- `raw` (`incoming_messages.raw_text`) — полный abstract + метаданные arXiv

## Поля, зарезервированные, но пока не отдаваемые MAIA

- `scorer` — версия оценщика MAIA. В схеме `maia-db` отсутствует. В шаблонах и пакетах пишется `scorer: —` до момента, когда MAIA добавит поле.
- `shortlist_pos` — номер в шорт-листе Первого эшелона. Не отдаётся БД; Редактор присваивает в Gate 1.

## Ссылки на код, проект, видео

Берутся **только** из текста статьи (`raw_text`). Не из подсказок OpenAlex, не из внешних агрегаторов.

## score > 8

`score` — ориентир для шорт-листа, не истина. Порог `> 8` прежний. Калибровка — по накопленному `logs/triage.jsonl` после достаточного объёма.
