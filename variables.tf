###############################################
#                  Variables                  #
###############################################

variable "gcp_project_id" {
    description = "GCP Project ID"
    type = string
    default = "sigma-smile-251818"
}

variable "smtp_relay_host" {
    description = "The host to use for the SMTP relay in Postfix"
    type = string
    default = "in-v3.mailjet.com"
}

variable "smtp_relay_port" {
    description = "The port to use for the SMTP relay in Postfix - 587 for TLS connections"
    type = string
    default = "587"
}

variable "smtp_relay_domain_key" {
    description = "Domain key for SMTP realy like Sendgrid or Mailjet"
    type = string
    default = "\"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbzB41im0rybgDbci3hg/pKadT3A9kmn5Ww6wtZY2wl0QQmV1ayfGpvwF/U37q/kj7AJ33tkIBdXh3CnhcKDdQTVzkNg+IpT9g0Ar4TMfRbDL+BY4d1PWcMl2UVDMf6J5Q+kfuLjPSarbzM5cZlH5yhH+wAzupMM3kmRDz+6jxjwIDAQAB\""
}


variable "personal_domain" {
    description = "Domain where emails will be sent to (joe@example.com would be example.com)"
    type = string
    default = "barisano.dev"
}

variable "mail-server-name" {
    description = "Name of the mail server VM"
    type = string
    default = "mail"
}

variable "terraform-gcp-service-account" {
    description = "Service account to attach to GCP VMs"
    type = string
    default = "terraform-service-account@sigma-smile-251818.iam.gserviceaccount.com"
}