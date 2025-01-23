###############################################
#                     DNS                     #
###############################################

resource "google_dns_managed_zone" "my_domain_zone" {
  name        = "barisano-dev-zone"
  dns_name    = "${var.personal_domain}."
  description = "Managed zone for barisano.dev"
}

resource "google_dns_record_set" "mail_a_record" {
  name         = "${var.mail-server-name}.${var.personal_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = [google_compute_address.mail_server_ip.address]
}

resource "google_dns_record_set" "domain_a_record" {
  name         = "${var.personal_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = [google_compute_address.mail_server_ip.address]
}

resource "google_dns_record_set" "mail_mx_record" {
  name         = "${var.personal_domain}."
  type         = "MX"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = ["10 mail.barisano.dev."]
}

resource "google_dns_record_set" "spf_record_mail_host" {
  name         = "${var.mail-server-name}.${var.personal_domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = ["\"v=spf1 mx ~all\""] # escaped quotes are used to avoid change warning with each apply
                                                # GCP separates each field into their own quoted strings
}

resource "google_dns_record_set" "spf_record_domain" {
  name         = "${var.personal_domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = ["\"v=spf1 mx include:spf.mailjet.com ~all\""] # escaped quotes are used to avoid change warning with each apply
                                                # GCP separates each field into their own quoted strings
}

resource "google_dns_record_set" "dmarc" {
  name         = "_dmarc.${var.personal_domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = ["\"v=DMARC1; p=quarantine;\""]
}

###############################################
#                   mailjet                   #
###############################################

resource "google_dns_record_set" "domain_key" {
  name         = "mailjet._domainkey.${var.personal_domain}."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_domain_zone.name
  rrdatas      = [var.smtp_relay_domain_key]
}
