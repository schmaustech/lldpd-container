#!/bin/bash

# Gather Ethernet devices that are Mellanox
mapfile -t devices < <( lspci -nn | awk '/Ethernet/ && /Mellanox/ {print $1}' )

# Iterate through the devices and find the real interface name and add it to interfaces string
for i in "${devices[@]}"
do
  itmp=`grep PCI_SLOT_NAME /sys/class/net/*/device/uevent|grep $i|awk -F'/' {'print $5'}`
  interfaces="${interfaces} ${itmp}"
done

# Run lldpd daemon passing the interfaces for it to run on
#/usr/sbin/lldpd -dd -l -C $interfaces
/usr/sbin/lldpd -l -I $interfaces

# Echo to logs container is ready - Sleep container indefinitly

echo "-------------------------------------------------------------------"
echo "LLDPD is up and running on $interfaces!"
echo "-------------------------------------------------------------------"
sleep infinity & wait
