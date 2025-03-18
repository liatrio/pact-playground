#!/bin/bash

# Set environment variables for Pact Broker
export PACT_BROKER_BASE_URL="<your_pact_broker_base_url>"
export PACT_BROKER_TOKEN="<your_pact_broker_token>"

# Run tests to generate verification results
rye test -- -junitxml=results.xml

# Check if the latest version of the provider can be deployed to the test environment
pact-broker can-i-deploy \
  --pacticipant provider \
  --version latest \
  --to-environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the deployment of the latest version of the provider to the test environment
pact-broker record-deployment \
  --pacticipant provider \
  --version latest \
  --environment test \
  --branch main \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the release of the latest version of the provider in the test environment
pact-broker record-release \
  --pacticipant provider \
  --version latest \
  --environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" 