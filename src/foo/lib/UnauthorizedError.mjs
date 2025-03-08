export default class UnauthorizedError extends Error {
  constructor (httpMethod) {
    super()
    this.name = 'UnauthorizedError'
    this.httpMethod = httpMethod
  }
}
