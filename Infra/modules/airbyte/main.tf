terraform {
    required_providers {
      airbyte = {
        source = "airbytehq/airbyte"
        version = "0.6.5"
      }
    }
}

resource "airbyte_source_postgres" "my_source_postgres" {
  configuration = {
    database        = var.postgres_db_name
    host            = var.postgres_host
    #jdbc_url_params = "...my_jdbc_url_params..." it is optional
    password        = var.postgres_db_password
    port            = 5432
    replication_method = {
        detect_changes_with_xmin_system_column = {}
    }
    
    schemas = [
      "public"
    ]
    
    tunnel_method = {
      ssh_key_authentication = {
        ssh_key = var.ssh_key
        tunnel_host = var.tunnel_host
        tunnel_port = 22
        tunnel_user = var.tunnel_user
      }
    }
    
    username = var.postgres_db_username
  }
  #definition_id = "cfdc6fb5-04a1-42b7-b23c-bf0223ae822e" OPTIONAL
  name          = var.db_source_name
  #secret_id     = "...my_secret_id..." OPTIONAL
  workspace_id  = var.workspace_id 
                   
}

resource "airbyte_source_s3" "my_source_s3" {
  configuration = {
    aws_access_key_id     = var.access_key_id
    aws_secret_access_key = var.secret_access_key
    bucket                = var.s3bucket
    streams = [
      {
        name = "medication_data_stream"
        
        days_to_sync_if_history_is_full = 6
        format = {
          csv_format = {
            #double_as_string = true
            delimiter = ","
            double_quote = true
          }
        }
        globs = [
          "raw_data/medications/*.csv",
        ]

        #primary_key = ["medication_id"]
        /*
        schema = jsonencode({
          type = "object",
          properties = {
            medication_id = { type = "string" }
            medication_name = { type = "string" }
            category = {type = "string"}
            cost = {type = "number"}
            created_at = { type = "string", format = "date-time" }
            updated_at = { type = "string", format = "date-time" }
          }
        })
        */
      },
      {
        name = "procedure_data_streams"
        days_to_sync_if_history_is_full = 7
        format = {
          csv_format = {
            delimiter = ","
            double_quote = true
            double_as_string = true
          }
          
        }
        globs = [
          "raw_data/procedures/*.csv",
        ]
        #primary_key = ["procedure_code"]
        /*
        schema = jsonencode({
          type = "object",
          properties = {
            procedure_code = { type = "string" }
            procedure_name = { type = "string" }
            procedure_description = { type = "string" }
            procedure_category = { type = "string" }
            procedure_cost = {type = "number"}
            risk_level = { type = "string" }
            created_at = { type = "string", format = "date-time" }
            updated_at = { type = "string", format = "date-time" }
          }
        })
        */
        #schemaless        = false
      }
    ]
  }
  name          = var.s3_source_name
  workspace_id  = var.workspace_id
}


resource "airbyte_destination_redshift" "my_destination_redshift" {
  configuration = {
    database            = var.redshift_database_name
    disable_type_dedupe = true
    drop_cascade        = false
    host                = var.redshift_host
    #jdbc_url_params     = "...my_jdbc_url_params..." optional
    password            = var.redshift_password
    port                = 5439
    #raw_data_schema     = "...my_raw_data_schema..." optional
    schema              = "public"

    tunnel_method = {
      ssh_key_authentication = {
        ssh_key = var.ssh_key
        tunnel_host = var.tunnel_host
        tunnel_port = 22
        tunnel_user = var.tunnel_user
      }
    }

    uploading_method = {
      awss3_staging = {
        access_key_id      = var.access_key_id
        file_name_pattern  = "data_{date}.csv"
        purge_staging_data = true
        s3_bucket_name     = var.airbyte_s3_bucket_name #"airbyte.staging"
        s3_bucket_path     = "data_sync/test"
        s3_bucket_region   = "eu-west-3"
        secret_access_key  = var.secret_access_key
      }
    }
    
    username = var.redshift_database_username
  }
  name          = var.destination_name
  workspace_id  = var.workspace_id 
}


resource "airbyte_connection" "rds_to_redshift" {
  name                 = var.rds_to_redshift_connection_name # example postgre to redshift
  source_id            = airbyte_source_postgres.my_source_postgres.source_id
  destination_id       = airbyte_destination_redshift.my_destination_redshift.destination_id

  schedule = {
    schedule_type = "manual"
    #cron_expression = "0 0 9 * * ? UTC"
  }

  status               = "active"
  
  /*
  configurations       = {
    streams = [
      {
        name = "stream"

      }
    ]
  }
  */
 # runs every day at 9:00 AM UTC

}

resource "airbyte_connection" "s3_to_redshift" {
  name = var.s3_to_redshift_connection_name
  source_id = airbyte_source_s3.my_source_s3.source_id
  destination_id = airbyte_destination_redshift.my_destination_redshift.destination_id
  prefix                               = "dim_"
  namespace_definition                 = "custom_format"
  namespace_format                     = "public"
  status = "active" #"deprecated"
  configurations = {
    streams = [ 
      {
      name = "medication_data_stream"
      sync_mode = "full_refresh_append"
      primary_key = [[ "medication_id" ]]
      #cursor_field = ["updated_at"]
      selected_fields = [
        {
        field_path = ["medication_id"]
        },
        {
        field_path = ["medication_name"]
        },
        {
        field_path = ["category"]
        },
        {
        field_path = ["cost"]
        },
        {
        field_path = ["created_at"]
        },
        {
        field_path = ["updated_at"]
        }
      ]
    #cursor_field = ["updated_at"]
    },
    {
      name = "procedure_data_streams"
      sync_mode = "full_refresh_append"
      #cursor_field = ["updated_at"]
      primary_key = [[ "procedure_code" ]]
      selected_fields = [
        {
        field_path = ["procedure_code"]
        },
        {
        field_path = ["procedure_name"]
        },
        {
        field_path = ["procedure_description"]
        },
        {
        field_path = ["procedure_category"]
        },
        {
        field_path = ["procedure_cost"]
        },
        {
        field_path = ["risk_level"]
        },
        {
        field_path = ["created_at"]
        },
        {
        field_path = ["updated_at"]
        }
      ]
    }
    ]
  }
  schedule = {
    schedule_type = "manual"
  }
  
}
