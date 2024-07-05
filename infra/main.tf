# DynamoDb Creation
resource "aws_dynamodb_table" "resume-counter-table" {
  name = "resume-counter-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "resume_counter"
  }
}

resource "aws_dynamodb_table_item" "resume-counter-item" {
  table_name = aws_dynamodb_table.resume-counter-table.name
  hash_key = "id"

  item = <<ITEM
  {
    "id": {"S": "counter_id"},
    "views": {"N": "0"}
  }
  ITEM
}

# Lambda Function Creation
resource "aws_iam_role" "lambda_role" {
  name = "aws_resume_lambda_role"
  assume_role_policy = <<EOF
  {
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# get the current region name
data "aws_region" "current" {}

# get account_id
data "aws_caller_identity" "current" {}

# create iam policy
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name = "iam_policy_for_lambda_role"
  path = "/"
  description = "Iam policy for lambda function"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect" : "Allow",
        "Action": [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        "Resource": "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PotLogEvents"
        ],
        "Resource": "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Effect": "Allow",
        "Action": "logs:CreateGroup",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Archive the python file
data "archive_file" "zip_the_python_code" {
  type = "zip"
  source_dir = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/dynamo-counter.zip"
}

# lambda function creation
resource "aws_lambda_function" "cloud_resume_lambda_function" {
  filename = "${path.module}/lambda/dynamo-counter.zip"
  function_name = "cloud_resume_lambda_function"
  role = aws_iam_role.lambda_role.arn
  handler = "dynamo-counter.lambda_handler"
  runtime = "python3.8"
  depends_on = [ aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role ]
}

# create the lambda function url
resource "aws_lambda_function_url" "lambda_function_url" {
  function_name = aws_lambda_function.cloud_resume_lambda_function.function_name
  authorization_type = "NONE"

  cors{
    allow_credentials = true
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["date", "keep-alive"]
    expose_headers = ["keep-alive", "date"]
    max_age = 86400
  }
}