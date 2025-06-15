import json
import boto3
import os
import uuid

# S3クライアントを初期化
s3_client = boto3.client('s3')

# Lambdaの環境変数からバケット名を取得
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME', 'default-bucket-name-if-not-set')

def lambda_handler(event, context):
    try:
        # API Gatewayからのリクエストボディはevent['body']に文字列として入っている
        body = json.loads(event.get('body', '{}'))

        file_name = body.get('fileName')
        content_type = body.get('contentType')

        if not file_name:
            raise ValueError("fileNameがリクエストに含まれていません。")

        # S3に保存する際のオブジェクトキーを生成 (ここでは元のファイル名をそのまま使用)
        object_key = file_name 

        # 署名付きURLを生成 (PUTリクエスト用 = アップロード用)
        presigned_url = s3_client.generate_presigned_url(
            ClientMethod='put_object',
            Params={
                'Bucket': S3_BUCKET_NAME,
                'Key': object_key,
                'ContentType': content_type
            },
            ExpiresIn=300  # URLの有効期限（秒単位、ここでは5分）
        )

        # フロントエンドに返すレスポンス
        response_body = {
            'uploadUrl': presigned_url,
            'key': object_key
        }
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
            },
            'body': json.dumps(response_body)
        }

    except Exception as e:
        print(f"エラー発生: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
            },
            'body': json.dumps({'error': str(e)})
        }