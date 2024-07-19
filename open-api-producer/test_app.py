from fastapi.testclient import TestClient

from app import app

client = TestClient(app)

def test_read_main():
    response = client.get("user")
    assert response.status_code == 200
    assert response.json() == {"id": 1, "name": "John Doe", "email": "john.doe@example.com"}