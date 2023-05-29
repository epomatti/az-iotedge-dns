#!/bin/bash

##### Setup #####

output_file="infra/output.json"

# DNS
remote_dns_ip=$(jq -r .dns_public_ip $output_file)
echo "Edge Gateway VM public IP: $remote_dns_ip"
remote_target_dir="/home/dnsadmin/"

# Copy

scp "./bind9/db.myzone.internal" "dnsadmin@$remote_dns_ip:$remote_target_dir"
scp "./bind9/named.conf.local" "dnsadmin@$remote_dns_ip:$remote_target_dir"
scp "./bind9/named.conf.options" "dnsadmin@$remote_dns_ip:$remote_target_dir"
