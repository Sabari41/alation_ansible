provider "aws" {
  region      = "${var.aws_region}"
  access_key  = "${var.aws_access_key}"
  secret_key  = "${var.aws_secret_key}"
}

resource "aws_instance" "alation-webservers" {
  count         = "${var.number_of_webservers}"
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.aws_key.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.egress-tls.id}",
    "${aws_security_group.ingress-tls.id}",
    "${aws_security_group.ping-ICMP.id}"
  ]

  connection {
    user        = "${var.ansible_user}"
    private_key = file("${var.private_key_path}")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update",
              "sudo apt-get -qq install python -y"]
  }

  provisioner "file" {
    content     = "HelloWorld from webserver - ${count.index}"
    destination = "/home/ubuntu/index.html"
  }

   provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >docker.ini;
	  echo "[docker]" | tee -a docker.ini;
	  echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key_path}" | tee -a docker.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key_path} -i docker.ini ../ansible_playbooks/install-docker-ubuntu.yaml
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >docker.ini;
	  echo "[docker]" | tee -a docker.ini;
	  echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key_path}" | tee -a docker.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
    ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key_path} -i docker.ini ../ansible_playbooks/run-docker-app.yaml
    EOT
  }

  tags = { 
    Name = "alation-webserver-${count.index}"
  }
}

resource "aws_instance" "alation-lb" {
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.aws_key.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web.id}",
    "${aws_security_group.egress-tls.id}",
    "${aws_security_group.ingress-tls.id}",
    "${aws_security_group.ping-ICMP.id}"
  ]

  connection {
    user        = "${var.ansible_user}"
    private_key = file("${var.private_key_path}")
    host        = self.public_ip
  }

  provisioner "file" {
    content = templatefile("../loadbal/haproxy.cfg.tpl", {balance = "${var.haproxy_balance}", port = 8080, ips = list("${aws_instance.alation-webservers.*.public_ip}")})
    destination = "/home/ubuntu/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update",
              "sudo apt-get -qq install python -y"]
  }

   provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >docker.ini;
	  echo "[docker]" | tee -a docker.ini;
	  echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key_path}" | tee -a docker.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key_path} -i docker.ini ../ansible_playbooks/install-docker-ubuntu.yaml
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >docker.ini;
	  echo "[docker]" | tee -a docker.ini;
	  echo "${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key_path}" | tee -a docker.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
    ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key_path} -i docker.ini ../ansible_playbooks/run-docker-haproxy.yaml
    EOT
  }

  tags = { 
    Name = "alation-lb"
  }
}

output "haproxy-ip" {
  value = "${aws_instance.alation-lb.public_ip}"
}


