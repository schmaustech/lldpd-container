# Containerization of lldpd for OpenShift

Containerization of lldpd for OpenShift.

**Goal**: The goal of this document is to containerize lldpd so we can run it as a container in an OpenShift environment and do device discovery on the network.

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
EOF
~~~

Now that we have our Dockerfile and lldpd.conf we can build the image.

~~~bash
$ podman build -t quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.1 -f Dockerfile 
STEP 1/4: FROM registry.access.redhat.com/ubi9/ubi:latest
STEP 2/4: COPY lldpd.conf /etc/lldpd.conf
--> Using cache c75885685cd29c566a8132f28a007bbb26869e65b07bb0c9c3eed5b212b4bd2a
--> c75885685cd2
STEP 3/4: RUN dnf install -y lldpad lldpd tcpdump 
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
--> 07eeb7a24fa5
STEP 4/4: ENTRYPOINT ["lldpd", "-dd", "-l"]
COMMIT quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.1
--> 8067ca8b6ebb
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.1
8067ca8b6ebbb011158ad8ba95648448321e812205629075455cf203c3b8a2e4
~~~

## Running the Container as Daemonset

## Using the Container for lldp Troubleshooting
