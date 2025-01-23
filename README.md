# Terraform Mail Server Setup on GCP

This repository contains a Terraform configuration to deploy a mail server on Google Cloud Platform (GCP) using Postfix. The mail server is set up with SMTP relay settings, a domain key for the SMTP relay, and a specific domain for email sending. You can customize this setup by adjusting the provided variables.

## Prerequisites

Before using this Terraform configuration, make sure you have the following:

- A **Google Cloud Platform (GCP)** account and project.
- **Terraform** installed on your local machine.
- A **service account key** for GCP with appropriate permissions (e.g., `Compute Admin`, `Storage Admin`).
- A **Mail Relay Provider** (e.g., Mailjet or SendGrid) for the SMTP relay settings.

## Variables

The following variables need to be updated to suit your project. You can either update them directly in the `terraform.tfvars` file or provide values via command line when running Terraform commands.


- gcp_project_id
- smtp_relay_host
- smtp_relay_port
- smtp_relay_domain_key
    > This is your dns entry that should come from your SMTP hosting provider. Some providers may have more than one key and in that case you will need to add additional blocks to your terraform configuration
- personal_domain
    > If your email address is joe@example.com this would be "example.com"
- mail-server-name
    > if your server FQDN is mail.example.com this would be "mail"
- terraform-gcp-service-account
    > This shoudl be created in your GCP project outside of terraform. The default value you shoudl provide would be the email id of your service account: terraform-service-account@my-project-id.iam.gserviceaccount.com