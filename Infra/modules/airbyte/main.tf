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
  name          = var.db_source_name
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
            delimiter = ","
            double_quote = true
          }
        }
        globs = [
          "raw_data/medications/*.csv",
        ]
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
    password            = var.redshift_password
    port                = 5439
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
  prefix                               = "dim_"
  namespace_definition                 = "custom_format"
  namespace_format                     = "public"

  schedule = {
    schedule_type = "manual"
  }

  configurations       = {
    streams = [
      {
        name = "dim_appointments"
        sync_mode = "incremental_deduped_history" 
        primary_key = [[ "appointment_id" ]]
        selected_fields = [
        {
        field_path = ["appointment_id"]
        },
        {
        field_path = ["patient_id"]
        },
        {
        field_path = ["doctor_id"]
        },
        {
        field_path = ["appointment_date"]
        },
        {
        field_path = ["appointment_type"]
        },
        {
        field_path = ["diagnosis"]
        },
        {
        field_path = ["created_at"]
        },
        {
        field_path = ["updated_at"]
        }
      ]
      },
      {
        name = "dim_department"
        sync_mode = "incremental_deduped_history" 
        primary_key = [[ "department_id" ]]
        selected_fields = [
        {
        field_path = ["department_id"]
        },
        {
        field_path = ["department_name"]
        },
        {
        field_path = ["department_location"]
        },
        {
        field_path = ["created_at"]
        },
        {
        field_path = ["updated_at"]
        }
      ]
      },
      {
        name = "dim_doctors"
        sync_mode = "incremental_deduped_history" 
        primary_key = [[ "doctor_id" ]]
        selected_fields = [
        {
        field_path = ["doctor_id"]
        },
        {
        field_path = ["first_name"]
        },
        {
        field_path = ["last_name"]
        },
        {
        field_path = ["specialization"]
        },
        {
        field_path = ["department_id"]
        },
        {
        field_path = ["hire_date"]
        },
        {
        field_path = ["created_at"]
        },
        {
        field_path = ["updated_at"]
        }
      ]
      },
      {
        name = "dim_patients"
        sync_mode = "incremental_deduped_history" 
        primary_key = [[ "patient_id" ]]
        selected_fields = [
        {
        field_path = ["patient_id"]
        },
        {
        field_path = ["first_name"]
        },
        {
        field_path = ["last_name"]
        },
        {
        field_path = ["gender"]
        },
        {
        field_path = ["dob"]
        },
        {
        field_path = ["patient_address"]
        },
        {
        field_path = ["city"]
        },
        {
        field_path = ["country"]
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
}

resource "airbyte_connection" "s3_to_redshift" {
  name = var.s3_to_redshift_connection_name
  source_id = airbyte_source_s3.my_source_s3.source_id
  destination_id = airbyte_destination_redshift.my_destination_redshift.destination_id
  prefix                               = "dim_"
  namespace_definition                 = "custom_format"
  namespace_format                     = "public"
  #status = "active" #"deprecated"
  configurations = {
    streams = [ 
      {
      name = "dim_medication" 
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
      name = "dim_procedure"
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
