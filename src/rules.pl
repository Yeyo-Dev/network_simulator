% rules.pl
% Inference rules and helper predicates for Prolog Network Simulator.

% ------------------------------------------------------------
% Device type helpers
% ------------------------------------------------------------

device_type(Device, router) :- router(Device), !.
device_type(Device, switch) :- switch(Device), !.
device_type(Device, pc)     :- pc(Device), !.

interface_port(Device, Port, Type) :-
    interface(Device, Port),
    term_to_atom(Port, PortAtom),
    (   sub_atom(PortAtom, 0, 2, _, 'fa') -> Type = fastEthernet
    ;   sub_atom(PortAtom, 0, 2, _, 'se') -> Type = serial
    ;   Type = unknown
    ).

% ------------------------------------------------------------
% Validation rules
% ------------------------------------------------------------

ip_exists(IP) :-
    ip_config(_, _, IP, _, _).

interface_occupied(Device, Interface) :-
    connected(Device, Interface, _, _);
    connected(_, _, Device, Interface).

valid_device_type(router).
valid_device_type(switch).
valid_device_type(pc).

ensure_device_exists(Device) :-
    device(Device), !.
ensure_device_exists(Device) :-
    format('Error: device ~w does not exist.~n', [Device]),
    fail.

ensure_interface_exists(Device, Interface) :-
    interface(Device, Interface), !.
ensure_interface_exists(Device, Interface) :-
    format('Error: interface ~w on device ~w does not exist.~n', [Interface, Device]),
    fail.

ensure_interface_available(Device, Interface) :-
    \+ interface_occupied(Device, Interface), !.
ensure_interface_available(Device, Interface) :-
    format('Error: interface ~w on device ~w is already occupied.~n', [Interface, Device]),
    fail.

ensure_unique_ip(IP) :-
    \+ ip_exists(IP), !.
ensure_unique_ip(IP) :-
    format('Error: IP address ~w is already assigned.~n', [IP]),
    fail.

% ------------------------------------------------------------
% IP and subnet logic
% ------------------------------------------------------------

ip_to_binary(IP, Binary) :-
    split_string(IP, '.', '', Octets),
    maplist(atom_number, Octets, [O1, O2, O3, O4]),
    Binary is (O1 << 24) + (O2 << 16) + (O3 << 8) + O4.

same_subnet(IP1, IP2) :-
    ip_config(_, _, IP1, Netmask, _),
    ip_config(_, _, IP2, Netmask, _),
    ip_to_binary(IP1, Binary1),
    ip_to_binary(IP2, Binary2),
    ip_to_binary(Netmask, MaskBinary),
    (Binary1 /\ MaskBinary) =:= (Binary2 /\ MaskBinary).

% ------------------------------------------------------------
% Graph traversal over physical topology
% ------------------------------------------------------------

connected_devices(DeviceA, DeviceB) :-
    connected(DeviceA, _, DeviceB, _).
connected_devices(DeviceA, DeviceB) :-
    connected(DeviceB, _, DeviceA, _).

connected_ips(IP1, IP2) :-
    connected_devices(Device1, Device2),
    ip_config(Device1, _, IP1, _, _),
    ip_config(Device2, _, IP2, _, _).

reachable_device(Origin, Destination) :-
    route(Origin, Destination, _).

route(Origin, Destination, Route) :-
    ensure_device_exists(Origin),
    ensure_device_exists(Destination),
    route_recursive(Origin, Destination, [Origin], ReverseRoute),
    reverse(ReverseRoute, Route).

route_recursive(Device, Device, Visited, Visited) :- !.
route_recursive(Current, Destination, Visited, Route) :-
    connected_devices(Current, Next),
    \+ member(Next, Visited),
    route_recursive(Next, Destination, [Next|Visited], Route).

% ------------------------------------------------------------
% Network-level reachability
% ------------------------------------------------------------

% A simplified network reachability predicate.
% It checks:
% 1. Whether both devices exist.
% 2. Whether a physical route exists.
% 3. Whether they are in the same subnet or the origin has a gateway.

can_reach(Origin, Destination, Route) :-
    ensure_device_exists(Origin),
    ensure_device_exists(Destination),
    ip_config(Origin, _, OriginIP, _, Gateway),
    ip_config(Destination, _, DestinationIP, _, _),
    route(Origin, Destination, Route),
    (
        same_subnet(OriginIP, DestinationIP)
    ;
        Gateway \= none,
        ip_exists(Gateway)
    ).

ping(Origin, Destination) :-
    can_reach(Origin, Destination, Route), !,
    format('Ping from ~w to ~w successful.~n', [Origin, Destination]),
    format('Route: ~w~n', [Route]).

ping(Origin, Destination) :-
    format('Ping from ~w to ~w failed.~n', [Origin, Destination]),
    fail.

ping_result(Origin, Destination) :-
    ping(Origin, Destination).

% ------------------------------------------------------------
% Topology and reporting helpers
% ------------------------------------------------------------

show_topology :-
    writeln('Network topology:'),
    forall(connected(DeviceA, InterfaceA, DeviceB, InterfaceB),
        format('~w:~w <--> ~w:~w~n', [DeviceA, InterfaceA, DeviceB, InterfaceB])
    ).

show_devices :-
    writeln('Devices:'),
    forall(device(Device),
        (
            device_type(Device, Type),
            format('- ~w (~w)~n', [Device, Type])
        )
    ).

device_info(Device) :-
    ensure_device_exists(Device),
    device_type(Device, Type),
    format('Device: ~w~n', [Device]),
    format('Type: ~w~n', [Type]),
    writeln('Interfaces:'),
    forall(interface(Device, Interface),
        (
            interface_port(Device, Interface, InterfaceType),
            format('- ~w (~w)', [Interface, InterfaceType]),
            (
                ip_config(Device, Interface, IP, Netmask, Gateway)
            ->  format(' | IP: ~w | Mask: ~w | Gateway: ~w~n', [IP, Netmask, Gateway])
            ;   writeln(' | No IP configured')
            )
        )
    ).

show_ip_table :-
    writeln('IP configuration table:'),
    forall(ip_config(Device, Interface, IP, Netmask, Gateway),
        format('~w:~w | IP: ~w | Mask: ~w | Gateway: ~w~n',
            [Device, Interface, IP, Netmask, Gateway])
    ).

% ------------------------------------------------------------
% Dynamic modification predicates
% ------------------------------------------------------------

add_device(Type, Name) :-
    valid_device_type(Type),
    \+ device(Name), !,
    (
        Type = router -> assertz(router(Name));
        Type = switch -> assertz(switch(Name));
        Type = pc     -> assertz(pc(Name))
    ),
    format('Device ~w of type ~w created successfully.~n', [Name, Type]).

add_device(Type, _) :-
    \+ valid_device_type(Type), !,
    format('Error: invalid device type ~w. Use router, switch or pc.~n', [Type]),
    fail.

add_device(_, Name) :-
    device(Name),
    format('Error: device ~w already exists.~n', [Name]),
    fail.

add_interface(Device, Interface) :-
    ensure_device_exists(Device),
    \+ interface(Device, Interface), !,
    assertz(interface(Device, Interface)),
    format('Interface ~w added to device ~w.~n', [Interface, Device]).

add_interface(Device, Interface) :-
    format('Error: interface ~w already exists on device ~w.~n', [Interface, Device]),
    fail.

configure_ip(Device, Interface, IP, Netmask, Gateway) :-
    ensure_device_exists(Device),
    ensure_interface_exists(Device, Interface),
    ensure_unique_ip(IP),
    \+ ip_config(Device, Interface, _, _, _), !,
    assertz(ip_config(Device, Interface, IP, Netmask, Gateway)),
    format('IP ~w configured on ~w:~w.~n', [IP, Device, Interface]).

configure_ip(Device, Interface, _, _, _) :-
    ip_config(Device, Interface, _, _, _),
    format('Error: device ~w interface ~w already has an IP configuration.~n', [Device, Interface]),
    fail.

connect_devices(DeviceA, InterfaceA, DeviceB, InterfaceB) :-
    ensure_device_exists(DeviceA),
    ensure_device_exists(DeviceB),
    ensure_interface_exists(DeviceA, InterfaceA),
    ensure_interface_exists(DeviceB, InterfaceB),
    ensure_interface_available(DeviceA, InterfaceA),
    ensure_interface_available(DeviceB, InterfaceB),
    assertz(connected(DeviceA, InterfaceA, DeviceB, InterfaceB)),
    format('Connected ~w:~w to ~w:~w.~n', [DeviceA, InterfaceA, DeviceB, InterfaceB]).

% Adds a device with multiple interfaces and IP configurations.
% Example:
% add_device_full(pc, pc4, [fa0/0], [ip_config(pc4, fa0/0, '192.168.2.30', '255.255.255.0', '192.168.2.1')]).

add_device_full(Type, Name, Interfaces, IPConfigs) :-
    add_device(Type, Name),
    forall(member(Interface, Interfaces), add_interface(Name, Interface)),
    forall(
        member(ip_config(Name, Interface, IP, Netmask, Gateway), IPConfigs),
        configure_ip(Name, Interface, IP, Netmask, Gateway)
    ),
    format('Device ~w created with interfaces and IP configuration.~n', [Name]).

% ------------------------------------------------------------
% Interactive device creation
% ------------------------------------------------------------

new_device :-
    write('Enter device type (router, switch, pc): '),
    read(Type),
    write('Enter device name, for example r3, s3, pc4: '),
    read(Name),
    add_device(Type, Name),
    collect_interfaces(Name),
    collect_ip_configs(Name).

collect_interfaces(Device) :-
    write('Add an interface? (yes/no): '),
    read(Response),
    (
        Response = yes ->
            write('Enter interface, for example fa0/0: '),
            read(Interface),
            add_interface(Device, Interface),
            collect_interfaces(Device)
    ;
        true
    ).

collect_ip_configs(Device) :-
    write('Add an IP configuration? (yes/no): '),
    read(Response),
    (
        Response = yes ->
            write('Enter interface, for example fa0/0: '),
            read(Interface),
            write('Enter IP address, for example 192.168.1.20: '),
            read(IP),
            write('Enter netmask, for example 255.255.255.0: '),
            read(Netmask),
            write('Enter gateway or none: '),
            read(Gateway),
            configure_ip(Device, Interface, IP, Netmask, Gateway),
            collect_ip_configs(Device)
    ;
        true
    ).
