#!/bin/bash

export PACT_BROKER_BASE_URL="https://libotrio.pactflow.io"
export PACT_BROKER_TOKEN="9hSJ6__axJ28A1iztiKzkA"

# run unit test 
rye test

# Publish the consumer contract to the Pact Broker
pact-broker publish userapiclient-open-api-producer.json --broker-base-url "$PACT_BROKER_BASE_URL" --broker-token "$PACT_BROKER_TOKEN" --consumer-app-version 0.0.1

# Can I deploy?
pact-broker can-i-deploy --pacticipant UserApiClient --version 0.0.2 --broker-base-url "$PACT_BROKER_BASE_URL" --broker-token "$PACT_BROKER_TOKEN"

# record deployment
pact-broker record-deployment --pacticipant UserApiClient --version 0.0.1 --environment test