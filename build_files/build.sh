#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Remove packages
dnf5 remove -y gnome-tour

# Install packages
dnf5 install -y \
chezmoi \
quickemu \
seahorse \
steam \
yad

# Compile gsettings schemas to apply custom overrides
glib-compile-schemas /usr/share/glib-2.0/schemas/

# Ensure the yad-setup script is executable
chmod +x /usr/libexec/yad-setup.sh
