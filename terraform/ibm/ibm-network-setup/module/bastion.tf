resource "ibm_is_ssh_key" "bastion" {
  resource_group = local.resource_group_id

  name   = "${local.prefix}-${var.region}-bastion-ssh"
  public_key = var.ssh_pub_key
}

# to get id of image you want run:
# ibmcloud is images |grep -v obsolete | grep -v deprecated |grep ubuntu
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-22-04-3-minimal-amd64-2"
}


resource "ibm_is_instance" "bastion" {
  resource_group = local.resource_group_id

  name    = "${local.prefix}-${var.region}-bastion"
  image   =  data.ibm_is_image.ubuntu.id
  profile =  var.instance_profile

  default_trusted_profile_target = ibm_iam_trusted_profile.bastion.id

  metadata_service {
    enabled = true
    protocol = "https"
  }
  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.subnet[var.zone].id
    security_groups = [ ibm_is_security_group.bastion.id ]
  }

  vpc       = ibm_is_vpc.main.id
  zone      = var.zone
  keys      = [ ibm_is_ssh_key.bastion.id ]
  user_data = templatefile("${path.module}/bastion.cloud-init.tpl", {
    ssh_key = base64encode(var.ssh_key),
    ssh_pub = base64encode(var.ssh_pub_key),
    }
  )
}



resource "ibm_is_floating_ip" "bastion" {
  resource_group = local.resource_group_id

  name   = "${local.prefix}-${var.region}-bastion"
  target = ibm_is_instance.bastion.primary_network_interface[0].id
}



output "bastion_ssh" {
  description = "Connect to bastion to be able to connect to other private only servers"
  value       = format("ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_ibm.aws.vm ubuntu@%s", ibm_is_floating_ip.bastion.address)
}

output "bastion_id" {
  value = ibm_is_instance.bastion.id
}

output "bastion_ip" {
  value = ibm_is_floating_ip.bastion.address
}

output "expose_bastion_proxy_locally" {
  description = "Exposes proxy on localhost:8888 which can be used to connect to private only servers, sample: HTTP_PROXY=localhost:8888 curl http://private_server"
  value       = format("ssh -o StrictHostKeyChecking=accept-new -f -N -i ~/.ssh/id_rsa.ibm.vm ubuntu@%s -L 8888:127.0.0.1:8888", ibm_is_floating_ip.bastion.address)
}
