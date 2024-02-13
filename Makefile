MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include ${MAKEFILE_DIR}.env
include .env.secret

TERRAFORM := docker run --rm \
	-e AWS_REGION="${AWS_REGION}" \
	-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
	-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
	-v .:/terraform \
	${IMAGE_NAME}

# Dockerイメージ作成
build:
	docker build \
		--build-arg ORIGINAL_IMAGE_NAME=${ORIGINAL_IMAGE_NAME} \
		-t ${IMAGE_NAME} \
		-f Dockerfile .

# Terraformバージョン確認
version:
	${TERRAFORM} version

# コンテナ内でシェルを使います
sh:
	docker run -it --rm --entrypoint sh -v .:/terraform ${IMAGE_NAME}

init:
	docker run --rm \
		--entrypoint terraform \
		${IMAGE_NAME} \
		init

plan:
	docker run --rm \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-e AWS_REGION="${AWS_REGION}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		plan ${TARGET}

apply:
	docker run -it --rm \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-e AWS_REGION="${AWS_REGION}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		apply ${TARGET}

#
# S3やECRにデータが存在すると削除できません
#
destroy:
	docker run -it --rm \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-e AWS_REGION="${AWS_REGION}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		destroy ${TARGET}

output:
	docker run --rm \
		-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
		-e AWS_REGION="${AWS_REGION}" \
		-v ${PWD}:${MOUNT_DEST} \
		-w ${MOUNT_DEST}/${ENTRY_PATH} \
		--entrypoint terraform \
		${IMAGE_NAME} \
		output