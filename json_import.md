# JSON network import

The simulator can import a complete topology from a JSON file using:

```prolog
?- import_network('examples/network.json').
```

The import process clears the current in-memory network and then loads:

- devices;
- interfaces;
- IP configurations;
- physical connections.

## JSON schema

```json
{
  "devices": [
    {
      "name": "r1",
      "type": "router",
      "interfaces": ["fa0/0", "fa0/1"],
      "ip_configs": [
        {
          "interface": "fa0/0",
          "ip": "192.168.1.1",
          "netmask": "255.255.255.0",
          "gateway": null
        }
      ]
    }
  ],
  "connections": [
    {
      "from": {"device": "r1", "interface": "fa0/0"},
      "to": {"device": "s1", "interface": "fa0/1"}
    }
  ]
}
```

## Supported device types

- `router`
- `switch`
- `pc`

## Validation

The importer validates that:

- each device has a valid type;
- each IP configuration references an existing interface;
- duplicated IP addresses are rejected;
- each connection references existing devices and interfaces;
- an interface is not used by more than one connection.

## Gateway values

Use `null` when a device does not need a gateway:

```json
"gateway": null
```

Use a string when a gateway exists:

```json
"gateway": "192.168.1.1"
```
