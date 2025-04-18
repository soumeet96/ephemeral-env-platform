import boto3
import os
from datetime import datetime, timezone, timedelta

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket = os.environ['STATE_BUCKET']
    prefix = 'env/'
    ttl_hours = int(os.environ.get('TTL_HOURS', '6'))

    print(f"Checking for expired state files in bucket: {bucket} with TTL: {ttl_hours} hours")

    try:
        response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
        if 'Contents' not in response:
            print("No objects found.")
            return

        now = datetime.now(timezone.utc)
        expired = []

        for obj in response['Contents']:
            key = obj['Key']
            if key.endswith('terraform.tfstate'):
                last_modified = obj['LastModified']
                age = now - last_modified
                if age > timedelta(hours=ttl_hours):
                    print(f"[EXPIRED] {key} last modified at {last_modified}, age: {age}")
                    expired.append(key)
                else:
                    print(f"[ACTIVE] {key} last modified at {last_modified}, age: {age}")
        
        print(f"Expired state files: {expired if expired else 'None'}")
        
    except Exception as e:
        print(f"Error: {e}")
        raise
