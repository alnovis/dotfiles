# Dotfiles

Hyprland tiling window manager configuration with Toyota instrument panel inspired color scheme.

## Components

| Component | Description |
|-----------|-------------|
| **hypr** | Hyprland window manager config |
| **waybar** | Status bar with custom modules |
| **wofi** | Application launcher |
| **dunst** | Notification daemon |
| **fish** | Fish shell config |
| **nvim** | Neovim config with LSP |

## Quick Install (Arch/Manjaro)

```bash
git clone https://github.com/alnovis/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh install
```

Log out and select **Hyprland** at the login screen.

## Manual Install

### 1. Install dependencies

```bash
sudo pacman -S --needed \
    hyprland waybar wofi kitty fish neovim \
    swaybg dunst libnotify grim slurp wl-clipboard \
    blueman bluez bluez-utils pavucontrol brightnessctl \
    power-profiles-daemon networkmanager nm-connection-editor \
    ttf-font-awesome ttf-jetbrains-mono curl stow
```

### 2. Enable services

```bash
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now power-profiles-daemon.service
```

### 3. Stow configs

```bash
cd ~/dotfiles
stow hypr waybar wofi dunst fish nvim
```

### 4. Configure weather (optional)

Edit city in `~/.config/waybar/scripts/weather.conf`:

```bash
CITY="Your-City-Name"
```

## Hotkeys

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (kitty) |
| `Super + D` | App launcher (wofi) |
| `Super + Q` | Close window |
| `Super + V` | Toggle floating |
| `Super + F` | Fullscreen |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Arrow` | Move focus |
| `Super + Shift + Arrow` | Move window |
| `Super + Space` | Switch keyboard layout |
| `Super + T` | Telegram |
| `Super + B` | Firefox |
| `Super + I` | IntelliJ IDEA |
| `Super + N` | Toggle DND |
| `Super + M` | Toggle mic mute |
| `Super + Shift + E` | Exit Hyprland |
| `Print` | Screenshot (select area) |

## Waybar Modules

| Module | Description |
|--------|-------------|
| Workspaces | Click to switch |
| DND | Red when active, auto-enables on screen share |
| MIC | Blinking red when muted |
| Weather | City weather from wttr.in, hover for details |
| Clock | Date/time, hover for calendar |
| CPU/RAM/Temp | System monitoring with warning colors |
| Bluetooth | Green when connected, shows battery when low |
| Network | Click to open nm-connection-editor |
| Volume | Click to open pavucontrol |
| Power Profile | Click to cycle PERF/BAL/SAVE |
| Battery | Laptop battery status |

## Color Scheme

Toyota instrument panel inspired (soft yellow-green):

| Color | Hex | Usage |
|-------|-----|-------|
| Accent | `#9EBD6E` | Active elements, connected status |
| Text | `#d4d4c8` | Primary text |
| Background | `#1e1e28` | Bar background |
| Warning | `#C4B454` | Low battery, high CPU |
| Critical | `#d4726a` | Critical states |
| Muted | `#6c7070` | Disabled, disconnected |

## File Structure

```
dotfiles/
├── hypr/
│   └── .config/hypr/
│       ├── hyprland.conf
│       └── wallpapers/
├── waybar/
│   └── .config/waybar/
│       ├── config
│       ├── style.css
│       └── scripts/
│           ├── bluetooth.sh
│           ├── power-profile.sh
│           ├── weather.sh
│           └── weather.conf
├── wofi/
│   └── .config/wofi/
│       ├── config
│       └── style.css
├── dunst/
│   └── .config/dunst/
│       └── dunstrc
├── fish/
│   └── .config/fish/
├── nvim/
│   └── .config/nvim/
├── install.sh
└── README.md
```

## Troubleshooting

### Bluetooth audio not working

Reconnect device:
```bash
bluetoothctl disconnect XX:XX:XX:XX:XX:XX
bluetoothctl connect XX:XX:XX:XX:XX:XX
```

Or restart wireplumber:
```bash
systemctl --user restart wireplumber
```

### Weather not showing

Check curl and city name:
```bash
curl -s 'wttr.in/Your-City?format=%t'
```

### Waybar not starting

Check for errors:
```bash
waybar
```

Restart waybar:
```bash
pkill waybar && hyprctl dispatch exec waybar
```

### Power profiles not working

Check if daemon is running:
```bash
powerprofilesctl
```

## Uninstall

Remove symlinks:
```bash
cd ~/dotfiles
./install.sh unstow
```
