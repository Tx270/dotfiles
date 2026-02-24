#!/bin/bash

# system_monitor.sh - System monitoring for Debian
# Run as root with cron every 5 minutes

DISK_THRESHOLD=85
LOG_FILE="/var/log/system_monitor.log"
NOTIFICATION_INTERVAL=1800  # 30 min

REAL_USER="tx27"
DISPLAY=:0
XAUTHORITY="/home/$REAL_USER/.Xauthority"
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $REAL_USER)/bus"

export DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

TIMESTAMP_FILE="/tmp/sysmonitor.timestamp"

send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"

    echo "$(date '+%Y-%m-%d %H:%M:%S') - $title: $message" >> "$LOG_FILE"
    sudo -u $REAL_USER DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY \
        DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
        notify-send -u "$urgency" "$title" "$message"
}

should_notify() {
    if [ ! -f "$TIMESTAMP_FILE" ] || [ $(($(date +%s) - $(cat "$TIMESTAMP_FILE"))) -ge $NOTIFICATION_INTERVAL ]; then
        date +%s > "$TIMESTAMP_FILE"
        chmod 666 "$TIMESTAMP_FILE"
        return 0
    fi
    return 1
}

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# System checks
check_boot_errors() {
    local boot_errors=$(journalctl -b -p err..emerg --no-pager | grep -v "TLS handshake failed" | tail -n 10)
    if [ -n "$boot_errors" ] && should_notify; then
        send_notification "Boot errors detected" \
        "Errors found during boot. Check with:\n  journalctl -b -p err..alert" \
        "critical"
    fi
}

check_disk_usage() {
    local disks_over_threshold=$(df -h --output=target,pcent | grep -v "^/boot" | grep -v "^/dev" | awk '{sub(/%/,""); if ($2 > '$DISK_THRESHOLD' && $1 != "Mounted") print $1 " (" $2 "%)"}')
    if [ -n "$disks_over_threshold" ] && should_notify; then
        send_notification "High disk usage" \
        "Mount points exceeding ${DISK_THRESHOLD}%:\n$disks_over_threshold\n\nCheck with:\n  df -h" \
        "critical"
    fi
}

check_failed_services() {
    local failed_services=$(systemctl --failed --no-legend | wc -l)
    if [ "$failed_services" -gt 0 ] && should_notify; then
        local list=$(systemctl --failed --no-legend | awk '{print $1}')
        send_notification "Failed services" \
        "Detected $failed_services failed services:\n$list\n\nCheck with:\n  systemctl --failed" \
        "critical"
    fi
}

check_package_issues() {
    local broken_packages=$(dpkg -l | grep -E '^..H|^..R|^..W')
    if [ -n "$broken_packages" ] && should_notify; then
        local count=$(echo "$broken_packages" | wc -l)
        send_notification "Package issues" \
        "$count problematic packages detected.\nCheck with:\n  dpkg -l | grep -E '^..H|^..R|^..W'" \
        "normal"
    fi
}

check_updates() {
    apt-get update -qq > /dev/null
    local updates=$(apt-get -s upgrade | grep -P '^\d+ upgraded' | grep -o -P '^\d+')
    local security_updates=$(apt-get -s dist-upgrade | grep -i security | wc -l)

    if [ "$security_updates" -gt 0 ] && should_notify; then
        send_notification "Security updates available" \
        "$security_updates security updates ready.\nCheck with:\n  apt list --upgradable | grep security" \
        "critical"
    elif [ "$updates" -gt 0 ] && should_notify; then
        send_notification "System updates available" \
        "$updates system updates ready.\nCheck with:\n  apt list --upgradable" \
        "normal"
    fi
}

check_smart_status() {
    local failed_disks=""
    for disk in $(lsblk -d -o name | grep -v "loop\|ram" | tail -n +2); do
        if ! smartctl -H /dev/$disk | grep -q "PASSED"; then
            failed_disks="$failed_disks /dev/$disk"
        fi
    done

    if [ -n "$failed_disks" ] && should_notify; then
        send_notification "SMART disk issues" \
        "Disks with problems: $failed_disks\nCheck with:\n  smartctl -H /dev/sdX" \
        "critical"
    fi
}

check_syslog_errors() {
    if [ -f /var/log/syslog ]; then
        local recent_errors=$(grep -i "error\|fail\|critical" /var/log/syslog | tail -n 20)
        if [ -n "$recent_errors" ] && should_notify && [ $(echo "$recent_errors" | wc -l) -gt 10 ]; then
            send_notification "Syslog errors" \
            "Recent system errors found.\nCheck with:\n  grep -i 'error\\|fail\\|critical' /var/log/syslog" \
            "normal"
        fi
    fi
}

check_user_services() {
    local failed=$(sudo -u $REAL_USER XDG_RUNTIME_DIR=/run/user/$(id -u $REAL_USER) systemctl --user --failed --no-legend 2>/dev/null | wc -l)
    if [ "$failed" -gt 0 ] && should_notify; then
        local list=$(sudo -u $REAL_USER XDG_RUNTIME_DIR=/run/user/$(id -u $REAL_USER) systemctl --user --failed --no-legend 2>/dev/null | awk '{print $1}')
        send_notification "Failed user services" \
        "Detected $failed failed user services:\n$list\n\nCheck with:\n  systemctl --user --failed" \
        "normal"
    fi
}

check_xorg_errors() {
    local user_home="/home/$REAL_USER"
    local log="$user_home/.local/share/xorg/Xorg.0.log"
    if [ -f "$log" ]; then
        local count=$(grep -i "error\|fail\|fatal" "$log" | wc -l)
        if [ "$count" -gt 10 ] && should_notify; then
            send_notification "Xorg log errors" \
            "$count errors in Xorg log.\nCheck with:\n  grep -i 'error\\|fail\\|fatal' $log" \
            "normal"
        fi
    fi
}

check_home_space() {
    local usage=$(df -h /home/$REAL_USER | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$usage" -gt "$DISK_THRESHOLD" ] && should_notify; then
        send_notification "Home usage high" \
        "Home dir is ${usage}% full.\nCheck with:\n  df -h ~" \
        "critical"
    fi
}

check_tmp_files() {
    local large=$(find /tmp -type f -user "$REAL_USER" -size +100M 2>/dev/null | wc -l)
    if [ "$large" -gt 1 ] && should_notify; then
        send_notification "Large /tmp files" \
        "$large large temp files found.\nCheck with:\n  find /tmp -type f -user $REAL_USER -size +100M" \
        "normal"
    fi
}

check_user_processes() {
    if ! pgrep -u $REAL_USER -x "picom\|compton\|xcompmgr" >/dev/null && should_notify; then
        send_notification "Compositor not running" \
        "No compositor detected.\nCheck with:\n  pgrep -u $REAL_USER picom" \
        "normal"
    fi
}

# Run all checks
check_boot_errors
check_disk_usage
check_failed_services
check_package_issues
check_smart_status
check_syslog_errors
check_updates
check_user_services
check_xorg_errors
check_home_space
check_tmp_files
check_user_processes

