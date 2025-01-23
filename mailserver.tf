provider "google" {
  project = var.gcp_project_id
  region  = "us-east1"
}

resource "google_compute_network" "mail_network" {
  name = "mail-network"
}

resource "google_compute_subnetwork" "mail_subnetwork" {
  name          = "mail-subnetwork"
  network       = google_compute_network.mail_network.self_link
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-east1"
}

resource "google_compute_instance" "mail_server" {
  name         = var.mail-server-name
  hostname = "${var.mail-server-name}.${var.personal_domain}"
  machine_type = "e2-micro"
  zone         = "us-east1-b"
  allow_stopping_for_update = true

  tags = ["allow-list"] # Add the same tag as in the firewall rule

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    auto_delete = false
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mail_subnetwork.self_link
    access_config {
      nat_ip = google_compute_address.mail_server_ip.address # Associate static IP
      public_ptr_domain_name = "${var.mail-server-name}.${var.personal_domain}."
    }
  }

  service_account {
    email = var.terraform-gcp-service-account
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    # sudo echo "$(hostname -I) ${var.mail-server-name}.${var.personal_domain}" >> /etc/hosts
    sudo apt-get install ufw -y
    sudo ufw enable
    sudo ufw allow 22,25,80,587,993/tcp
    sudo ufw reload
    echo "Firewall installed"
    josh_pass=$(gcloud secrets versions access latest --secret="josh-mail-user-password" --format="get(payload.data)" | tr '_-' '/+' | base64 --decode)
    mail_relay_user=$(gcloud secrets versions access latest --secret="mail-relay-account-user" --format="get(payload.data)" | tr '_-' '/+' | base64 --decode)
    mail_relay_pass=$(gcloud secrets versions access latest --secret="mail-relay-account-password" --format="get(payload.data)" | tr '_-' '/+' | base64 --decode)
    gcloud storage cp gs://mail-barisano-dev/postfix.sh /tmp/postfix.sh
    gcloud storage cp gs://mail-barisano-dev/dovecot.sh /tmp/dovecot.sh
    sudo chmod +x /tmp/postfix.sh /tmp/dovecot.sh
    sudo debconf-set-selections <<< "postfix postfix/mailname string mail.barisano.dev"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    sudo apt-get install --assume-yes postfix
    sudo apt-get install dovecot-core dovecot-imapd -y
    echo "Postfix and dovecot installed. Configure them manually."
    sudo useradd -m josh
    sudo echo "josh:$josh_pass" | chpasswd
    sudo touch /var/mail/josh
    sudo chown josh:mail /var/mail/josh
    sudo chmod 660 /var/mail/josh
    # uncomment next two lines if using certbot and comment out storage bucket and tar
    #sudo apt-get install certbot -y
    #sudo certbot certonly --standalone -n -d $(hostname -f) -m jbarisan@gmail.com --agree-tos
    # copy from bucket so we dont hit rate limits
    gcloud storage cp gs://mail-barisano-dev/letsencrypt.tar /tmp/letsencrypt.tar
    tar -xf /tmp/letsencrypt.tar -C /etc/
    sudo /tmp/postfix.sh ${var.smtp_relay_host} ${var.smtp_relay_port} $mail_relay_user $mail_relay_pass
    sudo /tmp/dovecot.sh
    echo "done" > /tmp/startup-completed.log
  EOT
}

resource "google_compute_address" "mail_server_ip" {
  name = "mail-server-ip"
  region = "us-east1"
}

resource "google_compute_firewall" "allow_list" {
  name    = "allow-list"
  network = google_compute_network.mail_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "25", "587", "993", "80"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow from anywhere (use carefully)
  direction     = "INGRESS"
  target_tags   = ["allow-list"] # Apply this rule only to instances with this tag
}

output "mail_server_ip" {
  value = google_compute_address.mail_server_ip.address
}

output "mail_server_hostname" {
  value = google_compute_instance.mail_server.hostname
}
