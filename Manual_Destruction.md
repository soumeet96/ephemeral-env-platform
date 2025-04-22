# 🫨 Manual Destruction Guide: Ephemeral Environment Deployment Platform

This document provides step-by-step guidance to manually clean up AWS resources created by the **Ephemeral Environment Deployment Platform**, in case of:

- CI/CD pipeline failure
- TTL-based destroy malfunction
- Orphaned resources due to branch/PR deletion
- Environment testing in a different AWS account

---

## 📦 Resources Created Per Environment

Each ephemeral environment creates the following AWS resources (names are prefixed with `app_name` and `branch_name`):

### 1. **S3**
- `terraform.tfstate` stored at:  
  ```
  s3://<STATE_BUCKET>/env/<sanitized-branch-name>/terraform.tfstate
  ```

### 2. **VPC & Networking**
- `aws_vpc`
- `aws_subnet` (Public)
- `aws_internet_gateway`
- `aws_route_table`
- `aws_route_table_association`
- `aws_eip`

### 3. **Security**
- `aws_security_group` (Ingress/Egress for app)

### 4. **Compute (ECS)**
- `aws_ecs_cluster`
- `aws_ecs_task_definition`
- `aws_ecs_service`

### 5. **Load Balancing**
- `aws_lb` (ALB) – Name: `<app>-<branch>-alb`
- `aws_lb_target_group` – Name: `<app>-<branch>-tg`
- `aws_lb_listener`

### 6. **IAM (if provisioned)**
- `aws_iam_role` (Task Execution Role)
- `aws_iam_policy_attachment`

### 7. **CloudWatch Logs**
- Log group for ECS task execution

---

## 🔍 Step-by-Step Manual Cleanup

### Step 1: Identify the Branch Name / Environment

If you do not know which environments are active:

```bash
aws s3 ls s3://<STATE_BUCKET>/env/ --recursive | grep terraform.tfstate
```

You may also find a `branch.txt` file alongside the state file to restore the original branch name.

---

### Step 2: Destroy Using Terraform

> ✅ Recommended if you're able to restore the working directory and backend state.

```bash
git clone https://github.com/<your-org>/ephemeral-env-platform.git
cd ephemeral-env-platform

# (Optional) Checkout the branch if it still exists
git checkout main

terraform init \
  -backend-config="bucket=<STATE_BUCKET>" \
  -backend-config="key=env/<sanitized-branch-name>/terraform.tfstate" \
  -backend-config="region=<AWS_REGION>"

terraform destroy \
  -var="app_name=<app-name>" \
  -var="branch_name=<sanitized-branch-name>" \
  -auto-approve
```

---

### Step 3: Manual Deletion via AWS Console (if Terraform not usable)

#### VPC & Subnets
- Search for VPCs with tags or names like `<app>-<branch>-vpc`
- Delete associated subnets, route tables, IGWs

#### ECS
- Go to **Amazon ECS > Clusters**
- Find and delete:
  - Cluster
  - Service
  - Task Definitions (optional)

#### Load Balancer
- Go to **EC2 > Load Balancers**
- Delete ALB with name: `<app>-<branch>-alb`
- Also delete:
  - Target Group: `<app>-<branch>-tg`
  - Listeners

#### IAM
- If provisioned manually, delete:
  - IAM Role: `<app>-<branch>-role`
  - Attached policies

#### CloudWatch
- Go to **CloudWatch > Log Groups**
- Delete log groups with prefix: `/ecs/<app>-<branch>`

#### S3
- Clean up the state folder:

```bash
aws s3 rm s3://<STATE_BUCKET>/env/<sanitized-branch-name>/ --recursive
```
---
