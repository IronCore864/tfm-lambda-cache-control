resource "aws_iam_role" "lambda_s3_role" {
  name = "lambda_s3_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execute" {
  role       = aws_iam_role.lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_lambda_function" "set_cache_control" {
  publish       = true
  function_name = "${var.naming_prefix}_origin_cache_control"
  role          = aws_iam_role.lambda_s3_role.arn
  s3_bucket     = var.s3_bucket
  s3_key        = "set_cache_control.zip"
  handler       = "main.handler"
  runtime       = "python3.7"
}

resource "aws_lambda_permission" "allow_bucket" {
  for_each = var.s3_notification_bucket_arns

  statement_id  = "AllowS3Exec${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.set_cache_control.arn
  principal     = "s3.amazonaws.com"
  source_arn    = each.value
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = var.s3_notification_bucket_arns
  bucket   = each.key

  lambda_function {
    lambda_function_arn = aws_lambda_function.set_cache_control.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
