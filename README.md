# SmartBear OpenStack

## Day 1

- Create an API definition with OpenAPI
  - [Swagger Editor](https://editor.swagger.io/)

1. Visit [Swagger Editor](https://editor.swagger.io/)
   1. You'll notice the OpenAPI definition editor on the left
   2. The UI renderer on the right hand side.
2. Make some changes to the API, and note these are reflected in our UI on the right hand side.
3. Save your API definition
   1. File -> Save as YAML
   2. File -> Convert and save as JSON
4. You can also generate client and server stub code from your API definition, we will cover this later.
5. Lets make a folder to hold our OpenAPI definitions.

```sh
mkdir -p openapi
```

6. Now let's populate it with some API's

The [Swagger-Codegen](https://github.com/swagger-api/swagger-codegen) project, provides [online generators](https://github.com/swagger-api/swagger-codegen?tab=readme-ov-file#online-generators), we can use this to get a copy of the Swagger Petstore example API definition, as shown in the swagger-editor.

```sh
curl -Ls https://generator3.swagger.io/openapi.json -o openapi/petstore.json
```

We have also prepared a PactFlow Product API definition, which you can pull in to this project, from an external location

```sh
curl -Ls https://raw.githubusercontent.com/YOU54F/swaggerhub-pactflow/main/oas/swagger.yaml -o openapi/products.yaml
```

7. Swagger Editor provides support for OpenAPI documents, traditionally used for RESTful, or REST-like services, that communicate over HTTP. Swagger-Editor next provides an enhanced editing and UI experience, and support for AsyncAPI and the event-driven messaging systems it can document.
   1. Click `Try our new editor` to see [Swagger-Editor Next](https://editor-next.swagger.io/)
   2. By default, it loads a Kafka AsyncAPI Streetlights example.
   3. You can select File -> Load Example -> OpenAPI 3.0 PetStore to see an OpenAPI document in the new editor.

That's it for day 1, join us tomorrow where we will how we can run Swagger UI and Swagger Editor (and Swagger Editor Next) on our local machine.

## Day 2

- Load your definition locally
  - Swagger UI
  - Swagger Editor
  - Swagger Editor Next
  - Stoplight Elements

## Day 3

- Stoplight Spectral
  - Validate your OpenAPI Document
- Stoplight Prism
  - Create a mock server from your OpenAPI document to serve to potential consumers

## Day 4

- Swagger CodeGen
  - Generate a server implementation

## Day 5

- SoapUI
  - Test Server implementation against OpenAPI with SoapUI

## Day 6

- Swagger CodeGen
  - Generate a client implementation

## Day 7

- Pact
  - Generate Consumer contract
- Swagger-Mock-Validator
  - Validate Consumer contract against OpenAPI Definition

## Day 8

- Swagger CodeGen
  - Update code-gen to generate Pact boilerplate to template
  - Utilise custom template to generate client with Pact tests

## Day 9

- Pact
  - Setup a Pact Broker
  - Publish Pact Contracts

## Day 10

- Pact
  - Provider validates consumer contracts

## Day ?