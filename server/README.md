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

## Локальна PostgreSQL у Docker

Урок 26 додає PostgreSQL для серверного словника. У папці `server` виконайте:

```powershell
Copy-Item .env.example .env
docker-compose up -d
docker-compose ps
```

Docker створить контейнер `devalias-postgres` і том `devalias_postgres_data`.
Том зберігає дані між перезапусками контейнера. Скрипти в `db/init/` виконаються
лише під час першого створення порожнього тому.

Схема має три таблиці:

- `categories` — категорії словника;
- `words` — IT-терміни; `source_id` збереже ідентифікатор зі старого JSON;
- `word_categories` — зв’язок «слово → категорія». Він робить модель гнучкою,
  якщо одне слово згодом належатиме кільком категоріям.

Перевірити таблиці можна так:

```powershell
docker-compose exec postgres psql -U devalias -d devalias -c "\dt"
docker-compose exec postgres psql -U devalias -d devalias -c "SELECT * FROM categories;"
```

Зупинити контейнер без видалення даних:

```powershell
docker-compose stop
```
