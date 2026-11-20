# POST — docs/

Архитектурные документы контура POST (Nova Cortex / MAIA).
Навигация и точки истины для LLM-сессий и Архитектора.

## Документы
- `WORKFLOW_AND_ROLES.md` — model-agnostic регламент трёх ролей (Архитектор, Редактор, Архиватор) и протокол onboarding.
- `distribution-hub-and-spoke.md` — матрица дистрибуции «2 языка × 2 скорости» (Hub & Spoke).
- `channels.md` — справочник площадок: форматы, лимиты, обложки 3:4.
- `nova-cortex-portal.md` — спецификация статического View Layer портала Nova Cortex.

## Связи
- Инварианты: `../INVARIANTS.md` (I1–I11).
- Редакционная политика: `../EDITORIAL_POLICY.md`.
- Операционный регламент Gates: `../CLAUDE.md`.
- Текущее состояние: `../RUNTIME.md`.

## Правило
Все документы в `docs/` — редактируемые. Они не входят в I1 (append-only блоки карточек и events.jsonl).
