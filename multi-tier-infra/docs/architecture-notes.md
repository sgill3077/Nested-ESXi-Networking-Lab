# Architecture Notes

## Components

- **Router VM:**
  - NAT gateway
  - DNS server (`dnsmasq`)
  - Reverse proxy & load balancer (`nginx`)
  - Interfaces:
    - `ens37` → External NAT (192.168.254.131/24)
    - `ens38` → VLAN10 (192.168.10.1/24)
    - `ens39` → VLAN20 (192.168.20.1/24)

- **Backend VMs:**
  - **web01** → VLAN10 (192.168.10.50)
  - **web02** → VLAN20 (192.168.20.50)

---

## Traffic Flow

Client → DNS (Router) → Nginx → Upstream Backend (web01 & web02) → Response

- Internal DNS (`web.lab`) resolves to router IP (192.168.254.131)
- Nginx performs round-robin load balancing
- VLAN isolation ensures backend servers cannot directly communicate across VLANs

---

## Network Segmentation

- **External Network:** 192.168.254.0/24 (NAT for router VM)
- **VLAN10 (DMZ1):** 192.168.10.0/24 (web01)
- **VLAN20 (DMZ2):** 192.168.20.0/24 (web02)

---

## Load Balancing Strategy

- Nginx upstream configured with backend servers (web01 + web02)
- Round-robin distribution
- Stateless backend nodes for simplicity

---

## Key Design Decisions

- VLAN-based segmentation for backend isolation
- Router VM acts as a jump box and central gateway
- Use `firewalld` zones for traffic control instead of raw `iptables`
- Internal DNS for service discovery (`web.lab`)
- Reverse proxy for centralized access to backend services
