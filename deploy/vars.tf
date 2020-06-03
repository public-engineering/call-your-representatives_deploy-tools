variable "digitalocean_token" {}
variable "twilio_sid" {}
variable "twilio_token" {}
variable "twilio_twiml_sid" {}
variable "numbers_outbound" {}
variable "google_api_key" {}

variable "droplet_size" {
  default = "1gb"
}
variable "region" {
  default = "nyc3"
}
variable "pool_size" {
  default = 2
}
variable "ssh_public_key_path" {
  default = "$HOME/.ssh/id_rsa.pub"
}

variable "host_record" {
  default = "@"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare DNS Zone"
}

variable "cloudflare_domain" {
  description = "Cloudflare Domain"
  default     = "your_domain.com"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
}



