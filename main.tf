# Configure the Google Cloud provider
provider "google" {
project = "arched-aleph-450718-n9"
region = "us-central1"
zone = "us-central1-a"
}

# Create a Google Cloud Storage bucket
resource "google_storage_bucket" "my_bucket" {
name = "zaheeeds-ramesh-bucket"
location = "US"
force_destroy = true # Allows the bucket to be destroyed even if it contains objects
}

# Assign IAM role to a user or service account for the bucket
resource "google_storage_bucket_iam_member" "bucket_iam_member" {
bucket = google_storage_bucket.my_bucket.name
role = "roles/storage.objectViewer"
member = "serviceAccount:terraform-deployment@arched-aleph-450718-n9.iam.gserviceaccount.com"
}

# Create a Firewall rule to allow HTTP traffic to a Compute Engine VM
resource "google_compute_firewall" "default" {
name = "allow-http"
network = "default"

allow {
protocol = "tcp"
ports = ["80"]
}

source_ranges = ["0.0.0.0/0"]
target_tags = ["http-server"]
}

# Create a service account with specific access
resource "google_service_account" "my_service_account" {
account_id = "my-service-account"
display_name = "My Service Account"
}

# Assign IAM roles to the service account
resource "google_project_iam_member" "service_account_role" {
project = "arched-aleph-450718-n9"
role = "roles/compute.instanceAdmin"
member = "serviceAccount:${google_service_account.my_service_account.email}"
}

# Enable encryption for storage bucket (using default GCP encryption)
resource "google_storage_bucket_object" "my_bucket_encrypted_object" {
name = "example-object.txt"
bucket = google_storage_bucket.my_bucket.name
content = "This is a test file content."

# GCP automatically encrypts objects at rest using Google-managed keys
}

# Outputs
output "bucket_name" {
value = google_storage_bucket.my_bucket.name
}

output "service_account_email" {
value = google_service_account.my_service_account.email
}