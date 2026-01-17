# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── hypr/           # Hyprland window manager
├── waybar/         # Status bar
├── wofi/           # Application launcher
├── fish/           # Fish shell
├── nvim/           # Neovim (Lazy.nvim)
├── install.sh      # Installation script
└── README.md
```

## Installation

### Quick install (Arch-based)

```bash
git clone https://github.com/alnovis/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh install
```

### Manual stow

```bash
cd ~/dotfiles
stow hypr waybar wofi fish
```

### Remove symlinks

```bash
cd ~/dotfiles
./install.sh unstow
```

## Hyprland Hotkeys

| Keys                      | Action                    |
|---------------------------|---------------------------|
| Super + Enter             | Terminal (kitty)          |
| Super + D                 | Launcher (wofi)           |
| Super + Q                 | Close window              |
| Super + F                 | Fullscreen                |
| Super + V                 | Floating window           |
| Super + 1-9               | Switch workspace          |
| Super + Shift + 1-9       | Move window to workspace  |
| Super + Arrows / HJKL     | Focus between windows     |
| Super + Shift + Arrows    | Move window               |
| Super + Mouse             | Drag / Resize             |
| Super + Space             | Switch layout (EN/RU)     |
| Super + Shift + E         | Exit Hyprland             |
| Print                     | Screenshot area           |
| Shift + Print             | Screenshot fullscreen     |

## Waybar Modules

- Clock with calendar (hover, scroll to change month, right-click for year view)
- CPU, Memory, Temperature
- Language indicator (RU highlighted in red)
- Bluetooth, Network, Volume, Battery

## Dependencies

Arch Linux:
```bash
sudo pacman -S hyprland waybar wofi kitty fish neovim swaybg dunst \
    grim slurp wl-clipboard blueman pavucontrol brightnessctl \
    ttf-font-awesome ttf-jetbrains-mono
```

## Theme

Based on [Catppuccin Mocha](https://github.com/catppuccin/catppuccin).
