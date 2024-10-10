### Commands used
```bash

helm install book-management ./book-management -f values-dev.yaml --namespace dev
kubectl get all --namespace dev
helm uninstall book-management --namespace dev
helm upgrade --install book-management ./book-management -f values-dev.yaml --namespace dev
helm list --namespace dev
helm install book-management ./ -f values-dev.yaml --namespace dev
echo "$(minikube ip) nginx-app.local" | sudo tee -a /etc/hosts
minikube addons enable ingress 
```