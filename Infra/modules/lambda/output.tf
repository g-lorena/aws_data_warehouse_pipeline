output "lambda_function_name" {
  value = aws_lambda_function.lambda_1.function_name
  description = "lambda function name"
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_1.arn
  description = "arn of the lambda function"
}