FROM registry.access.redhat.com/ubi9/ubi:latest
COPY lldpd.conf /etc/lldpd.conf
RUN dnf install lldpad lldpd tcpdump
ENTRYPOINT ["lldpd", "-dd", "-l"]
