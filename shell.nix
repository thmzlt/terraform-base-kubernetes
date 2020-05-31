{ pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/0b72a749ae200b30a1ed0379cca7dc989763c8df.tar.gz) {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.google-cloud-sdk
    pkgs.jq
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.terraform
  ];

  shellHook = ''
    export CLOUDSDK_CORE_PROJECT="$(jq -r .project_id < credentials.json)";

    terraform init
  '';
}
