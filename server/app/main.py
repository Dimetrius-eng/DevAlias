from fastapi import FastAPI
from pydantic import BaseModel


class HealthResponse(BaseModel):
    """The small response returned when a client checks the API."""

    service: str
    status: str


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
