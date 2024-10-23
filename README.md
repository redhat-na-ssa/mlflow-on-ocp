# MLflow on OCP

The objective of this project is to create an easy path to deploy MLflow on OpenShift.

## Prerequisites

This project assumes that you do not currently have MinIO installed.

Installed operators:
* Crunchy Operator (see `operators/crunchy_subscription.yaml`)
* RHOAI

## Instructions

If you need Crunchy installed, run the following:

```oc apply -f operators/crunchy_subscription.yaml```

Either way, to deploy all of the resources just run (you may need to change execute permissions)

```./deploy.sh```