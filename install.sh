#!/usr/bin/env bash
# Link handoff from this checkout into place: ~/.local/bin/handoff -> bin/handoff
#   ./install.sh              install
#   ./install.sh --uninstall  remove the link (your hosts file is kept)
# Keybindings are never touched; see the README to add your own.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
src=$here/bin/handoff
dst=~/.local/bin/handoff

if [ "${1:-}" = --uninstall ]; then
	if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
		rm "$dst"
		echo "Removed $dst"
	else
		echo "uninstall: $dst is not a link to this checkout; leaving it alone" >&2
	fi
	exit 0
fi

if [ -e "$dst" ] || [ -L "$dst" ]; then
	if [ "$(readlink "$dst" 2>/dev/null)" != "$src" ]; then
		echo "install: $dst already exists and is not this handoff; move it aside first" >&2
		exit 1
	fi
fi
mkdir -p "$(dirname "$dst")"
ln -sfn "$src" "$dst"
echo "$dst -> $src"

case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) echo "Note: ~/.local/bin is not on your PATH; add it so 'handoff' can be found." ;;
esac
found=$(command -v handoff || true)
if [ -n "$found" ] && [ "$found" != "$dst" ]; then
	echo "Note: another handoff at $found comes first on your PATH."
fi

missing=""
for cmd in ssh rsync wl-paste wl-copy notify-send; do
	command -v "$cmd" >/dev/null || missing="$missing $cmd"
done
[ -z "$missing" ] || echo "Missing:$missing (see Requirements in the README)"

echo "Next: list your machines in ${XDG_CONFIG_HOME:-~/.config}/handoff/hosts (the first run creates it), then add keybindings (see the README)."
