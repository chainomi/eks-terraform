import logging
import boto3
from botocore.exceptions import ClientError


def delete_bucket(bucket_name, region):
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
        # delete bucket
            print(f'Deleting bucket named "{bucket_name}"')
            s3_client = boto3.client('s3', region_name=region)
            s3_client.delete_bucket(Bucket=bucket_name)
        else:
            print(f'The bucket does not exist..skipping deletion of bucket named "{bucket_name}"')

    except ClientError as e:
        logging.error(e)
        return False
    return True

delete_bucket(bucket_name="tester-backend2000", region="us-west-1")



def delete_table(table_name, region):
# Query client and list_tables to see if table exists or not
    
    # Instantiate your dynamo client object
    client = boto3.client('dynamodb', region_name=region)

    # Get an array of table names associated with the current account and endpoint.
    response = client.list_tables()

    if table_name in response['TableNames']:
        table_found = True
        # Delete the DynamoDB table 
        client.delete_table(TableName=table_name)
        client.get_waiter('table_not_exists').wait(TableName=table_name)    
        print(f'Deleting table named - "{table_name}"')
    else:
        table_found = False
        print(f'The dynamodb table does not exist..skipping deletion of table named "{table_name}"')


delete_table(table_name="tester-backend2000", region="us-west-1")    