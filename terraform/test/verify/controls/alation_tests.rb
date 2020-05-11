title 'alation terraform tests'

# load data from terraform output
content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

HAPROXY_LB_IP = params['haproxy-ip']['value']

# execute test

# describe aws_ec2_instances do
#     its('entries.count') { should eq 3}
# end

describe aws_ec2_instances.where(tags: {"Name" => "alation-lb"}) do
    it { should exist }
    its('entries.count') {should eq 1}
end

describe aws_ec2_instance(name: 'alation-lb') do
  it {should be_running}
  its('public_ip_address') {should cmp HAPROXY_LB_IP}
  its('key_name') { should cmp 'ec2_key' }
  its('image_id') { should eq 'ami-0f56279347d2fa43e' }
end

describe aws_security_groups do
    its('entries.count') { should eq 3}
end

describe aws_security_group(group_name: 'default-web') do
  it { should exist }
  it {should allow_in(port: 80, ipv4_range: '0.0.0.0/0')}
  its('group_name') { should eq 'default-web' }
  its('description') { should eq 'Security group for web that allows web traffic from internet' }
end

describe aws_security_group(group_name: 'default-ssh') do
  it { should exist }
  it {should allow_in(port: 22, ipv4_range: '0.0.0.0/0')}
  its('group_name') { should eq 'default-ssh' }
  its('description') { should eq 'Security group for nat instances that allows SSH and VPN traffic from internet' }
end

describe aws_security_group(group_name: 'default-egress-tls') do
  it { should exist }
  it {should allow_out(ipv4_range: '0.0.0.0/0')}
  its('group_name') { should eq 'default-egress-tls' }
  its('description') { should eq 'Default security group that allows outbound traffic to all instances in the VPC' }
end

describe aws_security_group(group_name: 'default-ingress-tls') do
  it { should exist }
  it {should allow_in(ipv4_range: '0.0.0.0/0')}
  its('group_name') { should eq 'default-ingress-tls' }
  its('description') { should eq 'Default security group that allows inbound traffic from all instances in the VPC' }
end

describe aws_security_group(group_name: 'default-ping') do
  it { should exist }
  it {should allow_in(protocol: 'icmp', ipv4_range: '0.0.0.0/0')}
  its('group_name') { should eq 'default-ping' }
  its('description') { should eq 'Default security group that allows to ping the instance' }
end