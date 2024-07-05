import json
import boto3


# resource name
dynamodb = boto3.resource('dynamodb')

# get table
counter_table = dynamodb.Table('resume-counter-table')

def lambda_handler(event, context):
    response = counter_table.get_item(Key={
        'id': 'counter_id'
    })
    views=response["Item"]["views"]
    views = views + 1
    print(views)
    response = counter_table.put_item(Item={
        'id':'counter_id',
        'views': views
    })
    return views