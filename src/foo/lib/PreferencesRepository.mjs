import { GetCommand, PutCommand } from '@aws-sdk/lib-dynamodb'

const TABLE_USER_PREFERENCES = 'user-preferences'
const TABLE_COMPANY_PREFERENCES = 'company-preferences'

export default class PreferencesRepository {
  #dynamodbDocumentClient

  constructor (dynamodbDocumentClient) {
    this.#dynamodbDocumentClient = dynamodbDocumentClient
  }

  async getUserPreferences (userId) {
    const getCommand = new GetCommand({
      TableName: TABLE_USER_PREFERENCES,
      Key: {
        userId
      }
    })
    const data = await this.#dynamodbDocumentClient.send(getCommand)
    if (data.Item) {
      return data.Item
    } else {
      return this.#buildDefaultUserPreferences(userId)
    }
  }

  async updateUserPreferences (userId, userPreferencesData) {
    const putCommand = new PutCommand({
      TableName: TABLE_USER_PREFERENCES,
      Item: {
        userId,
        preferences: userPreferencesData.preferences
      }
    })
    await this.#dynamodbDocumentClient.send(putCommand)
    return {
      userId,
      preferences: userPreferencesData.preferences
    }
  }

  #buildDefaultUserPreferences (userId) {
    return {
      userId,
      preferences: {
        general: {
          language: 'fr'
        }
      }
    }
  }

  async getCompanyPreferences (companyId) {
    const getCommand = new GetCommand({
      TableName: TABLE_COMPANY_PREFERENCES,
      Key: {
        companyId
      }
    })
    const data = await this.#dynamodbDocumentClient.send(getCommand)
    if (data.Item) {
      return data.Item
    } else {
      return this.#buildDefaultCompanyPreferences(companyId)
    }
  }

  async updateCompanyPreferences (companyId, companyPreferencesData) {
    const putCommand = new PutCommand({
      TableName: TABLE_COMPANY_PREFERENCES,
      Item: {
        companyId,
        preferences: companyPreferencesData.preferences
      }
    })
    await this.#dynamodbDocumentClient.send(putCommand)
    return {
      companyId,
      preferences: companyPreferencesData.preferences
    }
  }

  #buildDefaultCompanyPreferences (companyId) {
    return {
      companyId,
      preferences: {
        workflows: {
          reception: {
            mode: 'manual'
          },
          sending: {
            mode: 'auto'
          }
        }
      }
    }
  }
}
