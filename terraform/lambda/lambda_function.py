import json
import urllib.request
import os
from datetime import datetime, timezone, timedelta
import boto3
import base64

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket = os.environ['STATE_BUCKET']
    prefix = 'env/'
    ttl_hours = float(os.environ.get('TTL_HOURS', '6'))
    github_token = os.environ['GITHUB_TOKEN']
    github_repo = os.environ['GITHUB_REPO']  # e.g., "soumeet96/ephemeral-env"
    github_owner = os.environ['GITHUB_OWNER']
    github_branch = os.environ.get('BRANCH_PREFIX', 'feature-update')  # optional fallback

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

        if expired:
            for key in expired:
                branch_name = key.split('/')[1]
                print(f"Triggering destroy for branch: {branch_name}")
                trigger_destroy_workflow(github_owner, github_repo, github_token, branch_name)
        else:
            print("No expired environments to destroy.")

    except Exception as e:
        print(f"Error: {e}")
        raise

def trigger_destroy_workflow(owner, repo, token, branch_name):
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/workflows/remote-destroy.yml/dispatches"
    data = {
        "ref": branch_name,
        "inputs": {
            "branch": branch_name
        }
    }
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json",
        "User-Agent": "LambdaTrigger"
    }

    request = urllib.request.Request(url, data=json.dumps(data).encode(), headers=headers, method="POST")

    try:
        with urllib.request.urlopen(request) as response:
            print(f"Triggered workflow for branch {branch_name}, status: {response.status}")
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"Failed to trigger workflow: {e.code}, {error_body}")
