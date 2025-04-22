# 🚀 Ephemeral Environment Deployment Platform

This platform enables on-demand **ephemeral environment deployments** for feature branches using **GitHub Actions**, **Terraform**, and **AWS**.  
It is ideal for staging, QA testing, and fast feedback cycles — all without persistent infrastructure costs.

---

## 🔧 Use Case

> Automatically deploy and tear down AWS infrastructure per feature branch.  
> Trigger deployments via **GitHub push**, **PR close**, or a **manual UI/API trigger**.

---

## ⚙️ Key Features

- 🧠 Fully automated **deploy/destroy pipelines** via GitHub Actions + Terraform  
- 🕒 **TTL-based auto-destroy** for stale environments using AWS Lambda + CloudWatch  
- 🌐 Unique **Preview URLs** per environment (`http://<branch>.soumeet.store`)  
- 📩 Instant **Slack notifications** via [Captain Deployer]  
- ✋ Manual trigger support via **API Gateway + Lambda**  
- 🔐 Secure and scalable with **least-privilege IAM policies**

---

## 🧱 Architecture Overview

```text
             +------------------------+
             |      GitHub (Push)     |
             +-----------+------------+
                         |
                         v
             +-------------------------+
             | GitHub Actions Workflow |
             +-----------+-------------+
                         |
                         v
               +--------------------+
               |  Terraform (IaC)   |
               +--------------------+
                         |
                         v
             +--------------------------+
             | AWS Infra (ECS, etc)     |
             +--------------------------+
                         |
                         v
        +-------------------------------+
        | API Gateway + Lambda (Manual) |
        +-------------------------------+
                         |
                         v
             +------------------------+
             | Slack Notifications    |
             +------------------------+
                         |
                         v
       +-----------------------------------+
       | Lambda TTL Destroy (CloudWatch)  |
       +-----------------------------------+

---

## 🚀 Deployment Triggers

### 🔁 Auto Deploy (CI/CD)

- Push to any `feature/*` branch ➜ **Deploy environment**
- Pull request closed ➜ **Destroy environment**

### ✋ Manual Deploy (via API)

Trigger deployment manually without pushing new code:

<API_URL>?repo=soumeet96/ephemeral-env-platform&branch=feature/my-branch


> `API_URL` is auto-generated and included in Slack deploy notification.

---

## 🌐 Preview URL

Once deployed, preview the app at:

http://<branch-name>.soumeet.store


Example:  
`http://feature-update.soumeet.store`

---

## 🔐 IAM and Security

- Uses **least-privilege IAM roles** for Lambda and Terraform  
- **State file** stored in **S3**, with **DynamoDB locking**  
- GitHub Actions uses **inherited secrets** for credentials  
- Manual and auto triggers handled via **secure API Gateway + Lambda**

---

## 🧪 TTL-Based Auto-Destroy

- Lambda function runs every minute via **CloudWatch**  
- Checks `LastModified` time of S3 state files  
- If expired (`now > last_modified + TTL`), triggers `terraform destroy` via GitHub API

---

## 📩 Slack Notifications

Deploy and destroy events are sent to Slack via webhook.

Example notification:

🚀 Deployment Successful!! Branch: feature/update Trigger API: https://<api-url>?repo=soumeet96/ephemeral-env-platform&branch=feature/update 🌐 Preview URL: http://feature-update.soumeet.store

---

## 🛠️ Technologies Used

- Terraform  
- GitHub Actions  
- AWS: ECS Fargate, API Gateway, Lambda, S3, Route 53  
- Python (TTL Lambda)  
- Slack Webhook 

---

## 📁 Repo Structure

.
├── Dockerfile               # Dockerfile for image building
├── terraform/               # Infrastructure as Code (ECS, VPC, S3, etc.)
│   ├── lambda/          
│   │   ├── github_trigger.py
│   |   └── lambda_function.py
│   |
│   ├── modules/          
│   │   ├── network/   
│   │   │   ├── igw.tf
│   │   │   ├── nat.tf
│   │   │   ├── outputs.tf
│   │   │   ├── private_route_table.tf
│   │   │   ├── sg.tf
│   │   │   ├── subnets.tf
│   │   │   ├── variables.tf
│   │   │   └── vpc.tf
│   │   ├── service/   
│   │   │   ├── alb.tf
│   │   │   ├── ecs.tf
│   │   │   ├── iam.tf
│   │   │   ├── outputs.tf
│   │   │   ├── route53.tf
│   │   │   └── variables.tf
│   │   |
│   ├── network/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   ├── github_trigger.zip
│   ├── lambda_function.zip
│   ├── lambda.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── variables.tf
|
├── .github/
│   └── workflows/           # CI/CD Workflows
│       ├── deploy.yml       # Main deploy workflow (push, PR, manual)
│       ├── destroy.yml      # Optional destroy workflow (if separated)
│       ├── _deploy-template.yml    # Reusable workflow templates
│       └── _destroy-template.yml   # Reusable workflow templates
│           
├── app/ 
│   ├──go.mod
│   └──main.go                     # Go application code
├── scripts/ 
│   ├──deploy.sh             # Script to trigger the deployment
│   └──destroy.sh            # Script to trigger destroy
└── README.md                # Project documentation

---

## 🙌 Credits

Built with ❤️ by [Soumeet96](https://github.com/soumeet96)