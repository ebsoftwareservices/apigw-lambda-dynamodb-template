import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb'
import Route from './lib/Route.mjs'
import PreferencesRepository from './lib/PreferencesRepository.mjs'
import SettingsRepository from './lib/SettingsRepository.mjs'

// https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/dynamodb/
// https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-aws-sdk-lib-dynamodb/
const client = new DynamoDBClient({
  region: 'eu-central-1'
})
const dynamodbDocumentClient = DynamoDBDocumentClient.from(client)
const settingsRepository = new SettingsRepository(dynamodbDocumentClient)
const preferencesRepository = new PreferencesRepository(dynamodbDocumentClient)
const route = new Route(settingsRepository, preferencesRepository)

export const handler = async event => {
  console.log(JSON.stringify(event))
  return route.route(event.path, event.httpMethod, event)
}
