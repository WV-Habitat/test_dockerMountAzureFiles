FROM ubuntu:22.04

# Install Azure file storage tools and azure cli
RUN apt-get update
RUN apt-get -yq install sudo curl iptables wget tcpdump dnsutils netcat mount cifs-utils samba smbclient
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Add script to mount Azure file storage inside the Docker
COPY mount_azure.sh .
