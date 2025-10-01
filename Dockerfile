FROM registry.access.redhat.com/ubi9/ubi:latest
COPY lldpd.conf /etc/lldpd.conf
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
RUN dnf install -y lldpad lldpd tcpdump procps-ng pci-utils
ENTRYPOINT ["/root/entrypoint.sh"]
