FROM ubuntu:22.04

# Add Rprofile for vscode-r extension and httpgd graphics
COPY .devcontainer/.Rprofile /root/.Rprofile

# Install Azure file storage tools and azure cli
RUN apt-get update
RUN apt-get -yq install sudo curl iptables wget tcpdump dnsutils netcat mount cifs-utils samba smbclient
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
