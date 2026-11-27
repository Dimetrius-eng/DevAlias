from enum import Enum
from typing import Annotated

from fastapi import FastAPI, HTTPException, Query, status
from pydantic import BaseModel, Field, field_validator, model_validator
from psycopg.errors import UniqueViolation

from app.database import open_database
from app.dictionary_repository import (
    category_exists,
    create_word,
    get_word,
    list_categories,
    list_words_for_moderation,
    random_word,
    set_word_approval,
    update_word,
)


class HealthResponse(BaseModel):
    """The small response returned when a client checks the API."""

    service: str
    status: str


class Difficulty(str, Enum):
    easy = "easy"
    medium = "medium"
    hard = "hard"


class CategoryResponse(BaseModel):
    slug: str
    display_name_uk: str
    word_count: int


class WordResponse(BaseModel):
    source_id: str
    term: str
    difficulty: Difficulty
    categories: list[str]


class ModerationWordResponse(WordResponse):
    is_approved: bool


class WordCreateRequest(BaseModel):
    source_id: str = Field(min_length=1, max_length=100, pattern=r"^[a-z0-9][a-z0-9_-]*$")
    term: str = Field(min_length=1, max_length=200)
    difficulty: Difficulty
    categories: list[str] = Field(min_length=1, max_length=4)

    @field_validator("term")
    @classmethod
    def strip_term(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("Term cannot be blank.")
        return value

    @field_validator("categories")
    @classmethod
    def validate_categories(cls, values: list[str]) -> list[str]:
        cleaned_values = [value.strip() for value in values]
        if any(not value for value in cleaned_values):
            raise ValueError("Category cannot be blank.")
        if len(set(cleaned_values)) != len(cleaned_values):
            raise ValueError("Categories cannot repeat.")
        return cleaned_values


class WordUpdateRequest(BaseModel):
    term: str | None = Field(default=None, min_length=1, max_length=200)
    difficulty: Difficulty | None = None
    categories: list[str] | None = Field(default=None, min_length=1, max_length=4)

    @field_validator("term")
    @classmethod
    def strip_optional_term(cls, value: str | None) -> str | None:
        return value.strip() if value is not None else None

    @field_validator("categories")
    @classmethod
    def validate_optional_categories(cls, values: list[str] | None) -> list[str] | None:
        return WordCreateRequest.validate_categories(values) if values is not None else None

    @model_validator(mode="after")
    def require_at_least_one_change(self) -> "WordUpdateRequest":
        if not self.model_fields_set:
            raise ValueError("Provide at least one field to update.")
        if self.term == "":
            raise ValueError("Term cannot be blank.")
        return self


class ModerationRequest(BaseModel):
    approved: bool


app = FastAPI(
    title="DevAlias API",
    version="0.1.0",
    description="The future server API for the DevAlias IT terminology game.",
)


@app.get("/", tags=["service"])
def read_root() -> dict[str, str]:
    """Return a friendly response for a browser opening the server URL."""
    return {
        "service": "DevAlias API",
        "message": "Server is running. Open /docs to explore the API.",
    }


@app.get("/health", response_model=HealthResponse, tags=["service"])
def read_health() -> HealthResponse:
    """Return an inexpensive status response for people and future clients."""
    return HealthResponse(service="DevAlias API", status="ok")


@app.get("/categories", response_model=list[CategoryResponse], tags=["dictionary"])
def read_categories() -> list[CategoryResponse]:
    """Return every published word category and its available word count."""
    with open_database() as connection:
        return [CategoryResponse(**category) for category in list_categories(connection)]


@app.get("/words/random", response_model=WordResponse, tags=["dictionary"])
def read_random_word(
    difficulty: Difficulty | None = None,
    category: str | None = Query(default=None, min_length=1, max_length=64),
) -> WordResponse:
    """Return one random approved word, optionally filtered for a game setup."""
    with open_database() as connection:
        if category is not None and not category_exists(connection, category):
            raise HTTPException(status_code=404, detail="Category was not found.")
        word = random_word(
            connection,
            difficulty=difficulty.value if difficulty is not None else None,
            category=category,
        )
    if word is None:
        raise HTTPException(status_code=404, detail="No word matches these filters.")
    return WordResponse(**word)


@app.post(
    "/words",
    response_model=ModerationWordResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["moderation"],
)
def create_dictionary_word(payload: WordCreateRequest) -> ModerationWordResponse:
    """Create a new word in the pending moderation state."""
    try:
        with open_database() as connection:
            word = create_word(
                connection,
                source_id=payload.source_id,
                term=payload.term,
                difficulty=payload.difficulty.value,
                categories=payload.categories,
            )
    except UniqueViolation as error:
        raise HTTPException(status_code=409, detail="source_id already exists.") from error
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error
    return ModerationWordResponse(**word)


@app.patch("/words/{source_id}", response_model=ModerationWordResponse, tags=["moderation"])
def edit_dictionary_word(source_id: str, payload: WordUpdateRequest) -> ModerationWordResponse:
    """Edit a pending or approved word without changing its moderation state."""
    changes = payload.model_dump(exclude_unset=True)
    if "difficulty" in changes:
        changes["difficulty"] = changes["difficulty"].value
    try:
        with open_database() as connection:
            word = update_word(connection, source_id=source_id, changes=changes)
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error
    if word is None:
        raise HTTPException(status_code=404, detail="Word was not found.")
    return ModerationWordResponse(**word)


@app.patch(
    "/words/{source_id}/moderation",
    response_model=ModerationWordResponse,
    tags=["moderation"],
)
def moderate_dictionary_word(source_id: str, payload: ModerationRequest) -> ModerationWordResponse:
    """Publish or unpublish a word. Authorization is added in Lesson 33."""
    with open_database() as connection:
        word = set_word_approval(connection, source_id=source_id, approved=payload.approved)
    if word is None:
        raise HTTPException(status_code=404, detail="Word was not found.")
    return ModerationWordResponse(**word)


@app.get("/moderation/words", response_model=list[ModerationWordResponse], tags=["moderation"])
def read_words_for_moderation(
    approved: bool = False,
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
) -> list[ModerationWordResponse]:
    """List pending words by default so a local moderator can review them."""
    with open_database() as connection:
        words = list_words_for_moderation(connection, approved=approved, limit=limit)
    return [ModerationWordResponse(**word) for word in words]
