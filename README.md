# Contract Testing

This repository demonstrates simple examples of different Pact testing flows. It uses [Pactflow](https://pactflow.io/) as the Pact Broker to convert OpenAPI Specifications (OAS) and JUnit test results into contracts. The examples focus on Python, using both Flask and FastAPI frameworks.

Contract testing is crucial for ensuring reliable integration between services by verifying that they can communicate as expected. It helps catch integration issues early in the development process, reducing the risk of failures in production.

## Pre-requisites

- Access to Pactflow: Used as the Pact Broker to manage and share contracts between services.
- [Pact Standalone CLIs](https://docs.pactflow.io/docs/bi-directional-contract-testing/publishing): Provides command-line tools for publishing and verifying contracts. Install with `npm install -g @pact-foundation/pact-cli`.
- [rye](https://rye.astral.sh/): A Python tool for managing virtual environments and dependencies. Install with `brew install rye`.
  - For each of the apps, `cd` into the respective directories and run the following commands:
    - `rye sync` sets up a Python virtual environment and installs dependencies.
    - `rye test` runs the pytest tests.
    - `rye run dev` runs the web services locally.

## Consumer-Driven Contract Testing

In this approach, the consumer defines the contract, and the producer verifies it. This is demonstrated in the relationship between the `consumer` and `producer` components.

**Summary**: Consumer-driven contract testing allows the consumer to specify the interactions it expects from the producer. This ensures that the producer can meet the consumer's needs, leading to more reliable integrations and fewer surprises during deployment.

### Consumer-Driven Steps

#### Consumer-Driven Consumer Side

- **Write Tests**: Define expected interactions with the producer using a mock service.
- **Generate Contract**: Run tests to generate a contract file (`consumer-producer.json`).
- **Publish Contract**: Use the `pact-broker` CLI to publish the contract to the Pact Broker.

#### Consumer-Driven Producer Side

- **Retrieve Contract**: Fetch the contract from the Pact Broker.
- **Verify Contract**: Run verification tests to ensure compatibility with the consumer's expectations.
- **Deploy**: If verification is successful, proceed with deployment.

### Consumer-Driven Webhooks

1. **Contract Publication Notification**
   - **Purpose**: Notify the producer when a new contract is published by the consumer.
   - **Action**: Trigger the producer's CI/CD pipeline to verify the contract against the current implementation.
   - **Implementation**: Set up a webhook in the Pact Broker to listen for contract publication events and trigger a verification job on the producer's side.
   - **Benefits**: Automates the notification and verification process, reducing manual intervention and ensuring the producer is aware of new consumer expectations.

2. **Verification Result Notification**
   - **Purpose**: Inform the consumer of the verification results once the producer has tested the contract.
   - **Action**: Update the consumer's status or trigger further actions based on the verification outcome.
   - **Implementation**: Use a webhook to send the verification results back to the consumer's CI/CD system.
   - **Benefits**: Provides immediate feedback to the consumer, allowing for quick adjustments if necessary.

3. **Deployment Notification**
   - **Purpose**: Notify the consumer when the producer deploys a new version that has passed contract verification.
   - **Action**: Trigger consumer-side tests to ensure compatibility with the new producer version.
   - **Implementation**: Set up a webhook to notify the consumer's system whenever a new producer version is deployed.
   - **Benefits**: Ensures that the consumer is always compatible with the latest producer version, reducing integration issues.

## Bi-Directional Contract Testing

This approach involves both the consumer and provider defining and verifying contracts. It is demonstrated in the relationship between the `consumer` and `open-api-producer` components.

**Summary**: Bi-directional contract testing ensures that both the consumer and provider agree on the contract. This mutual agreement helps prevent integration issues by verifying that both sides meet each other's expectations, leading to smoother deployments and more robust integrations.

### Bi-Directional Steps

#### Bi-Directional Provider Side

- **Define API Spec**: Create an OpenAPI specification for the provider.
- **Publish Spec**: Use the `pactflow` CLI to publish the specification to the Pact Broker.
- **Verify Consumer Contract**: Retrieve and verify the consumer-generated contract.

#### Bi-Directional Consumer Side

- **Write Tests**: Define expected interactions with the provider using a mock service.
- **Generate Contract**: Run tests to generate a contract file (`consumer-open-api-producer.json`).
- **Verify Provider Spec**: Retrieve and verify the provider's OpenAPI specification.

### Bi-Directional Webhooks

1. **Contract Change Notification**
   - **Purpose**: Notify the provider whenever a new consumer contract is published.
   - **Action**: Trigger a verification process on the provider side to ensure compatibility with the new contract.
   - **Implementation**: Set up a webhook in the Pact Broker to listen for contract publication events and trigger a CI/CD pipeline or a verification script.
   - **Benefits**: Automates the process of keeping both sides informed and in sync, reducing manual intervention.

2. **Verification Status Notification**
   - **Purpose**: Notify the consumer when the provider has verified a contract.
   - **Action**: Update the consumer's deployment status or trigger further testing.
   - **Implementation**: Use a webhook to send verification results back to the consumer's CI/CD system.
   - **Benefits**: Ensures that both consumer and provider are always compatible before deployment, enhancing reliability.

3. **Deployment Notification**
   - **Purpose**: Inform the consumer when the provider has deployed a new version.
   - **Action**: Trigger consumer-side tests to ensure compatibility with the new provider version.
   - **Implementation**: Set up a webhook to notify the consumer's system whenever a new provider version is deployed.
   - **Benefits**: Reduces manual intervention and speeds up the feedback loop, ensuring robust integration.

4. **Environment Change Notification**
   - **Purpose**: Notify both consumer and provider teams when a contract is moved to a new environment (e.g., from staging to production).
   - **Action**: Trigger environment-specific tests or deployments.
   - **Implementation**: Use webhooks to automate environment-specific workflows.
   - **Benefits**: Ensures that both sides are aware of environment changes, reducing the risk of deployment issues.

### Starting with the Provider Side

This example demonstrates starting with the provider side of bi-directional contract testing, inspired by the [Stoplight blog](https://blog.stoplight.io/bi-directional-contract-testing-a-basic-guide-to-api-contract-testing-compatibilities).

1. The provider creates their OpenAPI specification (OAS) by hand or using a code generator tool. This specification is the Provider Contract.

    ℹ️ **Note:** *In this example, FastAPI is used, a Python framework with built-in OpenAPI support.*

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

    ℹ️ **Note:** *The pact contract from OAS is only available in the SaaS PactFlow broker and not in a self-hosted pact broker.*

4. The provider calls can-i-deploy to trigger the contract verification process.

    ```shell
    pact-broker can-i-deploy \
        --pacticipant open-api-producer \
        --version 0.0.1 \
        --to-environment test \
        --broker-base-url "$PACT_BROKER_BASE_URL" \
        --broker-token "$PACT_BROKER_TOKEN"
    ```

5. Pactflow generates a Verification Result, determining if the Provider Contract is compatible with the Consumer Contract.

6. If the contracts are compatible, the provider deploys their interface and records the deployment using pact-broker-record-deployment.

    ```shell
    pact-broker record-deployment \
    --pacticipant open-api-producer \
    --version latest \
    --environment test \
    --broker-base-url "$PACT_BROKER_BASE_URL" \
    --broker-token "$PACT_BROKER_TOKEN"
    ```

## Starting with the Consumer Side

This example demonstrates starting with the consumer side of bi-directional contract testing, inspired by the [Stoplight blog](https://blog.stoplight.io/bi-directional-contract-testing-a-basic-guide-to-api-contract-testing-compatibilities).

1. The consumer tests the behavior of their application using a mock service like Pact or Wiremock.
2. Pact produces a Consumer Contract in the form of a .pact file, capturing the interactions produced by the consumer's code.

    ```shell
    rye test
    ```

3. The consumer uploads the Consumer Contract to Pactflow.

    ```shell
    pact-broker publish consumer-open-api-producer.json \
        --broker-base-url "$PACT_BROKER_BASE_URL" \
        --broker-token "$PACT_BROKER_TOKEN" \
        --consumer-app-version 0.0.2
    ```

4. The consumer calls can-i-deploy, triggering Pactflow's contract validation process.

    ```shell
    pact-broker can-i-deploy \
        --pacticipant consumer \
        --to-environment test \
        --version 0.0.2 \
        --broker-base-url "$PACT_BROKER_BASE_URL" \
        --broker-token "$PACT_BROKER_TOKEN"
    ```

5. Pactflow generates a Verification Result, determining if the Consumer Contract is compatible with the Provider Contract.
6. If the contract passes the verification test, the consumer can deploy their application and record the deployment using the command pact-broker-record-deployment.

## Breaking Change Detection

Breaking changes in contract testing can occur when:

1. A consumer adds a new expectation (e.g., a new field or endpoint) that the provider does not support.
2. A provider makes a change (e.g., removes or renames a field) that breaks an existing consumer.

The `can-i-deploy` tool in the API Hub for Contract Testing helps detect such situations by performing a contract comparison. It checks if the consumer contract is a valid subset of the provider contract in the target environment.

### Provider Breaking Changes

- If a provider makes a backward-incompatible change, such as removing a field that consumers rely on, the `can-i-deploy` tool will alert you to the incompatibility.
- Safe changes, like removing unused fields, will not trigger a failure.

**Example**: If a provider removes a field called `price` from its API, and no consumers use this field, the change is safe. However, if a consumer relies on the `price` field, the `can-i-deploy` tool will prevent the provider from deploying this change.

### Consumer Breaking Changes

- If a consumer adds a new expectation that the provider does not support, the `can-i-deploy` tool will prevent deployment until the provider supports the change.

**Example**: If a consumer adds a new field `color` to its expected response from the provider, but the provider does not support this field, the `can-i-deploy` tool will block the consumer's deployment until the provider adds support for `color`.

### Key Points

- It is safe to remove a field from a provider if no consumers are using it.
- Removing a field or endpoint that consumers use is unsafe and will be detected by the API Hub for Contract Testing.
- The tool prevents consumers from deploying changes that providers do not yet support.

This section is relevant to both consumer-driven and bi-directional contract testing, as breaking change detection is crucial for maintaining compatibility and preventing integration issues.

## CLI References

When you install the Pact CLIs, you get a bunch of binaries to interact with the Pact Broker APIs hosted by PactFlow and importantly the PactFlow-specific APIs required for OAS contract publishing. Here are some of the most important ones:

- `pactflow`: Used for publishing OAS contracts to PactFlow, required only from the provider side. This command is essential for sharing the provider's API specification with the Pact Broker, enabling consumers to verify their contracts against it.

    ```shell
    pactflow publish-provider-contract CONTRACT_FILE --provider=PROVIDER -a, --provider-app-version=PROVIDER_APP_VERSION -b, --broker-base-url=BROKER_BASE_URL # Publish provider contract to PactFlow
    ```

- `pact-broker`: Houses most of the functionality you will require. It is used for various operations such as checking deployment readiness and recording deployments. For some use cases, it may be more beneficial to use the SDKs. There are many commands available, so make sure to check them out with `pact-broker --help`.

    - **can-i-deploy**: Checks if the specified pacticipant version is safe to be deployed. This command is crucial for ensuring that all contracts are compatible before deploying a new version.

    ```shell
    pact-broker can-i-deploy -a, --pacticipant=PACTICIPANT -b, --broker-base-url=BROKER_BASE_URL # Checks if the specified pacticipant version is safe to be deployed.
    ```

    - **record-deployment**: Records the deployment of a pacticipant version to an environment. This helps keep track of which versions are deployed where, ensuring that the correct versions are running in each environment.

    ```shell
    pact-broker record-deployment --environment=ENVIRONMENT -a, --pacticipant=PACTICIPANT -b, --broker-base-url=BROKER_BASE_URL -e, --version=VERSION # Record deployment of a pacticipant version to an environment. See https://docs.pact.io/go/record-deployment for more information.
    ```

## Links

- [Contract Tests vs Functional Tests](https://docs.pact.io/consumer/contract_tests_not_functional_tests): Explains the differences between contract tests and functional tests, highlighting the unique benefits of contract testing.
- [CI/CD Setup Guide](https://docs.pact.io/pact_nirvana): Provides a comprehensive guide to setting up CI/CD pipelines with Pact, ensuring smooth integration and deployment processes.
- [Pact JVM](https://docs.pact.io/implementation_guides/jvm/readme): Offers detailed instructions for implementing Pact in JVM-based projects, including setup and usage examples.
- [Breaking Change Detection](https://support.smartbear.com/api-hub/contract-testing/docs/en/pactflow-university/bi-directional-contract-testing/workshop/10--breaking-change-detection.html): Discusses how to detect breaking changes in contracts and the tools available to prevent them.
- [Github Action Workshop](https://support.smartbear.com/api-hub/contract-testing/docs/en/pactflow-university/bi-directional-contract-testing/quick-start-guide-with-github-actions.html): A workshop guide for integrating Pact with GitHub Actions, automating contract testing workflows.

## Next Steps

### Short-Term Goals

- Fix the consumer unit tests since they are always passing even when they should be failing.
- Build more understanding around the consumer mocking the producer.
- Walk through a scenario where the consumer needs to publish a breaking change.
- Walk through a scenario where the provider needs to publish a breaking change.
- Demo a use case of the webhook.

### Long-Term Goals

- Integrate this workflow with the existing pact lab in RB.
- Feedback from pact CLI's worth digging into:
  - Add Pact verification tests to the open-api-producer build. See https://docs.pact.io/go/provider_verification
  - Configure separate open-api-producer pact verification build and webhook to trigger it when the pact content changes. See https://docs.pact.io/go/webhooks
- Previous producer versions remain active even after a new version is deployed; we may need to look into how to remove the old versions.
- Show an example of the consumer using the OpenAPI spec to define model and request/response objects to use in tests and then using Pact to verify the contract.

    ```shell
    CONSUMER      | C.VERSION | PROVIDER          | P.VERSION | SUCCESS? | RESULT#
    --------------|-----------|-------------------|-----------|----------|--------
    consumer      | 0.0.3     | open-api-producer | 0.0.3     | true     | 1      
    consumer      | 0.0.3     | open-api-producer | latest    | true     | 2    
    ```
