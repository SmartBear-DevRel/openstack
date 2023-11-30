# SmartBear OpenStack

## Pre-Reqs

1. Run `make setup` to fetch a demo OpenAPI document and add a `.gitignore` file to your repository. If you are authoring an OpenAPI document from scratch you can ignore this step, but be sure to update the `OAS_FILE` path in the `Makefile` and update any other refs.

## Design

## Overview

In this step, we will showcase tools used to author, and standardize/govern an API description to ensure it adhere to the OpenAPI Specification and potentially any custom rules you want to enforce.

We will use a free hosted editor, and show how we can run these locally on our machine.

### Tools Used

1. Swagger Editor
2. Swagger Editor Next
3. Stoplight Spectral

### Steps

1. Design an OpenAPI document online with Swagger Editor
   1. https://editor.swagger.io/
   2. Load our sample OpenAPI document from `openapi/openapi.yaml`
      1. File -> Import file
2. Check out the new Swagger Editor which supports OpenAPI & AsyncAPI
   1. https://editor-next.swagger.io/
3. Run Swagger Editor Locally
   1. https://swagger.io/docs/open-source-tools/swagger-editor/
   2. `make do_swagger_editor`
   3. `open http://localhost:8081`
4. Run Swagger Editor-Next Locally
   1. https://swagger.io/docs/open-source-tools/swagger-editor-next/
   2. `make do_swagger_editor_next`
   3. `open http://localhost:8082`
5. Lint the OpenAPI document with Stoplight Spectral
   1. `make create_spectral_default_ruleset`
   2. `make openapi_lint_spectral`

## Documentation

### Tools Used

1. Swagger UI
2. Stoplight Element

### Steps

1. Swagger UI
   1. `make do_swagger_ui`
   2. `open http://localhost:8083`
2. Stoplight Elements
   1. `make openapi_docs_elements`

## Mocking

### Tools Used

1. Stoplight Prism

### Steps

1. Stoplight Prism
   1. `make provider_mock_prism`
   2. `curl localhost:3001/products`

## Functional Testing - Provider Mock Implementation

Create functional tests for SoapUI, driven from the OpenAPI Specification.

Test these against our mock provider (provided by Prism), in order to verify the test suite / mock implementation, and prepare for verifying our provider codebase once implemented.

### Tools Used

1. SoapUI
   1. OpenApi2SoapUI
2. Stoplight Prism

### Steps

1. SoapUI
   1. `make openapi2soapui_docker_fetch`
   2. `make openapi2soapui_build`
   3. `make openapi2soapui_generate_project`
   4. `make provider_mock_prism` - Run our Mock Provider
   5. `make soapui_run`

## Client Code Generation & Contract Testing

### Tools Used

1. Swagger CodeGen
2. Pact
3. Swagger-Mock-Validator

### Steps

1. Fetch and build the Swagger CodeGen Project
   1. `make swagger_codegen_cli_fetch`
   2. `make swagger_codegen_generators_fetch`
   3. `make swagger_codegen_generators_build`
2. Generate the consumer template
   1. `make swagger_codegen_generators_generate`
   2. `make consumer_project_install`
3. Test the consumer project utilising Pact
   1. `make consumer_project_test`
4. Verify Pact's generated Consumer contracts against the OpenAPI
   1. `make consumer_project_verify_pact_openapi`

## Functional Testing - Provider Implementation

### Tools Used

1. SoapUI

### Steps

1. Download a pre-prepared Provider implementation and try it out
   1. `make provider_project_fetch`
   2. `make provider_project_install`
   3. `make provider_project_run`
   4. `curl localhost:3001/products`
2. With the provider still running, run our SoapUI tests
   1. `make provider_project_run` in terminal 1
   2. `make soapui_run` in terminal 2
3. Start the server and test, all in one, omitting the need for two terminals
   1. `make provider_start_test_stop`

## Contract Testing - Provider Implementation

### Tools Used

1. Pact

### Steps

1. Use Pact to replay the consumers contract expectations, against the provider implementation.
   1. `make provider_project_pact_verification`
