#!/usr/bin/env bash

set -e

MARKER="$HOME/.local/state/yad-setup"
if [ -f "$MARKER" ]; then
  exit 0
fi

#----------Establish internet connectivity----------#

if ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
  yad --title="Network Required" \
      --text="<span font='14'><b>Internet Connection Required</b></span>\n\nPlease connect to the internet to continue setting up your system." \
      --width=450 --borders=20 --on-top --no-buttons --no-escape --undecorated &
  PROMPT_PID=$!
  while ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; do
    sleep 1
  done
  kill $PROMPT_PID 2>/dev/null || true
fi

#----------Install flatpaks----------#

FLATPAKS=(
"be.alexandervanhee.gradia"
"com.github.PintaProject.Pinta"
"com.github.tchx84.Flatseal"
"com.mattjakeman.ExtensionManager"
"com.spotify.Client"
"com.vscodium.codium"
"io.github.flattool.Warehouse"
"io.gitlab.adhami3310.Impression"
"io.missioncenter.MissionCenter"
"md.obsidian.Obsidian"
"org.gnome.baobab"
"org.gnome.Calculator"
"org.gnome.Calendar"
"org.gnome.Contacts"
"org.gnome.Decibels"
"org.gnome.FileRoller"
"org.gnome.Firmware"
"org.gnome.Logs"
"org.gnome.Loupe"
"org.gnome.NautilusPreviewer"
"org.gnome.Showtime"
"org.gnome.Snapshot"
"org.gnome.TextEditor"
"org.gnome.Weather"
"org.gtk.Gtk3theme.adw-gtk3"
"org.gtk.Gtk3theme.adw-gtk3-dark"
"org.mozilla.firefox"
"page.tesk.Refine"
)

TOTAL=${#FLATPAKS[@]}
CURRENT=0

(
  for app in "${FLATPAKS[@]}"; do
    CURRENT=$((CURRENT + 1))
    PERCENT=$((CURRENT * 90 / TOTAL))
    echo "$PERCENT"
    echo "# Installing $app..."
    flatpak install --system -y flathub "$app" >/dev/null 2>&1 || true
  done

#----------Initialise chezmoi----------#

  echo "90"
  echo "# Applying configurations and developer tools..."
  chezmoi init --apply https://github.com/jroxendale/dotfiles.git >/dev/null 2>&1 || true

#----------Finish setup----------#

  echo "100"
  echo "# Setup Complete."
  sleep 2
  touch "$MARKER"

) | yad --progress \
  --title="System Setup" \
  --text="<b>Setting things up...</b>\nPlease wait while applications and settings are installed." \
  --fullscreen \
  --no-buttons \
  --no-escape \
  --auto-close
