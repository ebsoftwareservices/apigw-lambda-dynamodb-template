import Route from './lib/Route.mjs'

const route = new Route()

export const handler = async event => {
    console.log(JSON.stringify(event))
    return route.route(event.path, event.httpMethod, event)
}
