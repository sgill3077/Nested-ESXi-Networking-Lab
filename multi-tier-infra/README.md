# Nested ESXi Infrastructure Lab (Fedora Linux)

![Linux](https://img.shields.io/badge/Linux-Fedora-blue)
![VMware](https://img.shields.io/badge/VMware-ESXi-orange)
![Networking](https://img.shields.io/badge/Networking-Lab-green)
![Nginx](https://img.shields.io/badge/Nginx-Reverse%20Proxy-brightgreen)
![DNS](https://img.shields.io/badge/DNS-dnsmasq-yellow)

---

## 📌 Overview

This project demonstrates a **full-stack homelab infrastructure** built on Fedora Linux using nested VMware ESXi.

It evolves from basic virtualization into a **production-style multi-tier architecture**, including networking, firewalling, VLAN segmentation, and load balancing.

---

## 🧱 Lab Evolution

### 🔹 Phase 1 — Virtualization (ESXi)

- Nested ESXi deployment on Fedora
- Virtual networking setup
- VM provisioning and management

---

### 🔹 Phase 2 — Networking & Routing (Updated)

- Linux-based **router VM as jump box**
- NAT configuration (masquerade)
- VLAN segmentation:
  - **VLAN10** → Web01 (backend, only reachable via router)
  - **VLAN20** → Web02 (backend, only reachable via router)
- NAT (.247) network is reserved for router host access

---

### 🔹 Phase 3 — Security (Firewall)

- firewalld zones (DMZ, internal)
- Policy-based forwarding
- VLAN isolation enforced (Web01 cannot reach Web02 and vice versa)

---

### 🔹 Phase 4 — Infrastructure Services

Extended the lab into a multi-tier infrastructure by implementing:

- Internal DNS using `dnsmasq`
- Nginx reverse proxy for centralized access
- Load balancing across multiple backend servers (Web01 & Web02)
- Segmented DMZ-based architecture via VLANs

---

## 🏗️ High-Level Architecture (Click to Expand)

<details>
<summary><strong>Logical Topology</strong></summary>

![Architecture Diagram](./assets/architecture.png)

### Logical Layout

```bash
                                                         LAB NETWORK TOPOLOGY

                        ┌──────────────────────────────────────────────────────────────────────────────────────┐
                        │                                    Fedora Host                                       │
                        │                            Runs Nested VMware ESXi & Router VM                       │
                        └───────────────────────────────────────┬──────────────────────────────────────────────┘
                                                                │
                                              ESXi vSwitch (802.1Q Trunk • VLAN 4095)
                                                                │
                                  ┌─────────────────────────────┼───────────────────────────────────┐
                                  │                             │                                   │
                                  │                             │                                   │
                                  ▼                             ▼                                   ▼
                         ┌───────────────────┐         ┌───────────────────┐              ┌───────────────────┐
                         │     Router VM     │         │      Web01 VM     │              │      Web02 VM     │
                         │      Fedora       │         │      VLAN 10      │              │      VLAN 20      │
                         └─────────┬─────────┘         └───────────────────┘              └───────────────────┘
                                   │
                                   │
                         ┌─────────┴──────────────────────────────────────────────────────────────────────────┐
                         │                             Router VM Network Interfaces                           │
                         ├────────────────────────────────────────────────────────────────────────────────────┤
                         │ ens37                    WAN / NAT             192.168.254.131                     │
                         │ ens38 & ens39           802.1Q Trunk           VLANs 10, 20                        │
                         │       ├── ens38.10                             192.168.10.1   (Gateway - VLAN 10)  │
                         │       └── ens39.20                             192.168.20.1   (Gateway - VLAN 20)  │
                         └────────────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │
                                   ├──────────────────────────────┐
                                   │                              │
                                   ▼                              ▼
                         ┌─────────────────────┐         ┌─────────────────────┐
                         │      VLAN 10        │         │      VLAN 20        │
                         │ 192.168.10.0/24     │         │ 192.168.20.0/24     │
                         │ Gateway: .10.1      │         │ Gateway: .20.1      │
                         │       Web01         │         │       Web02         │
                         └─────────────────────┘         └─────────────────────┘


                               Router VM Services
                               ──────────────────
                               • IP Forwarding
                               • nftables / iptables NAT
                               • Nginx Reverse Proxy
                               • dnsmasq DNS
```

### Traffic Flow

1. Client → Router NAT (247.50)
2. Router → Nginx Reverse Proxy
3. Nginx → Web01 (VLAN10) or Web02 (VLAN20)
4. Backend servers isolated from each other via firewalld

### 📋 Network Details & Architecture

- **VLAN Isolation:** Strict firewall rules ensure backend servers (`Web01` and `Web02`) are isolated from each other and the external network, making them reachable _only_ through the Router/Jump Box.
- **Traffic Flow:**
  - Inbound requests hit the Router VM's external NAT interface (`192.168.247.50`).
  - An **Nginx Reverse Proxy** acts as a load balancer on the Router VM, distributing incoming traffic across both backend web servers.

---

### 🛠️ Interface Mapping Reference

| Component     | Interface Role     | Subnet / IP         |
| :------------ | :----------------- | :------------------ |
| **Router VM** | External WAN (NAT) | `192.168.247.50/24` |
| **Router VM** | VLAN 10 Gateway    | `192.168.10.1/24`   |
| **Router VM** | VLAN 20 Gateway    | `192.168.20.1/24`   |
| **Web01**     | Backend Node       | `192.168.10.50/24`  |
| **Web02**     | Backend Node       | `192.168.20.50/24`  |

</details>

---

## 📸 Validation Screenshots (Click to Expand)

<details>
<summary><strong>1. Load Balancing Verification</strong></summary>

Demonstrates nginx distributing requests across backend servers (web01 & web02).

![Load Balancing](./assets/load-balancing-proof.png)

</details>

---

<details>
<summary><strong>2. DNS Resolution (web.lab)</strong></summary>

Confirms internal DNS resolution via dnsmasq.

![DNS Resolution](./assets/dns-resolution.png)

</details>

---

<details>
<summary><strong>3. Router Services Status</strong></summary>

Verifies nginx and dnsmasq are running on the router VM.

![Router Services](./assets/router-services.png)

</details>

---

<details>
<summary><strong>4. Backend Server Verification</strong></summary>

Direct access to backend servers confirms individual node availability.

![Backend Servers](./assets/backend-servers.png)

</details>

---

<details>
<summary><strong>5. Network Connectivity</strong></summary>

Validates network connectivity and routing from the backend VM, including default gateway and external reachability.

![Network Connectivity](./assets/network-connectivity.png)

</details>

---

## 🌐 Key Features

- Nested virtualization (ESXi on Fedora)
- Multi-network design with VLAN segmentation (VLAN10 / VLAN20)
- NAT routing and jump-box router
- Firewall segmentation using firewalld
- VLAN isolation enforced
- Internal DNS resolution
- Reverse proxy and load balancing
- Real-world troubleshooting scenarios

---

## 🧠 Key Skills Demonstrated

- Linux system administration
- Network design and troubleshooting
- VLAN and firewall configuration
- DNS and name resolution
- Reverse proxy and load balancing
- Infrastructure debugging and root cause analysis

---

## 📂 Project Structure

```text
── multi-tier-infra
│   ├── assets
│   │   ├── architecture.png
│   │   ├── backend-servers.png
│   │   ├── dns-resolution.png
│   │   ├── load-balancing-proof.png
│   │   ├── network-connectivity.png
│   │   └── router-services.png
│   ├── configs
│   │   ├── dnsmasq.conf
│   │   ├── firewalld.conf
│   │   └── nginx.conf
│   ├── docs
│   │   ├── architecture-notes.md
│   │   └── troubleshooting-kb.md
│   └── README.md
```

---

## 📈 Outcome

This project demonstrates the ability to build, scale, and troubleshoot a multi-layered infrastructure stack mimicking enterprise patterns used in:

DevOps
Infrastructure Automation
Systems Engineering

With VLAN isolation, jump-box routing, and load balancing, it mirrors production-style architecture.

## 📌 Resume Summary

```text
Built a nested ESXi lab on Fedora Linux with multi-tier VLAN segmentation, a jump-box router, firewall-based isolation, internal DNS using dnsmasq, and an Nginx reverse proxy load balancing across backend servers. Implemented and debugged 802.1Q VLAN tagging inside ESXi, resolving a trunking issue that prevented backend connectivity.
```

---

## Future Enhancements

- Automated SSL/TLS Termination (Local Root Authority Certificates)
- Containerized Microservice Pods (Podman/Docker engine integrations)
- Centralized Telemetry Logging (Prometheus metric collectors & Grafana interfaces)
- Infrastructure as Code (Automating ESXi deployment maps with Terraform/Ansible)

---
