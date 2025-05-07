#!/usr/bin/env bash

# Constants
divider="---------"
goback="Back"

# Run bluetoothctl with timeout to prevent hanging if bluetoothd is not available
btctl() {
    timeout 1 bluetoothctl "$@"
}

# Checks if bluetooth controller is powered on
power_on() {
    if btctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles power state
toggle_power() {
    if power_on; then
        btctl power off
        show_menu
    else
        if rfkill list bluetooth | grep -q 'blocked: yes'; then
            rfkill unblock bluetooth && sleep 3
        fi
        btctl power on
        show_menu
    fi
}

scan_on() {
    if btctl show | grep -q "Discovering: yes"; then
        echo "Scan: on"
        return 0
    else
        echo "Scan: off"
        return 1
    fi
}

toggle_scan() {
    if scan_on; then
        kill $(pgrep -f "bluetoothctl --timeout 5 scan on") 2>/dev/null
        btctl scan off
        show_menu
    else
        btctl --timeout 5 scan on
        echo "Scanning..."
        show_menu
    fi
}

pairable_on() {
    if btctl show | grep -q "Pairable: yes"; then
        echo "Pairable: on"
        return 0
    else
        echo "Pairable: off"
        return 1
    fi
}

toggle_pairable() {
    if pairable_on; then
        btctl pairable off
        show_menu
    else
        btctl pairable on
        show_menu
    fi
}

discoverable_on() {
    if btctl show | grep -q "Discoverable: yes"; then
        echo "Discoverable: on"
        return 0
    else
        echo "Discoverable: off"
        return 1
    fi
}

toggle_discoverable() {
    if discoverable_on; then
        btctl discoverable off
        show_menu
    else
        btctl discoverable on
        show_menu
    fi
}

device_connected() {
    device_info=$(btctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_connection() {
    if device_connected "$1"; then
        btctl disconnect "$1"
        device_menu "$device"
    else
        btctl connect "$1"
        device_menu "$device"
    fi
}

device_paired() {
    device_info=$(btctl info "$1")
    if echo "$device_info" | grep -q "Paired: yes"; then
        echo "Paired: yes"
        return 0
    else
        echo "Paired: no"
        return 1
    fi
}

toggle_paired() {
    if device_paired "$1"; then
        btctl remove "$1"
        device_menu "$device"
    else
        btctl pair "$1"
        device_menu "$device"
    fi
}

device_trusted() {
    device_info=$(btctl info "$1")
    if echo "$device_info" | grep -q "Trusted: yes"; then
        echo "Trusted: yes"
        return 0
    else
        echo "Trusted: no"
        return 1
    fi
}

toggle_trust() {
    if device_trusted "$1"; then
        btctl untrust "$1"
        device_menu "$device"
    else
        btctl trust "$1"
        device_menu "$device"
    fi
}

print_status() {
    if power_on; then
        printf ''
        paired_devices_cmd="devices Paired"
        if (( $(echo "$(btctl version | cut -d ' ' -f 2) < 5.65" | bc -l) )); then
            paired_devices_cmd="paired-devices"
        fi

        mapfile -t paired_devices < <(btctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
        counter=0

        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                device_alias=$(btctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)
                if [ $counter -gt 0 ]; then
                    printf ", %s" "$device_alias"
                else
                    printf " %s" "$device_alias"
                fi
                ((counter++))
            fi
        done
        printf "\n"
    else
        echo "%{F#cba6f7}%{F-}"
    fi
}

device_menu() {
    device=$1
    device_name=$(echo "$device" | cut -d ' ' -f 3-)
    mac=$(echo "$device" | cut -d ' ' -f 2)

    if device_connected "$mac"; then
        connected="Connected: yes"
    else
        connected="Connected: no"
    fi
    paired=$(device_paired "$mac")
    trusted=$(device_trusted "$mac")
    options="$connected\n$paired\n$trusted\n$divider\n$goback\nExit"

    chosen="$(echo -e "$options" | $rofi_command "$device_name")"

    case "$chosen" in
        "" | "$divider")
            echo "No option chosen."
            ;;
        "$connected")
            toggle_connection "$mac"
            ;;
        "$paired")
            toggle_paired "$mac"
            ;;
        "$trusted")
            toggle_trust "$mac"
            ;;
        "$goback")
            show_menu
            ;;
    esac
}

show_menu() {
    if ! btctl show &>/dev/null; then
        echo -e "Bluetooth unavailable\nExit" | $rofi_command "Bluetooth"
        exit 1
    fi

    if power_on; then
        power="Power: on"
        devices=$(btctl devices | grep Device | cut -d ' ' -f 3-)
        scan=$(scan_on)
        pairable=$(pairable_on)
        discoverable=$(discoverable_on)
        options="$devices\n$divider\n$power\n$scan\n$pairable\n$discoverable\nExit"
    else
        power="Power: off"
        options="$power\nExit"
    fi

    chosen="$(echo -e "$options" | $rofi_command "Bluetooth")"

    case "$chosen" in
        "" | "$divider")
            echo "No option chosen."
            ;;
        "$power")
            toggle_power
            ;;
        "$scan")
            toggle_scan
            ;;
        "$discoverable")
            toggle_discoverable
            ;;
        "$pairable")
            toggle_pairable
            ;;
        *)
            device=$(btctl devices | grep "$chosen")
            if [[ $device ]]; then device_menu "$device"; fi
            ;;
    esac
}

rofi_command="rofi -dmenu $* -p"

case "$1" in
    --status)
        print_status
        ;;
    *)
        show_menu
        ;;
esac

