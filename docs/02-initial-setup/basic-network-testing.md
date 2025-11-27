# Basic Network Testing and Verification

Comprehensive testing procedures to verify infrastructure setup and connectivity.

## Prerequisites

- All hardware configured and powered on
- OPNsense firewall initialized
- Switches configured with VLANs
- Proxmox cluster running
- Test device on VLAN 20 (Fellowship) or VLAN 10 (Rivendell)

## Essential Testing Tools

```bash
# Linux/macOS
ping          # ICMP connectivity test
traceroute    # Path analysis to destination
nslookup      # DNS query tool
ip/ifconfig   # Interface configuration
arp           # ARP table inspection
netstat       # Network statistics
tcpdump       # Packet capture
iperf3        # Bandwidth testing
nmap          # Port scanning

# Windows
ping          # Same as Linux
tracert       # Windows traceroute equivalent
nslookup      # DNS queries
ipconfig      # Interface config (Windows)
netsh         # Advanced network diagnostics
iperf3        # Bandwidth testing
```

## Phase 1: Basic Connectivity Tests

### 1.1 Local Device Network Verification

```bash
# Check own interface status
ip link show
# or (macOS/older Linux)
ifconfig

# Expected output: Device UP and RUNNING

# Check IP configuration
ip addr show
# Expected: IP in correct VLAN subnet (10.0.20.x/24 for VLAN 20)

# Check default gateway
ip route show default
# Expected: via 10.0.20.1 (OPNsense)
```

### 1.2 Gateway Connectivity

```bash
# Ping default gateway (OPNsense)
ping -c 5 10.0.20.1
# Expected: 5 packets transmitted, 5 received, 0% packet loss

# Traceroute to gateway
traceroute 10.0.20.1
# Expected: Single hop, should complete immediately
```

### 1.3 DNS Functionality

```bash
# Query DNS server
nslookup google.com
# Expected: Resolves to IP address (OPNsense DNS)

# Alternative DNS test
dig google.com
# Expected: ANSWER SECTION with A records

# Local DNS test
nslookup lab.local
# Expected: Internal domain resolves (if configured)
```

### 1.4 Internet Connectivity (WAN Outbound)

```bash
# Ping external IP directly
ping -c 5 8.8.8.8
# Expected: 5 packets transmitted, 5 received

# DNS + routing test (comprehensive)
ping -c 5 google.com
# Expected: Resolves via DNS, then pings successfully

# Traceroute to internet
traceroute google.com
# Expected: Shows path through OPNsense → ISP → internet
```

## Phase 2: VLAN Isolation Testing

### 2.1 Same VLAN Communication

```bash
# Test within VLAN 20 (Fellowship - Infrastructure)
# From device A on VLAN 20, ping device B on same VLAN
ping 10.0.20.11
# Expected: Successful (no VLAN boundary)

# Verify ARP finds device directly
arp -n 10.0.20.11
# Expected: MAC address appears in ARP table (direct link-layer)
```

### 2.2 Inter-VLAN Communication (Should Fail)

```bash
# Test isolation between VLANs
# From VLAN 20, attempt to reach VLAN 30 (Shire - User Devices)
ping 10.0.30.50
# Expected: Timeout or "Destination unreachable" (firewall blocks)

# Test VLAN 50 (Mirkwood - IoT) isolation
ping 10.0.50.100
# Expected: Blocked by firewall rules (isolation enforced)
```

### 2.3 Management VLAN (VLAN 10) Access

```bash
# From VLAN 20, test access to VLAN 10
ping 10.0.10.1  # OPNsense mgmt interface
# Expected: May timeout (if blocked) or succeed (if allowed)

# SSH to switch management (if on VLAN 10)
ssh -l admin 10.0.10.2
# Expected: Can SSH to core switch (credentials required)
```

## Phase 3: DHCP Testing

### 3.1 DHCP Discovery

```bash
# Release current lease
sudo dhclient -r eth0  # Linux
# or (macOS)
sudo ipconfig set en0 DHCP

# Request new lease with verbose output
sudo dhclient -v eth0
# Expected: DISCOVER → OFFER → REQUEST → ACK sequence

# Check lease details
cat /var/lib/dhcp/dhclient.eth0.leases
# Expected: Lease entry with IP, gateway, DNS
```

### 3.2 DHCP for Different VLANs

```bash
# If testing multiple VLANs, verify correct subnet assigned
# Device on VLAN 20 should get 10.0.20.x IP
# Device on VLAN 30 should get 10.0.30.x IP
# Incorrect: Device on VLAN 20 getting 10.0.30.x = VLAN misconfiguration
```

## Phase 4: Firewall Rule Testing

### 4.1 Allowed Traffic (Fellowship → Mordor)

```bash
# VLAN 20 (Fellowship) → VLAN 40 (Mordor) should be allowed
# Proxmox node on VLAN 20 pinging VM on VLAN 40
ping 10.0.40.100
# Expected: Successful (firewall allows this path)

# TCP connection test (SSH)
ssh admin@10.0.40.100
# Expected: Connects to VM on Mordor
```

### 4.2 Blocked Traffic (VLAN 10 Isolation)

```bash
# VLAN 10 (Rivendell) should be isolated
# From VLAN 10, attempt to reach VLAN 20
ping 10.0.20.50
# Expected: Timeout (firewall blocks outbound from VLAN 10)

# Verify firewall blocks at WAN
# From device on VLAN 30, attempt external SSH (port 22)
# Expected: Timeout or "Connection refused" if not port-forwarded
```

### 4.3 NAT Testing (Internal → External)

```bash
# Test outbound NAT translation
# Device on VLAN 30 accessing external service
curl http://ifconfig.me
# Expected: Returns external IP (OPNsense WAN IP)
# If returns 10.0.30.x: NAT not working

# Verify return traffic
ping -c 5 -R 8.8.8.8
# Expected: Ping succeeds, record route shows path through OPNsense
```

## Phase 5: Device-Specific Testing

### 5.1 OPNsense Firewall Testing

```bash
# SSH to OPNsense
ssh admin@10.0.10.1

# Check firewall statistics
pfctl -s info
# Expected: Shows firewall enabled, statistics visible

# View active rules
pfctl -s rules
# Expected: Lists configured firewall rules

# Check NAT translations
pfctl -s nat
# Expected: Shows active NAT entries

# Monitor logs (real-time)
tail -f /var/log/filter.log
# Expected: Shows matching rules and dropped packets
```

### 5.2 Proxmox Cluster Testing

```bash
# SSH to Proxmox node
ssh root@10.0.20.10

# Check cluster status
pvecm status
# Expected: cluster name, member nodes all ONLINE, quorum OK

# List all nodes
pvecm nodes
# Expected: All 3 nodes listed with status ONLINE

# Test inter-node communication
ping 10.0.20.11  # Secondary node
# Expected: Responds successfully
```

### 5.3 GPU Node Testing

```bash
# SSH to GPU node
ssh admin@10.0.20.20  # or appropriate IP

# Check GPU status
nvidia-smi
# Expected: GPU listed, driver version shown

# Check iSCSI connection (if configured)
sudo iscsiadm -m session -o show
# Expected: Connected session to iSCSI target

# Check network interfaces
ip link show
# Expected: 2 NICs (management + storage) both UP
```

## Phase 6: Performance Testing

### 6.1 Bandwidth Testing (iperf3)

```bash
# Server side (Proxmox node)
iperf3 -s

# Client side (test machine)
iperf3 -c 10.0.20.10 -t 30
# Expected: Close to 1Gbps (1000 Mbps for 1Gbps link)
# Actual: 900-950 Mbps typical (overhead)

# Bidirectional test
iperf3 -c 10.0.20.10 -t 30 -R -b 0
# Expected: 800-900 Mbps each direction (half duplex sharing)
```

### 6.2 Latency Testing

```bash
# Ping with statistics
ping -c 100 10.0.20.1 | tail -1
# Expected output: rtt min/avg/max/stddev = X/Y/Z/W ms
# Typical: 1-3ms average within same VLAN

# Cross-VLAN latency (through firewall)
ping -c 100 10.0.40.100
# Expected: 2-5ms (slightly higher than same VLAN)

# Traceroute timing
traceroute -n 10.0.20.1
# Expected: <1ms per hop (local network)
```

### 6.3 Packet Loss Testing

```bash
# High-frequency ping to detect loss
ping -c 1000 -i 0.1 10.0.20.1 | tail -1
# Expected: 0% packet loss (no drops)

# Under load
iperf3 -c 10.0.20.10 &  # Start bandwidth test
ping -c 50 10.0.20.1 | tail -1
# Expected: <1% packet loss (acceptable)
```

## Phase 7: Packet Analysis (tcpdump)

### 7.1 Capture and Analyze

```bash
# Capture on specific interface
sudo tcpdump -i eth0 -w capture.pcap

# Analyze VLAN tagged traffic
sudo tcpdump -i eth0 'vlan'

# Filter DHCP traffic
sudo tcpdump -i eth0 'dhcp'
# Expected: Shows DISCOVER, OFFER, REQUEST, ACK messages

# Filter DNS traffic
sudo tcpdump -i eth0 'udp port 53'
# Expected: Shows DNS queries and responses

# Filter traffic to specific host
sudo tcpdump -i eth0 'host 10.0.20.1'
# Expected: All packets to/from gateway
```

### 7.2 Wireshark Analysis

For GUI-based analysis:
```bash
# Capture packets
sudo tcpdump -i eth0 -w /tmp/capture.pcap

# Open in Wireshark
wireshark /tmp/capture.pcap &

# Apply filters
  dns     # Show DNS queries/responses
  dhcp    # Show DHCP handshake
  tcp.port == 22  # Show SSH traffic
```

## Test Results Summary Table

| Test | Expected Result | Actual Result | Pass/Fail |
|------|-----------------|---------------|-----------|
| Local interface UP | Link up, IP assigned | | |
| Ping gateway (10.0.20.1) | 5/5 received, <5ms | | |
| DNS resolution (google.com) | IP address returned | | |
| Ping 8.8.8.8 | 5/5 received (via NAT) | | |
| Same VLAN ping | Successful, <2ms | | |
| Cross VLAN ping (blocked) | Timeout/no response | | |
| DHCP lease obtained | IP in correct subnet | | |
| Firewall allows (VLAN 20→40) | Ping successful | | |
| Bandwidth test | ~900 Mbps | | |
| Latency (intra-VLAN) | <3ms average | | |
| Packet loss | <0.1% | | |

## Troubleshooting Failed Tests

| Failed Test | Potential Causes | Diagnostics |
|-------------|------------------|-------------|
| No internet | WAN cable disconnected, ISP down | Check OPNsense WAN status, ping ISP gateway |
| Gateway unreachable | VLAN misconfiguration | Verify IP on correct subnet, check switch config |
| DNS fails | OPNsense DNS down, port 53 blocked | Check firewall DNS port, SSH to OPNsense |
| VLAN isolation fails | Firewall rule not applied | Review firewall rules on OPNsense, reload config |
| Low bandwidth | Link negotiation issue | Check switch port speed, replace cable |
| High latency | Congestion or processing delay | Monitor CPU/RAM, check IDS/IPS load |

## Related Documentation

- [Network Topology](../01-hardware/network-topology.md) - Reference architecture
- [Firewall & IDS](../04-security/firewall-and-ids.md) - Firewall rules reference
- [Switch Setup](./switch-setup.md) - VLAN configuration procedures
