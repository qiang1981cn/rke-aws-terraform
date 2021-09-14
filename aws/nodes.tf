locals {
  cluster_id_tag = {
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}

data "aws_availability_zones" "az" {
}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags              = local.cluster_id_tag
  count             = length(data.aws_availability_zones.az.names)
}

resource "aws_security_group" "allow-all" {
  name        = "rke-default-security-group"
  description = "rke"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.cluster_id_tag
}

resource "aws_instance" "rke-node" {
  count = 8

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "demo"
  iam_instance_profile   = "RancherK8SUnrestrictedCloudProviderRoleAP"
  vpc_security_group_ids = [aws_security_group.allow-all.id]
  tags                   = local.cluster_id_tag

  provisioner "remote-exec" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      "curl ${var.docker_install_url} | sh",
      "sudo usermod -a -G docker ubuntu",
    ]
  }
}

