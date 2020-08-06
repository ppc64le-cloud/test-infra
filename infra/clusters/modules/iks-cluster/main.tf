data "ibm_is_vpc" "vpc1" {
  name = var.vpc_name
}

resource "ibm_is_public_gateway" "gateway" {
  count = length(var.zones)
  name  = "${var.name}-${var.zones[count.index]}-gateway"
  vpc   = data.ibm_is_vpc.vpc1.id
  zone  = var.zones[count.index]

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet" "subnet" {
  count                    = length(var.zones)
  name                     = "${var.name}-${var.zones[count.index]}-subnet"
  vpc                      = data.ibm_is_vpc.vpc1.id
  zone                     = var.zones[count.index]
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway[count.index].id
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = var.name
  vpc_id            = data.ibm_is_vpc.vpc1.id
  flavor            = var.flavor
  worker_count      = var.worker_count
  resource_group_id = data.ibm_resource_group.resource_group.id
  kube_version      = var.kube_version
  wait_till         = var.wait_till

  dynamic "zones" {
    for_each = var.zones
    content {
      name = zones.value
      subnet_id = ibm_is_subnet.subnet[zones.key].id
    }
  }
}
