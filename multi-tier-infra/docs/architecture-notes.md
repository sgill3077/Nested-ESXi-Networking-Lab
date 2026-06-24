# Architecture Notes

## Components

- Router VM:
  - NAT gateway
  - DNS server (dnsmasq)
  - Reverse proxy (nginx)

- Backend:
  - web01
  - web02

---

## Traffic Flow

Client → DNS → Router → Nginx → Backend → Response

---

## Network Segmentation

- External Network: 192.168.254.0/24
- DMZ Network: 192.168.247.0/24

---

## Load Balancing Strategy

- Nginx upstream (round-robin)
- Stateless backend servers

---

## Key Design Decisions

- Use firewalld instead of iptables
- Internal DNS for service discovery
- Reverse proxy for centralized access
