# Import necessary modules
import pytest
from app import UserApiClient
from pact import Consumer, Provider


# Define a fixture for the Pact mock server
@pytest.fixture
def pact_mock_server_fixture():
    pact = Consumer("consumer").has_pact_with(Provider("provider"), port=1234)
    pact.start_service()
    yield pact
    pact.stop_service()


# Write your Pact test using the fixture
def test_get_user(pact_mock_server_fixture):
    expected = {'email': 'john.doe@example.com', 'id': 1, 'name': 'John Doe'}

    pact_mock_server_fixture.given("a user exists").upon_receiving(
        "a request for a user"
    ).with_request(method="get", path="/user").will_respond_with(
        status=200, body=expected
    )

    with pact_mock_server_fixture:
        client = UserApiClient("http://localhost:1234")
        response = client.get_user()

        # Add an assertion to check if the response matches the expected outcome
        assert response.email == "john.doe@example.com", "The response from the consumer does not match the expected outcome." + response.email

    # Here you would typically assert that the response matches what you expect
    # For example, assert user['name'] == "John Doe"
