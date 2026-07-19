# GitHub ARC vs. Custom Helm Chart for Self-Hosted Runners

The main difference between GitHub Actions Runner Controller (ARC) and a custom Helm chart for self-hosted GitHub runners is the level of automation, scalability, and operational complexity.

| Feature | GitHub ARC | Custom Helm Chart |
| :--- | :--- | :--- |
| **Purpose** | Official Kubernetes operator for GitHub Actions runners | User-built deployment of runners using Helm |
| **Maintained by** | GitHub | Your organization |
| **Kubernetes Operator** | Yes | No |
| **Autoscaling** | Built-in | You build it yourself |
| **Ephemeral runners** | Native support | Must be implemented manually |
| **Runner lifecycle** | Automatically managed | Manual scripting |
| **Registration/Deregistration**| Automatic | Custom scripts/hooks |
| **Scaling based on jobs** | Yes | Usually HPA or custom automation |
| **Upgrades** | Operator manages CRDs and controllers | Manual Helm upgrade |
| **Complexity** | Medium | Low initially, High long-term |
| **Flexibility** | Good | Unlimited |
| **Enterprise support** | Yes | No |

## Architecture Comparison

### GitHub ARC
```text
GitHub Actions
       │
       │ Job
       ▼
+----------------------+
| Runner Scale Set     |
+----------------------+
         │
         ▼
+----------------------+
| ARC Controller       |
+----------------------+
         │
         ▼
Creates Ephemeral Runner Pod
         │
         ▼
Runs Job
         │
         ▼
Deletes Pod
```

**ARC consists of:**
* Controller
* CRDs
* Runner Scale Set
* Listener
* Autoscaler

*The runner only exists while processing a job.*

### Custom Helm Runner
```text
GitHub Actions
      │
      ▼
Deployment
 replicas=3
      │
      ▼
Runner Pod
Runner Pod
Runner Pod
```

**Normally you deploy:**
* `Deployment` (Replica: 5)
* or `StatefulSet`

*Every pod runs forever waiting for jobs.*

## Scaling

### ARC
**Supports:**
* Scale from 0
* Scale to 1000+
* Queue-based scaling
* Scale sets
* Idle runner timeout
* Ephemeral runners

**Example:**
* Jobs = 0 ➔ Pods = 0
* Jobs = 10 ➔ Pods = 10
* Jobs = 500 ➔ Pods = 500
*(No idle runners)*

### Custom Helm
**Usually:**
`replicaCount: 5`

Always means:
* Runner1
* Runner2
* Runner3
* Runner4
* Runner5

*(Even when there are no jobs.)*

## Runner Registration

### ARC (Automatic)
Create Pod ➔ Register Runner ➔ Execute Job ➔ Remove Runner ➔ Delete Pod
*(No orphan runners)*

### Custom Helm (Manual)
**Normally you need scripts (`entrypoint.sh`):**
Register Runner ➔ Run Runner ➔ Before Exit (Remove Runner)
*If pod crashes: Runner remains offline. Need cleanup.*

## Autoscaling

### ARC
```yaml
minRunners: 0
maxRunners: 100
```
*Automatically reacts to queued jobs.*

### Custom Helm
**Need:**
* HPA
* KEDA
* GitHub API polling
* CronJobs
* Custom controller

*(All custom code)*

## Upgrades

### ARC
`helm upgrade arc` ➔ Controller upgrades ➔ Scale Set upgrades ➔ Runner image upgrades
*(Everything coordinated)*

### Custom Helm
`helm upgrade` ➔ Hope registration script still works
*(Need more testing)*

## Security

### ARC
**Supports:**
* GitHub App authentication
* PAT
* Kubernetes Secrets
* Ephemeral runners
* Short-lived runners
* Workload Identity (cloud-provider dependent)

### Custom Helm
**Need to implement:**
* Secret rotation
* PAT management
* Cleanup
* Token refresh
* Registration token generation

## Maintenance

### ARC
**GitHub maintains:**
* APIs
* CRDs
* Scaling
* Runner lifecycle
* Compatibility

### Custom Helm
**Your team maintains:**
* Helm templates
* Bash scripts
* GitHub API integration
* Scaling logic
* Error handling

## Cost

### ARC
Jobs = 0 ➔ Pods = 0 ➔ Node Autoscaler ➔ Cluster scales to zero.
*Much lower idle cost.*

### Custom Helm
5 runners ➔ Always consuming CPU and RAM.
*Higher idle cost.*

## Flexibility

### Custom Helm
Custom Helm is more flexible.

**Example:**
Runner ➔ Install (Terraform, Azure CLI, AWS CLI, kubectl, Helm, Packer, Ansible, Docker, Node, Python) ➔ Company Certificates ➔ Proxy ➔ Security Agents.

*You control everything in the image and chart.*

### ARC
ARC also supports custom runner images, but the lifecycle and scaling are managed by the controller.

## Operational Complexity

### ARC
* Install ARC
* Configure Runner Scale Sets
* Configure GitHub authentication
* Deploy custom runner image (optional)

*(ARC manages the rest)*

### Custom Helm
**You typically need to build and maintain:**
* Registration token generation
* Runner registration
* Deregistration
* Health checks
* Autoscaling logic
* Pod cleanup
* Retry mechanisms
* GitHub API interactions
* Monitoring and alerting

## Conclusion & Recommendations

### When to choose ARC
ARC is a strong choice when you:
* Run Kubernetes (AKS, EKS, GKE, or on-premises)
* Need automatic scaling based on workflow demand
* Want ephemeral runners for improved security
* Have medium to large CI/CD workloads
* Prefer using GitHub's supported solution

### When to choose a custom Helm chart
A custom Helm deployment can make sense when you:
* Have relatively static workloads
* Need highly specialized runner initialization or sidecars
* Require organization-specific integrations not easily expressed through ARC configuration
* Want complete control over the deployment and are prepared to maintain it

### Recommendation for an enterprise DevSecOps platform
Given your focus on Kubernetes, GitHub Actions, DevSecOps, and scalable CI/CD platforms, a practical approach is:

1. **Use GitHub ARC** for runner lifecycle management and autoscaling.
2. **Build a custom runner image** containing your organization's tools (Terraform, Ansible, Docker CLI, Azure CLI, AWS CLI, kubectl, Helm, Trivy, SonarScanner, etc.).
3. **Use Helm only to package and deploy** your runner image and supporting resources if needed, while letting ARC handle registration, scaling, and cleanup.