"""PostgreSQL connection helpers for the DevAlias API."""

import os
from contextlib import contextmanager
from typing import Iterator

import psycopg
from psycopg.rows import dict_row


DEFAULT_DATABASE_URL = (
    "postgresql://devalias:devalias_local_password@localhost:5432/devalias"
)


@contextmanager
def open_database() -> Iterator[psycopg.Connection]:
    """Open one short-lived connection for an API request."""
    database_url = os.getenv("DATABASE_URL", DEFAULT_DATABASE_URL)
    with psycopg.connect(database_url, row_factory=dict_row) as connection:
        yield connection
