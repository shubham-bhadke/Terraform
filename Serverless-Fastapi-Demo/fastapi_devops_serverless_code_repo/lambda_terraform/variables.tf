variable "env_namespace" {
  type        = string
  description = "Value is coming from tfvars file that is being updated by buildspec environment variables"
}

variable "lambda_file_name" {
  type        = string
  default = "lambda_function.zip"
  description = "Value is coming from tfvars file that is being updated by buildspec environment variables"
}

variable "lambda_artifacts_bucket_name" {
  type        = string
  description = "Value is coming from tfvars file that is being updated by buildspec environment variables"
}
