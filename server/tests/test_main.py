from app.main import read_health, read_root


def test_root_describes_the_service() -> None:
    response = read_root()

    assert response["service"] == "DevAlias API"
    assert "/docs" in response["message"]


def test_health_reports_an_operational_server() -> None:
    response = read_health()

    assert response.model_dump() == {"service": "DevAlias API", "status": "ok"}
