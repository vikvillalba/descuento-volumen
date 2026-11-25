terraform {
  required_version = ">= 1.11"

  # Estado remoto compartido, con bloqueo nativo de S3.
  # Cambien <ACCOUNT_ID> y la región por las de su cuenta.
  backend "s3" {
    bucket       = "tfstate-descuento-<ACCOUNT_ID>"
    key          = "descuento/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# La región la toma de AWS_REGION (CloudShell o configure-aws-credentials).
provider "aws" {
  default_tags {
    tags = local.tags
  }
}

locals {
  # Un nombre por workspace: descuento-default, descuento-qa, ...
  nombre = "${var.prefijo}-${terraform.workspace}"
  tags   = {
    curso    = "devops-2026"
    ambiente = terraform.workspace
  }
}

data "aws_caller_identity" "yo" {}

resource "aws_iam_role" "lambda" {
  name = "${local.nombre}-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "descuento" {
  function_name    = local.nombre
  role             = aws_iam_role.lambda.arn
  runtime          = "java21"
  handler          = "mx.itson.devops.descuento.Handler::handleRequest"
  filename         = var.jar
  source_code_hash = filebase64sha256(var.jar)
  memory_size      = var.memoria
  timeout          = var.timeout

  depends_on = [aws_iam_role_policy_attachment.logs]
}
