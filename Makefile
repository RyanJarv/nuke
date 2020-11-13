export TASK_ROLE ?= "ECSTaskFullAccountAdmin"
export AWS_NUKE_NO_DRYRUN ?= "false"

nuke/setup:
	@./aws-nuke/create-admin-role.sh
	cd aws-nuke; docker build -t aws-nuke .

nuke/test: nuke/setup
	docker run -e AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID -e AWS_SESSION_TOKEN -it aws-nuke --config /config.yml --force --force-sleep 3

nuke/job/setup: nuke/setup
	copilot init --app awsutils --name aws-nuke --schedule '@daily' --type "Scheduled Job" --dockerfile ./aws-nuke/Dockerfile --deploy

nuke/task/run: nuke/setup
	copilot task run --default --follow --dockerfile ./aws-nuke/Dockerfile --task-role "${TASK_ROLE}" --command "--config /config.yml --no-dry-run --force --force-sleep 3 --quiet"

