# GitLab Agent
Install by running:
```bash
helm repo add gitlab https://charts.gitlab.io

helm upgrade \
  --install \
  --version 2.0.0 \
  -n demo \
  -f values.yml \
  gitlab-agent \
  gitlab/gitlab-agent
```

The token should be created in a separate secret.
