# Multi-Tier Infrastructure Troubleshooting KB

## Troubleshooting Methodology

Always validate in this order:

1. IP Address
2. Routing
3. Connectivity
4. DNS
5. Application / Load Balancer

---

## Common Issues

### ❌ No Internet Access

**Symptom:**  
`ping 8.8.8.8` fails

**Fix:**  
Ensure router VM has correct default gateway and NAT interface. For backend VMs:

- **web01 (VLAN10):**

```bash
ip route add default via 192.168.10.1
web02 (VLAN20):
ip route add default via 192.168.20.1
```

---

### ❌ DNS Not Resolving

Symptom:
curl google.com or curl web.lab fails

Fix:

```bash
Set DNS server on the VM:

/etc/resolv.conf → nameserver 192.168.10.1   # For VLAN10
/etc/resolv.conf → nameserver 192.168.20.1   # For VLAN20
```

---

### ❌ Packet Filtered / Connectivity Issues

Cause:
Firewall blocking forwarding or VLAN isolation misconfiguration

Fix:

```text
Configure firewalld zones correctly on router VM:
```

---

## Allow VLAN10 and VLAN20 interfaces in trusted zone

```bash
sudo firewall-cmd --zone=trusted --add-interface=ens38 --permanent
sudo firewall-cmd --zone=trusted --add-interface=ens39 --permanent
sudo firewall-cmd --reload
```

---

### ❌ 502 Bad Gateway

Cause:
Nginx cannot reach backend servers

Fix:

```text
Ensure SELinux allows nginx network connections:
setsebool -P httpd_can_network_connect 1
Verify nginx service is running:
systemctl enable --now nginx
```

---

### ❌ Backend Not Reachable

Cause:
VLAN misconfiguration, firewall, or backend down

Fix:

```bash
Check VLAN assignment in ESXi and router VM
Ensure backend VM interface is up and IP assigned correctly:
web01: 192.168.10.50/24, gateway 192.168.10.1
web02: 192.168.20.50/24, gateway 192.168.20.1
Ping router gateway from backend:
ping 192.168.10.1   # web01
ping 192.168.20.1   # web02
```

---

### ❌ Load Balancing Not Working

Cause:

proxy_pass misconfigured
Upstream backend unreachable

Fix:

```bash
Ensure nginx upstream backend is configured with VLAN IPs:
upstream backend {
    server 192.168.10.50;   # web01
    server 192.168.20.50;   # web02
}
Test load balancing:
for i in {1..10}; do curl -s http://web.lab; echo; done
Validate round-robin responses from both backends
```

---

## 🛠️ Troubleshooting: ESXi VLAN Tagging Issue

### 🔍 Problem Summary

During initial VLAN testing, backend VMs (Web01 and Web02) could not reach their respective gateways:

- Web01 → could not reach 192.168.10.1
- Web02 → could not reach 192.168.20.1

Even though VLAN interfaces (`ens33.10`, `ens33.20`) were configured correctly inside Fedora, **no tagged traffic was arriving at the router**.

---

### 🔎 Root Cause

Both backend NICs in ESXi were configured as **untagged** (Access mode).  
In this mode, ESXi **strips VLAN tags** before delivering frames to the VM.

This prevented Linux VLAN interfaces from ever seeing 802.1Q‑tagged packets.

---

### 🧩 Fix Implemented

The ESXi port group was changed to:

```text
VLAN ID: 4095 (Trunk Mode)
This instructs ESXi to:
```

- Pass VLAN tags through untouched
- Allow VMs to perform their own tagging
- Support multiple VLANs on a single vNIC

---

### ✅ Result

After switching to trunk mode:

- Web01 successfully reached `192.168.10.1`
- Web02 successfully reached `192.168.20.1`
- Router VLAN interfaces (`ens38.10`, `ens39.20`) came online
- Multi-VLAN routing and load balancing worked as designed

---

### 📘 Takeaway

This issue mirrors real enterprise troubleshooting:

> Virtual switches behave like physical switches — if the uplink is not a trunk, VLANs will not pass.

Understanding this distinction is critical in hybrid virtual networking environments.

---
