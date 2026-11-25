output "function_name" {
  value = aws_lambda_function.descuento.function_name
}

output "function_arn" {
  value = aws_lambda_function.descuento.arn
}

output "cuenta" {
  value = data.aws_caller_identity.yo.account_id
}
