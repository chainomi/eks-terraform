#!/bin/sh
set -xe

region=$1

#load backend config values
source ./config/backend.conf $region

#check if s3 bucket exists
if aws s3 ls "s3://$bucket" 2>&1 | grep -q 'NoSuchBucket'
then
  #create s3 bucket
  aws s3 mb s3://$bucket --region $region

  #create dynamodb table for state locking
  aws dynamodb create-table \
  --region $region \
  --table-name $dynamodb_table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

fi