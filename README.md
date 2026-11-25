# Assignment 5: Production-Grade EpicBook — Terraform + Ansible Roles (Azure)

## Task 1: Use Terraform to Provision a Cloud VM

### What I did

I prepared Terraform configuration files to provision the infrastructure required for the EpicBook application on Microsoft Azure.

The configuration defines an Azure resource group, virtual network, subnet, Network Security Group, public IP address, network interface and Ubuntu Linux virtual machine.

I configured inbound network rules for SSH (port 22) and HTTP (port 80). I also introduced an SSH CIDR variable to restrict administrative access to an approved IP address.

I initialized the Terraform working directory locally and successfully validated the configuration using Terraform.

**Commands executed:**

```bash
terraform fmt -recursive terraform/azure

terraform -chdir=terraform/azure init -backend=false

terraform -chdir=terraform/azure validate
```

### What I learned

I learned how Terraform uses declarative configuration files to describe cloud infrastructure and how infrastructure can be formatted, initialized and validated before deployment.

I also learned the importance of restricting SSH access and managing infrastructure configuration securely.

### Issue faced and solution

I initially configured SSH access using an unrestricted source address (`*`). I corrected this by introducing an `admin_ssh_cidr` variable.

I also discovered that the configured SSH public-key path did not match the key generated for this project. I corrected the path to reference the dedicated EpicBook SSH public key.

**Current status:** Terraform configuration initialized and validated successfully. Azure resources have not yet been provisioned.

## 2. Configure Passwordless SSH

### What I did

I generated a dedicated ED25519 SSH key pair for the EpicBook infrastructure project.

The key pair was created using:

```bash
ssh-keygen -t ed25519 -C "epicbook-azure" -f ~/.ssh/epicbook_azure
```

I configured Terraform to reference the public key during virtual machine creation.

The private key remains on my local machine and is excluded from version control.

### What I learned

I learned how SSH public-key authentication works and why it is important for secure, passwordless server access.

I also learned how SSH key authentication supports automation tools such as Ansible.

### Issue faced and solution

The existing Terraform configuration referenced a public key that did not exist on my machine.

I resolved this by generating a dedicated SSH key pair and updating Terraform to use the correct public-key path.

**Current status:** SSH key generation and Terraform configuration are complete. Actual SSH connectivity will be tested after the Azure virtual machine is provisioned.

## 3. Run Ansible Roles to Deploy EpicBook

### What I did

I prepared a role-based Ansible configuration to automate the installation and configuration of the EpicBook application environment.

The project contains four main roles:

- **common:** Installs basic server dependencies.
- **mysql:** Installs MySQL, starts the database service and configures the application database and user.
- **nginx:** Installs and configures Nginx as a reverse proxy.
- **epicbook:** Installs Node.js dependencies, retrieves the application source code and configures PM2.

I also updated the database configuration to use the `bookstore` database expected by the original EpicBook application.

To improve security, I configured Ansible Vault to protect the database password rather than storing it as plaintext in the playbook.

I successfully ran the Ansible syntax check.

```bash
ansible-playbook --syntax-check \
  -i ansible/inventory.ini.example \
  --ask-vault-pass \
  ansible/site.yml
```

### What I learned

I learned how Ansible roles help organize automation into reusable components.

I also learned how Ansible Vault protects sensitive information and how syntax checking helps identify playbook errors before execution.

### Issue faced and solution

One security issue was the presence of a hardcoded database password in the original MySQL task.

I replaced the hardcoded password with a variable connected to an encrypted Ansible Vault file.

I also corrected the database name to match the application configuration.

**Current status:** Ansible playbook syntax validation passed. The playbook has not yet been executed against a cloud server.

## Task 2: Application Deployment and Verification

### What I did

The application deployment stage is prepared in the Ansible configuration.

The intended deployment process is to install the application dependencies, configure the MySQL database, start the Node.js application using PM2 and expose the application through Nginx.

The original EpicBook application uses Node.js and Express, with its default application port set to 8080.

The deployment configuration will be tested against the Azure virtual machine once the infrastructure is available.

### What I learned

I learned how Nginx acts as a reverse proxy by accepting external HTTP requests and forwarding them to an application running on an internal port.

I also learned why the application port and Nginx proxy configuration must match.

### Issue faced and solution

During configuration review, I identified a port mismatch between the original application's default port (8080) and the existing Nginx proxy configuration (3000).

The configuration needs to be aligned to port 8080 before deployment verification.

**Current status:** Application deployment and browser verification are pending.

## 2. Confirm Idempotent Re-run

### What I did

I prepared the Ansible playbook using reusable roles and declarative tasks.

The playbook is intended to be executed repeatedly to maintain the desired server configuration without introducing unnecessary changes.

The idempotency test will be performed after the first successful deployment by running the playbook again and reviewing the execution summary.

### What I learned

I learned that idempotency is an important property of configuration management because it allows automation to be repeated safely.

### Issue faced and solution

No idempotency test has been performed yet because the playbook has not been executed against a provisioned server.

**Current status:** Pending deployment.

## 3. Verify Nginx Configuration

### What I did

I prepared an Nginx configuration template under:

```text
ansible/roles/nginx/templates/epicbook.conf.j2
```

The template is intended to configure Nginx as a reverse proxy for the EpicBook Node.js application.

The expected proxy destination is:

```nginx
proxy_pass http://127.0.0.1:8080;
```

The Nginx configuration will be tested on the server using:

```bash
sudo nginx -t
```

### What I learned

I learned how Nginx reverse proxy configuration connects external web traffic to a backend application and why validating Nginx configuration before reloading the service is important.

### Issue faced and solution

The initial configuration used port 3000, while the application defaults to port 8080.

The mismatch was identified during review. The final Nginx configuration still needs to be corrected and verified on the server.

**Current status:** Nginx role prepared; live configuration testing pending.

## Task 3: Project Structure and Configuration

The project follows this structure:

```text
epicbook-prod/
│
├── ansible/
│   ├── group_vars/
│   │   ├── web.yml
│   │   └── web/
│   │       └── vault.yml
│   │
│   ├── roles/
│   │   ├── common/
│   │   ├── epicbook/
│   │   ├── mysql/
│   │   └── nginx/
│   │
│   ├── inventory.ini.example
│   └── site.yml
│
├── terraform/
│   └── azure/
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── .terraform.lock.hcl
│
├── .gitignore
└── README.md
```

### Security measures implemented

- Generated a dedicated SSH key pair.
- Restricted SSH access through a configurable CIDR variable.
- Stored the database password using Ansible Vault.
- Excluded Terraform state files from Git.
- Excluded the actual Ansible inventory from Git.
- Excluded private keys and sensitive configuration files from version control.

## Issues Faced and How I Addressed Them

| Issue | Action taken | Status |
|---|---|---|
| Missing SSH key | Generated a dedicated ED25519 key pair | Resolved |
| Incorrect SSH public-key path | Updated Terraform to use the new public key | Resolved |
| Unrestricted SSH access | Introduced an SSH CIDR variable | Resolved in configuration |
| Hardcoded database password | Replaced it with an Ansible Vault variable | Resolved |
| Incorrect database name | Changed the database configuration to `bookstore` | Resolved |
| Git detecting the home directory | Initialized a separate Git repository inside the project directory | Resolved |
| Sensitive files appearing in Git | Updated `.gitignore` to exclude Vault, inventory and Terraform state files | Resolved |
| Nginx/application port mismatch | Identified the mismatch between ports 3000 and 8080 | Correction pending |
| Azure account unavailable | Continued with local configuration and validation | Deployment pending |

## What I Learned

Through this project, I gained practical experience in:

- Writing Terraform configuration for cloud infrastructure.
- Initializing and validating Terraform projects.
- Generating SSH keys for automated server access.
- Organizing Ansible automation using roles.
- Protecting sensitive variables using Ansible Vault.
- Configuring MySQL for an application environment.
- Preparing Nginx reverse proxy configuration.
- Managing infrastructure code using Git and GitHub.
- Applying security practices to Infrastructure as Code projects.

## Conclusion

This project has helped me understand how Terraform and Ansible work together in an Infrastructure as Code workflow.

I prepared the Terraform infrastructure configuration, generated a dedicated SSH key pair, organized the Ansible automation into reusable roles and secured the database credentials using Ansible Vault.

I successfully initialized and validated the Terraform configuration and passed the Ansible playbook syntax check.

However, the Azure infrastructure provisioning, server connectivity, application deployment and live verification stages remain pending because an Azure subscription is not currently available.

The project is therefore prepared for the next stage: provisioning the cloud infrastructure and executing the Ansible deployment.

## Screenshot Evidence

Insert genuine screenshots of the completed local work in the following positions.

| Screenshot | Evidence to include |
|---|---|
| 1 | Dedicated SSH key generation |
| 2 | Terraform configuration showing the Azure resources |
| 3 | Terraform initialization output |
| 4 | Terraform validation showing `Success!` |
| 5 | Ansible Vault creation (without displaying passwords) |
| 6 | Ansible syntax check showing the playbook name |
| 7 | Git ignore checks showing sensitive files excluded |
| 8 | Git commit showing the project files committed |

The following screenshots should be added only after cloud deployment:

- Terraform apply showing successful resource creation.
- Terraform outputs showing the VM public IP.
- Successful passwordless SSH connection.
- Ansible execution showing `failed=0`.
- Nginx configuration and successful validation.
- EpicBook application successfully loading in a browser.
- Ansible idempotency re-run.

**Note:** No cloud deployment screenshots are included yet because the Azure deployment has not been performed.