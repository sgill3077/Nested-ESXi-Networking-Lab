# Lessons Learned

## Technical Lessons

* Bridged networking over Wi-Fi may fail in nested environments due to MAC address restrictions imposed by wireless infrastructure.
* VMware NAT networking provides a more reliable solution for home lab environments involving nested hypervisors.
* Nested virtualization often requires modifications to ESXi vSwitch security policies.
* Linux-hosted VMware Workstation environments can introduce permission-related networking challenges.

---

## Troubleshooting Lessons

* Effective troubleshooting should follow a structured, layer-by-layer approach.
* Verifying assumptions is often more valuable than repeatedly modifying configurations.
* Tools such as `vmkping`, `ip route`, `ip neighbor`, and `nmcli` provide critical visibility into different networking layers.
* Breaking the problem into smaller segments significantly reduces troubleshooting complexity.

---

## Professional Growth

This project reinforced the importance of understanding how infrastructure components interact rather than relying solely on implementation guides.

The most valuable outcome was developing confidence in diagnosing unfamiliar issues through systematic investigation and documentation.
