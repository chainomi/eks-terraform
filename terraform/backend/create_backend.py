import logging
import boto3
from botocore.exceptions import ClientError


def create_bucket(bucket_name, region):
    """Create an S3 bucket in a specified region

    If a region is not specified, the bucket is created in the S3 default
    region (us-east-1).

    :param bucket_name: Bucket to create
    :param region: String region to create bucket in, e.g., 'us-west-2'
    :return: True if bucket created, else False
    """
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
   
    try:
        if bucket.creation_date:
            print(f'The bucket already exists..skipping creating bucket named "{bucket_name}"')
        else:
        # Create bucket
            print(f'Creating bucket named "{bucket_name}"')
            s3_client = boto3.client('s3', region_name=region)
            location = {'LocationConstraint': region}
            s3_client.create_bucket(Bucket=bucket_name,
                                    CreateBucketConfiguration=location)
    except ClientError as e:
        logging.error(e)
        return False
    return True

create_bucket(bucket_name="tester-backend2000", region="us-west-1")



def create_table(table_name, region):
# Query client and list_tables to see if table exists or not
    
    # Instantiate your dynamo client object
    client = boto3.client('dynamodb', region_name=region)

    # Get an array of table names associated with the current account and endpoint.
    response = client.list_tables()

    if table_name in response['TableNames']:
        table_found = True
        print(f'The dynamodb table already exists..skipping creating table named "{table_name}"')
    else:
        table_found = False
        print(f'Creating table named - "{table_name}"')
        # Get the service resource.
        dynamodb = boto3.resource('dynamodb', region_name=region)
        # Create the DynamoDB table called followers
        table = dynamodb.create_table(
            TableName =table_name,
            KeySchema =
            [
                {
                    'AttributeName': 'LockID',
                    'KeyType': 'HASH'
                }
            ],
            AttributeDefinitions =
            [
                {
                    'AttributeName': 'LockID',
                    'AttributeType': 'S'
                }
            ],
            ProvisionedThroughput =
            {
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            }
        )

        # Wait until the table exists.
        table.meta.client.get_waiter('table_exists').wait(TableName=table_name)

    return table_found

create_table(table_name="tester-backend2000", region="us-west-1")    