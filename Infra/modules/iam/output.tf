output "access_key_id" {
  value       = aws_iam_access_key.airbyte_access_key.id
  description = "The AWS Access Key ID for the Airbyte user"
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.airbyte_access_key.secret
  description = "The AWS Secret Access Key for the Airbyte user"
  sensitive   = true
}

output "aws_iam_role_name" {
  value       = aws_iam_role.iam_for_ec2.name
  description = "The Name of the IAM role for the EC2 instance"
}

output "instance_profile_id" {
  value       = aws_iam_instance_profile.ec2_instance_profile.id
  description = "The ID of the IAM instance profile for the EC2 instance"
  
}