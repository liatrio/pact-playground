import threading
import time
from pact import Verifier

from fastapi.testclient import TestClient

from app import app

client = TestClient(app)

def test_read_main():
    response = client.get("user")
    assert response.status_code == 200
    assert response.json() == {"id": 1, "name": "John Doe", "email": "john.doe@example.com"}

def test_open_api_provider():
    # Start the FastAPI app using uvicorn in a separate thread
    def run_server():
        import uvicorn
        uvicorn.run(app, host='localhost', port=8082)

    server_thread = threading.Thread(target=run_server)
    server_thread.daemon = True
    server_thread.start()

    # Give the server a moment to start up
    time.sleep(1)

    verifier = Verifier(provider='open-api-provider', provider_base_url='http://localhost:8082')

    # Assuming the pact file is in the current directory
    pact_file_url = '../consumer/consumer-open-api-provider.json'

    # Verify the provider against the pact file without setting up states
    output, _ = verifier.verify_pacts(pact_file_url)

    # Check if the verification failed (assuming non-zero output indicates failure)
    if output != 0:
        raise AssertionError("Pact verification failed")