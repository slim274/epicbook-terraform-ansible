# EpicBook --- Terraform & Ansible on Microsoft Azure

Infrastructure-as-Code and configuration-management project for
preparing a production-oriented deployment environment for the EpicBook
Node.js application.

The project uses **Terraform** to describe the Azure infrastructure and
**Ansible** to configure the Linux server and prepare the application
stack.

> **Current project status:** Local configuration has been prepared and
> validated. Azure provisioning and remote application deployment have
> not yet been performed because an Azure subscription was not
> available. This README distinguishes completed local checks from
> deployment steps that remain pending.

## Project Overview

### Terraform --- Azure infrastructure

The Terraform configuration describes the Azure resources required by
the application:

-   Resource Group
-   Virtual Network and subnet
-   Network Security Group (NSG)
-   Public IP address
-   Network interface
-   Ubuntu Linux virtual machine

The network configuration includes inbound access for:

-   **SSH:** TCP port `22`
-   **HTTP:** TCP port `80`

SSH access is controlled through the `admin_ssh_cidr` input variable so
that administrative access can be restricted to an approved source IP
range.

### Ansible --- server configuration

The Ansible project is organized into reusable roles:

  -----------------------------------------------------------------------
  Role                                Responsibility
  ----------------------------------- -----------------------------------
  `common`                            Installs basic server dependencies.

  `mysql`                             Installs MySQL and prepares the
                                      application database and user.

  `nginx`                             Installs and configures Nginx as a
                                      reverse proxy.

  `epicbook`                          Retrieves the application source,
                                      installs Node.js dependencies and
                                      prepares PM2 to manage the
                                      application process.
  -----------------------------------------------------------------------

The application database is named `bookstore`. The application is
expected to listen on port `8080`, with Nginx acting as the reverse
proxy.

## Project Structure

``` text
epicbook-prod/
├── ansible/
│   ├── group_vars/
│   ├── roles/
│   │   ├── common/
│   │   ├── epicbook/
│   │   ├── mysql/
│   │   └── nginx/
│   ├── inventory.ini.example
│   └── site.yml
├── terraform/
│   └── azure/
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── .terraform.lock.hcl
├── .gitignore
└── README.md
```

## Prerequisites

The project workflow uses:

-   Terraform
-   Ansible
-   An SSH client and `ssh-keygen`
-   An Azure subscription for cloud provisioning
-   An Ubuntu Linux VM for remote Ansible execution

Azure provisioning and remote execution require an available Azure
subscription and a provisioned VM.

## SSH Key Preparation

A dedicated ED25519 key pair was generated for this project:

``` bash
ssh-keygen -t ed25519 -C "epicbook-azure" -f ~/.ssh/epicbook_azure
```

Terraform references the public key:

``` text
~/.ssh/epicbook_azure.pub
```

Keep the private key (`~/.ssh/epicbook_azure`) outside the repository.
Never commit or share it.

## Terraform Local Validation

The following local checks were completed:

``` bash
terraform fmt -recursive terraform/azure
terraform -chdir=terraform/azure init -backend=false
terraform -chdir=terraform/azure validate
```

Terraform initialization used `-backend=false`. These commands format,
initialize and validate the local configuration; they do **not**
provision Azure resources.

## Ansible Configuration Validation

The playbook syntax check was completed with:

``` bash
ansible-playbook --syntax-check \
  -i ansible/inventory.ini.example \
  --ask-vault-pass \
  ansible/site.yml
```

A successful syntax check confirms that Ansible can parse the playbook.
It does not confirm that the roles have been executed on a remote
server.

## Secrets and Repository Hygiene

The database password is stored as an Ansible Vault-backed variable
rather than as a plaintext value in the MySQL task.

Security practices prepared for this project:

-   Keep the private SSH key outside the repository.
-   Store sensitive database configuration using Ansible Vault.
-   Do not commit the Vault password or decrypted secrets.
-   Exclude actual Ansible inventory files and Terraform state files
    from Git.
-   Restrict SSH ingress through `admin_ssh_cidr`.
-   Review `git status` before committing to ensure sensitive files are
    not staged.

Do not place passwords, private keys, access tokens or decrypted Vault
contents in screenshots, issue reports or commits.

## Deployment Status and Remaining Work

The following local preparation and validation work has been completed:

-   Terraform configuration prepared.
-   Terraform formatting, initialization and validation completed.
-   Dedicated ED25519 SSH key pair generated.
-   Ansible roles and playbook prepared.
-   Database name aligned with `bookstore`.
-   Database password moved to an Ansible Vault-backed variable.
-   Ansible playbook syntax check passed.
-   Git ignore rules prepared for sensitive files and Terraform state.

The following work remains pending because an Azure VM has not yet been
provisioned:

1.  Provision the Azure infrastructure.
2.  Verify SSH access to the VM using the dedicated private key.
3.  Run the Ansible playbook against the VM.
4.  Correct and validate the Nginx upstream configuration.
5.  Verify that the EpicBook application is accessible through the HTTP
    endpoint.
6.  Run the Ansible playbook a second time and inspect the recap to
    confirm idempotent behavior.

### Important Nginx configuration note

During configuration review, a port mismatch was identified: the Nginx
template referenced port `3000`, while the EpicBook application uses
port `8080` by default. The template at:

``` text
ansible/roles/nginx/templates/epicbook.conf.j2
```

must be corrected to proxy to `127.0.0.1:8080` and validated on the
server before deployment is considered complete. The planned Nginx
validation command is:

``` bash
sudo nginx -t
```

## Learning Outcomes

This project provides practical experience with:

-   Declarative infrastructure management using Terraform.
-   Preparing and validating Terraform configuration before
    provisioning.
-   SSH public-key authentication.
-   Reusable Ansible roles and playbook organization.
-   Protecting sensitive variables with Ansible Vault.
-   Nginx reverse-proxy configuration for a Node.js application.
-   Git hygiene for inventories, secrets and Terraform state.
-   Separating local validation from actual cloud deployment and live
    verification.

## Project Status

**Local preparation:** Completed\
**Terraform validation:** Passed\
**Ansible syntax validation:** Passed\
**Azure provisioning:** Pending\
**Remote configuration and application deployment:** Pending\
**Live application and idempotency verification:** Pending
