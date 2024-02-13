output "lambda_arn" {
  value = aws_lambda_function.terraform_lambda_func.arn
}

output "teraform_aws_role_output" {
  value = aws_iam_role.lambda_role.name
}

output "teraform_aws_role_arn_output" {
  value = aws_iam_role.lambda_role.arn
}

output "teraform_logging_arn_output" {
  value = aws_iam_policy.iam_policy_for_lambda.arn
}

output "lambda_function_url" {
  value = aws_lambda_function_url.terraform_lambda_function_url.function_url
}