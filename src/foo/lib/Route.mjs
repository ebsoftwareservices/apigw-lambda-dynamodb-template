import MethodNotAllowedError from './MethodNotAllowedError.mjs'
import UnauthorizedError from './UnauthorizedError.mjs'

export default class Route {
  constructor () {

  }

  async route (path, httpMethod, event) {
    try {
      if (path === '/path') {
        return await this.operate(httpMethod, event)
      } else {
        return {
          statusCode: 404
        }
      }
    } catch (e) {
      if (e instanceof MethodNotAllowedError) {
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

  async operate (httpMethod, event) {
    let data = null
    if (httpMethod === 'GET') {
      data = { what: 'GET' }
    } else if (httpMethod === 'POST') {
      data = { what: 'POST' }
    } else {
      throw new MethodNotAllowedError(httpMethod)
    }
    return this.#buildResponse(data)
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
