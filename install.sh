#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(hypr waybar wofi fish nvim dunst)

echo "Dotfiles installer"
echo "=================="
echo "Directory: $DOTFILES_DIR"
echo ""

# Check for stow
if ! command -v stow &> /dev/null; then
    echo "GNU Stow not found. Installing..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm stow
    elif command -v apt &> /dev/null; then
        sudo apt install -y stow
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y stow
    else
        echo "Please install GNU Stow manually"
        exit 1
    fi
fi

# Install Hyprland dependencies (Arch-based)
install_deps() {
    if command -v pacman &> /dev/null; then
        echo "Installing Hyprland dependencies..."
        sudo pacman -S --needed --noconfirm \
            hyprland \
            waybar \
            wofi \
            kitty \
            fish \
            neovim \
            swaybg \
            dunst \
            libnotify \
            grim \
            slurp \
            wl-clipboard \
            blueman \
            bluez \
            bluez-utils \
            pavucontrol \
            brightnessctl \
            power-profiles-daemon \
            networkmanager \
            nm-connection-editor \
            ttf-font-awesome \
            ttf-jetbrains-mono \
            curl
    else
        echo "Not an Arch-based system. Please install dependencies manually."
    fi
}

# Enable system services
enable_services() {
    echo ""
    echo "Enabling services..."
    sudo systemctl enable --now bluetooth.service
    sudo systemctl enable --now NetworkManager.service
    sudo systemctl enable --now power-profiles-daemon.service
}

# Stow packages
stow_packages() {
    echo ""
    echo "Stowing packages..."
    cd "$DOTFILES_DIR"

    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            echo "  - $pkg"
            stow -v --restow "$pkg" -t "$HOME"
        fi
    done
}

# Unstow packages
unstow_packages() {
    echo ""
    echo "Unstowing packages..."
    cd "$DOTFILES_DIR"

    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            echo "  - $pkg"
            stow -v --delete "$pkg" -t "$HOME" 2>/dev/null || true
        fi
    done
}

# Main
case "${1:-}" in
    install)
        install_deps
        stow_packages
        enable_services
        echo ""
        echo "Done! Log out and select Hyprland at login screen."
        ;;
    stow)
        stow_packages
        echo ""
        echo "Done!"
        ;;
    unstow)
        unstow_packages
        echo ""
        echo "Done!"
        ;;
    *)
        echo "Usage: $0 {install|stow|unstow}"
        echo ""
        echo "  install - Install dependencies and stow configs"
        echo "  stow    - Only stow configs (create symlinks)"
        echo "  unstow  - Remove symlinks"
        exit 1
        ;;
esac
