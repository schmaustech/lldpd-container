# Containerization of lldpd for OpenShift

Containerization of lldpd for OpenShift.

**Goal**: The goal of this document is to containerize lldpd so we can run it as a container in an OpenShift environment and do device discovery on the network.

## Workflow Sections

- [Building The Container](#building-the-container)
- [Running the Container as Daemonset](#running-the-container-as-daemonset)
- [Using the lldp Container](#using-the-lldp-container)

## Building The Container

The first step is to make a lldp directory.

~~~bash
$ mkdir -p ~/lldp
$ cd ~/lldp
~~~

Next we need to create the following dockerfile we will use to build the container.

~~~bash
$ cat <<EOF > Dockerfile 
FROM registry.access.redhat.com/ubi9/ubi:latest
COPY lldpd.conf /etc/lldpd.conf
RUN dnf install -y lldpad lldpd tcpdump 
ENTRYPOINT ["lldpd", "-dd", "-l"]
EOF
~~~

Then we need to create the lldpd.conf file that will get embedded in the container.

~~~bash
$ cat <<EOF > lldpd.conf 
configure lldp tx-interval 30
configure lldp tx-hold 4
configure lldp portidsubtype ifname
EOF
~~~

Now that we have our Dockerfile and lldpd.conf we can build the image.

~~~bash
$ ppodman build -t quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.5 -f Dockerfile 
STEP 1/6: FROM registry.access.redhat.com/ubi9/ubi:latest
STEP 2/6: COPY lldpd.conf /etc/lldpd.conf
--> Using cache 1b1ed619ff75d4f4230524732252c1a074ad00f70f8d5976ad5dcde48f4c5397
--> 1b1ed619ff75
STEP 3/6: COPY entrypoint.sh /root/entrypoint.sh
--> Using cache 177281a10d3207b4bc8f653423d7db20afc849e0c7a084ac76b79be6c5f6c604
--> 177281a10d32
STEP 4/6: RUN chmod +x /root/entrypoint.sh
--> Using cache 37c85b784aafef1a5b109202e507457999fb681a9b3ae8682c767054fc2d3bc4
--> 37c85b784aaf
STEP 5/6: RUN dnf install -y lldpad lldpd tcpdump procps-ng pciutils
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
Red Hat Enterprise Linux 9 for x86_64 - BaseOS   10 MB/s |  79 MB     00:07    
Red Hat Enterprise Linux 9 for x86_64 - AppStre 9.8 MB/s |  69 MB     00:07    
Red Hat Universal Base Image 9 (RPMs) - BaseOS  2.0 MB/s | 531 kB     00:00    
Red Hat Universal Base Image 9 (RPMs) - AppStre 6.4 MB/s | 2.4 MB     00:00    
Red Hat Universal Base Image 9 (RPMs) - CodeRea 1.7 MB/s | 287 kB     00:00    
Dependencies resolved.
====================================================================================================
 Package                      Arch    Version                Repository                         Size
====================================================================================================
Installing:
 lldpad                       x86_64  1.1.1-4.gitf1dd9eb.el9 rhel-9-for-x86_64-baseos-rpms     300 k
 lldpd                        x86_64  1.0.18-6.el9           rhel-9-for-x86_64-appstream-rpms  202 k
 tcpdump                      x86_64  14:4.99.0-9.el9        rhel-9-for-x86_64-appstream-rpms  547 k
Installing dependencies:
 groff-base                   x86_64  1.22.4-10.el9          rhel-9-for-x86_64-baseos-rpms     1.1 M
 libconfig                    x86_64  1.7.2-9.el9            rhel-9-for-x86_64-baseos-rpms      75 k
(...)
 perl-podlators               noarch  1:4.14-460.el9         rhel-9-for-x86_64-appstream-rpms  118 k
 perl-subs                    noarch  1.03-481.1.el9_6       rhel-9-for-x86_64-appstream-rpms   11 k
 perl-vars                    noarch  1.05-481.1.el9_6       rhel-9-for-x86_64-appstream-rpms   13 k
Installing weak dependencies:
 perl-NDBM_File               x86_64  1.15-481.1.el9_6       rhel-9-for-x86_64-appstream-rpms   22 k

Transaction Summary
====================================================================================================
Install  71 Packages

Total download size: 12 M
Installed size: 41 M
Downloading Packages:
(1/71): libconfig-1.7.2-9.el9.x86_64.rpm        303 kB/s |  75 kB     00:00    
(2/71): libpcap-1.10.0-4.el9.x86_64.rpm         642 kB/s | 177 kB     00:00    
(3/71): groff-base-1.22.4-10.el9.x86_64.rpm     3.1 MB/s | 1.1 MB     00:00    
(...)
(69/71): perl-overload-1.31-481.1.el9_6.noarch. 165 kB/s |  45 kB     00:00    
(70/71): perl-subs-1.03-481.1.el9_6.noarch.rpm   64 kB/s |  11 kB     00:00    
(71/71): perl-vars-1.05-481.1.el9_6.noarch.rpm   78 kB/s |  13 kB     00:00    
--------------------------------------------------------------------------------
Total                                           4.3 MB/s |  12 MB     00:02     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : net-snmp-libs-1:5.9.1-17.el9.x86_64                   1/71 
  Installing       : libnl3-3.11.0-1.el9.x86_64                            2/71 
  Installing       : libibverbs-54.0-1.el9.x86_64                          3/71 
(...)
  Verifying        : perl-overloading-0.02-481.1.el9_6.noarch             69/71 
  Verifying        : perl-subs-1.03-481.1.el9_6.noarch                    70/71 
  Verifying        : perl-vars-1.05-481.1.el9_6.noarch                    71/71 
Installed products updated.

Installed:
  groff-base-1.22.4-10.el9.x86_64                                               
  libconfig-1.7.2-9.el9.x86_64                                                  
  libibverbs-54.0-1.el9.x86_64                                                  
(...)                                       
  perl-subs-1.03-481.1.el9_6.noarch                                             
  perl-vars-1.05-481.1.el9_6.noarch                                             
  tcpdump-14:4.99.0-9.el9.x86_64                                                

Complete!
--> 551ad3117cc0
STEP 6/6: ENTRYPOINT ["/root/entrypoint.sh"]
COMMIT quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.5
--> 1cb95d923693
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.5
1cb95d92369354bc8b9eff1bfb6e480b2ea67b4e5c3c9f24beb966eea7598c52
~~~

Then push the newly built image to a registry.

~~~bash
$ podman push quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.5
Getting image source signatures
Copying blob b5e1756c65d6 done   | 
Copying blob ed0f88307912 done   | 
Copying blob 4f9e5bd3a426 done   | 
Copying blob 54483677b5cb skipped: already exists  
Copying blob a31fe918a805 skipped: already exists  
Copying config 1cb95d9236 done   | 
Writing manifest to image destination
~~~

Now that we have built our image and pushed it to a registry we can move onto running the daemonset in our environment.

## Running the Container as Daemonset

To run our lldpd container daemonset we will need to provide a service account with privilege access similar to what we do with NMState.   The first step is to create a service account we will simply call lldp.  In this example I am creating it under the nvidia-network-operator namespace.  First craft the custom resource file.

~~~bash
$ cat <<EOF > lldp-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: lldp
  namespace: nvidia-network-operator
EOF
~~~

Then use the custom resource file to create the service account on the cluster.

~~~bash
$ oc create -f lldp-serviceaccount.yaml 
serviceaccount/lldp created
~~~

Once the service account is created we can apply the privileges to it.

~~~bash
$ oc -n nvidia-network-operator adm policy add-scc-to-user privileged -z lldp
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:privileged added: "lldp"
~~~

With our service account created and given the permissision it needs we can now focus on creating our lldpd daemonset.   This daemonset will live in the nvidia-network-operator namespace as well.  Further in this example I am assiging a secondary resource to enable a secondary interface that is connected to the Spectrum-X switch.  That way we can demonsrate the sending and recieving of lldp packets.  Create the below custom resource file and modify as necessary for the environment.

~~~bash
$ cat <<EOF > lldpd-daemonset.yaml 
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: lldpd-container
  namespace: nvidia-network-operator
  labels:
    app: lldpd
spec:
  selector:
    matchLabels:
      app: lldpd
  template:
    metadata:
      labels:
        app: lldpd
    spec:
      serviceAccountName: lldp
      hostNetwork: true
      containers:
        - name: lldpd-container
          image: quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.5
          securityContext:
            privileged: true
EOF
~~~

Once we have created the daemonset custom resource file we can create it on the cluster.

~~~bash
$ oc create -f lldpd-daemonset.yaml 
daemonset.apps/lldpd-container created
~~~

We can validate it is running by looking at the pods in the nvidia-network-operator namespace.

~~~bash
1$ oc get pods -n nvidia-network-operator -l app=lldpd -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP             NODE                                       NOMINATED NODE   READINESS GATES
lldpd-container-gcx6j   1/1     Running   0          13m   10.128.3.149   nvd-srv-29.nvidia.eng.rdu2.dc.redhat.com   <none>           <none>
lldpd-container-lwn7f   1/1     Running   0          13m   10.131.0.65    nvd-srv-30.nvidia.eng.rdu2.dc.redhat.com   <none>           <none>
~~~

## Using the lldp Container

Now that our daemonset for lldp has been launched we should be able to go into one of the containers and run some lldp commands.

First let't gather the list of our containers.

~~~bash
$ oc get pods -n nvidia-network-operator -l app=lldpd -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP             NODE                                       NOMINATED NODE   READINESS GATES
lldpd-container-4lbrt   1/1     Running   0          97m   10.131.0.68    nvd-srv-30.nvidia.eng.rdu2.dc.redhat.com   <none>           <none>
lldpd-container-thxvv   1/1     Running   0          97m   10.128.3.153   nvd-srv-29.nvidia.eng.rdu2.dc.redhat.com   <none>           <none>
~~~

Next let's rsh into one of the them.

~~~bash
$ oc rsh -n nvidia-network-operator lldpd-container-4lbrt
sh-5.1# 
~~~

Once inside the container we can list out the processes and see that lldpd is running.

~~~bash
sh-5.1# ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 18:45 ?        00:00:00 lldpd -dd -l
lldpd          3       1  0 18:45 ?        00:00:00 lldpd -dd -l
root           4       0  0 18:46 pts/0    00:00:00 /bin/sh
root           7       4  0 18:50 pts/0    00:00:00 ps -ef
~~~

We can use the lldpcli utlity to show the configuration of lldpd.

~~~bash
sh-5.1# lldpcli show conf
-------------------------------------------------------------------------------
Global configuration:
-------------------------------------------------------------------------------
Configuration:
  Transmit delay: 30
  Transmit delay in milliseconds: 30000
  Transmit hold: 4
  Maximum number of neighbors: 32
  Receive mode: no
  Pattern for management addresses: (none)
  Interface pattern: (none)
  Permanent interface pattern: (none)
  Interface pattern for chassis ID: (none)
  Override chassis ID with: (none)
  Override description with: (none)
  Override platform with: Linux
  Override system name with: (none)
  Override system capabilities: no
  Advertise version: yes
  Update interface descriptions: no
  Promiscuous mode on managed interfaces: no
  Disable LLDP-MED inventory: yes
  LLDP-MED fast start mechanism: yes
  LLDP-MED fast start interval: 1
  Source MAC for LLDP frames on bond slaves: local
  Port ID TLV subtype for LLDP frames: unknown
  Agent type:   unknown
-------------------------------------------------------------------------------
~~~

We can use the lldpcli utlity to show the interfaces lldpd is using.

~~~bash
sh-5.1# lldpcli show int
-------------------------------------------------------------------------------
LLDP interfaces:
-------------------------------------------------------------------------------
Interface:    eth0
  Administrative status: RX and TX
  Chassis:     
    ChassisID:    mac 0a:58:0a:83:00:44
    SysName:      lldpd-container-4lbrt
    SysDescr:     Red Hat Enterprise Linux 9.6 (Plow) Linux 5.14.0-570.39.1.el9_6.x86_64 #1 SMP PREEMPT_DYNAMIC Sat Aug 23 04:30:05 EDT 2025 x86_64
    MgmtIP:       10.131.0.68
    MgmtIface:    2
    MgmtIP:       fe80::858:aff:fe83:44
    MgmtIface:    2
    Capability:   Bridge, off
    Capability:   Router, off
    Capability:   Wlan, off
    Capability:   Station, on
  Port:        
    PortID:       mac 0a:58:0a:83:00:44
    PortDescr:    eth0
  TTL:          120
-------------------------------------------------------------------------------
Interface:    net1
  Administrative status: RX and TX
  Chassis:     
    ChassisID:    mac 0a:58:0a:83:00:44
    SysName:      lldpd-container-4lbrt
    SysDescr:     Red Hat Enterprise Linux 9.6 (Plow) Linux 5.14.0-570.39.1.el9_6.x86_64 #1 SMP PREEMPT_DYNAMIC Sat Aug 23 04:30:05 EDT 2025 x86_64
    MgmtIP:       10.131.0.68
    MgmtIface:    2
    MgmtIP:       fe80::858:aff:fe83:44
    MgmtIface:    2
    Capability:   Bridge, off
    Capability:   Router, off
    Capability:   Wlan, off
    Capability:   Station, on
  Port:        
    PortID:       mac a2:2e:29:11:c7:68
    PortDescr:    net1
  TTL:          120
-------------------------------------------------------------------------------
~~~

We can use the lldpcli utlity to show the statistics of each interface.

~~~bash
sh-5.1# lldpcli show stat
-------------------------------------------------------------------------------
LLDP statistics:
-------------------------------------------------------------------------------
Interface:    eth0
  Transmitted:  168
  Received:     0
  Discarded:    0
  Unrecognized: 0
  Ageout:       0
  Inserted:     0
  Deleted:      0
-------------------------------------------------------------------------------
Interface:    net1
  Transmitted:  172
  Received:     50
  Discarded:    0
  Unrecognized: 4
  Ageout:       0
  Inserted:     1
  Deleted:      0
-------------------------------------------------------------------------------
~~~

We can use the lldpcli utlity to show the neighbors.

~~~bash
sh-5.1# lldpcli show nei 
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
Interface:    net1, via: LLDP, RID: 1, Time: 0 day, 01:22:55
  Chassis:     
    ChassisID:    mac 9c:63:c0:3a:23:f0
    SysName:      cumulus
    SysDescr:     Cumulus Linux version 5.9.0 running on Nvidia SN5600
    MgmtIP:       10.6.156.1
    MgmtIface:    1
    MgmtIP:       2620:52:9:1688:9e63:c0ff:fe3a:23f0
    MgmtIface:    2
    Capability:   Bridge, on
    Capability:   Router, on
  Port:        
    PortID:       ifname swp4s1
    PortDescr:    swp4s1
    TTL:          300
  Unknown TLVs:
    TLV:          OUI: 00,80,C2, SubType: 11, Len: 2 08,08
    TLV:          OUI: 00,80,C2, SubType: 9, Len: 21 00,00,03,00,60,32,00,00,32,00,00,00,00,02,02,02,02,02,02,00,02
    TLV:          OUI: 00,80,C2, SubType: 10, Len: 21 00,00,03,00,60,32,00,00,32,00,00,00,00,02,02,02,02,02,02,00,02
    TLV:          OUI: 00,80,C2, SubType: 12, Len: 4 00,63,12,B7
-------------------------------------------------------------------------------
~~~

Let's login to the Spectrum SN5600 switch.

~~~bash
$ ssh cumulus@nvd-sn5600-bmc.mgmt.nvidia.eng.rdu2.dc.redhat.com
Debian GNU/Linux 12
Linux cumulus 6.1.0-cl-1-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.38-4+cl5.9.0u64 (2024-04-21) x86_64
Last login: Fri Sep 26 21:28:00 2025 from 10.22.66.108
~~~

On the switch we can run lldpctl and we can see which ports have lldp data.  Note our two containers show up.

~~~bash
cumulus@cumulus:mgmt:~$ sudo lldpctl | egrep 'Inter|Port|SysName'
Interface:    eth0, via: LLDP, RID: 4, Time: 0 day, 01:38:50
    SysName:      sw01-access-f42.rdu3.redhat.com
  Port:        
    PortID:       ifname ge-0/0/47
    PortDescr:    ge-0/0/47
Interface:    swp65, via: LLDP, RID: 3, Time: 0 day, 01:38:50
    SysName:      sw02-access-e42.rdu3.redhat.com
  Port:        
    PortID:       ifname xe-0/0/45
    PortDescr:    link to sn5600
Interface:    swp2s1, via: LLDP, RID: 11, Time: 0 day, 01:26:32
    SysName:      lldpd-container-thxvv
  Port:        
    PortID:       mac 46:02:3e:14:b7:72
    PortDescr:    net1
Interface:    swp4s1, via: LLDP, RID: 12, Time: 0 day, 01:26:32
    SysName:      lldpd-container-4lbrt
  Port:        
    PortID:       mac a2:2e:29:11:c7:68
    PortDescr:    net1
Interface:    swp16s0, via: LLDP, RID: 5, Time: 0 day, 01:38:49
  Port:        
    PortID:       mac c4:70:bd:c5:6f:79
Interface:    swp16s1, via: LLDP, RID: 7, Time: 0 day, 01:38:33
  Port:        
    PortID:       mac c4:70:bd:c5:6f:78
Interface:    swp17s0, via: LLDP, RID: 8, Time: 0 day, 01:38:21
  Port:        
    PortID:       mac c4:70:bd:c2:c1:78
Interface:    swp17s1, via: LLDP, RID: 6, Time: 0 day, 01:38:33
  Port:        
    PortID:       mac c4:70:bd:c2:c1:79
~~~

Hopefully this gives an idea of how this container can be useful.
