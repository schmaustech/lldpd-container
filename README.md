# Containerization of lldpd for OpenShift

Containerization of lldpd for OpenShift.

**Goal**: The goal of this document is to containerize lldpd so we can run it as a container in an OpenShift environment and do device discovery on the network.

## Workflow Sections

- [Building The Container](#building-the-container)
- [Running the Container as Daemonset](#running-the-container-as-daemonset)
- [Using the Container for lldp Troubleshooting](#using-the-container-for-lldp-troubleshooting)

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
$ podman build -t quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.2 -f Dockerfile 
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
COMMIT quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.2
--> d397bfab9139
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.2
d397bfab91397214203ae4b8d47dc5947283ace9c78008e7c8437b2f66490a80
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
      annotations:
        k8s.v1.cni.cncf.io/networks: rdmashared-net
    spec:
      serviceAccountName: lldp
      containers:
        - name: lldpd-container
          image: quay.io/redhat_emp1/ecosys-nvidia/lldpd:0.0.2
          securityContext:
            privileged: true
            capabilities:
              add: ["IPC_LOCK"]
          resources:
            limits:
              #nvidia.com/gpu: 1
              rdma/rdma_shared_device_eth: 1
            requests:
              #nvidia.com/gpu: 1
              rdma/rdma_shared_device_eth: 1
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

## Using the Container for lldp Troubleshooting
