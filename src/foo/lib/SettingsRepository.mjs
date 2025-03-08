import { GetCommand, ScanCommand } from '@aws-sdk/lib-dynamodb'

export default class SettingsRepository {
  #dynamodbDocumentClient

  constructor (dynamodbDocumentClient) {
    this.#dynamodbDocumentClient = dynamodbDocumentClient
  }

  async getClient (clientId) {
    const organizations = await this.getOrganizationsFromDb()
    const organization = organizations.find(
      organization => organization.companies?.find(
        company => company.clientApps?.includes(clientId)
      )
    )
    if (organization) {
      const company = organization.companies?.find(company => company.clientApps?.includes(clientId))
      organization.companies = [company]
    }
    return organization
  }

  async getUser (userId) {
    const user = await this.#getUserFromDb(userId)
    if (user == null) {
      return null
    }
    const organizations = await this.getOrganizationsFromDb()
    user.organization = this.#findOrganizationByUserId(organizations, userId)
    return user
  }

  async getOrganizationsFromDb () {
    const scanCommand = new ScanCommand({
      TableName: 'organization-settings'
    })
    const data = await this.#dynamodbDocumentClient.send(scanCommand)
    return data.Items
  }

  async #getUserFromDb (userId) {
    const getCommand = new GetCommand({
      TableName: 'user-settings',
      Key: {
        userId
      }
    })
    const data = await this.#dynamodbDocumentClient.send(getCommand)
    return data.Item
  }

  #findOrganizationByUserId (organizations, userId) {
    const organization = organizations.find(organization =>
      organization.companies?.find(company => company.users?.includes(userId))
    )

    // Filter out the companies that the user doesn't belong to
    organization.companies = organization.companies.filter(company => company.users?.includes(userId))

    return organization
  }
}
