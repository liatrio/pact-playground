#!/bin/bash

# Set environment variables for Pact Broker
export PACT_BROKER_BASE_URL="<your_pact_broker_base_url>"
export PACT_BROKER_TOKEN="<your_pact_broker_token>"

# Run tests to generate verification results
rye test -- -junitxml=results.xml

# Check if the latest version of the producer can be deployed to the test environment
pact-broker can-i-deploy \
  --pacticipant producer \
  --version latest \
  --to-environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the deployment of the latest version of the producer to the test environment
pact-broker record-deployment \
  --pacticipant producer \
  --version latest \
  --environment test \
  --branch main \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the release of the latest version of the producer in the test environment
pact-broker record-release \
  --pacticipant producer \
  --version latest \
  --environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" 