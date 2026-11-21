#!/usr/bin/env bash

set -e

MARKER="$HOME/.local/state/yad-setup"
if [ -f "$MARKER" ]; then
  exit 0
fi

#----------Kiosk lockdown----------#

function restore_keys() {
  gsettings reset org.gnome.desktop.wm.keybindings close
  gsettings reset org.gnome.desktop.session idle-delay
  gsettings reset org.gnome.mutter overlay-key
  gsettings reset org.gnome.desktop.wm.keybindings panel-run-dialog
  gsettings reset org.gnome.desktop.wm.keybindings switch-applications
  gsettings reset org.gnome.desktop.wm.keybindings switch-to-workspace-left
  gsettings reset org.gnome.desktop.wm.keybindings switch-to-workspace-right
}
trap restore_keys EXIT

gsettings set org.gnome.desktop.wm.keybindings close "[]"
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.mutter overlay-key ''
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "[]"

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

#----------Start progress bar----------#

exec 3> >(exec yad --progress \
  --title="System Setup" \
  --text="<b>Setting things up...</b>\nPlease wait while applications and settings are installed." \
  --fullscreen \
  --no-buttons \
  --no-escape)
PROGRESS_PID=$!

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

for app in "${FLATPAKS[@]}"; do
  CURRENT=$((CURRENT + 1))
  PERCENT=$((CURRENT * 90 / TOTAL))
  echo "$PERCENT" >&3
  echo "# Installing $app..." >&3
  flatpak install --system -y flathub "$app" >/dev/null 2>&1 || true
done

#----------Initialise chezmoi----------#

echo "90" >&3
echo "# Applying configurations and developer tools..." >&3
chezmoi init --apply https://github.com/jroxendale/dotfiles.git >/dev/null 2>&1 || true

#----------Finish setup----------#

echo "100" >&3
echo "# Setup Complete." >&3
sleep 5
touch "$MARKER"

(sleep 0.5; kill "$PROGRESS_PID" 2>/dev/null || true) &

set +e

yad --title="System Setup" \
    --text="<span font='28' weight='heavy'>Deployment Successful</span>\n\n<span font='14'>Your personalized OS is ready.</span>\n\n<span font='12'>A session restart is required to activate all extensions.</span>" \
    --justify="center" \
    --button="Log Out:0" --button="Reboot:1" --button="Shut Down:2" \
    --timeout=10 --timeout-indicator=bottom \
    --fullscreen

USER_CHOICE=$?

set -e

exec 3>&-

case $USER_CHOICE in
    0|70) loginctl terminate-user "$USER" ;;
    1) systemctl reboot ;;
    2) systemctl poweroff ;;
    *) loginctl terminate-user "$USER" ;;
esac
