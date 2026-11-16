% main.pl
% Entry point for Prolog Network Simulator.

:- consult('facts.pl').
:- consult('rules.pl').
:- consult('json_import.pl').

help :-
    writeln('Prolog Network Simulator'),
    writeln('Available commands:'),
    writeln('  show_devices.'),
    writeln('  show_topology.'),
    writeln('  show_ip_table.'),
    writeln('  device_info(Device).'),
    writeln('  ping(Origin, Destination).'),
    writeln('  route(Origin, Destination, Route).'),
    writeln('  add_device(Type, Name).'),
    writeln('  add_interface(Device, Interface).'),
    writeln('  configure_ip(Device, Interface, IP, Netmask, Gateway).'),
    writeln('  connect_devices(DeviceA, InterfaceA, DeviceB, InterfaceB).'),
    writeln('  import_network(FilePath).'),
    writeln('  clear_network.'),
    writeln('  new_device.').
