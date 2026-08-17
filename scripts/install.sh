#!/usr/bin/env bash

set -euo pipefail

REPO_SCRIPTS_DIR=$(git rev-parse --show-toplevel)/scripts
SCRIPTS="backup-to-pbs.sh list-pbs-snapshots.sh pbs-environment.sh restore-pbs-backup.sh"

for script in $SCRIPTS; do
  if [ ! -f "$REPO_SCRIPTS_DIR/$script" ]; then
    echo "Error: $REPO_SCRIPTS_DIR/$script does not exist. Aborting installation."
    exit 1
  else
    REPO_REMOTE_URL=$(git config --get remote.origin.url)
    cat >> "$REPO_SCRIPTS_DIR/$script" <<EOF

# --- Script Info ---
# This script was installed from the pbc-scripts repository.
#
# For more information, visit the remote repository at:
# $REPO_REMOTE_URL
# -------------------
EOF
  fi
done

read -r -p "Enter the installation directory (default: ~/.local/bin): " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-~/.local/bin}

# Validate that the installation directory is on PATH
if ! echo "$PATH" | grep -q "$(realpath "$INSTALL_DIR")"; then
  echo "WARNING: The installation directory $INSTALL_DIR is not on the PATH. You may need to add it to your PATH to run the installed scripts easily."
fi

echo "Installing scripts to: $INSTALL_DIR"

mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR} || exit

for script in $SCRIPTS; do
  cp -l "$REPO_SCRIPTS_DIR/$script" "$INSTALL_DIR/$script" || {
		echo "Error: Failed to create a hardlink for $script. Creating a symlink instead."
		ln -s "$REPO_SCRIPTS_DIR/$script" "$INSTALL_DIR/$script" || {
			echo "Error: Failed to create a copy for $script. Aborting installation."
			exit 1
		}
	}
done
