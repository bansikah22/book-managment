## Deploy dev environment
```bash
minikube start
minikube addons enable ingress
kubectl create namespace book-management-dev
helm install book-management ./ --namespace book-management-dev -f values-dev.yaml
kubectl get all --namespace book-management-dev
#debugging 
helm uninstall book-management --namespace book-management-dev
minikube addons enable metrics-server
chmod +x create_helm_chart.sh

```

## Deploymemt using script
```bash
kubectl create namespace book-management
bash create_helm_chart.sh dev dev

```
