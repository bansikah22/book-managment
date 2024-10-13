#!/bin/bash

# Variables for environments and namespace
ENV=${1:-dev}  # Default to 'dev' if no argument is provided
NAMESPACE=${2:-default}  # Default to 'default' if no namespace is provided

# Create namespaces for dev and prod
kubectl create namespace dev || true
kubectl create namespace prod || true

# Create the directory structure
mkdir -p book-management/templates

# Create Chart.yaml
cat <<EOL > book-management/Chart.yaml
apiVersion: v2
name: book-management
description: A Helm chart for managing book management applications
version: 1.0.0
appVersion: "1.0"
EOL

# Create values-dev.yaml
cat <<EOL > book-management/values-dev.yaml
replicaCount: 1

image:
  backend:
    repository: bansikah/book-backend
    tag: "1.2.0"
    pullPolicy: IfNotPresent
  frontend:
    repository: bansikah/book-frontend
    tag: "1.2.0"
    pullPolicy: IfNotPresent

backend:
  port: 8082
  logMonitor:
    image: alpine:latest  # Sidecar image for log monitoring

frontend:
  port: 80

db:
  username: devuser  # Development username
  password: devpassword  # Development password

postgres:
  database: devdb  # Your database name

service:
  type: ClusterIP
  port: 80

hpa:
  enabled: false

ingress:
  enabled: true
  host: book-management.local

environment: dev  # Environment variable for the ConfigMap
EOL

# Create values-prod.yaml
cat <<EOL > book-management/values-prod.yaml
replicaCount: 3

image:
  backend:
    repository: bansikah/book-backend
    tag: "1.2.0"
    pullPolicy: IfNotPresent
  frontend:
    repository: bansikah/book-frontend
    tag: "1.2.0"
    pullPolicy: IfNotPresent

backend:
  port: 8082
  logMonitor:
    image: alpine:latest  # Sidecar image for log monitoring

frontend:
  port: 80

db:
  username: produser  # Production username
  password: prodpassword  # Production password

postgres:
  database: prod_db  # Your database name

service:
  type: LoadBalancer
  port: 80

hpa:
  enabled: true
  minReplicas: 2
  maxReplicas: 20
  cpu: 80  # Target CPU utilization percentage

ingress:
  enabled: true
  host: book-management.local

environment: prod  # Environment variable for the ConfigMap
EOL

# Create templates/_helpers.tpl
cat <<EOL > book-management/templates/_helpers.tpl
{{/*
Common helper templates
*/}}

{{- define "book-management.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "book-management.service.name" -}}
{{- printf "%s-service" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "book-management.backend.name" -}}
{{- printf "%s-backend" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "book-management.frontend.name" -}}
{{- printf "%s-frontend" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
EOL

# Create templates/secret.yaml
cat <<EOL > book-management/templates/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-secret
type: Opaque
data:
  SPRING_DATASOURCE_USERNAME: {{ .Values.db.username | b64enc }}
  SPRING_DATASOURCE_PASSWORD: {{ .Values.db.password | b64enc }}
EOL

# Create templates/configmap.yaml
cat <<EOL > book-management/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  SPRING_PROFILES_ACTIVE: {{ .Values.environment }}
  SPRING_DATASOURCE_URL: jdbc:postgresql://{{ .Release.Name }}-postgres:5432/{{ .Values.postgres.database }}
  SPRING_JPA_HIBERNATE_DDL_AUTO: update
  SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT: org.hibernate.dialect.PostgreSQLDialect
  SPRING_JPA_SHOW_SQL: "true"
EOL

# Create templates/postgresql-deployment.yaml
cat <<EOL > book-management/templates/postgresql-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  labels:
    app: postgresql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
        - name: postgresql
          image: postgres:latest
          env:
            - name: POSTGRES_DB
              value: {{ .Values.postgres.database }}  # Your database name
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: {{ .Release.Name }}-secret
                  key: SPRING_DATASOURCE_USERNAME
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Release.Name }}-secret
                  key: SPRING_DATASOURCE_PASSWORD
          ports:
            - containerPort: 5432
EOL

# Create templates/postgresql-service.yaml
cat <<EOL > book-management/templates/postgresql-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgresql
spec:
  type: ClusterIP
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    app: postgresql
EOL

# Create templates/deployment-backend.yaml
cat <<EOL > book-management/templates/deployment-backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: {{ .Values.image.backend.repository }}:{{ .Values.image.backend.tag }}
          ports:
            - containerPort: {{ .Values.backend.port }}
          env:
            - name: SPRING_DATASOURCE_URL
              value: jdbc:postgresql://postgresql:5432/{{ .Values.postgres.database }}
            - name: SPRING_DATASOURCE_USERNAME
              valueFrom:
                secretKeyRef:
                  name: {{ .Release.Name }}-secret
                  key: SPRING_DATASOURCE_USERNAME
            - name: SPRING_DATASOURCE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Release.Name }}-secret
                  key: SPRING_DATASOURCE_PASSWORD
            - name: SPRING_PROFILES_ACTIVE
              valueFrom:
                configMapKeyRef:
                  name: {{ .Release.Name }}-config
                  key: SPRING_PROFILES_ACTIVE
        - name: log-monitor
          image: {{ .Values.backend.logMonitor.image }}
          command: ['sh', '-c', 'while true; do echo "logging" >> /opt/logs.txt; sleep 1; done']
          volumeMounts:
            - name: data
              mountPath: /opt
      volumes:
        - name: data
          emptyDir: {}
EOL

# Create templates/service-backend.yaml
cat <<EOL > book-management/templates/service-backend.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: ClusterIP
  ports:
    - port: {{ .Values.backend.port }}
      targetPort: {{ .Values.backend.port }}
  selector:
    app: backend
EOL

# Create templates/deployment-frontend.yaml
cat <<EOL > book-management/templates/deployment-frontend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: {{ .Values.image.frontend.repository }}:{{ .Values.image.frontend.tag }}
          ports:
            - containerPort: {{ .Values.frontend.port }}
EOL

# Create templates/service-frontend.yaml
cat <<EOL > book-management/templates/service-frontend.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: ClusterIP
  ports:
    - port: {{ .Values.frontend.port }}
      targetPort: {{ .Values.frontend.port }}
  selector:
    app: frontend
EOL

# Create templates/ingress.yaml
cat <<EOL > book-management/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress
spec:
  rules:
  - host: {{ .Values.ingress.host }}
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: {{ .Release.Name }}-backend
            port:
              number: {{ .Values.backend.port }}
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ .Release.Name }}-frontend
            port:
              number: {{ .Values.frontend.port }}
EOL

echo "Helm chart structure created for book-management application."

# Deploy the application with the specified environment and namespace
helm upgrade --install book-management book-management --namespace $NAMESPACE -f book-management/values-$ENV.yaml
