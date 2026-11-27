-- DevAlias dictionary schema.
-- Users, authorization and online games deliberately belong to later lessons.

CREATE TABLE IF NOT EXISTS categories (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug VARCHAR(64) NOT NULL UNIQUE,
    display_name_uk VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT categories_slug_format CHECK (slug ~ '^[a-z0-9_]+$')
);

CREATE TABLE IF NOT EXISTS words (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_id VARCHAR(100) NOT NULL UNIQUE,
    term VARCHAR(200) NOT NULL,
    difficulty VARCHAR(16) NOT NULL,
    is_approved BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT words_term_not_blank CHECK (LENGTH(BTRIM(term)) > 0),
    CONSTRAINT words_difficulty_valid CHECK (difficulty IN ('easy', 'medium', 'hard'))
);

CREATE TABLE IF NOT EXISTS word_categories (
    word_id BIGINT NOT NULL REFERENCES words(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    PRIMARY KEY (word_id, category_id)
);

CREATE INDEX IF NOT EXISTS words_difficulty_approved_idx
    ON words (difficulty)
    WHERE is_approved;

CREATE INDEX IF NOT EXISTS word_categories_category_idx
    ON word_categories (category_id);
