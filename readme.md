## API Gateway with Lambda template

This is an example repo of API gateway integrating with Lambda, and Lambda is using DynamoDB as backend DB.

### Dir Structure 

There are 2 dirs: `src` and `terraform`. `terraform` is used for managing the infra and deployment resources. `src` is the code, you can manage multiple Lambdas in individual dir, just make sure terraform can find and deploy it to the right place. 

### Deployment role

The pipeline needs a deployment role which is managed in `Infrastructure` repo, please refer to `cloudformation/iam/release-and-deployment-roles/apigw-lambda-dynamodb-template-deployment-role.yaml` and `.github/workflows/deploy-iam-apigw-lambda-dynamodb-template-deployment-role.yml` to create it first.

### Test intergration

For this example, use following command for test.
```
curl -X POST https://v4n3jkew11.execute-api.ap-southeast-2.amazonaws.com/foo -H "content-type: application/json" -d "{ \"year\": \"2000\", \"foo\": \"John\" }"

curl -X POST https://v4n3jkew11.execute-api.ap-southeast-2.amazonaws.com/bar -H "content-type: application/json" -d "{ \"year\": \"2020\", \"bar\": \"Andy\" }"
```
If everything is fine, you can see these data are inserted in the right table.

### Logs

The API gateway and Lambda logs are injected into the cloudwatch log groups, please check the relevant logs for detail.
