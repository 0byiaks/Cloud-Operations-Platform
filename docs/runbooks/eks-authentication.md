# EKS Authentication & Access Control

## Overview

There are four separate authentication and permission layers in the COP EKS setup.
Each layer is independent — having access at one layer does not grant access at another.

---

## Layer 1 — EKS Cluster talking to AWS

**What it controls:** The EKS cluster and worker nodes communicating with AWS services.

**Why it exists:** EKS needs AWS permissions to manage infrastructure on your behalf —
creating network interfaces, pulling ECR images, sending logs to CloudWatch etc.

**What we created:**
- `dev-cop-eks-cluster-role` — attached to the EKS cluster itself
  - Policy: `AmazonEKSClusterPolicy`
- `dev-cop-eks-node-role` — attached to the EC2 worker nodes
  - Policies: `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`

**Where it lives:** `terraform/modules/eks/main.tf`

---

## Layer 2 — You and GitHub Actions talking TO the cluster

**What it controls:** Who can run `kubectl` commands and Terraform Kubernetes resources
against the cluster.

**Why it exists:** EKS has its own access control system separate from AWS IAM.
Valid AWS credentials alone are not enough — identities must be explicitly
added to the cluster's access list.

**What we created:**
- `aws_eks_access_entry.terraform_user` — allows `cop-terraform-user` (local machine)
- `aws_eks_access_entry.github_actions` — allows the GitHub Actions IAM role (pipeline)
- Both are associated with `AmazonEKSClusterAdminPolicy`

**Where it lives:** `terraform/modules/eks/main.tf`

**Important:** These access entries must exist BEFORE any Kubernetes or Helm resources
are created or destroyed. Deleting them mid-operation locks Terraform out of the cluster.
This is why all Helm releases depend on these access entries — see destroy ordering below.

---

## Layer 3 — Pods talking to AWS (IRSA)

**What it controls:** Individual pods inside the cluster making AWS API calls.

**Why it exists:** Pods cannot have IAM users. IRSA (IAM Roles for Service Accounts)
allows pods to assume IAM roles temporarily using the cluster's OIDC provider as
a trusted identity issuer.

**How it works:**
1. Cluster has an OIDC provider registered in AWS IAM
2. Each tool gets a dedicated IAM role with a trust policy scoped to its specific
   Kubernetes service account
3. When the pod starts, it automatically receives temporary AWS credentials

**What we created:**
- `dev-cop-alb-controller-role` — allows ALB Controller pods to create/update
  load balancers, target groups, listener rules
- `dev-cop-cluster-autoscaler-role` — allows Cluster Autoscaler pods to add/remove
  EC2 nodes via Auto Scaling Groups

**Where it lives:** `terraform/modules/eks-platform/main.tf`

**Common mistake:** The trust policy must match the EXACT service account name the
Helm chart creates. The Cluster Autoscaler chart creates a service account named
`cluster-autoscaler-aws-cluster-autoscaler` — not just `cluster-autoscaler`.
A mismatch causes `AccessDenied: sts:AssumeRoleWithWebIdentity` and CrashLoopBackOff.

---

## Layer 4 — Permissions inside Kubernetes (RBAC)

**What it controls:** What actions identities can perform INSIDE the cluster —
creating namespaces, installing Helm charts, managing pods etc.

**Why it exists:** Kubernetes has its own internal permission system (RBAC) completely
separate from AWS IAM. Authenticating to the cluster via Layer 2 only proves identity —
RBAC controls what that identity can actually do once inside.

**What we created:**
- `cop-terraform-user-admin` ClusterRoleBinding — grants `cop-terraform-user`
  cluster-admin inside Kubernetes so Terraform can manage all resources and
  Helm can uninstall cleanly on destroy

**Where it lives:** `terraform/modules/eks-platform/main.tf`

---

## Destroy Ordering — Why It Matters

### The problem
Terraform destroys resources in parallel by default. If access entries (Layer 2)
are deleted before Helm releases (Layer 4) are uninstalled, Terraform loses
access to the cluster mid-destroy and cannot clean up Kubernetes resources.
This leaves the EKS cluster, IRSA roles, and VPC subnets stranded — still
running and still costing money.

### The fix
All Helm releases and Kubernetes resources depend on the access entries via
`depends_on = [var.access_entry_arns]`. This forces Terraform to:
1. Uninstall Helm releases first
2. Delete Kubernetes resources
3. Then delete access entries
4. Then delete EKS cluster
5. Then delete VPC and networking

### Emergency recovery (if destroy fails mid-way)
If destroy fails with `Unauthorized` or `cluster unreachable`, remove Helm
resources from state and retry:

```bash
terraform state rm module.eks-platform.helm_release.argocd
terraform state rm module.eks-platform.helm_release.aws_load_balancer_controller
terraform state rm module.eks-platform.helm_release.cluster_autoscaler
terraform state rm module.eks-platform.helm_release.secrets_store_csi_driver
terraform state rm module.eks-platform.helm_release.secrets_store_csi_driver_aws
terraform state rm module.eks-platform.kubernetes_namespace.argocd
terraform state rm module.eks-platform.kubernetes_cluster_role_binding.terraform_user_admin
terraform destroy
```

Deleting the EKS cluster removes all Kubernetes resources inside it automatically —
no clean Helm uninstall needed when the whole cluster is going away.

---

## Quick Reference

| I want to... | Which layer | Where to look |
|---|---|---|
| Give EKS permission to create ENIs | Layer 1 | `modules/eks/main.tf` — cluster role |
| Give nodes permission to pull ECR images | Layer 1 | `modules/eks/main.tf` — node role |
| Allow my laptop to run kubectl | Layer 2 | `modules/eks/main.tf` — access entries |
| Allow pipeline to run kubectl | Layer 2 | `modules/eks/main.tf` — access entries |
| Give ALB Controller AWS permissions | Layer 3 | `modules/eks-platform/main.tf` — IRSA |
| Give Autoscaler AWS permissions | Layer 3 | `modules/eks-platform/main.tf` — IRSA |
| Allow Terraform to manage Kubernetes resources | Layer 4 | `modules/eks-platform/main.tf` — RBAC |
