#!/bin/bash

# Set environment variables for Pact Broker
export PACT_BROKER_BASE_URL="<your_pact_broker_base_url>"
export PACT_BROKER_TOKEN="<your_pact_broker_token>"

# Run tests to generate pact files
rye test

# Publish both pact files to the broker
pact-broker publish userapiclient-provider.json \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" \
  --consumer-app-version latest

pact-broker publish userapiclient-open-api-provider.json \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN" \
  --consumer-app-version latest

# Check if the latest version of the UserApiClient can be deployed to the test environment
pact-broker can-i-deploy \
  --pacticipant UserApiClient \
  --version latest \
  --to-environment test \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"

# Record the deployment of the latest version of the UserApiClient to the test environment
pact-broker record-deployment \
  --pacticipant UserApiClient \
  --version latest \
  --environment test \
  --branch main \
  --broker-base-url "$PACT_BROKER_BASE_URL" \
  --broker-token "$PACT_BROKER_TOKEN"