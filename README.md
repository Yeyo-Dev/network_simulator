# Prolog Network Simulator

A logic-based network simulator built with Prolog.

This project models routers, switches, PCs, interfaces, IP configurations, gateways and physical connections using logical facts and inference rules.

The simulator allows basic connectivity checks between devices, similar to a `ping` command, by reasoning about subnets, gateways and connected nodes.

## Why this project exists

This was originally a personal experiment created to practice Prolog and basic networking concepts. It has been cleaned and organized as a portfolio project to demonstrate logic programming, knowledge representation and recursive inference.

## Features

- Device modeling: routers, switches and PCs.
- Interface representation.
- IP, netmask and gateway configuration.
- Physical connection modeling.
- Subnet validation using bitwise IP comparison.
- Recursive route discovery between devices.
- Ping-like connectivity checks.
- Interface occupation validation.
- Duplicate IP validation.
- Dynamic device, interface and IP creation.
- Basic topology and device reporting commands.
- JSON topology import through `network.json`.

## Default topology

```text
pc1 ─ s1 ─ r1 ─ r2 ─ s2 ─ pc2
                       └── pc3
```

See [`docs/network_topology.md`](docs/network_topology.md) for the full topology and IP table.

## Project structure

```text
prolog-network-simulator/
│
├── README.md
├── LICENSE
├── .gitignore
├── src/
│   ├── facts.pl
│   ├── rules.pl
│   ├── json_import.pl
│   └── main.pl
│
├── examples/
│   ├── sample_queries.pl
│   └── network.json
│
└── docs/
    ├── network_topology.md
    └── json_import.md
```

## Requirements

- SWI-Prolog recommended.

## How to run

From the project root:

```bash
swipl src/main.pl
```

Then run:

```prolog
?- help.
```

## Example queries

Show all devices:

```prolog
?- show_devices.
```

Show physical topology:

```prolog
?- show_topology.
```

Show a device summary:

```prolog
?- device_info(pc1).
```

Check connectivity:

```prolog
?- ping(pc1, pc2).
```

Expected output:

```text
Ping from pc1 to pc2 successful.
Route: [pc1,s1,r1,r2,s2,pc2]
true.
```

Get the route directly:

```prolog
?- route(pc1, pc2, Route).
```

Expected output:

```text
Route = [pc1, s1, r1, r2, s2, pc2].
```

Add a new device:

```prolog
?- add_device(pc, pc4).
?- add_interface(pc4, fa0/0).
?- configure_ip(pc4, fa0/0, '192.168.2.30', '255.255.255.0', '192.168.2.1').
```

Connect devices:

```prolog
?- connect_devices(s2, fa0/4, pc4, fa0/0).
```

> Note: the interface must exist before it can be connected.


## Import a topology from JSON

You can load a complete network from a JSON file without manually editing `facts.pl`.

Example:

```prolog
?- import_network('examples/network.json').
```

After importing, you can use the normal predicates:

```prolog
?- show_devices.
?- show_topology.
?- ping(pc1, pc2).
?- route(pc1, pc2, Route).
```

See [`docs/json_import.md`](docs/json_import.md) for the JSON schema.

Minimal JSON example:

```json
{
  "devices": [
    {
      "name": "pc1",
      "type": "pc",
      "interfaces": ["fa0/0"],
      "ip_configs": [
        {
          "interface": "fa0/0",
          "ip": "192.168.1.10",
          "netmask": "255.255.255.0",
          "gateway": "192.168.1.1"
        }
      ]
    }
  ],
  "connections": []
}
```

## Main predicates

| Predicate | Description |
|---|---|
| `show_devices.` | Lists all devices and their type. |
| `show_topology.` | Shows physical links between devices. |
| `show_ip_table.` | Shows all IP configurations. |
| `device_info(Device).` | Shows details about a device. |
| `route(Origin, Destination, Route).` | Infers a physical route between two devices. |
| `ping(Origin, Destination).` | Checks whether two devices can communicate. |
| `add_device(Type, Name).` | Adds a router, switch or PC. |
| `add_interface(Device, Interface).` | Adds an interface to a device. |
| `configure_ip(Device, Interface, IP, Netmask, Gateway).` | Assigns IP configuration to an interface. |
| `connect_devices(DeviceA, InterfaceA, DeviceB, InterfaceB).` | Creates a physical link. |
| `import_network(FilePath).` | Imports a full topology from JSON. |
| `clear_network.` | Clears all current devices, interfaces, IPs and connections. |
| `new_device.` | Interactive device creation. |

## Learning goals

This project demonstrates:

- Declarative programming.
- Knowledge representation.
- Recursive graph traversal.
- Basic network modeling.
- IP addressing and subnet logic.
- Rule-based reasoning.

## Possible future improvements

- Add VLAN support.
- Add routing tables.
- Add path cost calculation.
- Add CLI-like commands.
- Export topology to Graphviz.
- Export current topology to JSON.
- Add automated tests.
- Add packet-level simulation.

## Portfolio description

**Prolog Network Simulator** is a logic-based network simulation project developed in Prolog. It models routers, switches, PCs, interfaces, IP configurations, gateways and physical connections using facts and inference rules. The system can infer routes and verify connectivity between devices through recursive reasoning, demonstrating declarative programming, knowledge representation and basic computer networking concepts.
