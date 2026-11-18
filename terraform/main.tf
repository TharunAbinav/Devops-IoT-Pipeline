terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}

resource "aws_iot_thing" "demo_device" {
  name = var.thing_name
}

resource "aws_iot_certificate" "device_cert" {
  active = true
}

resource "aws_iot_policy" "demo_policy" {
  name = var.policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "policy_attach" {
  policy = aws_iot_policy.demo_policy.name
  target = aws_iot_certificate.device_cert.arn
}

resource "aws_iot_thing_principal_attachment" "thing_attach" {
  principal = aws_iot_certificate.device_cert.arn
  thing     = aws_iot_thing.demo_device.name
}

data "http" "root_ca" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}

resource "local_file" "root_ca_file" {
  content  = data.http.root_ca.response_body
  filename = "${path.module}/../certs/AmazonRootCA1.pem"
}

resource "local_file" "cert_file" {
  content  = aws_iot_certificate.device_cert.certificate_pem
  filename = "${path.module}/../certs/certificate.pem.crt"
}

resource "local_sensitive_file" "private_key_file" {
  content  = aws_iot_certificate.device_cert.private_key
  filename = "${path.module}/../certs/private.pem.key"
}
