output "codepipeline_configs" {
    value = {
        codepipeline = aws_codepipeline.codepipeline.arn
    }
}
output "deployment_role_arn" {
    value = aws_iam_role.lambda_codebuild_role.arn
}

output "s3_configs" {
    value = {
        s3_repo_name = aws_s3_bucket.codepipeline_bucket.id
        s3_repo_arn = aws_s3_bucket.codepipeline_bucket.arn
    }
}