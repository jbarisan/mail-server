terraform {
  backend "gcs" {
    bucket = "mail-server-terraform-state"
  }
}

resource "google_storage_bucket" "terraform-state-bucket" {
  name     = "mail-server-terraform-state"
  location = "US-EAST1"

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}