import json
import os
import urllib.request

def lambda_handler(event, context):
    try:
        repo = event['queryStringParameters']['repo']
        branch = event['queryStringParameters']['branch']
    except (KeyError, TypeError):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing repo or branch parameters'})
        }

    github_token = os.environ['GITHUB_TOKEN']
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
    }

    body = json.dumps({
        'ref': branch,
        'inputs': {
            'branch': branch
        }
    }).encode('utf-8')

    repo_api_url = f'https://api.github.com/repos/soumeet96/ephemeral-env-platform/actions/workflows/deploy.yml/dispatches'

    req = urllib.request.Request(repo_api_url, data=body, headers=headers, method='POST')

    try:
        with urllib.request.urlopen(req) as res:
            return {
                'statusCode': res.getcode(),
                'body': json.dumps({'message': 'Workflow triggered successfully'})
            }
    except urllib.error.HTTPError as e:
        return {
            'statusCode': e.code,
            'body': json.dumps({'error': f'GitHub API Error: {e.read().decode()}'})
        }
