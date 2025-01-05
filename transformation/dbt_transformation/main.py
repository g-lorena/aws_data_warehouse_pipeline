from dbt.cli.main import dbtRunner, dbtRunnerResult
import os
import subprocess
import re
from botocore.exceptions import NoCredentialsError
import boto3


# Initialize S3 client
s3_client = boto3.client('s3')

# Initialize dbt runner
dbt = dbtRunner()

# create CLI args as a list of strings
#cli_args = ["run", "--profiles-dir", project_dir]

def run_dbt_command(command, args):
    """Run a dbt command with the specified arguments."""
    try:
        cli_args = [command] + args

        # run the command
        res: dbtRunnerResult = dbt.invoke(cli_args)

        # inspect the results
        for r in res.result:
            print(f"{r.node.name}: {r.status}")

        return res
    except Exception as e:
        print(f"Error running dbt {command}: {str(e)}")
        raise

def run_dbt_macro():
    """Run the dbt macro and capture the output."""
    try:
        # Run the dbt command to execute the macro
        
        result = subprocess.run(
            ['dbt', 'run-operation', 'generate_models'],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        
        # Capture the output
        output = result.stdout

        lines = output.splitlines()
        
        # Initialize variables to hold model name and SQL content
        model_name = None
        sql_content = None
        is_collecting_sql = False
       
        for line in lines:
            
            
            if "Error running dbt command:" in line:
                break

            if is_log_line(line):
                continue

            # Check if line contains model name
            if "Generating model content for:" in line:
                # Extract model name from line
                #model_name = line.split(": ")[-1].strip().split('/')[-1].replace('.sql', '')  # Get just the model name
                model_name = line.split(": ")[-1].strip().split('/')[-1].replace('.sql', '').replace(':','').replace('dim', 'stg')
                
                sql_content = None
            # Check if line contains SQL content
            elif "Model content:" in line:
                is_collecting_sql = True
                sql_content = ""  # Reset sql_content when we encounter a new model content section

            
            elif is_collecting_sql:#sql_content is not None:  
                sql_content += line + "\n" 
            
            # If we have both model name and content, write to file

            if model_name and sql_content:
                write_sql_to_file(model_name, sql_content.strip())  # Write trimmed SQL content
                # Reset for next model
                #model_name = None
                #sql_content = ""
    
    except subprocess.CalledProcessError as e:
        print(f"Error running dbt command: {e}")
        print(f"Stdout: {e.stdout}")
        print(f"Stderr: {e.stderr}")

def is_log_line(line):
    """Determine if the line is a log line that should be skipped."""
    # Skip if the line contains typical dbt log patterns or warnings
    log_patterns = [
        "Running with dbt",  # dbt version info
        "Registered adapter",  # Adapter info
        "Configuration paths exist",  # Warnings about unused paths
        "Found",  # General dbt info
        "Generated models:",  # Models generated info
        "REDSHIFT_DATABASE",  # Database info
        "DBT_EXECUTE",  # Execution flags
        "[WARNING]",  # Warnings
        "[",  # Any ANSI escape code start (colored logs)
        "There are 1 unused configuration paths:",
        "- models.dbt_transformation.example"
    ]
    return any(pattern in line for pattern in log_patterns)

def write_sql_to_file(model_name, sql_content):
    try:
        """Write the SQL content to a file."""
        model_file_path = f'models/healthcare/staging/{model_name}.sql'
        
        # Ensure the models directory exists
        os.makedirs(os.path.dirname(model_file_path), exist_ok=True)
        
        cleaned_content = '\n'.join(line for line in sql_content.splitlines() if line.strip())

        with open(model_file_path, 'w') as f:
            f.write(cleaned_content)
        
        #print(f"Wrote SQL content to {model_file_path}")
    except Exception as e:
        # Print an error message if something goes wrong
        print(f"Error writing file for model {model_name}: {str(e)}")

#Write the generated SQL files to an S3 bucket instead of the local filesystem

def upload_sql_to_s3(model_name, sql_content):
    try:
        """Upload the SQL content to an S3 bucket."""
        
        cleaned_content = '\n'.join(line for line in sql_content.splitlines() if line.strip())

        # Upload the file to S3
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=f"{S3_PREFIX}{model_name}.sql",
            Body=cleaned_content.encode('utf-8')
        )
        
        print(f"Uploaded SQL content to s3://{S3_BUCKET}/{S3_PREFIX}{model_name}.sql")
    except NoCredentialsError:
        print("Credentials not available")
    except Exception as e:
        print(f"Error uploading file for model {model_name}: {str(e)}")

run_dbt_macro()
