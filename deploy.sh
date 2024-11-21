oc apply -f manifests

PASSWORD=$(oc get secret -n mlflow mlflow-postgres-pguser-mlflowuser -o json | jq -r .data.password | tr -d '\n' | tr -d '\r\n' | base64 -d)
AWSACCESSKEYID=$(oc get secret -n minio aws-connection-my-storage -o json | jq -r .data.AWS_ACCESS_KEY_ID | tr -d '\n' | tr -d '\r\n' | base64 -d)
AWSSECRETACCESSKEY=$(oc get secret -n minio aws-connection-my-storage -o json | jq -r .data.AWS_SECRET_ACCESS_KEY | tr -d '\n' | tr -d '\r\n' | base64 -d)

# TODO: Make this cleaner for folks who may or may not want this repository with this name
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update

helm uninstall -n mlflow mlflow
helm install -n mlflow mlflow -f helm/mlflow_values.yaml \
 --set artifactRoot.s3.awsAccessKeyId=$AWSACCESSKEYID \
 --set artifactRoot.s3.awsSecretAccessKey=$AWSSECRETACCESSKEY \
 --set backendStore.postgres.password=$PASSWORD \
  community-charts/mlflow
