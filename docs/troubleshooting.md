# Troubleshooting ARC Container Pulls from Azure Container Registry (ACR)

When configuring GitHub Actions Runner Controller (ARC) to automate workflows, the pod running your job requires its own pull access to your Azure Container Registry (ACR) for images like `build-node20`. This is a completely separate pull operation from whatever pulled the initial `runner-generic` image, and one succeeding does not guarantee the other will.

## 1. Spotting the Bug in the Workflow

Before debugging authentication, verify the image path. If your workflow specifies a GitHub Container Registry (GHCR) path but you actually pushed to ACR, the pull will fail regardless of your auth setup.

**Incorrect:**
```yaml
container:
  image: ghcr.io/yourorg/build-node20:latest
```

**Correct:**
```yaml
container:
  image: yourregistry.azurecr.io/build-node20:v1
```

## 2. Why Separate Access is Needed: Two Pull Mechanisms

How ARC actually executes a `container: job` depends entirely on which hook mode you are running:

### Mode A: Kubernetes Hooks (Default/Recommended)
When a job specifies `container:`, ARC's runner doesn't do a plain Docker pull. It asks the Kubernetes API to schedule the job container, and `kubelet` pulls the image—exactly the same way it pulled `runner-generic`.
* **Action:** In this mode, if your AKS cluster is already attached to ACR (`az aks update --attach-acr`), you're covered automatically. Kubelet's node identity has pull rights to the whole registry, so `build-node20` pulls seamlessly. No extra configuration is needed.

### Mode B: Docker/DinD Hooks
If your setup runs job containers via the Docker daemon inside the pod (e.g., using a DinD sidecar or mounted socket), the pull is done by that in-pod Docker daemon. This daemon operates in a separate identity/credential context from `kubelet`. ACR-attach at the AKS/node level **does not** automatically give this in-pod Docker daemon credentials.
* **Action:** You must explicitly authenticate the runner pod's Docker daemon.
```yaml
# In your runner pod's entrypoint/startup, or as a workflow step before container use:
- run: |
    az acr login --name yourregistry --identity
```
*(Alternatively, bake a credential helper into `runner-base` / `runner-docker-dind` so docker pulls against ACR work without a manual login step each time.)*

## 3. How to Identify Your Hook Mode

Run the following command to check your configuration:
```bash
kubectl get configmap -n arc-systems -o yaml | grep -i hook
```
Or check your Helm values for `containerMode.type`—it will say either `kubernetes` or `dind`.

## 4. Practical Recommendation Matrix

| Your Setup | What to Do |
| :--- | :--- |
| **`containerMode.type: kubernetes` (Default)** | Just attach ACR to AKS once. This covers `runner-generic`, `build-node20`, and everything else with no extra steps. |
| **`containerMode.type: dind`** | Attach ACR to AKS **and** ensure the in-pod Docker daemon logs into ACR (via managed identity or `az acr login`), since kubelet-level access doesn't reach it. |

**Simplest Universal Fix (for Kubernetes-hook mode):**
```bash
az aks update --name <cluster-name> --resource-group <rg> --attach-acr <acr-name>
```

---

## Frequently Asked Questions (FAQs)

**Q: Why does my workflow fail to pull the `build-node20` image if it successfully pulled `runner-generic`?**  
**A:** Pulling `runner-generic` and pulling a job container (like `build-node20`) are two separate operations. Depending on your ARC configuration, they might be executed by completely different entities (e.g., `kubelet` vs. an in-pod Docker daemon). Each mechanism needs explicit access to the registry.

**Q: I attached ACR to my AKS cluster using `az aks update`, but the pull still fails. What's wrong?**  
**A:** First, check your workflow file's image path to ensure it points to your ACR (`yourregistry.azurecr.io`) and not GHCR (`ghcr.io`). If the path is correct, you might be using Docker/DinD hooks (`containerMode.type: dind`), which require an explicit `az acr login` step inside the runner pod because the in-pod Docker daemon cannot use the node's kubelet credentials.

**Q: How do I know if I'm using Kubernetes hooks or DinD hooks for ARC?**  
**A:** You can verify this by running `kubectl get configmap -n arc-systems -o yaml | grep -i hook` in your cluster. You can also inspect your Helm chart values for `containerMode.type`.

**Q: What is the recommended ARC mode for running GitHub Actions at scale on AKS?**  
**A:** Kubernetes hooks (`containerMode.type: kubernetes`) are the default and strongly recommended approach for the `gha-runner-scale-set`. It dramatically simplifies authentication because once you attach ACR to AKS, `kubelet` natively handles all container image pulls without requiring in-workflow authentication steps.