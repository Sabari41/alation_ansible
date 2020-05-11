variable "aws_access_key" {
  	description = "AWS Access key with which the AWS will be accessed"
}
variable "aws_secret_key" {
  	description = "AWS secret key for the access key "
}
variable "aws_region" {
  	description = "AWS region to launch servers."
    default = "us-west-1"
}

variable "ansible_user" {
	description = "user to execute ansible playbooks inside aws instances"
  	default = "ubuntu"
}

variable "public_key_path" {
  	description = <<DESCRIPTION
	Path to the SSH public key to be used for authentication.
	Ensure this keypair is added to your local SSH agent so provisioners can
	connect
	DESCRIPTION
}

variable "private_key_path" {
  	description = <<DESCRIPTION
	Path to the SSH private key to be used for authentication.
	Ensure this keypair is added to your local SSH agent so provisioners can
	connect
	DESCRIPTION
}

variable "aws_key_name" {
  	description = "Desired name of AWS key pair"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    eu-west-2 = "ami-0eb89db7593b5d434"
    us-east-1 = "ami-085925f297f89fce1"
    us-west-1 = "ami-0f56279347d2fa43e"
  }
}

variable "haproxy_balance" {
	description = "Type of haproxy load balancing method"
}

variable "number_of_webservers" {
	description = "Number of webservers - Number of EC2 instances in AWS where the application will be deployed"
}



