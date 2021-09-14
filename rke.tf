
terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "1.2.3"
    }
  }
}

provider "rke" {
  # Configuration options
}


module "nodes" {
  source = "./aws"
  # region        = "us-east-1"
  # instance_type = "t2.micro"
  # cluster_id    = "rke"
}

resource "rke_cluster" "cluster" {
  cloud_provider {
    name = "aws"
  }

  nodes {
    address = module.nodes.addresses[0]
    internal_address = module.nodes.internal_ips[0]
    user    = module.nodes.ssh_username
    # ssh_key = module.nodes.private_key
    # ssh_key_path = "~/.ssh/id_rsa"
    role    = ["etcd"]
  }
  nodes {
    address = module.nodes.addresses[1]
    internal_address = module.nodes.internal_ips[1]
    user    = module.nodes.ssh_username
    role    = ["etcd"]
  }
  nodes {
    address = module.nodes.addresses[2]
    internal_address = module.nodes.internal_ips[2]
    user    = module.nodes.ssh_username
    role    = ["etcd"]
  }
  nodes {
    address = module.nodes.addresses[3]
    internal_address = module.nodes.internal_ips[3]
    user    = module.nodes.ssh_username
    role    = ["controlplane"]
  }
  nodes {
    address = module.nodes.addresses[4]
    internal_address = module.nodes.internal_ips[4]
    user    = module.nodes.ssh_username
    role    = ["controlplane"]
  }
  nodes {
    address = module.nodes.addresses[5]
    internal_address = module.nodes.internal_ips[5]
    user    = module.nodes.ssh_username
    role    = ["worker"]
  }
  nodes {
    address = module.nodes.addresses[6]
    internal_address = module.nodes.internal_ips[6]
    user    = module.nodes.ssh_username
    role    = ["worker"]
  }
  nodes {
    address = module.nodes.addresses[7]
    internal_address = module.nodes.internal_ips[7]
    user    = module.nodes.ssh_username
    role    = ["worker"]
  }

  ssh_key_path = "~/.ssh/id_rsa"
}

resource "local_file" "kube_cluster_yaml" {
  filename = "./kube_config_cluster.yml"
  content  = rke_cluster.cluster.kube_config_yaml
}

