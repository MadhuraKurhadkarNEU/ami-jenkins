packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type = string
  // default = env("AWS_REGION")
  default = "us-east-1"
}

variable "ssh_username" {
  type = string
  // default = env("SSH_USERNAME")
  default = "ubuntu"
}

variable "source_ami" {
  type = string
  // default = env("SOURCE_AMI")
  default = "ami-04b70fa74e45c3917"
}

variable "aws_root_account_id" {
  type = string
  // default = env("AWS_ROOT_ACCOUNT_ID")
  default = "523515574467"
}


source "amazon-ebs" "jenkins-ami" {
  region          = var.aws_region
  ami_name        = "JenkinsAMI_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  ami_description = "AMI for Jenkins"
  ami_users       = [var.aws_root_account_id]
  ami_regions     = [var.aws_region]

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }

  instance_type = "t2.micro"
  source_ami    = var.source_ami
  ssh_username  = var.ssh_username

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp2"
  }
}

build {
  sources = ["source.amazon-ebs.jenkins-ami"]

  provisioner "shell" {
    script = "./scripts/installations.sh"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
  }
}
