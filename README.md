# Terraform Module - Lambda Function for Adding S3 Cache Control Headers

Creates lambda s3 role, lambda function source from s3, permission to allow s3 bucket to send event to trigger the function to set cache control headers.

## Usage

Example:

```
locals {
  s3_ids  = [s3-bucket-1.id, s3-bucket-2.id, ...] 
  s3_arns = [s3-bucket-1.arn, s3-bucket-2.arn, ...]
}

module "lambda_cache_control" {
  source                      = "git::https://github.com/IronCore864/tfm-lambda-cache-control.git"
  naming_prefix               = "xxx"
  s3_bucket                   = "xxx"
  s3_notification_bucket_arns = zipmap(local.s3_ids, local.s3_arns)
}
```
