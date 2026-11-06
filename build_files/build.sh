#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Remove packages
dnf5 remove -y gnome-tour

# Remove web shortcut desktop entries
rm -f \
/usr/share/applications/discourse.desktop \
/usr/share/applications/documentation.desktop

# Install packages
dnf5 install -y \
chezmoi \
gnome-shell-extension-no-overview \
quickemu \
seahorse \
steam \
yad

# Clean cache to minimize container layer size
dnf5 clean all

# Enable custom systemd services
systemctl enable set-hostname.service

# Ensure the yad-setup script is executable
chmod +x /usr/libexec/yad-setup.sh
