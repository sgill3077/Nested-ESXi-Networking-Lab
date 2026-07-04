
# Fedora NetworkManager Notes (Nested ESXi Lab)

## Purpose

This document summarizes common NetworkManager commands and troubleshooting steps for Fedora virtual machines running inside nested ESXi environments.

---

# Quick Network Diagnostics

```bash
# Interface status
nmcli device status
ip link show
ip addr show
ip -4 addr show
ip -6 addr show

# Connection profiles
nmcli connection show
nmcli connection show --active

# NetworkManager
nmcli general status

# Routing
ip route
ip -6 route
ip neighbor

# DNS
resolvectl status

# Hostname
hostnamectl

# Verify default gateway
ping -c4 $(ip route | awk '/default/ {print $3}')

# Internet connectivity
ping -c4 8.8.8.8
ping -c4 google.com

# Resource utilization
free -h
vmstat 1 5
df -h

# NetworkManager logs
journalctl -u NetworkManager --since "30 min ago"
journalctl -fu NetworkManager
```

---

# Interface Administration

## Show interfaces

```bash
ip link
ip -details link
ip -s link
```

## Show a specific interface

```bash
ip addr show dev ens34
ip link show ens34
```

## Bring interface down/up

```bash
sudo ip link set ens34 down
sudo ip link set ens34 up
```

---

# NetworkManager Device Commands

## Device status

```bash
nmcli device status
```

## Device details

```bash
nmcli device show
nmcli device show ens34
```

## Disconnect / reconnect interface

```bash
nmcli device disconnect ens34
nmcli device connect ens34
```

## Reapply configuration

```bash
nmcli device reapply ens34
```

## Reload NetworkManager

```bash
nmcli general reload
```

---

# Connection Management

## List connections

```bash
nmcli connection show
nmcli connection show --active
```

## View connection details

```bash
nmcli connection show "lab-dhcp"
```

## Show IPv4 settings

```bash
nmcli --fields ipv4 connection show "lab-dhcp"
```

## Bring connection down/up

```bash
nmcli connection down "lab-dhcp"
nmcli connection up "lab-dhcp"
```

## Delete a connection

```bash
nmcli connection delete "lab-dhcp"
```

## Create a DHCP connection

```bash
nmcli connection add \
    type ethernet \
    con-name "lab-dhcp" \
    ifname ens34 \
    ipv4.method auto
```

---

# DHCP Operations

## Renew DHCP lease

```bash
nmcli connection down "lab-dhcp"
nmcli connection up "lab-dhcp"
```

## Restart NetworkManager

```bash
sudo systemctl restart NetworkManager
```

## View DHCP log messages

```bash
journalctl -u NetworkManager | grep -i dhcp
```

---

# Static IP Configuration

## Assign a static IP

```bash
nmcli connection modify "lab-dhcp" \
    ipv4.addresses 192.168.1.50/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "8.8.8.8 1.1.1.1" \
    ipv4.method manual
```

## Activate changes

```bash
nmcli connection up "lab-dhcp"
```

## Return to DHCP

```bash
nmcli connection modify "lab-dhcp" ipv4.method auto
nmcli connection up "lab-dhcp"
```

---

# IP Address Management

## Show addresses

```bash
ip addr
ip -4 addr
ip -6 addr
```

## Flush addresses

```bash
sudo ip addr flush dev ens34
```

## Add a temporary IP

```bash
sudo ip addr add 192.168.1.100/24 dev ens34
```

## Remove a temporary IP

```bash
sudo ip addr del 192.168.1.100/24 dev ens34
```

---

# Routing

## Show routing table

```bash
ip route
ip -6 route
```

## Show default gateway

```bash
ip route | grep default
```

## Show route to destination

```bash
ip route get 8.8.8.8
```

## Add temporary default route

```bash
sudo ip route add default via 192.168.1.1
```

## Delete default route

```bash
sudo ip route del default
```

---

# Neighbor / ARP Cache

## Show neighbors

```bash
ip neighbor
ip neigh
```

## Flush neighbor cache

```bash
sudo ip neigh flush all
```

---

# DNS

## Show resolver configuration

```bash
resolvectl status
cat /etc/resolv.conf
```

## Show configured DNS servers

```bash
resolvectl dns
```

## Resolve hostname

```bash
resolvectl query google.com
```

## Test DNS

```bash
dig google.com
host google.com
```

---

# Connectivity Testing

## Gateway

```bash
ping -c4 <gateway-ip>
```

## Internet

```bash
ping -c4 8.8.8.8
```

## DNS

```bash
ping -c4 google.com
```

## Trace path

```bash
tracepath google.com
```

## Traceroute (if installed)

```bash
traceroute google.com
```

---

# Socket & Port Information

## Listening ports

```bash
ss -tulnp
```

## Established connections

```bash
ss -tun
```

## All sockets

```bash
ss -a
```

---

# Interface Hardware Information

## MAC addresses

```bash
ip link
```

## Driver information

```bash
ethtool -i ens34
```

## Link status

```bash
ethtool ens34
```

---

# NetworkManager Service

## Service status

```bash
systemctl status NetworkManager
```

## Restart service

```bash
sudo systemctl restart NetworkManager
```

## Enable at boot

```bash
sudo systemctl enable NetworkManager
```

---

# Logs

## NetworkManager

```bash
journalctl -u NetworkManager
```

## Recent logs

```bash
journalctl -u NetworkManager --since "1 hour ago"
```

## Live logs

```bash
journalctl -fu NetworkManager
```

---

# System Resource Monitoring

## Memory

```bash
free -h
vmstat 1 5
```

## CPU

```bash
top
```

or

```bash
htop
```

## Disk

```bash
df -h
lsblk
```

---

# Common Issues

## 1. DHCP Failure

**Symptoms**

- `IP configuration could not be reserved`
- No IPv4 address assigned

**Possible Causes**

- VMware Workstation VMnet8 DHCP service stopped
- Nested ESXi networking issue
- Incorrect virtual switch or port group configuration

**Resolution**

- Verify VMnet8 DHCP service
- Verify NAT configuration
- Reconnect the NetworkManager profile
- Recreate the connection profile if necessary

---

## 2. Missing DHCP Client

**Symptoms**

```text
dhclient: command not found
```

**Cause**

Minimal Fedora installations do not install `dhclient`.

**Resolution**

Use NetworkManager (`nmcli`) for DHCP operations.

---

## 3. Interface Connected but No IP

**Symptoms**

```bash
nmcli device status
```

Shows:

```text
connected
```

But:

```bash
ip addr
```

Shows no IPv4 address.

**Resolution**

```bash
nmcli connection delete "lab-dhcp"

nmcli connection add \
    type ethernet \
    con-name "lab-dhcp" \
    ifname ens34 \
    ipv4.method auto

nmcli connection up "lab-dhcp"
```

---

## 4. Missing Default Route

Verify:

```bash
ip route
```

If no default route exists:

- Verify DHCP
- Verify gateway assignment
- Reconnect the interface

---

## 5. DNS Failure

Symptoms:

- Internet reachable via IP
- Hostnames fail to resolve

Verify:

```bash
resolvectl status
cat /etc/resolv.conf
```

---

# All-in-One Troubleshooting Commands

```bash
hostnamectl

nmcli general status
nmcli device status
nmcli device show
nmcli connection show
nmcli connection show --active

ip link
ip addr
ip route
ip neighbor

resolvectl status

ss -tulnp

systemctl status NetworkManager

journalctl -u NetworkManager --since "30 min ago"

free -h
vmstat 1 5
df -h

ping -c4 8.8.8.8
ping -c4 google.com

tracepath google.com
```

---

# Key Insight

In nested virtualization environments (VMware Workstation → ESXi → Fedora), DHCP failures are frequently caused by upstream virtualization networking (VMnet, vSwitches, port groups, or NAT configuration) rather than the Fedora guest operating system. Always verify the networking stack from the outermost layer inward before troubleshooting the guest.
````
