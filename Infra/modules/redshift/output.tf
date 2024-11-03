output "redshift_role_arn"  {
  value = aws_iam_role.iam_for_redshift.arn
}

output "redshift_hostname" {
  value = split(":", aws_redshift_cluster.my_healthcare_redshift.endpoint)[0]
}

output "redshift_cluster" {
  value = aws_redshift_cluster.my_healthcare_redshift
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.my_healthcare_redshift.endpoint
}