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

Після Уроку 28 за запущеної PostgreSQL також доступні:

- `GET /categories` — категорії та кількість доступних слів;
- `GET /words/random` — одне випадкове слово;
- `GET /words/random?difficulty=hard&category=databases` — випадкове слово
  із фільтрами. Допустимі складності: `easy`, `medium`, `hard`.

Урок 29 додає локальні moderation-маршрути. До Уроку 33 вони не мають
авторизації, тому використовуються лише під час розробки на вашому комп’ютері:

- `POST /words` — створює слово як `is_approved: false`;
- `PATCH /words/{source_id}` — редагує термін, складність або категорії;
- `GET /moderation/words` — показує очікуючі слова;
- `PATCH /words/{source_id}/moderation` з `{ "approved": true }` — схвалює
  слово для публічного `GET /words/random`.

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

## Імпорт офлайн-словника до PostgreSQL

Урок 27 переносить ті самі слова, які Android MVP бере з
`assets/data/words_uk.json`. Увімкніть контейнер PostgreSQL, активуйте Python
середовище та запустіть імпорт із папки `server`:

```powershell
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m scripts.import_words
```

Імпорт використовує `source_id` з JSON і працює без дублікатів: повторний
запуск оновить термін, складність і його категорію. Перевірити результат:

```powershell
docker-compose exec postgres psql -U devalias -d devalias -c "SELECT difficulty, COUNT(*) FROM words GROUP BY difficulty ORDER BY difficulty;"
```
