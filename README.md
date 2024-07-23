# Bi Directional Contract Testing

I wrote this document to help me understand the bi-directional contract testing process. I use [Pactflow](https://pactflow.io/) as the Pact Broker and importantly as the component which converts my OAS(OpenAPI Specficiation) and JUnit test results into a contract. I use the [Pactflow CLI](https://docs.pactflow.io/docs/bi-directional-contract-testing/publishing) to demonstrate the process that will likely be used in the pipeline for the bi-directional contract testing. I'm most famaliar with Python so I chose to focus my efforts in that realm as I can quickly ramp up and get a working example of the bi-directional contract testing process. Obviously the configuration for a Java project would be different but the overarching process should be the same.

## Pre-requisites

- [Acces to Pactflow](https://ritchiebros.atlassian.net/wiki/spaces/mkteng/pages/217514570/Access+to+tools#Pactflow)
- [Pact Standalone CLIs](https://docs.pactflow.io/docs/bi-directional-contract-testing/publishing) - `npm install -g @pact-foundation/pact-cli`
- [rye](https://rye.astral.sh/) - `brew install rye`
  - For each of the apps, `cd` into the respective directories and run the following commands
    - `rye sync` sets up a python virtual environment and installs dependencies
    - `rye test` runs the pytest tests
    - `rye run dev` runs the web services locally

## Starting with the provider side

This is a simple example of how to start with the provider side of the bi-directional contract testing that comes from the [Stoplight blog](https://blog.stoplight.io/bi-directional-contract-testing-a-basic-guide-to-api-contract-testing-compatibilities).

 Starting bi-directional contract testing on the provider’s side involves the following steps.

1. The provider creates their OpenAPI specification (OAS) by hand or using a code generator tool. This specification is the Provider Contract.

    ℹ️ **Note:** *In this example I'm using FastAPI a Python framework that comes with OpenAPI built in.*

2. The provider tests the Provider Contract using a functional API testing tool (such as ReadyAPI or Postman).

    ```shell
    rye test -- --junitxml=results.xml
    ```

3. The provider uploads the Provider Contract to Pactflow.

    ```shell
    pactflow publish-provider-contract openapi_broken.json\
        --provider open-api-producer \
        --provider-app-version 0.0.1 \
        --broker-base-url "$PACT_BROKER_BASE_URL" \
        --broker-token "$PACT_BROKER_TOKEN" \
        --content-type "application/json" \
        --verification-results="results_broken.xml" \
        --verification-results-content-type="application/xml" \
        --verification-success \
        --verifier="pytest"
    ```

    ℹ️ **Note:** *It's key to remember the pact contract from OAS(OpenAPI spec) is only available in the SaaS PactFlow broker and not in a self hosted pact broker.*

4. The provider calls can-i-deploy to trigger the contract verification process.

    ```shell
    pact-broker can-i-deploy \
        --pacticipant open-api-producer \
        --version 0.0.1 \
        --to-environment test \
        --broker-base-url "$PACT_BROKER_BASE_URL" \
        --broker-token "$PACT_BROKER_TOKEN"
    ```

5. Pactflow generates a Verification Result, which determines if the Provider Contract is compatible with the Consumer Contract.

    ℹ️ **Note:** *What happens if there isn't a consumer yet, what's the result of can-i-deploy?*

6. If the contracts are compatible, the provider deploys their interface and records the deployment using pact-broker-record-deployment.

    ```shell
    pact-broker record-deployment \
    --pacticipant open-api-producer \
    --version latest \
    --environment test \
    --broker-base-url "$PACT_BROKER_BASE_URL" \
    --broker-token "$PACT_BROKER_TOKEN"
    ```

## Starting with the consumer side

This is a simple example of how to start with the consumer side of the bi-directional contract testing that comes from the [Stoplight blog](https://blog.stoplight.io/bi-directional-contract-testing-a-basic-guide-to-api-contract-testing-compatibilities).

To start BDCT on the consumer side, the consumer takes the following steps.

1. The consumer tests the behavior of their application using a mock service like Pact or Wiremock.
2. Pact produces a Consumer Contract in the form of a .pact file, which captures the interactions produced by the consumer’s code.

    ```shell
    rye test
    ```

3. The consumer uploads the Consumer Contract to Pactflow.

    ```shell
    pact-broker publish userapiclient-open-api-producer.json \
        --broker-base-url "$PACT_BROKER_BASE_URL" \
        --broker-token "$PACT_BROKER_TOKEN" \
        --consumer-app-version 0.0.2
    ```

4. The consumer calls can-i-deploy, triggering Pactflow’s contract validation process.

```shell
pact-broker can-i-deploy \
    --pacticipant UserApiClient \
    --to-environment test \
    --version 0.0.2 \
    --broker-base-url "$PACT_BROKER_BASE_URL" \
    --broker-token "$PACT_BROKER_TOKEN"
```

5. Pactflow generates a Verification Result, which determines if the Consumer Contract is compatible with the Provider Contract.
6. If the contract passes the verification test, the consumer can deploy their application and record the deployment using the command pact-broker-record-deployment.

## CLI References

When you install the Pact CLIs you get a bunch of binaries that you can use to interact with the Pact Broker APIs hosted by PactFlow and importantly the PactFlow specific APIs which are required for OAS(OpenAPI Specification contract publishing). Here are some of the most important ones:

- `pactflow` is only used for publishing OAS contracts to PactFlow so is only required from the provider side.

    ```shell
    pactflow publish-provider-contract CONTRACT_FILE --provider=PROVIDER -a, --provider-app-version=PROVIDER_APP_VERSION -b, --broker-base-url=BROKER_BASE_URL # Publish provider contract to PactFlow
    ```

- `pact-broker` houses most of the functionality you will require just keep in mind for some use cases it may be more beneficial to use the SDKs which I'll cover in another section. There are a ton of commands available so I'll just list the ones that are most relevant to the bi-directional contract testing process but make sure to check them out with `pact-broker --help`.

    ```shell
    pact-broker can-i-deploy -a, --pacticipant=PACTICIPANT -b, --broker-base-url=BROKER_BASE_URL # Checks if the specified pacticipant version is safe to be deployed.
    pact-broker record-deployment --environment=ENVIRONMENT -a, --pacticipant=PACTICIPANT -b, --broker-base-url=BROKER_BASE_URL -e, --version=VERSION # Record deployment of a pacticipant version to an environment. See https://docs.pact.io/go/record-deployment for more information.
    ```

## SDK References

Test body

## Links

- [Contract Tests vs Functional Tests](https://docs.pact.io/consumer/contract_tests_not_functional_tests)
- [CI/CD Setup Guide](https://docs.pact.io/pact_nirvana)
- [Pact JVM](https://docs.pact.io/implementation_guides/jvm/readme)

## Next Steps

- fix the consumer unit tests since they are always passing even when they should be failing
- build more understanding around the consumer mocking the producer
- walk through a scenario where the consumer needs to publish a breaking change
- walk through a scenario where the provider needs to publish a breaking change
- demo a use case of the webhook
- integrate this workflow with the existing pact lab in RB
- Feedback from pact cli's worth digging into
  - Add Pact verification tests to the open-api-producer build. See https://docs.pact.io/go/provider_verification
  - Configure separate open-api-producer pact verification build and webhook to trigger it when the pact content changes. See https://docs.pact.io/go/webhooks
- previous producer versions remain active even after a new version is deployed, we may need to look into how to remove the old versions 

    ```shell
    CONSUMER      | C.VERSION | PROVIDER          | P.VERSION | SUCCESS? | RESULT#
    --------------|-----------|-------------------|-----------|----------|--------
    UserApiClient | 0.0.3     | open-api-producer | 0.0.3     | true     | 1      
    UserApiClient | 0.0.3     | open-api-producer | latest    | true     | 2    
    ```
