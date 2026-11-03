#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Install packages
dnf5 install -y \
chezmoi \
quickemu \
seahorse \
steam

# Enable system unit files
systemctl enable install-flatpaks.service

# Enable user unit files
systemctl enable --global chezmoi-init.service
