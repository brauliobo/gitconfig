#!/bin/bash
# Fix port forwarding issue after wg-quick@wg0 starts

# Function to detect the LAN interface
detect_lan_interface() {
  # Exclude interfaces: loopback, WireGuard, docker, veth, bridges, tunnels
  LAN_INTERFACE=$(ip -o -4 addr show scope global | grep -vE ' lo| wg| docker| veth| br-| tun| tap' | awk '{print $2}' | head -n1)

  if [ -z "$LAN_INTERFACE" ]; then
    echo "Error: Could not detect LAN interface."
    exit 1
  fi
  echo "Detected LAN interface: $LAN_INTERFACE"
}

# Function to get the default route associated with the LAN interface
get_lan_default_route() {
  DEFAULT_ROUTE=$(ip route show table main | grep "^default" | grep "$LAN_INTERFACE")
  if [ -z "$DEFAULT_ROUTE" ]; then
    echo "Error: Could not find default route for $LAN_INTERFACE."
    exit 1
  fi
  echo "Detected default route for $LAN_INTERFACE: $DEFAULT_ROUTE"
}

# Execute the functions
detect_lan_interface
get_lan_default_route

# Mark incoming connections on LAN interface and save the mark
iptables -t mangle -A PREROUTING -i "$LAN_INTERFACE" -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -i "$LAN_INTERFACE" -j CONNMARK --save-mark

# Restore the mark on outgoing packets
iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark

# Add the default route to table 100
ip route add $DEFAULT_ROUTE table 100

# Add policy routing rule with higher priority
ip rule add fwmark 1 lookup 100 priority 1000

# Flush routing cache
ip route flush cache
