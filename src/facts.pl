% facts.pl
% Base topology for Prolog Network Simulator.

:- dynamic router/1.
:- dynamic switch/1.
:- dynamic pc/1.
:- dynamic ip_config/5.
:- dynamic connected/4.
:- dynamic interface/2.

% ------------------------------------------------------------
% Device definitions
% ------------------------------------------------------------

router(r1).
router(r2).

switch(s1).
switch(s2).

pc(pc1).
pc(pc2).
pc(pc3).

% A device can be a router, switch or PC.
device(Device) :-
    router(Device);
    switch(Device);
    pc(Device).

% ------------------------------------------------------------
% Interface definitions
% ------------------------------------------------------------

interface(r1, fa0/0).
interface(r1, fa0/1).
interface(r2, fa0/0).
interface(r2, fa0/1).

interface(s1, fa0/1).
interface(s1, fa0/2).

interface(s2, fa0/1).
interface(s2, fa0/2).
interface(s2, fa0/3).

interface(pc1, fa0/0).
interface(pc2, fa0/0).
interface(pc3, fa0/0).

% ------------------------------------------------------------
% IP configuration
% ip_config(Device, Interface, IP, Netmask, Gateway).
% ------------------------------------------------------------

ip_config(r1, fa0/0, '192.168.1.1',  '255.255.255.0',   none).
ip_config(r1, fa0/1, '10.0.0.1',      '255.255.255.252', none).

ip_config(r2, fa0/0, '10.0.0.2',      '255.255.255.252', none).
ip_config(r2, fa0/1, '192.168.2.1',   '255.255.255.0',   none).

ip_config(s1, fa0/1, '192.168.1.2',   '255.255.255.0',   none).
ip_config(s1, fa0/2, '192.168.1.3',   '255.255.255.0',   none).

ip_config(s2, fa0/1, '192.168.2.2',   '255.255.255.0',   none).
ip_config(s2, fa0/2, '192.168.2.3',   '255.255.255.0',   none).

ip_config(pc1, fa0/0, '192.168.1.10', '255.255.255.0',   '192.168.1.1').
ip_config(pc2, fa0/0, '192.168.2.10', '255.255.255.0',   '192.168.2.1').
ip_config(pc3, fa0/0, '192.168.2.20', '255.255.255.0',   '192.168.2.1').

% ------------------------------------------------------------
% Physical connections
% connected(DeviceA, InterfaceA, DeviceB, InterfaceB).
% ------------------------------------------------------------

connected(r1, fa0/0, s1, fa0/1).
connected(r1, fa0/1, r2, fa0/0).
connected(r2, fa0/1, s2, fa0/1).
connected(s1, fa0/2, pc1, fa0/0).
connected(s2, fa0/2, pc2, fa0/0).
connected(s2, fa0/3, pc3, fa0/0).
