# Network Topology

## Logical Topology

```text
Physical Fedora Laptop (Wi-Fi)
        ↓
VMware Workstation (VMnet8 NAT)
        ↓
Nested ESXi Host
        ↓
vSwitch0 → VM Network
        ↓
Nested Fedora Guest VM
```

---

## Components

### Physical Host

* Fedora Linux laptop connected to the Internet over Wi-Fi.

### VMware Workstation

* Hosts the nested ESXi environment.
* Uses VMnet8 NAT networking to provide upstream connectivity.

### Nested ESXi Host

* Provides virtualization services for downstream guest virtual machines.
* Uses `vSwitch0` and the `VM Network` port group.

### Nested Fedora Guest VM

* Used as a test workload to validate networking and Internet connectivity.

---

## Addressing Scheme

| Component              | Example Address |
| ---------------------- | --------------- |
| VMware NAT Gateway     | 192.168.254.2   |
| ESXi Management (vmk0) | 192.168.254.129 |
| Fedora Guest VM        | 192.168.254.150 |

---

## Traffic Flow

Fedora Guest VM → ESXi vSwitch0 → ESXi Host → VMware Workstation NAT → Physical Fedora Laptop → Internet
