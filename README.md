# fleetdrop

Drop this machine's clipboard, or some files, onto another machine in your
fleet, over ssh.

```
fleetdrop clip [LABEL]            clipboard -> LABEL's clipboard
fleetdrop file [LABEL] [PATH...]  files -> LABEL:~/Downloads/fleetdrop/
```

- Without LABEL a menu asks which machine (unless there is only one other);
  without PATHs a file chooser opens.
- Files copied in a file manager are on the clipboard as `file://` URIs, so
  `clip` sends those as files.
- Images are sent as images, text as text.
- The receiver gets a notification. On Omarchy, clicking it opens the folder.

It is a single bash script with no background service. It works on any Wayland
desktop, and uses Omarchy's menu and file chooser when they are installed.

## Requirements

On both machines:

- `ssh` and `rsync` (3.2.3 or newer)
- `wl-clipboard` (`wl-copy`, `wl-paste`)
- `notify-send` (`libnotify`) for notifications; optional

The receiver must be logged in to a Wayland session for `clip`.

The sender also needs, for when you leave out the machine or the files:

- a menu: `omarchy-menu-select`, `walker`, `fuzzel`, `wofi`, `rofi`, `zenity`,
  or `fzf` in a terminal
- a file chooser: `omarchy-file-select`, `zenity` or `kdialog`

ssh must log in without asking for a password, using a key
(`ssh-copy-id <target>` sets that up). fleetdrop never prompts.

## Install

```bash
git clone https://github.com/Frestina/fleetdrop.git
cd fleetdrop
./install.sh
```

This links `~/.local/bin/fleetdrop` to the checkout, so `git pull` updates it.
It will not replace an existing `fleetdrop` that is not this one, and it does not
add any keybindings. `./install.sh --uninstall` removes the link.

## Machines

The first run creates `~/.config/fleetdrop/hosts`. List your machines there, one
per line:

```
<label>  <ssh target>  [<hostname>]
```

```
desktop  desktop.lan     desktop
laptop   me@192.0.2.20   my-laptop
```

- The label is what the menu shows and what you type after `clip` or `file`.
- The target is whatever you would type after `ssh`: a `Host` from
  `~/.ssh/config`, `user@address`, or an address.
- The hostname is what `uname -n` prints on that machine. The line for the
  machine you are on is skipped, so the same file can be copied to all of them.

[Fleetwatch](https://github.com/Frestina/omarchy-fleetwatch) uses the same
format. If you use it too, you can share one list:

```bash
ln -s ../fleetwatch/hosts ~/.config/fleetdrop/hosts
```

## Options

Optional settings go in `~/.config/fleetdrop/config`:

```
# Extra options for every ssh connection, separated by spaces.
ssh_options = -o IdentityAgent=none
```

Use `-o IdentityAgent=none` if your ssh agent asks for approval on each use
(Bitwarden, 1Password, KeePassXC), so fleetdrop uses your on-disk key instead.

fleetdrop never forwards your ssh agent. It keeps one shared connection per
machine open for a minute, so repeat sends get past firewalls that rate-limit
ssh.

## Keybindings

fleetdrop adds no keybindings, so it can't take over a key you already use. Pick
your own. These are the suggested ones:

| Keys | Action |
| --- | --- |
| `SUPER + ALT + C` | `fleetdrop clip` |
| `SUPER + SHIFT + ALT + C` | `fleetdrop file` |

**Check that the keys are free first.** In Hyprland, a second binding on the
same keys does not replace the first one; both run.

- Omarchy: `omarchy menu keybindings --print`, and look for `SUPER ALT + C`
  and `SUPER SHIFT ALT + C`.
- Hyprland: this prints any binding already on those keys (no output means
  they are free):

  ```bash
  hyprctl binds -j | jq '.[] | select(.key == "C" and (.modmask == 72 or .modmask == 73))'
  ```

  (`modmask` adds up SUPER 64, ALT 8, SHIFT 1: 72 is SUPER+ALT, 73 adds SHIFT.)

Then add them:

**Omarchy** (`~/.config/hypr/bindings.lua`):

```lua
o.bind("SUPER + ALT + C", "Send clipboard to machine", "fleetdrop clip")
o.bind("SUPER + SHIFT + ALT + C", "Send files to machine", "fleetdrop file")
```

**Hyprland** (`~/.config/hypr/hyprland.conf`):

```
bindd = SUPER ALT, C, Send clipboard to machine, exec, fleetdrop clip
bindd = SUPER SHIFT ALT, C, Send files to machine, exec, fleetdrop file
```

**GNOME, KDE and others:** add a custom shortcut in the keyboard settings
that runs `fleetdrop clip` or `fleetdrop file`. The settings warn you when keys are
already taken.

## See also

[Fleetwatch](https://github.com/Frestina/omarchy-fleetwatch), a bar widget
that shows which of your machines needs attention. The two are separate tools;
neither needs the other.

## License

MIT
