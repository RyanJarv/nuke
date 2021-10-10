#!/usr/bin/env bash
set -euo pipefail

trace() {
  1>&2 echo "[ERR] Command on line $1 exited with $2"
}
trap 'trace $LINENO $?' ERR

ROLE_NAME='ECSTaskFullAccountAdmin'

account_id="$(aws sts get-caller-identity --query 'Account' --out text)"

create_role() {
    aws --out text iam create-role \
      --role-name "$ROLE_NAME" \
      --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com",
        "AWS": "arn:aws:iam::'"${account_id}"':root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
' > /dev/null
    
    aws iam attach-role-policy \
      --role-name "$ROLE_NAME" \
      --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess" > /dev/null
}


aws --out text iam get-role --role-name "$ROLE_NAME" > /dev/null || { ret=$?
  if [[ "$ret" == 254 ]]; then
    create_role
  else
    exit $ret
  fi
}

echo "[INFO] $ROLE_NAME is setup with full administrator access"

