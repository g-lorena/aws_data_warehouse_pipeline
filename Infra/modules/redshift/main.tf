
resource "aws_redshift_cluster" "my_healthcare_redshift" {
  cluster_identifier = "my_healthcare_redshift_cluster"
  database_name      = "my_healthcare_datawarehouse"
  master_username    = "exampleuser"
  master_password    = "Mustbe8characters"
  node_type          = "dc1.large"
  cluster_type       = "single-node"
}

/*
resource "aws_redshift_subnet_group" "subnet_group" {
  subnet_ids = [var.subnet_id]
  name       = "my-redshift-subnet"
}

resource "aws_redshift_parameter_group" "redshift_parameters" {
  name   = "my-redshift-parameter-group"
  family = "redshift-1.0"
}
*/

resource "null_resource" "init_redshift_tables" {
  provisioner "local-exec" {
    command = <<EOT
    psql -h ${aws_redshift_cluster.my_healthcare_redshift.endpoint} \
    -U ${aws_redshift_cluster.my_healthcare_redshift.master_username} \
    -d ${aws_redshift_cluster.my_healthcare_redshift.database_name} \
    -f ./sql/create_tables.sql
    EOT
    environment = {
      PGPASSWORD = aws_redshift_cluster.my_healthcare_redshift.master_password
    }
  }
  depends_on = [aws_redshift_cluster.my_healthcare_redshift]
}