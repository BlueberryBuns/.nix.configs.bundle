SOPS_FILE := "../secrets/.sops.yaml"

default:
    @just --list

diff:
    git diff '!:flake.lock'

update:
    nix flake update

age-key:
    nix-shell -p age --run "age-keygen"
