#!/usr/bin/env bash
# Link fleetdrop from this checkout into place: ~/.local/bin/fleetdrop -> bin/fleetdrop
#   ./install.sh              install
#   ./install.sh --uninstall  remove the link, and ask about its settings
# Keybindings are never touched; see the README to add your own.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
src=$here/bin/fleetdrop
dst=~/.local/bin/fleetdrop
fleet=${XDG_CONFIG_HOME:-$HOME/.config}/fleet

ask() {
	printf '%s [y/N] ' "$1"
	read -r answer || answer=
	case $answer in [yY]*) return 0 ;; *) return 1 ;; esac
}

if [ "${1:-}" = --uninstall ]; then
	if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
		rm "$dst"
		echo "Removed $dst"
	else
		echo "uninstall: $dst is not a link to this checkout; leaving it alone" >&2
	fi
	if [ -e "$fleet/drop" ] && ask "Remove fleetdrop's settings in $fleet/drop?"; then
		rm -r "$fleet/drop"
		echo "Removed $fleet/drop"
	fi
	# The hosts file is shared by the Fleet tools: offer it only when no other
	# tool's folder is left beside it.
	others=$(find "$fleet" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n1)
	if [ -e "$fleet/hosts" ]; then
		if [ -n "$others" ]; then
			echo "Kept $fleet/hosts: other Fleet tools use it."
		elif ask "Remove your list of machines, $fleet/hosts? No other Fleet tool uses it."; then
			rm "$fleet/hosts"
			rmdir "$fleet" 2>/dev/null || true
			echo "Removed $fleet/hosts"
		fi
	fi
	exit 0
fi

if [ -e "$dst" ] || [ -L "$dst" ]; then
	if [ "$(readlink "$dst" 2>/dev/null)" != "$src" ]; then
		echo "install: $dst already exists and is not this fleetdrop; move it aside first" >&2
		exit 1
	fi
fi
mkdir -p "$(dirname "$dst")"
ln -sfn "$src" "$dst"
echo "$dst -> $src"

case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) echo "Note: ~/.local/bin is not on your PATH; add it so 'fleetdrop' can be found." ;;
esac
found=$(command -v fleetdrop || true)
if [ -n "$found" ] && [ "$found" != "$dst" ]; then
	echo "Note: another fleetdrop at $found comes first on your PATH."
fi

missing=""
for cmd in ssh rsync wl-paste wl-copy notify-send; do
	command -v "$cmd" >/dev/null || missing="$missing $cmd"
done
[ -z "$missing" ] || echo "Missing:$missing (see Requirements in the README)"

echo "Next: list your machines in $fleet/hosts (the first run creates it), then add keybindings (see the README)."
