import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb'

const tableName = process.env.GIFTS_TABLE_NAME

export const handler = async event => {
    console.log(JSON.stringify(event))

    if (!tableName) {
        throw new Error('GIFTS_TABLE_NAME is not configured')
    }

    const client = DynamoDBDocumentClient.from(new DynamoDBClient({}))
    const response = await client.send(new ScanCommand({ TableName: tableName }))
    const gifts = (response.Items ?? []).map(item => ({
        id: item.id,
        name: item.name
    }))

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(gifts)
    }
}
