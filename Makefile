$(info [Makefile] Loading commons variables from config/dev.config ...)
include config/dev.config

terraform-init:
	terraform -chdir=$(TERRAFORM_DIR) init -backend-config="bucket=${AWS_BUCKET_NAME}" -backend-config="key=${AWS_BUCKET_KEY_NAME}" -backend-config="region=${AWS_REGION}"

terraform-validate:
	terraform -chdir=$(TERRAFORM_DIR) validate -no-color

terraform-plan:
	terraform -chdir=$(TERRAFORM_DIR) plan -no-color

terraform-apply:
	terraform -chdir=$(TERRAFORM_DIR) apply -auto-approve -input=false

terraform-destroy:
#terraform -chdir=$(TERRAFORM_DIR) destroy -auto-approve
	terraform -chdir=$(TERRAFORM_DIR) destroy -target module.lambdaLayer.null_resource.lambda_layer -target module.s3bucket.aws_s3_bucket.etl_bucket 

login-ecr:
	aws ecr get-login-password --region eu-west-3 | docker login --username $(ECR_USER) --password-stdin $(ECR_HOST)

build-docker-image:
	docker build --platform linux/amd64 -t $(DOCKER_IMAGE) transformation/dbt_transformation


push-docker-image:
	docker tag $(DOCKER_IMAGE) $(ECR_IMAGE)
	docker push $(ECR_IMAGE)
