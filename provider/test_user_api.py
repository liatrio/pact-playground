import threading
import time
from pact import Verifier
from app import app

def test_provider():
    # Start the Flask app in a separate thread
    def run_server():
        app.run(host='localhost', port=8082)

    server_thread = threading.Thread(target=run_server)
    server_thread.daemon = True
    server_thread.start()

    # Give the server a moment to start up
    time.sleep(1)

    verifier = Verifier(provider='provider', provider_base_url='http://localhost:8082')

    # Assuming the pact file is in the current directory
    pact_file_url = '../consumer/consumer-provider.json'

    # Verify the provider against the pact file without setting up states
    output, _ = verifier.verify_pacts(pact_file_url)

    # Check if the verification failed (assuming non-zero output indicates failure)
    if output != 0:
        raise AssertionError("Pact verification failed")