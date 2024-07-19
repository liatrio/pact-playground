from pact import Verifier
import pytest

def test_provider():
    verifier = Verifier(provider='UserProvider', provider_base_url='http://localhost:8082')

    # Assuming the pact file is in the current directory
    pact_file_url = '../consumer/userapiclient-userprovider.json'

    # Verify the provider against the pact file without setting up states
    output, _ = verifier.verify_pacts(pact_file_url)

    # Check if the verification failed (assuming non-zero output indicates failure)
    if output != 0:
        raise AssertionError("Pact verification failed")