# Mirasys DevOps Assignment – ServiceExample

## Overview

This repository contains the Mirasys DevOps Assignment solution a complete, production-grade .NET 9 Web API deployed using Docker, Kubernetes, Helm, and Argo CD, with full CI/CD, observability, and security automation. 
The project demonstrates how to design, containerize, deploy, and operate a modern microservice-based application with GitOps, Prometheus metrics, persistent storage, and secure supply chain signing.

## Key Features

- Fully containerized .NET Web API

- MongoDB + Redis + NATS integration

- Helm chart for declarative deployment

- GitOps pipeline using Argo CD

- CI/CD via GitHub Actions

- Monitoring stack with Prometheus + Grafana

- Persistent storage with OpenEBS Local PV

- Secure artifacts signed using Sigstore Cosign

# Implemented Components

## CI/CD

Automated pipeline with build, test, image push, and Helm publish.

Images are pushed to Docker Hub (sathyafire/serviceexample).

Helm chart is published to ArtifactHub as OCI registry.

## Kubernetes + GitOps

Deployed on Minikube for local testing.

GitOps via Argo CD monitors GitHub and syncs Helm releases automatically.

## Monitoring

Prometheus scrapes /metrics exposed by the app.

Grafana dashboards visualize .NET performance and HTTP metrics.

## Storage

OpenEBS Local PV provides persistent volumes for MongoDB and Redis.

## Security

Docker and Helm artifacts digitally signed with Cosign.

Secrets stored securely in GitHub Actions secrets.

Containers run as non-root, with CPU/memory limits.

## Related Resources

ArtifactHub Chart: https://artifacthub.io/packages/helm/sathya/serviceexample

Docker Image: https://hub.docker.com/r/sathyafire/serviceexample

# Author

Sathya Narayanan 

sathya.austin@gmail.com
GitHub: SathyaNarayanan-tut

