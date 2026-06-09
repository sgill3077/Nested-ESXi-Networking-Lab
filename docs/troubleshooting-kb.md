# Troubleshooting Guide: Nested ESXi Networking

## Problem Statement

A nested Fedora guest VM running inside VMware ESXi (hosted on VMware Workstation) failed to access external networks.

Symptoms included:

* `Network is unreachable`
* `Destination Host Unreachable`
* DHCP failure during connection activation

---

## Environment Context

* Physical Host: Fedora Linux
* Hypervisor 1: VMware Workstation (VMnet8 NAT)
* Hypervisor 2: VMware ESXi (nested)
* Guest VM: Fedora Linux
* Virtual Switch: vSwitch0

---

## Root Causes Identified

### 1. VMware Workstation Network Mode

Bridged networking was unreliable over Wi-Fi due to MAC address filtering.

**Resolution:** Switched to NAT (VMnet8).

---

### 2. ESXi vSwitch Security Policies

Default ESXi settings blocked nested VM traffic.

**Resolution:**

* Promiscuous Mode: Accept
* MAC Address Changes: Accept
* Forged Transmits: Accept

---

### 3. DHCP Failure in Guest VM

Nested DHCP requests failed due to multi-layer virtualization.

**Resolution:** Used static IP or rebuilt NetworkManager profile.

---

### 4. Linux Host Virtual Network Permissions

VMware virtual network devices required permission adjustments for proper packet forwarding.

**Resolution:**

```bash id="fix1"
sudo chmod a+rw /dev/vmnet*
```

---

## Troubleshooting Methodology

The issue was resolved using a layered approach:

1. Verify physical host connectivity
2. Verify VMware Workstation NAT functionality
3. Verify ESXi management network (`vmkping`)
4. Verify vSwitch and port group configuration
5. Verify guest interface state (`ip link`, `nmcli`)
6. Verify IP configuration (`ip addr`, `ip route`)
7. Verify ARP resolution (`ip neighbor`)
8. Verify external connectivity (`ping`, `traceroute`)

---

## Key Insight

Nested virtualization networking failures are almost always caused by **layer mismatch between virtual switches, NAT boundaries, and MAC address handling**, not the guest OS itself.
