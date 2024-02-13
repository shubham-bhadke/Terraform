data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/"
  output_path = "${path.module}/${var.lambda_file_name}"
}

data "aws_s3_object" "lambda_artifacts_bucket" {
  bucket = "${var.lambda_artifacts_bucket_name}"
  key    = "${var.lambda_file_name}"
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.env_namespace}_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
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

# IAM policy for logging from a lambda

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sts:AssumeRole",
        "codebuild:*",
        "lambda:*",
        "iam:AddRoleToInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteRolePolicy",
        "iam:DeleteRole",
        "iam:CreatePolicy",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListPolicies",
        "iam:ListRolePolicies",
        "iam:ListRoles",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:UpdateAssumeRolePolicy",
        "iam:GetRolePolicy",
        "iam:ListInstanceProfilesForRole",
        "iam:GetPolicy"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}


# Create a lambda function
# In terraform ${path.module} is the current directory.
resource "aws_lambda_function" "terraform_lambda_func" {
  #filename                       = "${path.module}/lambda_function.zip"
  function_name     = "fastapi-Lambda-Function"
  role              = aws_iam_role.lambda_role.arn
  handler           = "main.handler"
  runtime           = "python3.8"
  s3_bucket         = data.aws_s3_object.lambda_artifacts_bucket.bucket
  s3_key            = data.aws_s3_object.lambda_artifacts_bucket.key
  s3_object_version = data.aws_s3_object.lambda_artifacts_bucket.version_id
  source_code_hash  = base64sha256(file("../main.py"))
  depends_on        = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_lambda_function_url" "terraform_lambda_function_url" {
  function_name      = aws_lambda_function.terraform_lambda_func.function_name
  authorization_type = "NONE"
  depends_on = [ aws_lambda_function.terraform_lambda_func ]
}