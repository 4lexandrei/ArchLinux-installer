#!/bin/bash

check_gum() {
    # Check if gum is installed
    if ! gum -v &> /dev/null; then
        echo "gum is not installed. Installing gum..."
        pacman -S --noconfirm gum
    else
        echo "gum is already installed."
    fi
}

gum() {
    local light_blue="#0000FF"
    local light_cyan="#00FFFF"

    export GUM_CHOOSE_CURSOR_FOREGROUND="$light_cyan"
    export GUM_CHOOSE_CURSOR_BACKGROUND=""
    export GUM_CHOOSE_HEADER_FOREGROUND="$light_blue"
    export GUM_CHOOSE_HEADER_BACKGROUND=""
    export GUM_CHOOSE_ITEM_FOREGROUND=""
    export GUM_CHOOSE_ITEM_BACKGROUND=""
    export GUM_CHOOSE_SELECTED_FOREGROUND="$light_cyan"
    export GUM_CHOOSE_SELECTED_BACKGROUND=""
    export GUM_CHOOSE_HEIGHT="10"
    command gum "$@"
}

check_gum
sleep 3