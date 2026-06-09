# ESXi + Linux Networking Cheat Sheet

## ESXi (ESXCLI)

```bash id="esx1"
esxcli network nic list
esxcli network vswitch standard list
esxcli network vm list
esxcli network vm port list -w <world-id>
vmkping -I vmk0 8.8.8.8
```

---

## VMware Host / VM Network Checks

```bash id="vmw1"
ip address show dev vmnet8
systemctl restart vmware.service
```

---

## Fedora / Linux Networking (Guest VM)

```bash id="lin1"
ip link
ip addr
ip route
ip neighbor
```

---

## NetworkManager (nmcli)

```bash id="nm1"
nmcli device status
nmcli connection show

nmcli connection down "Wired Static"
nmcli connection up "Wired Static"

nmcli connection add type ethernet con-name "lab-dhcp" ifname ens34 ipv4.method auto
```

---

## Connectivity Testing

```bash id="test1"
ping -c 3 8.8.8.8
ping -c 3 192.168.254.2
traceroute 8.8.8.8
nc -zv 192.168.254.129 443
```
