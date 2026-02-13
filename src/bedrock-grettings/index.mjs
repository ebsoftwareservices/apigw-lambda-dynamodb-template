export const handler = async event => {
    console.log(JSON.stringify(event))
    const messages = [
        'Hello',
        'Bonjour',
        '你好'
    ]
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(messages)
    }
}
