# Gitlab Runner

## Guide

#### Sources

[https://docs.gitlab.com/runner/executors/docker/](https://docs.gitlab.com/runner/executors/docker/)

### Registering the runner

```bash
sudo gitlab-runner register -n \
  --url "https://<instance_url>.com/" \
  --registration-token REGISTRATION_TOKEN \
  --executor docker \
  --description "My Docker Runner" \
  --tag-list "validation" \
  --docker-image "docker:24.0.5" \
  --docker-privileged
```
