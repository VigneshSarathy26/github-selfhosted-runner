# Advanced Features Configuration

## 1. VPA Setup

### 1.1 VPA Architecture

**Installation:**

```bash
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm install vpa fairwinds-stable/vpa --namespace vpa-system
```

**VPA Configuration:**

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: runner-vpa
  namespace: arc-runners
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: github-runner
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
      - containerName: runner
        minAllowed:
          cpu: "500m"
          memory: "1Gi"
        maxAllowed:
          cpu: "8"
          memory: "32Gi"
        controlledResources: ["cpu", "memory"]
        controlledValues: RequestsAndLimits
```

---

## 2. Kube-downscaler Setup

**Installation:**

```bash
helm repo add kube-downscaler https://caas-team.github.io/helm-charts
helm install kube-downscaler kube-downscaler/kube-downscaler \
  --namespace kube-system \
  --set defaultUptime="Mon-Fri 06:00-22:00" \
  --set defaultDowntime="Mon-Fri 22:00-06:00, Sat-Sun 00:00-23:59"
```

**Exclude Critical Runners:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: github-runner-critical
  annotations:
    downscaler/exclude: "true"
```

---

## 3. OPA/Gatekeeper Setup

**Installation:**

```bash
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm install gatekeeper gatekeeper/gatekeeper \
  --namespace gatekeeper-system
```

**Constraint Template & Policy Constraint:**

```yaml
# Constraint Template: Runner Security
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: runnersecurity
spec:
  crd:
    spec:
      names:
        kind: RunnerSecurity
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package runnersecurity

        violation[{"msg": msg}] {
          container := input.review.object.spec.template.spec.containers[_]
          container.securityContext.privileged == true
          msg := sprintf("Container %v cannot be privileged", [container.name])
        }

        violation[{"msg": msg}] {
          container := input.review.object.spec.template.spec.containers[_]
          not container.securityContext.runAsNonRoot == true
          msg := sprintf("Container %v must run as non-root", [container.name])
        }

        violation[{"msg": msg}] {
          container := input.review.object.spec.template.spec.containers[_]
          not container.resources.limits
          msg := sprintf("Container %v must have resource limits", [container.name])
        }
---
# Apply Constraint
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: RunnerSecurity
metadata:
  name: enforce-runner-security
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces:
      - "arc-runners"
    labelSelector:
      matchLabels:
        app: github-runner
```

---

## 4. Kyverno 2.0 Setup

**Installation:**

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno \
  --namespace kyverno-system
```

**Cluster Policies:**

```yaml
# ClusterPolicy: Require Image Signatures
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-signature
  annotations:
    policies.kyverno.io/title: "Require Image Signatures"
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: validate-image-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  app: github-runner
      verifyImages:
        - imageReferences:
            - "*.docker.io/*"
            - "*.ecr.aws.amazon.com/*"
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      YOUR_COSIGN_PUBLIC_KEY
                      -----END PUBLIC KEY-----
      validate:
        message: "Image must be signed by authorized publisher"
        pattern:
          spec:
            containers:
              - image: "*"
---
# ClusterPolicy: Disallow Privilege Escalation
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privilege-escalation
spec:
  validationFailureAction: Enforce
  rules:
    - name: deny-privilege-escalation
      match:
        any:
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  app: github-runner
      validate:
        message: "Privilege escalation is not allowed"
        pattern:
          spec:
            containers:
              - securityContext:
                  allowPrivilegeEscalation: "false"
                  capabilities:
                    drop:
                      - ALL
```