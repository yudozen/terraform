MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include ${MAKEFILE_DIR}.env
# include .env.secret

TERRAFORM := docker run --rm -it \
	-e AWS_REGION="${AWS_DEFAULT_REGION}" \
	-e AWS_ACCESS_KEY_ID="${TERRAFORM_AWS_ACCESS_KEY_ID}" \
	-e AWS_SECRET_ACCESS_KEY="${TERRAFORM_AWS_SECRET_ACCESS_KEY}" \
	-v .:${MOUNT_DEST} \
	${IMAGE_NAME}

# Dockerイメージ作成
terraform_build:
	docker build \
		--build-arg ORIGINAL_IMAGE_NAME=${ORIGINAL_IMAGE_NAME} \
		--build-arg MOUNT_DEST=${MOUNT_DEST} \
		-t ${IMAGE_NAME} \
		-f ${MAKEFILE_DIR}Dockerfile ${MAKEFILE_DIR}

# Terraformバージョン確認
terraform_version:
	${TERRAFORM} -version

# コンテナ内でシェルを使います
terraform_sh:
	docker run -it --rm --entrypoint sh -v .:/terraform ${IMAGE_NAME}

terraform_init:
	docker run --rm \
		-e AWS_REGION="${AWS_DEFAULT_REGION}" \
		-v .:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		init

terraform_plan:
	docker run -it --rm \
		-e AWS_REGION="${AWS_DEFAULT_REGION}" \
		-e AWS_ACCESS_KEY_ID="${TERRAFORM_AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${TERRAFORM_AWS_SECRET_ACCESS_KEY}" \
		-e TF_VAR_account_id="${TF_VAR_account_id}" \
		-e TF_LOG=DEBUG \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		plan ${TARGET}

terraform_apply:
	docker run -it --rm \
		-e AWS_REGION="${AWS_DEFAULT_REGION}" \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		apply ${TARGET}

#
# S3やECRにデータが存在すると削除できません
#
terraform_destroy:
	docker run -it --rm \
		-e AWS_REGION="${AWS_DEFAULT_REGION}" \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		destroy ${TARGET}

terraform_output:
	docker run --rm \
		-e AWS_REGION="${AWS_DEFAULT_REGION}" \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		output