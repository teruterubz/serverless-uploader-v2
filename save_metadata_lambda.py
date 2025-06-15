import json
import boto3
import os
import uuid
import urllib.parse
from datetime import datetime

# DynamoDBリソースを初期化
dynamodb = boto3.resource('dynamodb')
# Lambdaの環境変数からDynamoDBテーブル名を取得
DYNAMODB_TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME', 'default-dynamodb-table-name')
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

def lambda_handler(event, context):
    try:
        for record in event.get('Records', []):
            bucket_name = record.get('s3', {}).get('bucket', {}).get('name')
            object_key_encoded = record.get('s3', {}).get('object', {}).get('key')
            
            if not object_key_encoded:
                print("警告: オブジェクトキーがイベントに含まれていません。")
                continue

            object_key = urllib.parse.unquote_plus(object_key_encoded)
            file_size = record.get('s3', {}).get('object', {}).get('size')
            event_time_str = record.get('eventTime')
            
            file_id = str(uuid.uuid4())
            original_filename = os.path.basename(object_key)
            upload_timestamp = datetime.utcnow().isoformat() + "Z"

            item_to_save = {
                'fileId': file_id,
                's3BucketName': bucket_name,
                's3ObjectKey': object_key,
                'originalFilename': original_filename,
                'fileSize': file_size,
                'uploadTimestamp': upload_timestamp,
                's3EventTime': event_time_str
            }

            print(f"DynamoDBに保存するアイテム: {json.dumps(item_to_save, ensure_ascii=False)}")
            table.put_item(Item=item_to_save)
            print(f"メタデータをDynamoDBに保存しました: fileId={file_id}")

        return { 'statusCode': 200, 'body': json.dumps('S3 event processed.') }

    except Exception as e:
        print(f"エラー発生: {e}")
        raise e