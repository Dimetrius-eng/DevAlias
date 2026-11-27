from enum import Enum

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel

from app.database import open_database
from app.dictionary_repository import category_exists, list_categories, random_word


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
