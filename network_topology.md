# Network Topology

The default topology included in the project is:

```text
pc1 ─ s1 ─ r1 ─ r2 ─ s2 ─ pc2
                       └── pc3
```

## Network segments

### LAN 1 - 192.168.1.0/24

| Device | Interface | IP |
|---|---:|---:|
| r1 | fa0/0 | 192.168.1.1 |
| s1 | fa0/1 | 192.168.1.2 |
| s1 | fa0/2 | 192.168.1.3 |
| pc1 | fa0/0 | 192.168.1.10 |

### Router-to-router link - 10.0.0.0/30

| Device | Interface | IP |
|---|---:|---:|
| r1 | fa0/1 | 10.0.0.1 |
| r2 | fa0/0 | 10.0.0.2 |

### LAN 2 - 192.168.2.0/24

| Device | Interface | IP |
|---|---:|---:|
| r2 | fa0/1 | 192.168.2.1 |
| s2 | fa0/1 | 192.168.2.2 |
| s2 | fa0/2 | 192.168.2.3 |
| pc2 | fa0/0 | 192.168.2.10 |
| pc3 | fa0/0 | 192.168.2.20 |
```
