#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Install packages

dnf5 install -y steam

# Enable System Unit Files

systemctl enable install-flatpaks.service
