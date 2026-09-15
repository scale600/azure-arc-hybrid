#!/usr/bin/env bash
# M0 — Local environment setup: install Multipass + create 2 Ubuntu VMs
# Run this ONCE from the project root. It will prompt for your sudo password
# during the Multipass install.
set -euo pipefail

echo "==> [1/3] Installing Multipass (prompts for sudo password)..."
brew install --cask multipass

echo "==> [2/3] Creating VM-01 (Ubuntu 22.04, 2 vCPU / 2 GB / 20 GB)..."
multipass launch 22.04 --name vm-01 --cpus 2 --memory 2G --disk 20G

echo "==> [2/3] Creating VM-02 (Ubuntu 22.04, 2 vCPU / 2 GB / 20 GB)..."
multipass launch 22.04 --name vm-02 --cpus 2 --memory 2G --disk 20G

echo "==> [3/3] Verifying..."
multipass list
