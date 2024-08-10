# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3
import os
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb_client = boto3.client('dynamodb')

def lambda_handler(event, context):
  table = os.environ.get('DDB_TABLE')
  logging.info(f"## Loaded table name from environemt variable DDB_TABLE: {table}")
  if event["body"]:
      item = json.loads(event["body"])
      logging.info(f"## Received payload: {item}")
      year = str(item["year"])
      bar = str(item["bar"])
      dynamodb_client.put_item(TableName=table,Item={"year": {'N':year}, "bar": {'S':bar}})
      message = "Successfully inserted data!"
      return {
          "statusCode": 200,
          "headers": {
              "Content-Type": "application/json"
          },
          "body": json.dumps({"message": message})
      }
  else:
      logging.info("## Received request without a payload")
      response = dynamodb_client.query(TableName=table,KeyConditions={"year": {"AttributeValueList":[{'N':'2022'}],'ComparisonOperator': 'EQ'}})
      return {
          "statusCode": 200,
          "headers": {
              "Content-Type": "application/json"
          },
          "body": json.dumps(response)
      }
