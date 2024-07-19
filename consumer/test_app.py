# Import necessary modules
import pytest
from pact import Consumer, Provider
from app import UserApiClient


# Define a fixture for the Pact mock server
@pytest.fixture
def pact_mock_server_fixture():
    pact = Consumer("UserApiClient").has_pact_with(Provider("open-api-producer"), port=1234)
    pact.start_service()
    yield pact
    pact.stop_service()


# Write your Pact test using the fixture
def test_get_user(pact_mock_server_fixture):
    expected = {"id": 1, "name": "John Doe", "email": "john.doe@example.com"}

    # Define the interaction
    pact_mock_server_fixture.given("a user exists").upon_receiving(
        "a request for a user"
    ).with_request(method="get", path="/user").will_respond_with(
        status=200, body=expected
    )

    # Use the actual client to make the request to the Pact mock server
    with pact_mock_server_fixture:
        client = UserApiClient("http://localhost:1234")
        client.get_user()

    # Here you would typically assert that the response matches what you expect
    # For example, assert user['name'] == "John Doe"
