export default class UnsupportedHttpMethod extends Error {
  constructor (httpMethod) {
    super()
    this.name = 'UnsupportedHttpMethod'
    this.httpMethod = httpMethod
  }
}
