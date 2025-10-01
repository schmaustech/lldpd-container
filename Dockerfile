FROM registry.access.redhat.com/ubi9/ubi:latest
COPY lldpd.conf /etc/lldpd.conf
RUN dnf install -y lldpad lldpd tcpdump procps-ng pci-utils
ENTRYPOINT ["lldpd", "-dd", "-l"]
