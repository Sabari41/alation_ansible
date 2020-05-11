Pre-requisites:
1. Terraform environment
2. AWS access and secret keys
3. public and private ssh keys in .pem format
4. aws profile should be set for running inspec tests

Inputs to be given to setup the environment, either can be given in a tfvars file or supply via command line or supplied in prompt with plain "terraform plan"
aws_access_key          - AWS access key to create the resources
aws_secret_key          - AWS secret key corresponding to the above access key
aws_region              - Region where the resources has to be deployed
aws_key_name            - Some name to create an AWS key pair to access the machines
public_key_path         - path to the AWS public key with which the AWS key pair above will be created
private_key_path        - path to the private key file with which the above public key is created
number_of_webservers    - Number of instances to be created and put behind the haproxy load balancer
balance                 - default 'roundrobin', can be configured as per the requirement and available haproxy options
ansible_user            - default 'ubuntu', depending on the aws platform and the user to ssh and execute inside aws instance

terraform plan          - will show 6 to add, 0 to change and 0 to destroy
terraform apply         - will add the 6 resources and print the Public IP of the load balancer

for inspec test         - run command "terraform output --json > test/verify/files/terraform.json"
Run inspec tests        - with command "inspec exec test/verify -t aws://" from terraform folder

curl PublicIP           - witness the HelloWorld from different webserver every time

terraform destroy       - Destroys all the 6 resources created in AWS

