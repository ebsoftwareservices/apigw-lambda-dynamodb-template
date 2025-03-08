## API Gateway with Lambda template

This is an example repo of API gateway integrating with Lambda, and Lambda is using DynamoDB as backend DB.

### Dir Structure 

There are 2 dirs: `src` and `terraform`. `terraform` is used for managing the infra and deployment resources. `src` is the code, you can manage multiple Lambdas in individual dir, just make sure terraform can find and deploy it to the right place. 

### Deployment role

The pipeline needs a deployment role which is managed in `Infrastructure-ebsoftwareservices` repo, please refer to `cloudformation/iam/release-and-deployment-roles/foo-deployment-role.yaml` and `.github/workflows/deploy-iam-foo-deployment-role.yml` to create it first.

### Test intergration

For this example, use following command for test.
```
curl -X POST https://API_GATEWAY_URL/foo -H "content-type: application/json" -d "{ \"year\": \"2000\", \"foo\": \"John\" }"
```
If everything is fine, you can see these data are inserted in the right table.

### Logs

The API gateway and Lambda logs are injected into the cloudwatch log groups, please check the relevant logs for detail.
