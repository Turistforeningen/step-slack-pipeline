# step-slack [![Build status](https://img.shields.io/wercker/ci/5541cd77771355eb4000583f.svg "Build status")](https://app.wercker.com/project/bykey/be0b458e85f974c293cf97dea2354a7c)

A slack notifier written in `bash` and `curl`. Make sure you create a Slack
webhook first (see the Slack integrations page to set one up).

# Options

- `url` Slack webhook url
- `username` (optional) Message username override
- `icon_url` (optional) Message icon override
- `notify_on` (optional) If set to `failed`, it will only notify on failed builds or deploys.

# Example

```yaml
build:
    after-steps:
        - turistforeningen/slack-pipeline-notifier:
            url: $SLACK_WEBHOOK_URL
```

The `url` parameter is the [slack
webhook](https://api.slack.com/incoming-webhooks) that wercker should post to.
You can create an *incoming webhook* on your slack integration page.  This url
is then exposed as an environment variable (in this case `$SLACK_WEBHOOK_URL`)
that you create through the wercker web interface as *deploy pipeline variable*.

# License

The MIT License (MIT)

# Changelog

## 2.0.0

- Fail/Pass username
- Fail/Pass icon

## 1.0.0

- Initial release
