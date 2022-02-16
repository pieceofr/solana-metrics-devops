#!/usr/bin/env bash

influxdb_name="slack testing"
slack_webhook="https://hooks.slack.com/services/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"
slack_alert(){
	sdata=$(jq --null-input --arg val "$slacktext" '{"text":$val}')
    echo *****$sdata-----
	curl -X POST -H 'Content-type: application/json' --data "$sdata" $slack_webhook
}

slacktext="$influxdb_name is restarting!"
slack_alert