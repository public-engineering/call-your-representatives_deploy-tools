provider "digitalocean" {
  token = var.digitalocean_token
}

provider "cloudflare" {
  version = "~> 2.0"
  # email   = var.cloudflare_email
  # api_key = var.cloudflare_api_key
  api_token = var.cloudflare_api_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = file(var.ssh_public_key_path)
}
