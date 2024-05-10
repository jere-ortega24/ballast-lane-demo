# PostgreSQL
Install by running:
```bash
helm upgrade \
  --install \
  --version 15.2.9 \
  -n demo \
  -f values.yml \
  postgresql \
  oci://registry-1.docker.io/bitnamicharts/postgresql
```

The passwords need to be created in a separate secret.
