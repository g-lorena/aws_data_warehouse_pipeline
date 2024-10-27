resource "aws_glue_crawler" "my_healthcare_crawler" {
    for_each = toset(var.tables)
    name = "${each.key}-crawler"
    database_name         = var.database
    role                  = var.glue_iam_role 
    table_prefix          = "${each.key}_"
    
    s3_target {
        path = "${var.s3_dst_bucket}/${each.key}"
    }
  
}