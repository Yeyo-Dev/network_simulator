% sample_queries.pl
% Load from src/main.pl first:
% ?- consult('../src/main.pl').

% Show all devices.
% ?- show_devices.

% Show physical topology.
% ?- show_topology.

% Show IP configuration table.
% ?- show_ip_table.

% Get information about a specific device.
% ?- device_info(pc1).

% Check connectivity between devices.
% ?- ping(pc1, pc2).

% Get the inferred physical route.
% ?- route(pc1, pc2, Route).

% Add a new PC dynamically.
% ?- add_device(pc, pc4).
% ?- add_interface(pc4, fa0/0).
% ?- configure_ip(pc4, fa0/0, '192.168.2.30', '255.255.255.0', '192.168.2.1').
% ?- connect_devices(s2, fa0/4, pc4, fa0/0).

% Add a device with interfaces and IP configuration in one call.
% ?- add_device_full(pc, pc5, [fa0/0], [ip_config(pc5, fa0/0, '192.168.2.40', '255.255.255.0', '192.168.2.1')]).

% Import a topology from JSON:
% ?- import_network('examples/network.json').
% ?- ping(pc1, pc2).
