#!/bin/bash
# Lab Validation Script
# Run on Router VM

echo "=== Lab Validation Start ==="
echo ""

# VLAN10: Web01
WEB01_IP="192.168.10.50"
WEB01_GW="192.168.10.1"

# VLAN20: Web02
WEB02_IP="192.168.20.50"
WEB02_GW="192.168.20.1"

echo "1. Ping gateways"
ping -c 3 $WEB01_GW && echo "VLAN10 gateway reachable" || echo "VLAN10 gateway unreachable"
ping -c 3 $WEB02_GW && echo "VLAN20 gateway reachable" || echo "VLAN20 gateway unreachable"
echo ""

echo "2. Ping backend servers"
ping -c 3 $WEB01_IP && echo "Web01 reachable" || echo "Web01 unreachable"
ping -c 3 $WEB02_IP && echo "Web02 reachable" || echo "Web02 unreachable"
echo ""

echo "3. Test VLAN isolation"
sshpass -p "<web01-password>" ssh -o StrictHostKeyChecking=no root@$WEB01_IP "ping -c 3 $WEB02_IP" &>/dev/null
if [ $? -ne 0 ]; then
    echo "VLAN isolation OK: Web01 cannot reach Web02"
else
    echo "VLAN isolation FAIL: Web01 can reach Web02"
fi
sshpass -p "<web02-password>" ssh -o StrictHostKeyChecking=no root@$WEB02_IP "ping -c 3 $WEB01_IP" &>/dev/null
if [ $? -ne 0 ]; then
    echo "VLAN isolation OK: Web02 cannot reach Web01"
else
    echo "VLAN isolation FAIL: Web02 can reach Web01"
fi
echo ""

echo "4. Test nginx load balancer"
for i in {1..6}; do
    curl -s http://web.lab
    echo ""
done
echo ""

echo "5. Check router interfaces"
ip a show ens38
ip a show ens38.10
ip a show ens38.20
ip a show ens37
echo ""

echo "6. Routing table"
ip route show
echo ""

echo "=== Lab Validation End ==="
