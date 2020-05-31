# Terraform Base: Kubernetes

This is a Terraform module for deploying a Kubernetes cluster on Google Cloud Platform using GKE. Use it as a starting point for building Kubernetes-based infrastructure.

The included submodules (under the `modules/` directory) are:

- `ingress-nginx`: controls external access to services
- `cert-manager`: issues and renews TLS certificates for HTTP virtual hosts
- `external-dns`: updates DNS records (and handling the DNS-based ACME challenge)
- `test-service`: serves an empty NGINX installation to test everything works

## How To Use

1. Install [Nix](https://nixos.org/nix) and use the `shell.nix` derivation to set up the environment by running `nix-shell` from the repository root

3. Install the [`kubectl` Terraform provider](https://github.com/gavinbunney/terraform-provider-kubectl)

2. Authenticate the Google Cloud CLI with `gcloud auth login` and enable the required Google Services APIs:

```
gcloud services enable cloudresourcemanager
gcloud services enable compute
gcloud services enable container
gcloud services enable servicenetworking
```

4. Create a `variables.auto.tfvars` to customize the module with your settings. Here is a template:

```terraform
region      = "us-east1"
zone        = "us-east1-c"
k8s_version = "1.16.8-gke.15"
project_id  = "atomic-saga-214365"
namespace   = "default"
dns_zone    = "example.com"
```
