#!/bin/bash

# check if slack webhook url is present
if [ -z "$WERCKER_SLACK_NOTIFIER_URL" ]; then
  fail "Please provide a Slack webhook URL"
fi

# if no username is provided use the default - werckerbot
if [ -z "$WERCKER_SLACK_NOTIFIER_USERNAME" ]; then
  if [ "$WERCKER_RESULT" = "failed" ]; then
    export USERNAME="Wercker Failed"
  else
    export USERNAME="Wercker Passed"
  fi
fi

# if no icon-url is provided for the bot use the default wercker icon
if [ -z "$WERCKER_SLACK_NOTIFIER_ICON_URL" ]; then
  if [ "$WERCKER_RESULT" = "failed" ]; then
    export ICON_URL="https://raw.githubusercontent.com/wantedly/step-pretty-slack-notify/master/icons/failed.jpg"
  else
    export ICON_URL="https://raw.githubusercontent.com/wantedly/step-pretty-slack-notify/master/icons/passed.jpg"
  fi
fi

# check if this event is a build or deploy
if [ -n "$DEPLOY" ]; then
  # its a deploy!
  export ACTION="deploy"
  export ACTION_URL=$WERCKER_DEPLOY_URL
else
  # its a build!
  export ACTION="build"
  export ACTION_URL=$WERCKER_BUILD_URL
fi


export MESSAGE="[<$WERCKER_APPLICATION_URL|$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME>] <$ACTION_URL|$ACTION(${WERCKER_GIT_COMMIT:0:8})> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY $WERCKER_RESULT"
export FALLBACK="[$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME] $ACTION(${WERCKER_GIT_COMMIT:0:8}) of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY $WERCKER_RESULT"
export COLOR="good"

if [ "$WERCKER_RESULT" = "failed" ]; then
  export MESSAGE="$MESSAGE at step: $WERCKER_FAILED_STEP_DISPLAY_NAME"
  export FALLBACK="$FALLBACK at step: $WERCKER_FAILED_STEP_DISPLAY_NAME"
  export COLOR="danger"
fi

# construct the json
json="{
    \"username\": \"$USERNAME\",
    \"icon_url\":\"$ICON_URL\",
    \"attachments\":[
      {
        \"fallback\": \"$FALLBACK\",
        \"text\": \"$MESSAGE\",
        \"color\": \"$COLOR\"
      }
    ]
}"


# skip notifications if not interested in passed builds or deploys
if [ "$WERCKER_SLACK_NOTIFIER_NOTIFY_ON" = "failed" ]; then
	if [ "$WERCKER_RESULT" = "passed" ]; then
		return 0
	fi
fi

# post the result to the slack webhook
RESULT=$(curl -d "payload=$json" -s "$WERCKER_SLACK_NOTIFIER_URL" --output "$WERCKER_STEP_TEMP"/result.txt -w "%{http_code}")
cat "$WERCKER_STEP_TEMP/result.txt"

if [ "$RESULT" = "500" ]; then
  if grep -Fqx "No token" "$WERCKER_STEP_TEMP/result.txt"; then
    fail "No token is specified."
  fi

  if grep -Fqx "No hooks" "$WERCKER_STEP_TEMP/result.txt"; then
    fail "No hook can be found for specified subdomain/token"
  fi

  if grep -Fqx "Invalid channel specified" "$WERCKER_STEP_TEMP/result.txt"; then
    fail "Could not find specified channel for subdomain/token."
  fi

  if grep -Fqx "No text specified" "$WERCKER_STEP_TEMP/result.txt"; then
    fail "No text specified."
  fi
fi

if [ "$RESULT" = "404" ]; then
  fail "Subdomain or token not found."
fi
