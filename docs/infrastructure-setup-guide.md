# Infrastructure Setup Guide

## 1. Prerequisites & Foundation

### 1.1 Core Requirements

| Component | Requirement | Notes |
| :--- | :--- | :--- |
| **Kubernetes Cluster** | EKS, AKS, or GKE (v1.28+) | Multi-cloud capable |
| **Helm** | v3.0+ | Package management |
| **GitHub App** | Created with proper permissions | Authentication for runners |
| **Container Registry** | ECR, ACR, or GCR | Custom runner images |
| **Storage** | RWX volumes (optional) | For build caching |
| **Network** | Private subnets with NAT Gateway | Security best practice |
| **AWS/Azure/GCP Account** | With proper IAM permissions | Node provisioning |

### 1.2 GitHub App Configuration

#### Step 1: Create GitHub App

```bash
1. Navigate to GitHub Organization Settings
2. Select Developer Settings > GitHub Apps
3. Click "New GitHub App"
4. Configure:
   - Name: custom-runner-platform
   - Homepage URL: https://internal.runner.platform
   - Webhook: Disable (not needed)
```

#### Step 2: Required Permissions

| Permission | Level | Purpose |
| :--- | :--- | :--- |
| **Repository > Actions** | Read-only | Check workflow status |
| **Repository > Administration** | Read & Write | Manage runner registration |
| **Repository > Metadata** | Read-only | Repository details |
| **Organization > Actions** | Read-only | Organization workflow info |
| **Organization > Self-hosted Runners** | Read & write | Register/unregister runners |

#### Step 3: Install App

```bash
1. Click "Install App" in GitHub App settings
2. Select "All repositories" or specific repos
3. Confirm installation
4. Copy Installation ID from URL:
   https://github.com/organizations/{org}/settings/installations/{INSTALLATION_ID}
```

#### Step 4: Generate and Store Secrets

```bash
# Generate private key
openssl pkcs12 -in cert.p12 -nocerts -out github.pem -nodes

# Create Kubernetes secret
kubectl create secret generic controller-manager \
  -n arc-systems \
  --from-literal=github_app_id=123456 \
  --from-literal=github_app_installation_id=654321 \
  --from-file=github_app_private_key=github.pem

# For KEDA authentication (if using PAT)
kubectl create secret generic github-token \
  -n arc-runners \
  --from-literal=token=ghp_XXXXXXXXXXXXXXXXXXXX
```

## 2. Cluster Architecture

### 2.1 Complete Node Pool Design

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                           EKS/AKS/GKE Cluster                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────┐     ┌──────────────────────────────────────┐  │
│  │    System Node Pool     │     │    Runner Node Pool (Karpenter)      │  │
│  │                         │     │                                      │  │
│  │  - ARC Controller       │     │  - Dynamic EC2/VM provisioning      │  │
│  │  - KEDA                 │     │  - Spot/On-Demand hybrid            │  │
│  │  - VPA                  │     │  - Runner pods with tolerations     │  │
│  │  - OPA/Gatekeeper       │     │  - Auto-remediation                  │  │
│  │  - Kyverno 2.0          │     │  - Consolidation policies           │  │
│  │  - cert-manager         │     │  - Instance diversity               │  │
│  │  - CoreDNS/Add-ons      │     │  - Multi-AZ distribution            │  │
│  └─────────────────────────┘     └──────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Critical Node Setup

```yaml
# System Node Pool configuration
nodeSelector:
  role: system
taints:
  - key: CriticalAddonsOnly
    value: "true"
    effect: NoSchedule

# Runner Node Pool configuration (via Karpenter)
taints:
  - key: workload
    value: github-runner
    effect: NoSchedule

tolerations:
  - key: workload
    operator: Equal
    value: github-runner
    effect: NoSchedule
```

## 3. Karpenter Integration

### 3.1 Why Karpenter?

#### Karpenter vs Cluster Autoscaler:

| Feature | Cluster Autoscaler | Karpenter |
| :--- | :--- | :--- |
| **Provisioning Speed** | Minutes | Seconds |
| **Instance Selection** | Fixed nodepools | Dynamic selection |
| **Spot Management** | Limited | Advanced |
| **Consolidation** | ❌ | ✅ |
| **Instance Diversity** | Manual | Automatic |
| **Cost Optimization** | Basic | Advanced |

### 3.2 Complete Karpenter Configuration

```yaml
# EC2NodeClass for AWS
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: runner-node-class
spec:
  amiFamily: AL2
  role: "arn:aws:iam::123456789012:role/karpenter-node-role"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "runner-cluster"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "runner-cluster"
  tags:
    Name: github-runner-node
    Environment: production
    CostCenter: platform

---
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: github-runners
spec:
  weight: 50
  template:
    metadata:
      labels:
        workload: github-runner
        node-type: runner
    spec:
      taints:
        - key: workload
          value: github-runner
          effect: NoSchedule
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: runner-node-class
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["c5", "c6i", "m5", "m6i", "r5"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
        - key: karpenter.k8s.aws/instance-cpu
          operator: In
          values: ["4", "8", "16", "32"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: topology.kubernetes.io/zone
          operator: In
          values: ["us-east-1a", "us-east-1b", "us-east-1c"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64", "arm64"]
  limits:
    cpu: 1000
    memory: 1000Gi
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 600s
    budgets:
      - nodes: "30%"
      - nodes: "5"
```

## 4. KEDA Configuration

### 4.1 Why KEDA?

#### KEDA vs HPA:

| Feature | HPA | KEDA |
| :--- | :--- | :--- |
| **Scaling Source** | CPU/Memory | Custom metrics |
| **GitHub Queue** | ❌ | ✅ |
| **Event-Driven** | ❌ | ✅ |
| **Zero Scaling** | ❌ | ✅ |
| **Custom Scalers** | ❌ | ✅ |

### 4.2 Complete KEDA Setup

```yaml
# TriggerAuthentication
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: github-auth
  namespace: arc-runners
spec:
  secretTargetRef:
    - parameter: personalAccessToken
      name: github-token
      key: token

---
# ScaledObject for Organization Runners
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: github-org-runner-scaler
  namespace: arc-runners
spec:
  scaleTargetRef:
    kind: Deployment
    name: github-runner-controller
  minReplicaCount: 2
  maxReplicaCount: 50
  pollingInterval: 30
  cooldownPeriod: 120
  idleReplicaCount: 1
  triggers:
    - type: github-runner
      metadata:
        owner: "your-org"
        runnerScope: "org"
        targetWorkflowQueueLength: "1"
        enableEtags: "true"
        labels: "production,large"
      authenticationRef:
        name: github-auth

---
# ScaledObject for Repository Runners
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: github-repo-runner-scaler
  namespace: arc-runners
spec:
  scaleTargetRef:
    kind: Deployment
    name: github-runner-controller
  minReplicaCount: 0
  maxReplicaCount: 10
  triggers:
    - type: github-runner
      metadata:
        owner: "your-org"
        runnerScope: "repo"
        repos: "frontend,backend,api"
        targetWorkflowQueueLength: "1"
```

## 5. Networking & Security

### 5.1 Network Architecture

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                                Internet                                 │
└─────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                               GitHub API                                │
└─────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                               NAT Gateway                               │
│                                                                         │
│   (GitHub API communication, container registry pulls)                  │
└─────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      Private Subnet (Runner Nodes)                      │
│                                                                         │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐   │
│   │   Runner Pods   │    │   Runner Pods   │    │   Runner Pods   │   │
│   └─────────────────┘    └─────────────────┘    └─────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Security Groups (AWS)

```yaml
# EKS Security Group
SecurityGroupRules:
  - Protocol: TCP
    Port: 443
    Source: "0.0.0.0/0"  # GitHub API
    Description: "GitHub API access"

  - Protocol: TCP
    Port: 80
    Source: "0.0.0.0/0"  # Container registry
    Description: "Container registry access"

  - Protocol: TCP
    Port: 22
    Source: "10.0.0.0/8"  # Internal SSH (if needed)
    Description: "Internal SSH access"

  # Node Communication
  - Protocol: TCP
    Port: 10250-10255
    Source: "10.0.0.0/8"
    Description: "Kubelet API access"

  # Runner Communication
  - Protocol: TCP
    Port: 3000-32767
    Source: "10.0.0.0/8"
    Description: "Runner service communication"
```

## 6. Storage Setup for Build Caching

```yaml
# Persistent Volume for Build Cache
apiVersion: v1
kind: PersistentVolume
metadata:
  name: runner-cache-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.internal
    path: /exports/runner-cache
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: runner-cache-pvc
  namespace: arc-runners
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi

# Runner Deployment with Cache Mount
---
spec:
  containers:
    - name: runner
      volumeMounts:
        - name: cache
          mountPath: /cache
  volumes:
    - name: cache
      persistentVolumeClaim:
        claimName: runner-cache-pvc
```