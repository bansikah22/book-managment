# Install in development
helm install book-management ./book-management -f values-dev.yaml

# Install in production
helm install book-management ./book-management -f values-prod.yaml
