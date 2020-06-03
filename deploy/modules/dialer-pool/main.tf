variable "droplet_size" {}
variable "ssh_key_fingerprints" {}
variable "region" {}
variable "twilio_sid" {}
variable "twilio_token" {}
variable "numbers_outbound" {}
variable "cloudflare_zone_id" {}
variable "host_record" {}
variable "pool_size" {}
variable "google_api_key" {}
variable "twilio_twiml_sid" {}

data "template_file" "dialer" {
  template = "${file("${path.module}/dialer.tpl")}"

  vars = {
    twilio_sid       = var.twilio_sid
    twilio_token     = var.twilio_token
    twilio_twiml_sid = var.twilio_twiml_sid
    numbers_outbound = var.numbers_outbound
    google_api_key   = var.google_api_key
  }
}

resource "digitalocean_droplet" "dialer" {
  name               = format("dialer-node-%02d", count.index)
  count              = var.pool_size
  image              = "ubuntu-18-04-x64"
  size               = var.droplet_size
  region             = var.region
  backups            = "false"
  private_networking = "false"
  ssh_keys           = var.ssh_key_fingerprints
  user_data          = data.template_file.dialer.rendered
}

resource "digitalocean_loadbalancer" "public" {
  name   = "call-your-reps"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 8080
    target_protocol = "http"
  }

  healthcheck {
    port     = 8080
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.dialer.0.id, digitalocean_droplet.dialer.1.id]
}

resource "cloudflare_record" "dial" {
  zone_id = var.cloudflare_zone_id
  name    = var.host_record
  value   = digitalocean_loadbalancer.public.ip
  type    = "A"
  ttl     = 1
  proxied = true
}
