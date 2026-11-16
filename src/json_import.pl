% json_import.pl
% JSON topology importer for Prolog Network Simulator.
%
% Expected JSON schema:
% {
%   "devices": [
%     {
%       "name": "r1",
%       "type": "router",
%       "interfaces": ["fa0/0", "fa0/1"],
%       "ip_configs": [
%         {
%           "interface": "fa0/0",
%           "ip": "192.168.1.1",
%           "netmask": "255.255.255.0",
%           "gateway": null
%         }
%       ]
%     }
%   ],
%   "connections": [
%     {
%       "from": {"device": "r1", "interface": "fa0/0"},
%       "to":   {"device": "s1", "interface": "fa0/1"}
%     }
%   ]
% }

:- use_module(library(http/json)).

% ------------------------------------------------------------
% Public predicates
% ------------------------------------------------------------

import_network(FilePath) :-
    exists_file(FilePath), !,
    setup_call_cleanup(
        open(FilePath, read, Stream),
        json_read_dict(Stream, NetworkDict),
        close(Stream)
    ),
    clear_network,
    import_devices(NetworkDict.devices),
    import_connections(NetworkDict.connections),
    writeln('Network imported successfully from JSON.'),
    show_devices,
    show_topology.

import_network(FilePath) :-
    format('Error: JSON file not found: ~w~n', [FilePath]),
    fail.

clear_network :-
    retractall(router(_)),
    retractall(switch(_)),
    retractall(pc(_)),
    retractall(interface(_, _)),
    retractall(ip_config(_, _, _, _, _)),
    retractall(connected(_, _, _, _)),
    writeln('Current network cleared.').

% ------------------------------------------------------------
% Device import
% ------------------------------------------------------------

import_devices([]).
import_devices([DeviceDict|Rest]) :-
    import_device(DeviceDict),
    import_devices(Rest).

import_device(DeviceDict) :-
    required_key(DeviceDict, name),
    required_key(DeviceDict, type),
    value_to_atom(DeviceDict.name, Name),
    value_to_atom(DeviceDict.type, Type),
    add_device_from_json(Type, Name),
    optional_key(DeviceDict, interfaces, [], Interfaces),
    optional_key(DeviceDict, ip_configs, [], IPConfigs),
    import_interfaces(Name, Interfaces),
    import_ip_configs(Name, IPConfigs).

add_device_from_json(router, Name) :- !,
    assertz(router(Name)).
add_device_from_json(switch, Name) :- !,
    assertz(switch(Name)).
add_device_from_json(pc, Name) :- !,
    assertz(pc(Name)).
add_device_from_json(Type, Name) :-
    format('Error: invalid device type ~w for device ~w. Use router, switch or pc.~n', [Type, Name]),
    fail.

import_interfaces(_, []).
import_interfaces(Device, [InterfaceValue|Rest]) :-
    value_to_atom(InterfaceValue, Interface),
    assertz(interface(Device, Interface)),
    import_interfaces(Device, Rest).

import_ip_configs(_, []).
import_ip_configs(Device, [ConfigDict|Rest]) :-
    required_key(ConfigDict, interface),
    required_key(ConfigDict, ip),
    required_key(ConfigDict, netmask),
    value_to_atom(ConfigDict.interface, Interface),
    value_to_atom(ConfigDict.ip, IP),
    value_to_atom(ConfigDict.netmask, Netmask),
    optional_key(ConfigDict, gateway, null, GatewayValue),
    json_gateway(GatewayValue, Gateway),
    ensure_json_interface_exists(Device, Interface),
    ensure_json_unique_ip(IP),
    assertz(ip_config(Device, Interface, IP, Netmask, Gateway)),
    import_ip_configs(Device, Rest).

% ------------------------------------------------------------
% Connection import
% ------------------------------------------------------------

import_connections([]).
import_connections([ConnectionDict|Rest]) :-
    import_connection(ConnectionDict),
    import_connections(Rest).

import_connection(ConnectionDict) :-
    required_key(ConnectionDict, from),
    required_key(ConnectionDict, to),
    EndpointA = ConnectionDict.from,
    EndpointB = ConnectionDict.to,
    required_key(EndpointA, device),
    required_key(EndpointA, interface),
    required_key(EndpointB, device),
    required_key(EndpointB, interface),
    value_to_atom(EndpointA.device, DeviceA),
    value_to_atom(EndpointA.interface, InterfaceA),
    value_to_atom(EndpointB.device, DeviceB),
    value_to_atom(EndpointB.interface, InterfaceB),
    ensure_device_exists(DeviceA),
    ensure_device_exists(DeviceB),
    ensure_json_interface_exists(DeviceA, InterfaceA),
    ensure_json_interface_exists(DeviceB, InterfaceB),
    ensure_json_interface_available(DeviceA, InterfaceA),
    ensure_json_interface_available(DeviceB, InterfaceB),
    assertz(connected(DeviceA, InterfaceA, DeviceB, InterfaceB)).

% ------------------------------------------------------------
% JSON validation helpers
% ------------------------------------------------------------

required_key(Dict, Key) :-
    get_dict(Key, Dict, _), !.
required_key(_, Key) :-
    format('Error: required JSON key missing: ~w~n', [Key]),
    fail.

optional_key(Dict, Key, _, Value) :-
    get_dict(Key, Dict, Value), !.
optional_key(_, _, Default, Default).

value_to_atom(Value, Atom) :-
    atom(Value), !,
    Atom = Value.
value_to_atom(Value, Atom) :-
    string(Value), !,
    atom_string(Atom, Value).
value_to_atom(Value, Atom) :-
    number(Value), !,
    term_to_atom(Value, Atom).

json_gateway(null, none) :- !.
json_gateway(none, none) :- !.
json_gateway(Value, Gateway) :-
    value_to_atom(Value, Gateway).

ensure_json_interface_exists(Device, Interface) :-
    interface(Device, Interface), !.
ensure_json_interface_exists(Device, Interface) :-
    format('Error: interface ~w is not declared for device ~w in JSON.~n', [Interface, Device]),
    fail.

ensure_json_unique_ip(IP) :-
    \+ ip_exists(IP), !.
ensure_json_unique_ip(IP) :-
    format('Error: duplicated IP address in JSON: ~w~n', [IP]),
    fail.

ensure_json_interface_available(Device, Interface) :-
    \+ interface_occupied(Device, Interface), !.
ensure_json_interface_available(Device, Interface) :-
    format('Error: interface ~w on device ~w is already used in another JSON connection.~n', [Interface, Device]),
    fail.
