#!/bin/bash
#Install the HAProxy package and other utilities:
sudo dnf install haproxy /usr/sbin/semanage
# Modify the firewall to allow communication with the cluster:
sudo systemctl enable --now firewalld
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-service=kube-apiserver --permanent
sudo firewall-cmd --reload
# For SELinux, allow HAProxy to listen on TCP port 6443 to serve kube-apiserver on this port:
sudo semanage port -a -t http_port_t -p tcp 6443
# Create a backup of the default HAProxy configuration:
sudo cp /etc/haproxy/haproxy.cfg{,.bak}
# Configure haproxy for use with the cluster:
export CRC_IP=$(crc ip)
sudo tee /etc/haproxy/haproxy.cfg &>/dev/null <<EOF
global
    log /dev/log local0

defaults
    balance roundrobin
    log global
    maxconn 100
    mode tcp
    timeout connect 5s
    timeout client 500s
    timeout server 500s

listen apps
    bind 0.0.0.0:80
    server crcvm $CRC_IP:80 check

listen apps_ssl
    bind 0.0.0.0:443
    server crcvm $CRC_IP:443 check

listen api
    bind 0.0.0.0:6443
    server crcvm $CRC_IP:6443 check
EOF
# Start the haproxy service:
sudo systemctl start haproxy
