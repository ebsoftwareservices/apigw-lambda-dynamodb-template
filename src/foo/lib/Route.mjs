import UnsupportedHttpMethod from './UnsupportedHttpMethodError.mjs'
import UnauthorizedError from './UnauthorizedError.mjs'

const PATTERN_COMPANY_PREFERENCES = /^\/companies\/[^/]+\/preferences\/ebdx$/

export default class Route {
  #settingsRepository
  #preferencesRepository

  constructor (settingsRepository, preferencesRepository) {
    this.#settingsRepository = settingsRepository
    this.#preferencesRepository = preferencesRepository
  }

  async route (path, httpMethod, event) {
    try {
      let data = null
      if (path === '/clients/me') {
        data = await this.#settingsRepository.getClient(event.requestContext.authorizer.claims.client_id)
      } else if (path.startsWith('/clients/')) {
        data = await this.#settingsRepository.getClient(event.pathParameters.id)
      } else if (path === '/users/me') {
        data = await this.#settingsRepository.getUser(event.requestContext.authorizer.claims.sub)
      } else if (path === '/users/me/preferences/ebdx') {
        data = await this.#operateUserPreferences(httpMethod, event.requestContext.authorizer.claims.sub, event)
      } else if (PATTERN_COMPANY_PREFERENCES.test(path)) {
        data = await this.#operateCompanyPreferences(httpMethod, event.pathParameters.companyId, event.requestContext.authorizer.claims, event)
      }
      return this.#buildResponse(data)
    } catch (e) {
      if (e instanceof UnsupportedHttpMethod) {
        return {
          statusCode: 405
        }
      } else if (e instanceof UnauthorizedError) {
        return {
          statusCode: 403
        }
      }
      throw e
    }
  }

  async #operateUserPreferences (httpMethod, authSub, event) {
    if (httpMethod === 'GET') {
      return await this.#preferencesRepository.getUserPreferences(authSub)
    } else if (httpMethod === 'PUT') {
      const bodyObject = JSON.parse(event.body)
      return await this.#preferencesRepository.updateUserPreferences(authSub, bodyObject)
    } else {
      throw new UnsupportedHttpMethod(httpMethod)
    }
  }

  async #operateCompanyPreferences (httpMethod, companyId, authClaims, event) {
    if (await this.#isSubjectFromCompany(companyId, authClaims.sub, authClaims.client_id)) {
      if (httpMethod === 'GET') {
        return await this.#preferencesRepository.getCompanyPreferences(companyId)
      } else if (httpMethod === 'PUT') {
        const bodyObject = JSON.parse(event.body)
        return await this.#preferencesRepository.updateCompanyPreferences(companyId, bodyObject)
      } else {
        throw new UnsupportedHttpMethod(httpMethod)
      }
    } else {
      throw new UnauthorizedError()
    }
  }

  async #isSubjectFromCompany (companyId, sub, clientId) {
    const organizations = await this.#settingsRepository.getOrganizationsFromDb()
    if (sub === clientId) {
      return this.#isClientFromCompany(organizations, companyId, sub)
    }
    return this.#isUserFromCompany(organizations, companyId, sub)
  }

  #isClientFromCompany (organizations, companyId, sub) {
    for (const org of organizations) {
      for (const company of org.companies) {
        if (company.companyId === companyId && company.clientApps.includes(sub)) {
          return true
        }
      }
    }
    return false
  }

  #isUserFromCompany (organizations, companyId, sub) {
    for (const organization of organizations) {
      const company = organization.companies?.find(company => company.companyId === companyId)

      if (company && company.users && company.users.includes(sub)) {
        return true
      }
    }
    return false
  }

  #buildResponse (data) {
    if (data) {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      }
    } else {
      return {
        statusCode: 404
      }
    }
  }
}
