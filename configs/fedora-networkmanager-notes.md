# Fedora NetworkManager Notes (Nested ESXi Lab)

## Purpose

This file documents NetworkManager behavior and troubleshooting steps used inside nested Fedora virtual machines.

---

## Device Status Checks

```bash
nmcli device status
ip link
ip addr
```

---

## Connection Management

### Show connections

```bash
nmcli connection show
```

### Bring connection down/up

```bash
nmcli connection down "<name>"
nmcli connection up "<name>"
```

### Add DHCP connection

```bash
nmcli connection add type ethernet con-name "lab-dhcp" ifname ens34 ipv4.method auto
```

---

## Common Issues Observed

### 1. DHCP Failure

* Symptom: "IP configuration could not be reserved"
* Cause: upstream NAT or DHCP lease failure in nested network
* Resolution: verify VMware Workstation VMnet8 DHCP service

---

### 2. Missing DHCP Client Tools

* Symptom:

  ```
  dhclient: command not found
  ```
* Cause: minimal Fedora install
* Resolution: rely on NetworkManager (`nmcli`) instead of dhclient

---

### 3. Device Connected but No IP

* Symptom: interface shows UP but no IPv4 address
* Cause: DHCP failure or misconfigured connection profile
* Resolution: recreate connection profile using nmcli

---

## Routing Debug

```bash
ip route
ip neighbor
```

---

## Key Insight

In nested environments, DHCP failures are often caused by upstream virtualization layers rather than the guest OS itself.
