#!/bin/bash

# Set environment variables for Pact Broker
export PACT_BROKER_BASE_URL="<your_pact_broker_base_url>"
export PACT_BROKER_TOKEN="<your_pact_broker_token>"

# Run tests to generate verification results
rye test -- -junitxml=results.xml

# Publish the provider contract to the Pact Broker from OAS spec with success
pactflow publish-provider-contract openapi.json \
  --provider open-api-producer \
  --provider-app-version latest \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" \
  --content-type "application/json" \
  --verification-results="results.xml" \
  --verification-results-content-type="application/xml" \
  --verification-success \
  --verifier="pytest"

# Check if the latest version of the open-api-producer can be deployed to the test environment
pact-broker can-i-deploy \
  --pacticipant open-api-producer \
  --version latest \
  --to-environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the deployment of the latest version of the open-api-producer to the test environment
pact-broker record-deployment \
  --pacticipant open-api-producer \
  --version latest \
  --environment test \
  --branch main \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the release of the latest version of the open-api-producer in the test environment
pact-broker record-release \
  --pacticipant open-api-producer \
  --version latest \
  --environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"