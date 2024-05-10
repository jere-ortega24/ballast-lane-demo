# Ingress Nginx
Install by running:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm \
  upgrade \
  --install \
  --version 4.10.1 \
  -f values.yml \
  -n demo \
  ingress-nginx \
  ingress-nginx/ingress-nginx
```
