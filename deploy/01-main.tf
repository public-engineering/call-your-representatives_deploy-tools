module "controllers" {
  source = "./modules/dialer-pool"

  twilio_sid           = var.twilio_sid
  twilio_token         = var.twilio_token
  twilio_twiml_sid     = var.twilio_twiml_sid
  numbers_outbound     = var.numbers_outbound
  droplet_size         = var.droplet_size
  ssh_key_fingerprints = [digitalocean_ssh_key.default.fingerprint]
  region               = var.region
  pool_size            = var.pool_size
  host_record          = var.host_record
  cloudflare_zone_id   = var.cloudflare_zone_id
  google_api_key       = var.google_api_key
}