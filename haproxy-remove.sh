#!/bin/bash
# Disable and stop haproxy
sudo systemctl stop haproxy
sudo systemctl disable haproxy
# Remove the HAProxy package and other utilities:
sudo dnf remove haproxy /usr/sbin/semanage
# Delete HAProxy configuration:
sudo rm -f /etc/haproxy/haproxy.*
# Modify the firewall to disallow communication with the cluster:
sudo firewall-cmd --remove-service=http --permanent
sudo firewall-cmd --remove-service=https --permanent
sudo firewall-cmd --remove-service=kube-apiserver --permanent
sudo firewall-cmd --reload
# For SELinux, disallow HAProxy to listen on TCP port 6443 to serve kube-apiserver on this port:
sudo semanage port -d -t http_port_t -p tcp 6443 
