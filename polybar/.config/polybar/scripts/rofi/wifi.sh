#!/usr/bin/env bash

wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
	toggle="󰖪  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
	toggle="󰖩  Enable Wi-Fi"
fi

chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )
read -r chosen_id <<< "${chosen_network:3}"

if [ "$chosen_network" = "" ]; then
	exit
elif [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
	nmcli radio wifi on
	date +%s > /tmp/network_event_timestamp
elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
	nmcli radio wifi off
else
	success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
	fail_message="Failed to connect to \"$chosen_id\"."

	saved_connections=$(nmcli -g NAME connection)
	if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
		if nmcli connection up id "$chosen_id" | grep -q "successfully"; then
			date +%s > /tmp/network_event_timestamp
			notify-send "Connection Established" "$success_message"
		else
			notify-send "Connection Failed" "$fail_message"
		fi
	else
		if [[ "$chosen_network" =~ "" ]]; then
			wifi_password=$(rofi -dmenu -p "Password: " )
		fi
		if nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep -q "successfully"; then
			date +%s > /tmp/network_event_timestamp
			notify-send "Connection Established" "$success_message"
		else
			notify-send "Connection Failed" "$fail_message"
		fi
	fi
fi
