# API Gateway + Lambda + DynamoDB Template

[![Deploy to Staging](https://github.com/ebsoftwareservices/apigw-lambda-dynamodb-template/actions/workflows/deploy-to-staging.yml/badge.svg)](https://github.com/ebsoftwareservices/apigw-lambda-dynamodb-template/actions/workflows/deploy-to-staging.yml)

This repository is a starter template for building and deploying a serverless HTTP API on AWS using:

- **Amazon API Gateway** for HTTP endpoints
- **AWS Lambda** for business logic
- **Amazon DynamoDB** for persistence
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD deployment

Use this template when you want a simple, production-friendly baseline for API development with infrastructure and deployment automated from day one.

## 1) AWS Services Introduction

### Amazon API Gateway (HTTP API)
API Gateway is AWS's managed service for publishing APIs. In this template, API Gateway:

- Exposes public HTTP routes such as `GET /greetings` and `GET /gifts`
- Forwards requests to Lambda using **AWS_PROXY** integrations
- Supports JWT authorization on protected routes
- Emits structured stage access logs to CloudWatch

Why it helps:
- No servers to manage
- Built-in routing, auth integration, and monitoring
- Scales automatically

### AWS Lambda
Lambda runs code on demand without provisioning servers. In this template:

- Each endpoint is backed by a Node.js Lambda function
- Functions return API Gateway compatible responses (`statusCode`, `headers`, `body`)
- IAM permissions are attached per function (for logs and DynamoDB access)

Why it helps:
- Pay per request and execution duration
- Automatic scaling
- Tight integration with API Gateway and DynamoDB

### Amazon DynamoDB
DynamoDB is a fully managed NoSQL key-value/document database. In this template:

- A table named `bedrock-gifts` is created
- `id` is the partition key
- Billing mode is `PAY_PER_REQUEST` (on-demand)
- The gifts Lambda scans the table and returns results as JSON

Why it helps:
- Serverless scaling
- High availability by default
- Good fit for low-latency API use cases

## 2) Terraform Introduction

Terraform lets you define infrastructure as code and apply it consistently across environments.

In this repository, Terraform is used to define:

- API Gateway routes, integrations, and authorizer
- Lambda functions and Lambda layers
- DynamoDB table
- IAM policies and Lambda invoke permissions
- S3 backend state configuration (environment-specific)

Key Terraform files:

- `terraform/main.tf`: provider, versions, backend, shared tags
- `terraform/apigateway.tf`: HTTP API, CORS, access logs, JWT auth, routes
- `terraform/lambda-bedrock-grettings.tf`: greetings Lambda + layer + invoke permission
- `terraform/lambda-bedrock-gifts.tf`: gifts Lambda + layer + DynamoDB env var + permission
- `terraform/dynamodb-bedrock-gifts.tf`: DynamoDB table
- `terraform/variables.tf`: input variables
- `terraform/outputs.tf`: API Gateway URL output
- `terraform/backend/staging.hcl`: remote state backend config
- `terraform/env/staging.tfvars`: environment variables (authorizer config)

Typical Terraform workflow:

```bash
cd terraform
terraform init --backend-config=./backend/staging.hcl
terraform plan -var-file=./env/staging.tfvars -out tf.plan
terraform apply tf.plan
```

## 3) GitHub Actions Introduction

GitHub Actions is GitHub's automation platform for CI/CD workflows.

This repository includes one workflow:

- `.github/workflows/deploy-to-staging.yml`

What it does:

1. Checks out the repository
2. Assumes an AWS deployment role
3. Installs Terraform
4. Runs `terraform init`
5. Runs `terraform plan`
6. Runs `terraform apply`

Trigger:
- On `push`
- On manual `workflow_dispatch`

Required repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## 4) How This Repository Works

At a high level, request flow is:

1. Client sends HTTP request to API Gateway
2. API Gateway routes request to Lambda
3. Lambda executes business logic
4. For `/gifts`, Lambda reads from DynamoDB
5. Lambda response is returned through API Gateway

Current endpoints:

- `GET /greetings`: returns a static list of greeting messages
- `GET /gifts`: JWT-protected route; returns items from DynamoDB table

Code locations:

- `src/bedrock-grettings/index.mjs`: greetings handler
- `src/bedrock-gifts/index.mjs`: gifts handler

## 5) Create a New Repository from This Template

Follow these steps to bootstrap a new project:

1. **Create repo from template**
   - In GitHub, click **Use this template**
   - Choose new repository name and owner

2. **Clone your new repository**
   ```bash
   git clone <your-new-repo-url>
   cd <your-new-repo-name>
   ```

3. **Update naming and defaults**
   - Rename Lambda functions, layers, API name, and table names in Terraform
   - Update paths/keys in backend config and env tfvars files
   - Adjust routes in `terraform/apigateway.tf`

4. **Set AWS credentials for deployment**
   - Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub repo secrets
   - Ensure IAM role trust/policies allow deployment from GitHub Actions

5. **Customize Lambda code**
   - Add or modify handlers in `src/`
   - Ensure handlers return API Gateway proxy responses

6. **Add new infrastructure as needed**
   - Create new Terraform files/modules for additional Lambdas, tables, or services
   - Wire routes to Lambda invoke ARNs in `terraform/apigateway.tf`

7. **Deploy**
   - Push to your default branch to trigger GitHub Actions
   - Or run Terraform locally using the staging backend/tfvars pattern

## 6) Adding a New Endpoint (Quick Pattern)

To add a new endpoint (for example, `GET /orders`):

1. Create `src/orders/index.mjs` with a Lambda handler
2. Add a new Lambda module file in `terraform/` (similar to existing lambda files)
3. Add route integration in `terraform/apigateway.tf`
4. Add any required permissions (DynamoDB, SQS, etc.)
5. `terraform plan` and `terraform apply`

## 7) Prerequisites

- AWS account and IAM permissions for API Gateway, Lambda, DynamoDB, IAM, CloudWatch
- Terraform `~> 1.14.4`
- Node.js (for Lambda dependencies when creating layers)
- GitHub repository with Actions enabled

## Notes

- The workflow file currently targets a staging deployment workflow name.
- Keep environment-specific values in `terraform/env/*.tfvars` and backend settings in `terraform/backend/*.hcl`.
- Use separate backend keys and tfvars files per environment (`dev`, `staging`, `prod`) to isolate state and settings.
