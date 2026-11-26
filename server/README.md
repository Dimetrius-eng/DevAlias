# DevAlias API

Це окремий Python-сервер для майбутніх онлайн-функцій DevAlias. Flutter-застосунок
поки продовжує працювати повністю офлайн; підключення до API буде в Уроці 30.

## Що таке API та HTTP

- **API** — домовленість, за якою застосунок просить дані в сервера й отримує
  відповідь у зрозумілому форматі.
- **HTTP-запит** — звернення до адреси, наприклад `GET /health`.
- **HTTP-відповідь** — статус (наприклад, `200 OK`) і дані. Тут дані мають
  формат JSON: `{ "service": "DevAlias API", "status": "ok" }`.

## Перший запуск

Потрібен Python 3.12 або новіший. У PowerShell, перебуваючи в цій папці:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
uvicorn app.main:app --reload
```

Після запуску відкрийте в браузері:

- `http://127.0.0.1:8000/` — проста відповідь сервера;
- `http://127.0.0.1:8000/health` — перевірка стану;
- `http://127.0.0.1:8000/docs` — інтерактивна документація FastAPI.

## Тести

```powershell
python -m pytest
```
