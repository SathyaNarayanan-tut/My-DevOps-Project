# Mirasys DevOps Assignment

This repository demonstrates a **production-ready DevOps setup** for a .NET 9.0 microservice using modern containerization, CI/CD, observability, and GitOps practices.

The project replicates an end-to-end DevOps workflow — from application build and containerization to Kubernetes deployment, GitOps automation, and observability — following security and reliability best practices.

## Key Highlights

- **Application:** .NET 9 Web API (`ServiceExample`)
- **Dependencies:** MongoDB, Redis and NATS messaging
- **Containerization:** Docker (multi-stage build)
- **CI/CD:** GitHub Actions (build → scan → push → sign)
- **GitOps:** ArgoCD for automated Kubernetes delivery
- **Kubernetes:** Self-managed local cluster (Minikube)
- **Storage:** OpenEBS (Local PV for persistence)
- **Monitoring:** Prometheus + Grafana (via kube-prometheus-stack)
- **Security:** Trivy image scanning and Cosign artifact signing
- **Packaging:** Helm chart published to Docker Hub & Artifact Hub

---

## Repository Structure

| Path | Description |
|------|--------------|
| `ServiceExample/` | .NET 9 Web API source code |
| `charts/serviceexample/` | Helm chart for Kubernetes deployment |
| `gitops/serviceexample-app.yaml` | ArgoCD GitOps application manifest |
| `.github/workflows/ci.yml` | CI/CD pipeline definition |
| `security/cosign.pub` | Public key for verifying image and chart signatures |

---

# Objective

Showcase:
- Infrastructure-as-Code deployment with Kubernetes and Helm  
- End-to-end DevOps automation (Build → Deploy → Observe)  
- Secure supply chain through artifact signing and scanning  
- Modular setup easily portable to cloud environments  

---

### Tech Stack

| Category | Tools / Frameworks |
|-----------|--------------------|
| Application | .NET 9 (C#), Swagger |
| CI/CD | GitHub Actions |
| Containerization | Docker |
| Orchestration | Kubernetes (Minikube) |
| GitOps | ArgoCD |
| Observability | Prometheus, Grafana |
| Storage | OpenEBS LocalPV |
| Security | Cosign, Trivy |
| Packaging | Helm, ArtifactHub |

---

### Prerequisites

Ensure you have the following installed locally:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/)
- [Cosign](https://docs.sigstore.dev/)

### Build & CI/CD Pipeline

The project uses **GitHub Actions** for continuous integration and delivery, defined in  
`.github/workflows/ci.yml`.

The pipeline ensures that every code change is automatically built, tested, scanned, and deployed as a signed container image and Helm chart.

---

### CI/CD Workflow Overview

Each commit to the `main` branch triggers a workflow with the following stages:

1. **Checkout & Setup**
   - Checks out the repository
   - Sets up the .NET 9 SDK and Docker environment

2. **Build and Test**
   - Restores dependencies and builds the application
   - Runs unit tests for code validation

3. **Docker Image Build**
   - Builds a production-ready image using a multi-stage Dockerfile
   - Tags it as `sathyafire/serviceexample:latest` (and semantic versions if applicable)

4. **Image Scan (Security)**
   - Scans the Docker image for vulnerabilities using **Trivy**

5. **Push to Docker Hub**
   - Pushes the image to Docker Hub using secure credentials stored as GitHub Secrets:
     - `DOCKERHUB_USERNAME`
     - `DOCKERHUB_TOKEN`

6. **Helm Chart Packaging**
   - Packages the Helm chart from `charts/serviceexample`
   - Publishes it to Docker Hub’s OCI Helm registry

7. **Cosign Signing**
   - Signs both the Docker image and Helm chart using **Sigstore Cosign**
   - Signing key stored securely as `COSIGN_KEY` (encrypted secret)
   - Public key `security/cosign.pub` is used for verification

---

### Secrets Configuration in GitHub

| Secret Name | Description |
|--------------|-------------|
| `DOCKERHUB_USERNAME` | Docker Hub username (`sathyafire`) |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `COSIGN_KEY` | Encrypted private key for signing images and charts |
| `DOCKERHUB_REPO` *(optional)* | Docker Hub repository name |

---

### Local Build and Test (Optional)

If you want to build and test locally instead of CI:

# Build Docker image locally

docker build -t sathyafire/serviceexample:latest -f ServiceExample/Dockerfile .

# Run locally and access Swagger

docker run -p 9080:9080 sathyafire/serviceexample:latest

→ http://localhost:9080/swagger/index.html

# Kubernetes Cluster Setup

A **self-managed Kubernetes cluster** was created locally using **Minikube**, simulating a real multi-service production setup.  
This cluster hosts all application components — MongoDB, Redis, NATS, and the .NET Web API — along with monitoring and GitOps systems.

---

### Cluster Initialization

Start the local cluster with sufficient resources for the application and observability stack:

minikube start --cpus=4 --memory=8192 --driver=docker

kubectl get nodes

kubectl cluster-info

# To fulfill the “Storage solution” requirement, OpenEBS LocalPV was deployed for persistent volumes.
This provides dynamic local storage provisioning for MongoDB and Redis :

helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install openebs openebs/openebs --namespace openebs --create-namespace

# Example : MongoDB & Redis with Persistent Volumes

MongoDB
helm upgrade --install mongodb bitnami/mongodb -n demo \
  --set architecture=standalone \
  --set auth.enabled=false \
  --set persistence.enabled=true \
  --set persistence.storageClass=openebs-hostpath \
  --set persistence.size=2Gi \
  --set fullnameOverride=mongodb

Redis
helm upgrade --install redis bitnami/redis -n demo \
  --set architecture=standalone \
  --set auth.enabled=false \
  --set master.persistence.enabled=true \
  --set master.persistence.storageClass=openebs-hostpath \
  --set master.persistence.size=1Gi \
  --set fullnameOverride=redis

# Create namespaces :

kubectl create namespace demo
kubectl create namespace monitoring
kubectl create namespace argocd

# Helm Chart & Deployment

The application is fully **containerized and deployed using Helm**.  
A custom chart was created under `charts/serviceexample/` to automate the deployment of the .NET API and its configurations.

---

### Helm Chart Structure

charts/serviceexample/
├── Chart.yaml
├── values.yaml
├── values.schema.json
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── NOTES.txt
└── artifacthub-repo.yml


Each component is modular and follows Helm’s best practices for readability and reuse.

---

### Helm Values Overview

Key configuration options are defined in `values.yaml`:

| Parameter | Description | Default |
|------------|-------------|----------|
| `image.repository` | Docker image repo | `sathyafire/serviceexample` |
| `image.tag` | Image tag | `latest` |
| `env.mongo` | MongoDB connection string | `mongodb://mongodb:27017` |
| `env.redis` | Redis connection string | `redis-master:6379` |
| `env.nats` | NATS connection string | `nats://nats:4222` |
| `service.port` | App port | `9080` |
| `resources.*` | CPU & memory limits | See file |

Schema validation is enforced by `values.schema.json`, ensuring only valid input types are accepted during deployment.

---

### Helm Installation Commands

Deploy the application to the Kubernetes cluster:

# Ensure namespace exists
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# Deploy the chart
helm upgrade --install svc charts/serviceexample -n demo \
  --set image.repository=sathyafire/serviceexample \
  --set image.tag=latest \
  --set env.mongo="mongodb://mongodb:27017" \
  --set env.redis="redis-master:6379" \
  --set env.nats="nats://nats:4222"

# Verify deployment: 

kubectl get pods -n demo
kubectl get svc -n demo

# Access the application:

kubectl -n demo port-forward svc/svc-serviceexample 9080:9080

Open → http://localhost:9080/swagger/index.html

# The chart is also published as an OCI Helm package on Docker Hub and linked to ArtifactHub :

helm package ./charts/serviceexample
helm push serviceexample-0.1.1.tgz oci://registry-1.docker.io/sathyafire

# Helm Package Signing 

cosign sign --key cosign.key registry-1.docker.io/sathyafire/serviceexample:0.1.1

Public key available : security/cosign.pub 

# GitOps Deployment with Argo CD

Application deployments are fully automated using **Argo CD**, which continuously watches the GitHub repository and synchronizes the Kubernetes cluster state with it.

This implements a complete **GitOps workflow** — any change committed to the `main` branch automatically updates the running application in the cluster.

---

### Argo CD Installation (on Minikube)

kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd

kubectl get pods -n argocd

kubectl port-forward svc/argocd-server -n argocd 8080:443

Open in browser → https://localhost:8080

Retrive Password : kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

Apply to the cluster: kubectl apply -f gitops/serviceexample-app.yaml

# Automatic Sync & Deployment

- Argo CD detects changes in the GitHub repository automatically.
- Each new Helm chart or Docker image tag triggers re-deployment.
- You can view status in the Argo CD UI (Synced, Healthy states).

# Observability and Monitoring

The application includes a full **observability stack** powered by **Prometheus** and **Grafana**,  
with the .NET service instrumented to expose runtime metrics at `/metrics`.

This satisfies the observability requirement of the assignment.

---

### Install kube-prometheus-stack (Prometheus + Grafana)

kubectl create namespace monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kps prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=ClusterIP

Port-forward Grafana service :
kubectl -n monitoring port-forward svc/kps-grafana 3000:80
Grafana dashboard :
http://localhost:3000

# Application Metrics Integration

The .NET service exposes metrics via prometheus-net.AspNetCore.

# Secure Access (Optional TLS)

Grafana and Prometheus endpoints can be TLS-enabled using a custom Ingress or NGINX ingress controller with self-signed certificates.
minikube addons enable ingress

