OAS_FILE=openapi/openapi.yaml
ENDPOINT?=http://localhost:3001
HEALTHCHECK_PATH?=http://localhost:3001/products
PROJECT_FOLDER?=project
PROJECT_FILE?=openapi2soapui.xml
# v2.2.3
WAIT_FOR_VERSION=4df3f9262d84cab0039c07bf861045fbb3c20ab7
setup: setup_dirs openapi_fetch git_ignore ## Run init
do_swagger_ui: swagger_ui_docker_run ## Run UI
do_swagger_editor: swagger_editor_docker_run ## Run Editor
do_swagger_editor_next: swagger_editor_next_docker_run ## Run Editor - Next
do_generate_consumer: swagger_codegen_cli_fetch swagger_codegen_generators_fetch swagger_codegen_generators_build swagger_codegen_generators_generate consumer_project_install ## Generate consumer project
do_generate_provider: provider_project_fetch provider_project_install provider_project_run ## Generate provider project
do_provider_test: provider_start_test_stop ## Test provider

setup_dirs:
	mkdir -p openapi
openapi_fetch: ## Downloads a reference OpenAPI specification
	curl -Ls https://raw.githubusercontent.com/YOU54F/swaggerhub-pactflow/main/oas/swagger.yaml -o ${OAS_FILE}

git_ignore: ## Creates a tailored .gitignore file
	echo 'swagger-codegen-generators \n\
	codegen.config.json \n\
	typescript-fetch-pact-consumer \n\
	openapi2soapui \n\
	openapi.yaml \n\
	swagger-codegen-cli.jar'>.gitignore

swagger_codegen_cli_fetch: ## Get the Swagger Codegen CLI
	wget https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.36/swagger-codegen-cli-3.0.36.jar -O swagger-codegen-cli.jar
	java -jar swagger-codegen-cli.jar --help

swagger_codegen_generators_fetch: ## Get a fork of Swagger-Code-Generators containing Pact templates
	git clone -b typescript-fetch-pact https://github.com/you54f/swagger-codegen-generators

swagger_codegen_generators_build: ## Build the swagger-codegen-generators project with Java 
	cd swagger-codegen-generators && mvn package

swagger_codegen_generators_generate: ## Generate a templated project from a given OpenAPI specification
	echo '{ "npmName": "typescript-fetch-pact-consumer" }'>codegen.config.json
	java -cp swagger-codegen-cli.jar:swagger-codegen-generators/target/swagger-codegen-generators-1.0.36-SNAPSHOT.jar io.swagger.codegen.v3.Codegen  \
     -i ${OAS_FILE} -l typescript-fetch-pact -c codegen.config.json -o typescript-fetch-pact-consumer

consumer_project_install: ## Install the templated project
	cd typescript-fetch-pact-consumer && npm i

provider_project_test: ## Test the templated project with Pact
	cd typescript-fetch-pact-consumer && npm test

openapi2soapui_fetch: ## Downloads the apiaddicts/openapi2soapui repository
	git clone https://github.com/apiaddicts/openapi2soapui

openapi2soapui_docker_fetch: ## Downloads the you54f/openapi2soapui Docker image
	docker pull you54f/openapi2soapui
	
openapi2soapui_build: ## Builds the apiaddicts/openapi2soapui repository
	cd openapi2soapui &&\
	mvn clean package -Pjar &&\
	docker-compose up -d
	
openapi2soapui_run: ## Runs the apiaddicts/openapi2soapui repository
	cd openapi2soapui &&\
	docker-compose up -d

openapi2soapui_docker_run:  ## Runs the you54f/openapi2soapui Docker image
	docker run -d -p 8080:8080 you54f/openapi2soapui

openapi2soapui_generate_stdout: ## Convert OpenAPI to SoapUI to stdout
	curl --location --request POST 'http://localhost:8080/api-openapi-to-soapui/v1/soap-ui-projects' \
	--header 'Content-Type: application/json' \
	--data-raw '{ "apiName": "Users", "oAuth2Profiles": [], "openApiSpec": "$(shell cat ${OAS_FILE} | base64 -w0 2> /dev/null|| cat ${OAS_FILE} | base64)", "testCaseNames": [ "Success" ], "headers": [] }'
openapi2soapui_generate_project:  ## Convert OpenAPI to SoapUI to project/openapi2soapui.xml
	mkdir -p project && make openapi2soapui_generate_stdout > project/openapi2soapui.xml && echo 'OK'
git_init: git_ignore ## Inits a git project, from the given folder
	git init && git add . && git commit -m 'first commit'

swagger_editor_next_docker_fetch:  ## Downloads the swaggerapi/swagger-editor:next-v5 Docker image
	docker pull swaggerapi/swagger-editor:next-v5

swagger_editor_next_docker_run:  ## Runs the swaggerapi/swagger-editor:next-v5 Docker image 
# https://github.com/swagger-api/swagger-editor/tree/next#docker 
# https://github.com/swagger-api/swagger-editor/issues/3270
	docker run -d -p 8081:80 swaggerapi/swagger-editor:next-v5

swagger_editor_docker_fetch:  ## Downloads the swaggerapi/swagger-editor Docker image
	docker pull swaggerapi/swagger-editor

swagger_editor_docker_run:  ## Runs the swaggerapi/swagger-editor Docker image 
# https://github.com/swagger-api/swagger-editor#running-the-image-from-dockerhub
	docker run -d -p 8082:8080 -e SWAGGER_FILE=/${OAS_FILE} -v ${PWD}/openapi:/openapi swaggerapi/swagger-editor

swagger_ui_docker_fetch:  ## Downloads the swaggerapi/swagger-ui Docker image
	docker pull swaggerapi/swagger-ui

swagger_ui_docker_run:  ## Runs the swaggerapi/swagger-ui Docker image 
# https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/configuration.md#docker
	docker run -d -p 8083:8080 -e SWAGGER_JSON=/${OAS_FILE} -v ${PWD}/openapi:/openapi swaggerapi/swagger-ui

provider_project_fetch: ## Downloads the pactflow/example-bi-directional-provider-soapui repository
	git clone https://github.com/pactflow/example-bi-directional-provider-soapui

provider_project_install: ## Installs the pactflow/example-bi-directional-provider-soapui project
	cd example-bi-directional-provider-soapui && npm i

provider_project_run:  ## Runs the provider project
	cd example-bi-directional-provider-soapui && npm run start

provider_start_test_stop: ## Runs the provider project and tests with SoapUI
	cd example-bi-directional-provider-soapui && { npm run start & PID=$$!;} && cd .. && \
	{ echo $$PID && wget -qO- https://raw.githubusercontent.com/eficode/wait-for/${WAIT_FOR_VERSION}/wait-for \
	| sh -s -- ${HEALTHCHECK_PATH} -- make soapui_run; } ; kill $$PID

soapui_run: ## Runs a SoapUI test suite in Docker
	case "$(shell uname -sm)" in \
	Darwin*|Windows) str='$(ENDPOINT)'; ENDPOINT=$${str/localhost/host.docker.internal};; \
	esac; \
	echo $${ENDPOINT:-ENDPOINT} && \
	docker run --rm --network="host" \
		-v="${PWD}"/"${PROJECT_FOLDER}":/project \
		-e ENDPOINT="$$ENDPOINT" \
		-e PROJECT_FILE="${PROJECT_FILE}" \
		-e COMMAND_LINE="'-e"$$ENDPOINT"' '-f/%project%/reports' -r -j /project/"${PROJECT_FILE}"" \
		smartbear/soapuios-testrunner:latest

.PHONY: help

help:
	@echo ======== SmartBear OpenStack ===========
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'