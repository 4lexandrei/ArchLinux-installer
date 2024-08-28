#!/bin/bash

# Constants
WINDOW_SIZE=10  # Number of options visible at a time

# Function to display the menu along with key instructions
display_menu() {
    clear
    if [ -n "$placeholder" ]; then
        echo -e "\e[1;36m$placeholder\e[0m"
    fi
    [ -n "$search_term" ] && echo "Search: $search_term"
    
    start=$scroll_offset
    end=$((scroll_offset + WINDOW_SIZE - 1))
    [ $end -ge ${#filtered_options[@]} ] && end=$((${#filtered_options[@]} - 1))

    for i in $(seq $start $end); do
        if [ "$i" -eq "$selected" ]; then
            local prefix="\e[1;32m> "
            local suffix="\e[0m"
            if [[ $multi_select_mode == "true" ]]; then
                echo -e "${prefix}${selected_map[$i]} ${filtered_options[$i]}${suffix}"
            else
                echo -e "${prefix}${filtered_options[$i]}${suffix}"
            fi
        else
            if [[ $multi_select_mode == "true" ]]; then
                echo "  ${selected_map[$i]} ${filtered_options[$i]}"
            else
                echo "  ${filtered_options[$i]}"
            fi
        fi
    done
    
    # Display concise instructions at the bottom
    echo -e "\n\e[1;36mUse ↑/↓ to navigate, Enter to select, Space to toggle (multi-select), Type to search\e[0m"
}

# Function to update the list of filtered options based on the search term
update_filtered_options() {
    filtered_options=()
    selected_map=()
    for index in "${!options[@]}"; do
        local option="${options[$index]}"
        if [ -z "$search_term" ] || [[ "$option" == *"$search_term"* ]]; then
            filtered_options+=("$option")
            if [[ $multi_select_mode == "true" ]]; then
                selected_map+=("${selected_indices[$index]:-[ ]}")
            fi
        fi
    done

    [ "$selected" -ge "${#filtered_options[@]}" ] && selected=0
    adjust_scroll
}

# Function to adjust the scroll offset based on the selected option
adjust_scroll() {
    if [ "$selected" -lt "$scroll_offset" ]; then
        scroll_offset="$selected"
    elif [ "$selected" -ge $((scroll_offset + WINDOW_SIZE)) ]; then
        scroll_offset=$((selected - WINDOW_SIZE + 1))
    fi
}

# Function to handle key input and update state
handle_key() {
    local key=$1
    case $key in
        $'\x1b') # Escape sequence for arrow keys
            read -rsn2 -t 0.1 key
            case $key in
                "[A") ((selected = (selected - 1 + ${#filtered_options[@]}) % ${#filtered_options[@]})) ;; # Up arrow
                "[B") ((selected = (selected + 1) % ${#filtered_options[@]})) ;;                         # Down arrow
            esac
            adjust_scroll
            ;;
        "") return 1 ;;  # Enter key to break loop
        $'\x20')         # Spacebar to toggle selection in multi-select mode
            [[ $multi_select_mode == "true" ]] && toggle_selection
            ;;
        $'\x7f') search_term="${search_term%?}" ;; # Backspace key
        *) search_term+="$key" ;;                  # Any other key to update search term
    esac
    return 0
}

# Function to toggle the selection status of the current option
toggle_selection() {
    local option="${filtered_options[$selected]}"
    for index in "${!options[@]}"; do
        if [ "${options[$index]}" == "$option" ]; then
            if [ "${selected_indices[$index]}" == "[*]" ]; then
                selected_indices[$index]="[ ]"
            else
                selected_indices[$index]="[*]"
            fi
            break
        fi
    done
}

# Function for single-select menu
single_select_menu() {
    local placeholder="$1"
    shift
    options=("$@")
    selected=0
    search_term=""
    scroll_offset=0
    multi_select_mode="false"

    update_filtered_options

    while true; do
        display_menu
        IFS= read -rsn1 key
        if ! handle_key "$key"; then break; fi
        update_filtered_options
    done

    echo "You selected: ${filtered_options[$selected]}"

    selected_option=(${filtered_options[$selected]})
    export SELECTED_OPTION=$selected_option
}

# Function for multi-select menu
multi_select_menu() {
    local placeholder="$1"
    shift
    options=("$@")
    selected=0
    search_term=""
    scroll_offset=0
    multi_select_mode="true"
    selected_indices=()

    for _ in "${options[@]}"; do
        selected_indices+=("[ ]")
    done

    update_filtered_options

    while true; do
        display_menu
        IFS= read -rsn1 key
        if ! handle_key "$key"; then break; fi
        update_filtered_options
    done

    echo "You selected:"
    selected_options=()
    for index in "${!options[@]}"; do
        if [ "${selected_indices[$index]}" == "[*]" ]; then
            echo "  ${options[$index]}"
            selected_options+=("${options[$index]}")
        fi
    done

    export SELECTED_OPTIONS="${selected_options[*]}"
}

# Main script execution block for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Testing single-select menu..."
    sleep 1
    single_select_menu "Please select an option:" "Option 1" "Option 2" "Option 3" "Option 4" "Option 5" \
        "Option 6" "Option 7" "Option 8" "Option 9" "Option 10" "Option 11" "Option 12" "Option 13"

    echo "Testing multi-select menu..."
    sleep 1
    multi_select_menu "Select multiple options:" "Option 1" "Option 2" "Option 3" "Option 4" "Option 5" \
        "Option 6" "Option 7" "Option 8" "Option 9" "Option 10" "Option 11" "Option 12" "Option 13"
fi
