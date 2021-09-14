
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
    role    = ["etcd","controlplane","worker"]
  }

  ssh_key_path = "~/.ssh/id_rsa"
}

resource "local_file" "kube_cluster_yaml" {
  filename = "./kube_config_cluster.yml"
  content  = rke_cluster.cluster.kube_config_yaml
}

