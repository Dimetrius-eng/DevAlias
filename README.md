# DevAlias

DevAlias — дипломний командний Alias для IT-термінів. Android є першим MVP,
Flutter UI та доменна логіка залишаються платформонезалежними, а правила гри
мають portable C++-ядро через CMake та FFI.

## Частини проєкту

- `lib/` — Flutter-застосунок: локальна гра, SQLite, історія, статистика та
  локальний профіль;
- `native/game_core/` — C++-ядро гри;
- `assets/data/words_uk.json` — офлайн-словник Android MVP;
- `server/` — майбутній FastAPI-сервер і PostgreSQL для серверного словника.

## Android MVP офлайн

Застосунок працює без мережі: словник і звуки входять до APK, а незавершені
партії, історія, статистика й профіль зберігаються локально.

```powershell
flutter analyze
flutter test
flutter run
```

Ручний сценарій перевірки є в
[docs/android_mvp_offline_checklist.md](docs/android_mvp_offline_checklist.md).

## Серверна частина

Починаючи з Уроку 25, сервер розміщений у `server/`. Детальні інструкції
FastAPI, Docker і PostgreSQL дивіться у [server/README.md](server/README.md).
