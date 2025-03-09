export default class MethodNotAllowedError extends Error {
  constructor (httpMethod) {
    super()
    this.name = 'MethodNotAllowedError'
    this.httpMethod = httpMethod
  }
}
