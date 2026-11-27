INSERT INTO categories (slug, display_name_uk)
VALUES
    ('general_it', 'Загальні IT'),
    ('programming_languages', 'Мови програмування'),
    ('web_development', 'Веброзробка'),
    ('databases', 'Бази даних')
ON CONFLICT (slug) DO UPDATE
SET display_name_uk = EXCLUDED.display_name_uk;
