global
    maxconn 50000
    log /dev/log local0

defaults
    timeout connect 10s
    timeout client 30s
    timeout server 30s
    log global
    mode http
    option httplog
    maxconn 3000

frontend testhaproxy
    bind *:80
    default_backend web_servers

backend web_servers
    balance ${balance}
    cookie SERVERUSED insert indirect nocache
    option httpchk HEAD /
    default-server check maxconn 20
    %{ for ipd in ips ~}
    %{ for ip in ipd ~}
    server server${index(ipd,ip)} ${tostring(ip)}:${port} cookie server${index(ipd,ip)}
    %{ endfor ~}
    %{ endfor ~}