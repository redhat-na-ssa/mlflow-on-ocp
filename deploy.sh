#!/bin/bash

oc apply -f manifests/namespaces.yaml
sleep 2
oc apply -f manifests
sleep 2

CONSOLE_URL=$(oc get route console -n openshift-console -o go-template='{{if .spec.tls}}https://{{else}}http://{{end}}{{.spec.host}}{{"\n"}}')
BASE_URL=.apps$(echo $CONSOLE_URL | sed 's/^.*apps//g')
AWSACCESSKEYID=$(oc get secret -n minio aws-connection-my-storage -o json | jq -r .data.AWS_ACCESS_KEY_ID | tr -d '\n' | tr -d '\r\n' | base64 -d)
AWSSECRETACCESSKEY=$(oc get secret -n minio aws-connection-my-storage -o json | jq -r .data.AWS_SECRET_ACCESS_KEY | tr -d '\n' | tr -d '\r\n' | base64 -d)

# TODO: Make this cleaner for folks who may or may not want this repository with this name
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update

helm uninstall -n mlflow mlflow
helm install -n mlflow mlflow -f helm/mlflow_values.yaml \
 --set artifactRoot.s3.awsAccessKeyId="$AWSACCESSKEYID" \
 --set artifactRoot.s3.awsSecretAccessKey="$AWSSECRETACCESSKEY" \
 --set backendStore.postgres.password="mlflowpass" \
 --set extraEnvVars.MLFLOW_S3_ENDPOINT_URL="https://minio-s3-minio$BASE_URL" \
 --set extraEnvVars.MLFLOW_SERVER_ALLOWED_HOSTS="*$BASE_URL,*mlflow.mlflow.svc.cluster.local" \
  community-charts/mlflow

oc adm policy add-scc-to-user anyuid -z mlflow -n mlflow