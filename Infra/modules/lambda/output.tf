output "lambda1_function_name" {
  value = aws_lambda_function.lambda_1.function_name
  description = "lambda function name"
}

output "lambda1_function_arn" {
  value = aws_lambda_function.lambda_1.arn
  description = "arn of the lambda function"
}
/*
output "lambda2_function_name" {
  value = aws_lambda_function.lambda_2.function_name
  description = "lambda function name"
}

output "lambda2_function_arn" {
  value = aws_lambda_function.lambda_2.arn
  description = "arn of the lambda function"
}
*/