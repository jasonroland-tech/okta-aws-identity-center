# Optional stretch: manage the permission sets and assignments as code.
# Run after Part 3, once Okta has pushed the AWS-ReadOnly and AWS-S3-Analysts groups.
# Auth: aws configure sso (or any profile with Identity Center admin rights).

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_ssoadmin_instances" "this" {}
data "aws_caller_identity" "current" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

# Groups come from Okta through SCIM, so Terraform only looks them up.
data "aws_identitystore_group" "readonly" {
  identity_store_id = local.identity_store_id
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "AWS-ReadOnly"
    }
  }
}

data "aws_identitystore_group" "s3_analysts" {
  identity_store_id = local.identity_store_id
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "AWS-S3-Analysts"
    }
  }
}

resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnly"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_ssoadmin_permission_set" "s3_analyst" {
  name             = "S3-Analyst"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "s3_analyst" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.s3_analyst.arn
  inline_policy      = file("${path.module}/../docs/s3-analyst-policy.json")
}

resource "aws_ssoadmin_account_assignment" "readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_group.readonly.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = data.aws_caller_identity.current.account_id
}

resource "aws_ssoadmin_account_assignment" "s3_analyst" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.s3_analyst.arn
  principal_type     = "GROUP"
  principal_id       = data.aws_identitystore_group.s3_analysts.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = data.aws_caller_identity.current.account_id
}
