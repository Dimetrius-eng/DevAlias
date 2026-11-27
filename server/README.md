# DevAlias API

Це окремий Python-сервер для словника й майбутніх онлайн-функцій DevAlias.
Flutter-застосунок працює офлайн, а за наявності сервера може синхронізувати
його словник у локальний SQLite-кеш.

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
- `GET /words` — усі затверджені слова для синхронізації офлайн-кешу.

Урок 29 додає локальні moderation-маршрути. До Уроку 33 вони не мають
авторизації, тому використовуються лише під час розробки на вашому комп’ютері:

- `POST /words` — створює слово як `is_approved: false`;
- `PATCH /words/{source_id}` — редагує термін, складність або категорії;
- `GET /moderation/words` — показує очікуючі слова;
- `PATCH /words/{source_id}/moderation` з `{ "approved": true }` — схвалює
  слово для публічного `GET /words/random`.

## Підключення Android до локального API

Урок 30 додає до Flutter екран «Серверний словник». Для перевірки з реального
телефону ПК і телефон мають бути в одній Wi-Fi мережі. Запустіть API так, щоб
він слухав локальну мережу:

```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Дізнайтеся IPv4-адресу ПК командою `ipconfig`, наприклад `192.168.1.20`, і
запустіть Flutter так:

```powershell
flutter run --dart-define=DEVALIAS_API_BASE_URL=http://192.168.1.20:8000
```

Не використовуйте `localhost`: на телефоні це означає сам телефон, а не ПК.
HTTP дозволено лише для debug Android-збірки; перед релізом використовуватимемо
HTTPS.

## Синхронізація словника в офлайн-кеш

Урок 31 додає `GET /words`: він повертає повний список **лише затверджених**
слів. Якщо Flutter запущено з `DEVALIAS_API_BASE_URL`, застосунок тихо пробує
оновити свій SQLite-кеш при старті. На екрані «Серверний словник» також є
кнопка «Синхронізувати для офлайн-гри» для ручного оновлення.

Після успішного оновлення нові схвалені слова доступні в «Новій грі» без
перевстановлення застосунку і без інтернету. Якщо сервер недоступний або кеш
ще не створено, DevAlias безпечно використовує вбудований `words_uk.json`.

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
