#!/bin/bash

export PACT_BROKER_BASE_URL="https://libotrio.pactflow.io"
export PACT_BROKER_TOKEN="9hSJ6__axJ28A1iztiKzkA"

rye test -- -junitxml=results.xml

# Publish the provider contract to the Pact Broker from OAS spec with success
pactflow publish-provider-contract openapi.json\
  --provider open-api-producer \
  --provider-app-version latest \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" \
  --content-type "application/json" \
  --verification-results="results.xml" \
  --verification-results-content-type="application/xml" \
  --verification-success \
  --verifier="pytest"
#  [--verification-exit-code=N] # consider using this with the exit code from the pytest

# Can I deploy 
pact-broker can-i-deploy --pacticipant open-api-producer --version latest --to-environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" 


# record deployment
pact-broker record-deployment --pacticipant open-api-producer --version latest --environment test --branch main \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# record release
pact-broker record-release --pacticipant open-api-producer --version latest --environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"