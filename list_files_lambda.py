import json
import boto3
import os
from decimal import Decimal

# DynamoDBリソースを初期化
dynamodb = boto3.resource('dynamodb')
# Lambdaの環境変数からDynamoDBテーブル名を取得
DYNAMODB_TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME', 'default-dynamodb-table-name')
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

# JSONに変換する際にDecimal型を通常の数値に変換するためのヘルパークラス
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            if obj % 1 == 0:
                return int(obj)
            else:
                return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        response = table.scan()
        items = response.get('Items', [])
        
        print(f"{len(items)} 件のアイテムを取得しました。")

        # フロントエンドに返すレスポンス
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps(items, cls=DecimalEncoder, ensure_ascii=False)
        }

    except Exception as e:
        print(f"エラー発生: {e}")
        return {
            'statusCode': 500,
            'headers': { 'Access-Control-Allow-Origin': '*' },
            'body': json.dumps({'error': str(e)})
        }