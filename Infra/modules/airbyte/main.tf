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
        read_changes_using_write_ahead_log_cdc = {
            publication = "airbyte_publication"
            replication_slot="airbyte_slot"
        }
      #detect_changes_with_xmin_system_column = {}
    }
    /* OPTIONAL 
    schemas = [
      "...",
    ]
    ssl_mode = {
      allow = {
        additional_properties = "{ \"see\": \"documentation\" }"
      }
    }
    */
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
  name          = var.source_name
  #secret_id     = "...my_secret_id..." OPTIONAL
  workspace_id  = var.workspace_id 
                   
}
/*
resource "airbyte_source_s3" "my_source_s3" {
  configuration = {
    aws_access_key_id     = "...my_aws_access_key_id..."
    aws_secret_access_key = "...my_aws_secret_access_key..."
    bucket                = "...my_bucket..."
    endpoint              = "https://my-s3-endpoint.com"
    region_name           = "...my_region_name..."
    role_arn              = "...my_role_arn..."
    start_date            = "2021-01-01T00:00:00.000000Z"
    streams = [
      {
        days_to_sync_if_history_is_full = 6
        format = {
          avro_format = {
            double_as_string = true
          }
        }
        globs = [
          "...",
        ]
        input_schema                                = "...my_input_schema..."
        name                                        = "Christie Emard"
        recent_n_files_to_read_for_schema_discovery = 3
        schemaless                                  = true
        validation_policy                           = "Emit Record"
      },
    ]
  }
  definition_id = "819ff393-429d-4316-9dd8-595e9c61e20d"
  name          = "Pedro West"
  #secret_id     = "...my_secret_id..."
  workspace_id  = var.workspace_id
}
*/
/*
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
      no_tunnel = {}
    }
    
    username = var.redshift_database_username
  }
  #definition_id = "295e6e54-dc30-4616-986b-73990fea69be"
  name          = var.destination_name
  workspace_id  = var.workspace_id 
}


resource "airbyte_connection" "my_connection" {
  name                 = var.airbyte_connection_name # example postgre to redshift
  source_id            = airbyte_source_postgres.my_source_postgres.source_id
  destination_id       = airbyte_destination_redshift.my_destination_redshift.destination_id

  schedule = {
    schedule_type = "manual"
    #cron_expression = "0 0 9 * * ? UTC"
  }

  status               = "active"
  
  configurations       = {
    streams = [
      {
        name = "stream"

      }
    ]
  }
 # runs every day at 9:00 AM UTC

}
*/